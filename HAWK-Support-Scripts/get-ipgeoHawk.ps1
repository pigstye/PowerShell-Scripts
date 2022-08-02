<#
	.Synopsis
		Processes Hawk auth logs, extracting IPs and retrieving IPgeo Info
	.Description
		Processes Hawk auth logs, extracting IPs and retrieving IPgeo Info.
		Creates IPGeo.csv using ip-api.com listing IP,Country,RegionName,City,Zip,Timezone,Isp,Org,AS,Mobile,Proxy,Hosting
		It should be run from the main HAWK directory.
	.NOTES
		Author: Tom Willett
		Date: 5/27/2022
#>

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

$ErrorActionPreference = "SilentlyContinue"
write-host "Getting IPs from Authenticatin Logs" -fore yellow
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
Write-host "Done" -fore red