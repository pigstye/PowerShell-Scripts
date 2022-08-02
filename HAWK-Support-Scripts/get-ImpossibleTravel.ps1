<#
	.Synopsis
		Processes Hawk auth logs and creates a csv showing possible impossible-travel.
	.Description
		Processes Hawk auth logs and creates a csv showing possible impossible-travel. The impossible-travel.csv contains the following fields:
		"CreationTime","UserId","ClientIP","RegionName","CountryName","AS"
		It should be run from the main HAWK directory.
	.PARAMETER ipgeo
		Optional
		The name of a file containing IPGeo Information
		It should contain at the least IP,RegionName,Country,AS
	.NOTES
		Author: Tom Willett
		Date: 5/26/2022
#>
Param([Parameter(Mandatory=$false)][string]$ipgeo='')

function get-ipgeo {
	<#

	.SYNOPSIS

	Get geoip information from ip-api.com.

	.DESCRIPTION

	This looks up an ip from ip-api.com which returns reverse lookup and geoip information. ip-api throttles queries so there is a built in delay.

	.PARAMETER ip

	The IP to look up.

	.EXAMPLE     
		.\get-ipgeo.ps1 8.8.8.8
		
		Returns the geoip informatino for 8.8.8.8 as a PowerShell object

	.NOTES
		
	 Author: Tom Willett
	 Date: 5/27/2022

	#>

	Param([Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)][string]$ip)
	process {
		$ErrorActionPreference = "SilentlyContinue"
		$geoip = convertfrom-json (new-object net.webclient).DownloadString("http://ip-api.com/json/" + $ip + "?fields=query,country,regionName,city,zip,timezone,isp,org,as,mobile,proxy,hosting")
		$geo = "" | select IP,Country,RegionName,City,Zip,Timezone,Isp,Org,AS,Mobile,Proxy,Hosting
		$geo.ip = $geoip.query
		$geo.Country = $geoip.Country
		$geo.RegionName = $geoip.RegionName
		$geo.City = $geoip.city
		$geo.Zip = $geoip.zip
		$geo.Timezone = $geoip.Timezone
		$geo.Isp = $geoip.Isp
		$geo.Org = $geoip.Org
		$geo.AS = $geoip.AS
		$geo.Mobile = $geoip.mobile
		$geo.Proxy = $geoip.Proxy
		$geo.hosting = $geoip.hosting
		#pause to keep from going over limitf
		Start-Sleep -m 1500
		if ($geoip) {
			$geo
		}
	}	
}

write-host "Create impossible-travel.csv to show possible impossible-travel" -fore green
$ErrorActionPreference = "SilentlyContinue"
if ($ipgeo -eq '') {
	write-host "Getting IPs from Authentication Logs" -fore yellow
	$s = @();dir Converted_Authentication_Logs* -recurse | %{(import-csv $_).clientip} | %{$s += ($_ + "`r`n")}
	$t=$s -replace "`r`n",""
	$ip = $t | select -unique
	$cnt = $ip.count
	$ctr = 1
	$ip | %{
		$msg = "Getting IPGeo Information for IP " + $_ + ' (' + $ctr + " of "+ $cnt + ')'
		write-host $msg -fore darkyellow
		get-ipgeo $_ | export-csv -notype -append ipgeo.csv
		$ctr += 1
		}
}

write-host "Modifying Auth Records adding Geo fields" -fore yellow
dir Converted_Authentication_Logs* -recurse | %{$tmp = import-csv $_.fullname; $_.fullname; $tmp | select *,@{Name='CountryName';Expression={''}},@{Name='RegionName';Expression={''}},@{Name='City';Expression={''}},@{Name='AS';Expression={''}},@{Name='zipcode';Expression={''}} | export-csv -notype $_.fullname}
$ErrorActionPreference = "Continue"

Write-host "Adding Geo information to each record" -fore yellow
if ($ipgeo) {
	$ip = import-csv $ipgeo | sort IP -unique
} else {
	$ip = import-csv ipgeo.csv | sort IP -unique
}
dir Converted_Authentication_Logs* -recurse | %{$s = import-csv $_.fullname
$_.fullname
$s |%{$h = $ip | where ip -eq $_.clientip;$_.countryname = $h.country;$_.regionname = $h.regionname;$_.city = $h.city;$_.zipcode = $h.zipcode;$_.as = $h.as}
$s | export-csv -notype $_.fullname}

Write-host "Creating impossible-travel.csv" -fore yellow
dir Converted_Authentication_Logs* -recurse | %{$name;import-csv $_.fullname | where Operation -eq 'UserLoggedIn' | sort creationtime | select creationtime,userid,clientIP,regionname,countryname,as | export-csv -notype -append impossible-travel.csv}

Write-host "Done" -fore red