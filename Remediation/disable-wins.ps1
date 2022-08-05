<#

.SYNOPSIS

Stop the WINS service and disable it.

.DESCRIPTION

Stop the WINS service and disable it from starting

.EXAMPLE

ps> .\disable-wins.ps1  servername

Stop the WINS service on one server

.EXAMPLE

type names.txt | disable-wins.ps1

Stop and Disable WINS on multiple servers listed in names.txt (one server per line)

.NOTES

Author: Tom Willett 
Date: 9/9/2014

#>

Param([Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)][string]$computername)

process { 
	#Get-Service -name WINS -computername $computername | Stop-Service -PassThru | Set-Service -StartupType disabled
	$reg = gwmi -computername $computername -class win32_service -filter "name='wins'"
	$reg.stopservice()
	$reg.changestartmode("disabled")
}