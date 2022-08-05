<#

.SYNOPSIS

Pull all CCNs from a file and verify the LUN

.DESCRIPTION

Pull all CCNs from a file and verify the LUN

.PARAMETER dump

The file to check (required)

.OUTPUTS

A list of valid CCNs

.EXAMPLE     
    .\get-ccns.ps1 dump.txt

.NOTES
	
 Author: Tom Willett
 Date: 4/7/2018

#>

Param([Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)][string]$dump)

begin {
	$ccregex = '(\b3611\d{10}|3[47]\d{13}\b|\b6011[ -]?\d{4}[ -]?\d{4}[ -]?\d{4}\b|\b35\d{2}[ -]?\d{4}[ -]?\d{4}[ -]?\d{4}\b|\b5[1-5]\d{2}[ -]?\d{4}[ -]?\d{4}[ -]?\d{4}\b|\b4\d{3}[ -]?\d{4}[ -]?\d{4}[ -]?\d{4}\b|\b3[0-8]\d{12}\b)'

	function Test-LuhnNumber([string]$CCN){
<#

.SYNOPSIS

Test a possible CCN to verify it is legit

.DESCRIPTION

Test a possible CCN to verify it is legit by checking its Luhn (Mod 10) value

.PARAMETER CCN

CCN to check (required)

.PARAMETER outFile

The file to which inFile will be appended

.OUTPUTS

$True of $false

.EXAMPLE     
	.\test-luhnnumber '444444444444'

.NOTES
	
 Date: 4/7/2016

#>

		 
		$digits = [int[]][string[]][char[]]$CCN
		[int]$sum=0
		[bool]$alt=$false

		for($i = $digits.length - 1; $i -ge 0; $i--){
			if($alt){
				$digits[$i] *= 2
				if($digits[$i] -gt 9) { $digits[$i] -= 9 }
			}

			$sum += $digits[$i]
			$alt = !$alt
		}

		return ($sum % 10) -eq 0
	}
}
process {
	$paste = gc $dump
	$ErrorActionPreference = "SilentlyContinue"
	$report = @()
	$regex = $ccregex
	foreach($l in $paste) {
		if ($l -match $regex) {
			$iin = $matches[1]
			$iin = $iin -replace " ", ""
			$iin = $iin -replace "-",""
			if (test-luhnnumber $iin) {
				$iin = $iin.substring(0,6)
				$b = import-csv .\bins.csv
				$bin = $b | where {$_.bin -eq $iin }
				if ($bin.length -gt 1) {$bin = $bin[0]}
				if (-not $bin) {
					$bin = (new-object net.webclient).DownloadString("https://lookup.binlist.net/$iin") | ConvertFrom-Json
				}
				if ($bin.bank) {
					$bank = "" | Select Filename, Bank, Brand, CCNo
					$bank.FileName = $dump
					$bank.bank = $bin.bank
					$bank.brand = $bin.brand
					$bank.ccno = $matches[1]
					$bank | export-csv -notype bank.csv -append
					write-output $bank
				}
			}
		}
	}
}