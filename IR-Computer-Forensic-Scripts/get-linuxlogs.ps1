function get-linuxlogs {
<#

.SYNOPSIS

Convert a linux log to a powershell object

.DESCRIPTION

Reads a standard linux log, converts it to a PowerShell object with DateTime, Server, LogSource, LogType, Data.

.PARAMETER LogFile

Logfile is required -- the path to the log file.

.EXAMPLE

 get-LinuxLogs c:\temp\secure

 Parse the log file called secure and display the results.
 
.EXAMPLE

 get-LinuxLogs.ps1 c:\temp\secure | export-csv -notypeinformation secure.csv

 Parse the log file called secure and export it to secure.csv.

.EXAMPLE
 dir *.log | get-LinuxLogs | export-csv -notype logs.csv
 
 Parse all the linux logs and export to logs.csv
 
.NOTES

Author: Tom Willett 
Date: 2/26/2015

#>

	Param([Parameter(Mandatory=$True,ValueFromPipeline=$True)][string]$LogFile)

	process {
		write-host "Processing " $logfile
		$log = get-content $logfile
		foreach ($line in $log) {
			if ($line -match '(\S{3} {1,2}\d+ \d\d:\d\d:\d\d) (\S+) (\S+:) (.+)' ) {
				$temp = "" | Select DateTime, Machine, LogSource, LogSourceType, Event
				$temp.DateTime = $matches[1]
				$temp.Machine = $matches[2]
				$temp.LogSourceType = $matches[3]
				$temp.Event = $matches[4]
				$temp.LogSource = $LogFile
				write-output $temp
			}
		}
	}
}
