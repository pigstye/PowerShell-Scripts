function get-ipgeo {
	<#
	.SYNOPSIS
	Get geoip information from ip-api.com.
	.DESCRIPTION
	This looks up an ip from api.ipgeolocation.io which returns reverse lookup and geoip information.
	Note you are limited to 1000 lookups a day with this.
	It outputs a PowerShell object.
	.PARAMETER ip
	The IP to look up.
	.EXAMPLE     
		.\get-ipgeo.ps1 8.8.8.8
		Returns the geoip informatino for 8.8.8.8 as a PowerShell object
	.EXAMPLE     
		type .\ip.txt |.\get-ipgeo.ps1 | export-csv -notypeinformation -append ip.csv
		Looks up the geoip information for all the ips in ip.txt (one per line) 
		It puts the output in ip.csv
	.NOTES
	 Author: Tom Willett
	 Date: 2/14/2015
	 Date: Updated 11/13/2018 to use ip-api.com
	 Date: Updated 11/5/2019 to use api.ipgeolocation.io
	 Date: Updated 9/6/2021 to use both
	#>

	Param([Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)][string]$ip)
	process {
		$ErrorActionPreference = "SilentlyContinue"
		#enter ipgeolocation.io API key to use ipgeolocation.io instead of ip-api.com
		#ip-geolocation.io limited to 1,000 a day 30,000 a month
		#ip-api.com limited to 45 requests a minute
		if ($apiKey) {
			$geoip = (new-object net.webclient).DownloadString("https://api.ipgeolocation.io/ipgeo?apiKey=$apiKey&ip=$ip")
			$geo = convertfrom-json $geoip
		} else {
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
			Start-Sleep -m 1400
		}
		if ($geoip) {
			$geo
		}
	}
}
