function get-eventlogs {
<#

.SYNOPSIS

Reads a windows event log file (evtx) and converts it to a csv 

.DESCRIPTION

Reads evt and evtx windows log files and outputs a powershell object. 
It returns DateTime, EventID, Level, ShortEvent, User, Event, Properties, LogSource, LogSourceType, and Machine.

Evt logs can sometimes get corrupted and you will get the error "The data is invalid".  Run fixevt.exe
to fix the log file.  http://www.whiteoaklabs.com/computer-forensics.html

.PARAMETER logFile

logfile is required -- the path to the log file.

.EXAMPLE

 .\get-eventlogs.ps1 c:\windows\system32\winevt\application.evtx | export-csv -notype c:\temp\app.csv

 Reads the log file at c:\windows\system32\winevt\application.evtx and puts the output in c:\temp\app.csv

 .EXAMPLE

 dir *.evtx |.\get-eventlog.ps1 | export-csv -notype c:\temp\log.csv

 converts all the evtx logs puts the output in c:\temp\app.csv
 
.NOTES

Author: Tom Willett 
Date: 5/19/2021

#>

Param([Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)][string]$FullName)

	process {
		$fext = [system.io.path]::getextension($FullName)
		$filter = @{Path="$FullName"}
		if ($fext -eq ".evt") {
			$old = $true
		} else {
			$old = $false
		}
		get-winevent -oldest:$old -filterhashtable $filter | 
		select-object @{Name="DateTime";Expression={$_.timecreated}},@{Name="EventID";Expression={$_.ID}},Level,@{Name="ShortEvent";Expression={$_.TaskDisplayName}},@{Name="User";Expression={$_.UserId}}, @{Name="Event";Expression={(($_.message).replace("`n", " ")).replace("`t"," ")}}, @{Name="Properties";Expression={([string]::Join(" - ",$_.properties.value)).replace(',',';')}}, @{Name="Record";Expression={$_.RecordID}}, @{Name="LogSource";Expression={$_.logname}}, @{Name="LogSourceType";Expression={$_.ProviderName}},@{Name="Machine";Expression={$_.MachineName}}
	}
}
