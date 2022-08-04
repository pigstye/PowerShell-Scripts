function get-etllog {
	<#
	.SYNOPSIS
	Reads a windows etl file and converts it to a PowerShell Object
	.DESCRIPTION
	Reads a windows etl file and converts it to a PowerShell Object
	.PARAMETER logFile
	logfile is required -- the path to the log file.
	.EXAMPLE
	 get-etllog.ps1 C:\ProgramData\Microsoft\Windows Security Health\Logs\SHS-01192022-112816-7-1ff-22000.1.amd64fre.co_release.210604-1628.etl
	.NOTES
	Author: Tom Willett 
	Date: 3/7/2022
	#>

	Param([Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)][string]$FullName)


	$fext = [system.io.path]::getextension($FullName)
	$filter = @{Path="$FullName"}
	get-winevent -oldest:$true -filterhashtable $filter | select * | fl
}

