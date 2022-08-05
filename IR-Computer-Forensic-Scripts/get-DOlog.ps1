function Get-DOLog {
<#
	.Synopsis
		Processes the Delivery Optimization Logs
	.Description
		Processes the Delivery Optimization Logs on Windows 10
		The logs are at one of the following depending on version.
		C:\Windows\Logs\dosvc
		C:\Windows\ServiceProfiles\NetworkService\AppData\Local\Microsoft\Windows\DeliveryOptimization\Logs
	.Parameter Logname
		The name and path of the log file
	.Example
		$logs | get-DOLog | export-csv -notype DOLogs.csv Where $logs contains a listing of the logs
	.NOTES
		Author: Tom Willett
		Date: 5/27/2021
	.Outputs
		an object containing the data
	.Inputs
		A logname
#>
Param([Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)][string]$logname)
	begin {
		$DeliveryOptimizationLog = @()
		$ErrorActionPreference = "SilentlyContinue"
	}
	process {
		tracerpt $logname -o tmp.xml -of xml -lr -y
		[xml]$do = gc .\tmp.xml
		$DeliveryOptimizationLog = @()
		foreach ($evt in $do.Events.Event) {
			$temp = [pscustomobject]@{
				TimeCreated = ""
				ProcessId = ""
				ThreadId = ""
				Level = ""
				LevelName = ""
				Message = ""
				Function = ""
				LineNumber = ""
				ErrorCode = ""
			}
			$temp.TimeCreated = $evt.system.timecreated.systemtime
			$temp.ProcessId   = $evt.system.execution.processid
			$temp.ThreadId    = $evt.system.execution.threadid
			$temp.Level       = $evt.system.level
			$temp.Message     = $evt.eventdata.data."#text"[0]
			$temp.Function    = $evt.eventdata.data."#text"[1]
			$temp.LineNumber  = $evt.eventdata.data."#text"[2]
			$temp.ErrorCode   = $evt.eventdata.data."#text"[3]
			if ($temp.level -eq '4') {
				$temp.LevelName = "Info"
			} elseif ($temp.level -eq '3') {
				$temp.LevelName = "Warning"
			} else {
				$temp.LevelName = "Error"
			}
			$DeliveryOptimizationLog += $temp
		}
	}
	end {
		rm tmp.xml
		$DeliveryOptimizationLog
	}
}

