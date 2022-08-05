<#

.SYNOPSIS

Check to see if a host is vulnerable to host header poisoning

.DESCRIPTION

Check to see if a host is vulnerable to host header poisoning

.PARAMETER website

Host to check (required)

.OUTPUTS

Result of test

.EXAMPLE     
    .\host-header-poison.ps1

.NOTES
	
 Author: Tom Willett

#>
Param([Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)][string]$website)
begin {
}
process {
	$h = invoke-webrequest -uri $website -headers @{Host="www.pigstye.net"} -maximumredirection 0
	"Host Header Poison"
	$website
	"Host: www.pigstye.net"
	"======================================="
	$h.rawcontent
}
