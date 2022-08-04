function get-shodan {
<#
	.SYNOPSIS     
		Retrieves Shodan.io information about an IP
	.DESCRIPTION   
		Retrieves Shodan.io information about an IP using the shodan.io API
	.NOTES     
		Author: Tom Willett
	.EXAMPLE     
		get-shodan 192.168.0.1
		Retrieves shodan info about 192.168.0.1
	#>
	param([string]$ip)
	(invoke-webrequest -uri https://internetdb.shodan.io/$ip).content | convertfrom-json	
}

