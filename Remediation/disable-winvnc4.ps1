<#

.SYNOPSIS

Stop the winvnc4 service and disable it.

.DESCRIPTION

Stop the winvnc4 service and disable it from starting

.EXAMPLE

ps> .\disable-winvnc4.ps1  servername

Stop the winvnc4 service on one server

.EXAMPLE

type names.txt | disable-winvnc4.ps1

Stop and Disable winvnc4 on multiple servers listed in names.txt (one server per line)

.NOTES

Author: Tom Willett 
Date: 9/9/2014

#>

Param([Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)][string]$computername)

process { 
	$computername
	#Get-Service -name winvnc4 -computername $computername | Stop-Service -PassThru | Set-Service -StartupType disabled
	$reg = gwmi -computername $computername -class win32_service -filter "name='winvnc4'"
	$reg.stopservice()
	$reg.changestartmode("disabled")
}