<#

.SYNOPSIS

Extract IPs from a text file

.DESCRIPTION

Extract IPs from a text file - Outputs the IPs one per line

.PARAMETER filename

The file to search (required)

.OUTPUTS

List of IPs

.EXAMPLE     
    .\get-ip.ps1 somefile.log > ips.txt

.NOTES
	
 Author: Tom Willett

#>
#extract all the ip's from a text file
Param([Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)][string]$filename)
process {
	sls '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}' -allmatches $filename | %{$_.matches} | %{$_.value}
}
