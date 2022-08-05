function decodeURI {
<#
	.SYNOPSIS
	Decodes common uri escape characters and sqli constructs from a uri
	.DESCRIPTION
	Decodes common uri escape characters and sqli constructs from a uri
	.EXAMPLE
	ps> $t | .\decode.ps1
	decodes the uri contained in $t
	.EXAMPLE
	ps> get-content file.txt | .\decode.ps1 | out-file -width 9999 decodedfile.txt
	decodes all the uri's in file.txt and puts them in file decodedfile.txt
	.EXAMPLE
	$csv = import-csv file.csv
	foreach($l in $csv) { $l.uri | .\decode.pst | out-file -width 9999 decodedfile.txt -append}
	imports file.csv, decodes the uri's and outputs them to decodedfile.txt
	.NOTES
	Author: Tom Willett 
	Date: 10/26/2015
#>
	Param([Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)][string]$uri)

	process {
		for($i=20;$i -lt 127;$i++) {
				$uri = $uri -replace ("%{0:X0}" -f $i),[char]$i
		}
		$r = [regex]'IFNULL\(CAST\((`?\w*`?)\sAS CHAR\),0x20\)'
		$m = $r.matches($uri)
		foreach($mtch in $m){
			$uri = $uri -replace [regex]::escape($mtch.groups.value[0]),$mtch.groups.value[1]
		}
		$r = [regex]'CONCAT\(([^\)]*)\)'
		$m = $r.matches($uri)
		foreach($mtch in $m){
			$uri = $uri -replace [regex]::escape($mtch.groups.value[0]),$mtch.groups.value[1]
		}
		$uri = $uri -replace '0x[\da-f]*,?',''
		write-output $uri
	}
}