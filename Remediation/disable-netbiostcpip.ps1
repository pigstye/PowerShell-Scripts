<#

.SYNOPSIS

Disable Netbios over TCP/IP

.DESCRIPTION

Disable Netbios over TCP/IP

.EXAMPLE

ps> .\disable-netbiostcpip.ps1  servername

Disable Netbios over TCP/IP on one server

.EXAMPLE

type names.txt | disable-netbiostcpip.ps1

Disable Netbios over TCP/IP on multiple servers listed in names.txt (one server per line)

.NOTES

Author: Tom Willett 
Date: 9/10/2014

#>

Param([Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)][string]$computername)

process {
	$tcp = reg query \\$computername\HKLM\SYSTEM\CurrentControlSet\Services\NetBT\Parameters\Interfaces
	foreach ($i in $tcp) {
		reg add \\$computername\$i /v NetBiosOptions /t REG_DWORD /d  2
	}
	reg add "\\$computername\HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v RestrictAnonymousSAM /t REG_DWORD /d 1
	reg add "\\$computername\HKLM\SYSTEM\CurrentControlSet\Control\Lsa" /v RestrictAnonymous /t REG_DWORD /d 1
}
