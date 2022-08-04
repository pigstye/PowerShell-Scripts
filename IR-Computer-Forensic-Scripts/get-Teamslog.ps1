function get-Teamslog {
	<#
	.SYNOPSIS
	Reads Teams logs and displays content 
	.DESCRIPTION
	Reads Microsoft Teams logs and extracts the recent content.
	.PARAMETER logFile
	logfile is required -- the path to User AppData\Roaming.
		By default it reads current user log files
	.EXAMPLE
	 .\get-Teamslog.ps1 c:\user\<username>\AppData\Roaming
	 Reads the Teams log file and extracts recent content
	.NOTES
	Author: Tom Willett 
	Date: 7/13/2021
	V1.0
	#>
	param([string]$logfile="$Env:AppData")

	$firstString = "<div"
	$secondString = "div>"

	$logfile += "\Microsoft\Teams\IndexedDB\https_teams.microsoft.com_0.indexeddb.leveldb\*.log"
	$text = Get-Content $logfile
	#Sample pattern
	$pattern = "(?<=$firstString).*?(?=$secondString)"
	$output = [regex]::Matches($text,$pattern).value
	$out = (($output -replace '</ >',"`r`n") -replace "></|><|`r`n`r`n","") | select -unique
	for($i=($out.length - 1);$i -ge 0;$i--) {$out[$i]}
}