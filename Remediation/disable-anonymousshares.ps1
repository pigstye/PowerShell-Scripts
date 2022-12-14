<#

.SYNOPSIS

disable anonymous enumeration of sam accounts

.DESCRIPTION

disable anonymous enumeration of sam accounts

.EXAMPLE

ps> .\disable-anonymousshares.ps1  servername

disable anonymous enumeration of sam accounts on one server

.EXAMPLE

type names.txt | disable-anonymousshares.ps1

disable anonymous enumeration of sam accounts on multiple servers listed in names.txt (one server per line)

.NOTES

Author: Tom Willett 
Date: 9/11/2014

#>

Param([Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)][string]$computername)

process { 
	reg add "\\$computername\HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v RestrictAnonymousSAM /t REG_DWORD /d 1
	reg add "\\$computername\HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v RestrictAnonymous /t REG_DWORD /d 1
}
