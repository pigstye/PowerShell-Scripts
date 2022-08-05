<#

.SYNOPSIS

Enable SMB Signing

.DESCRIPTION

Enable SMB Signing

.EXAMPLE

ps> .\enable-smbsigning.ps1

Enable SMB Signing on one server

.EXAMPLE

type names.txt | .\enable-smbsigning.ps1

Enable SMB Signing on multiple servers listed in names.txt (one server per line)

.NOTES

Author: Tom Willett 
Date: 9/10/2014

#>

Param([Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)][string]$computername)

process { 
	$computername
	reg add \\$computername\HKLM\System\CurrentControlSet\Services\LanManWorkstation\Parameters /v EnableSecuritySignature /t REG_DWORD /d 1 /f
	reg add \\$computername\HKLM\System\CurrentControlSet\Services\LanManWorkstation\Parameters /v RequireSecuritySignature /t REG_DWORD /d 1 /f
	reg add \\$computername\HKLM\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters /v EnableSecuritySignature /t REG_DWORD /d 1 /f
	reg add \\$computername\HKLM\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters /v RequireSecuritySignature /t REG_DWORD /d 1 /f
 	reg add \\$computername\HKLM\SYSTEM\CurrentControlSet\Services\LanManServer\Parameters /v enableW9xsecuritysignature /t REG_DWORD /d 1 /f
}
