<#
	.Synopsis
		Processes Hawk auth logs gathering all authentication attempts successful and unsuccessful
	.Description
		Processes Hawk auth logs gathering all authentication attempts successful and unsuccessful.
		Returns creationtime,userid,Operation,RequestType,resultstatusdetail,clientIP,region,country,as
		It should be run from the main HAWK directory.
	.PARAMETER ipgeo
		Optional
		The name of a file containing IPGeo Information
		It should contain at the least IP,RegionName,Country,AS
	.NOTES
		Author: Tom Willett
		Date: 5/27/2022
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

write-host "Create AllLoginAttempt.csv to show possible impossible-travel" -fore green
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

if ($ipgeo) {
	$ip = import-csv $ipgeo | sort IP -unique
} else {
	$ip = import-csv ipgeo.csv | sort IP -unique
}
write-host "Gathering Login Attempts" -fore yellow
dir Converted_Authentication_Logs* -recurse | %{$s = import-csv $_.fullname
$_.fullname
$s |%{$i = $ip | where ip -eq $_.clientip
	$temp = "" | Select creationtime,userid,Operation,RequestType,resultstatusdetail,clientIP,region,country,as
	$temp.creationtime = $_.creationtime
	$temp.userid = $_.userid
	$temp.clientip = $_.clientip
	$temp.operation = $_.operation
	$temp.RequestType = $_.RequestType
	$temp.resultstatusdetail = $_.resultstatusdetail
	$temp.region = $i.regionname
	$temp.country = $i.country
	$temp.as = $i.as
	$temp | export-csv -notype -append AllLoginAttempt.csv
}}