function convert-bashhistory {
	param([string]$fn)
	<#
	.SYNOPSIS
	Reads a bash history file with date/time records and converts them to readable data/time
	.DESCRIPTION
	Reads a bash history file with date/time records and converts them to readable data/time - sends output to standard out
	.PARAMETER $fn
	The bash history file
	.EXAMPLE
	ps> convert-bashhistory .\.bash_history > bash_history
	Note do not overwrite the original file 
	.NOTES
	Author: Tom Willett 
	Date: 7/10/2021
	#>

	gc $fn | %{if ($_.startswith('#')) {$ft = $_.substring(1);$l='#' + (([datetime] '1970-01-01Z').ToUniversalTime()).addseconds($ft)} else {$l=$_};$l}
}
