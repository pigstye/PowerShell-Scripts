<#

.SYNOPSIS

Resets logging on a Windows computer to defaults.

.DESCRIPTION

Resets logging on a Windows computer to defaults.
There is a companion script get-loggingReport.ps1 that reads these settings and offers recommendations.
To turn off or change a setting either edit the settings below or comment them out.

.EXAMPLE

PS>.\reset-logging.ps1

.NOTES

 Author: Tom Willett 
 Date:  8/17/2016
 Ver 1.0

#>

# This script resets logging on a windows computer to defaults -- comment out what you don't want changed.
#log sizes
set-itemproperty hklm:\system\currentcontrolset\services\eventlog\Application -name maxsize -value 20971520
set-itemproperty hklm:\system\currentcontrolset\services\eventlog\System -name maxsize -value 20971520
set-itemproperty hklm:\system\currentcontrolset\services\eventlog\Security -name maxsize -value 20971520

#set audit policy on registry keys
auditpol.exe /set /subcategory:'Registry' /success:disable /failure:disable
#$rule = $acl.getauditrules($true,$true, [System.Security.Principal.NTAccount] )

#HKLM Run key
$acl = get-acl hklm:\software\microsoft\windows\currentversion\run -audit
$rule = New-Object System.Security.AccessControl.RegistryAuditRule ("everyone","ReadPermissions","none","none","success")
$acl.removeauditrule($rule)
$rule = New-Object System.Security.AccessControl.RegistryAuditRule ("everyone","ReadPermissions","none","none","failure")
$acl.removeauditrule($rule)
$acl | set-acl hklm:\software\microsoft\windows\currentversion\run

#HKLM RunOnce Key
$acl = get-acl hklm:\software\microsoft\windows\currentversion\runonce -audit
$rule = New-Object System.Security.AccessControl.RegistryAuditRule ("everyone","ReadPermissions","none","none","success")
$acl.removeauditrule($rule)
$rule = New-Object System.Security.AccessControl.RegistryAuditRule ("everyone","ReadPermissions","none","none","failure")
$acl.removeauditrule($rule)
$acl | set-acl hklm:\software\microsoft\windows\currentversion\runonce

#HKCU Run Key
$acl = get-acl hkcu:\software\microsoft\windows\currentversion\run -audit
$rule = New-Object System.Security.AccessControl.RegistryAuditRule ("everyone","ReadPermissions","none","none","success")
$acl.removeauditrule($rule)
$rule = New-Object System.Security.AccessControl.RegistryAuditRule ("everyone","ReadPermissions","none","none","failure")
$acl.removeauditrule($rule)
$acl | set-acl hkcu:\software\microsoft\windows\currentversion\run

#HKCU RunOnce
$acl = get-acl hklm:\software\microsoft\windows\currentversion\runonce -audit
$rule = New-Object System.Security.AccessControl.RegistryAuditRule ("everyone","ReadPermissions","none","none","success")
$acl.removeauditrule($rule)
$rule = New-Object System.Security.AccessControl.RegistryAuditRule ("everyone","ReadPermissions","none","none","failure")
$acl.removeauditrule($rule)
$acl | set-acl hkcu:\software\microsoft\windows\currentversion\runonce

#Logon/Logoff Logging
auditpol.exe /set /subcategory:'Logon' /success:enable /failure:disable

#Computer Account Changes Logging
auditpol.exe /set /subcategory:'computer account management' /success:disable /failure:disable

#Security Group changes Logging
auditpol.exe /set /subcategory:'security group management' /success:enable /failure:disable

#User Account Changes Logging
auditpol.exe /set /subcategory:'user account management' /success:enable /failure:disable

#Firewall Events Logging
auditpol.exe /set /subcategory:'Filtering Platform Connection' /success:disable /failure:disable

#Process Creation Logging
auditpol.exe /set /subcategory:'Process Creation' /success:disable /failure:disable

#Process Termination Logging
auditpol.exe /set /subcategory:'Process Termination' /success:disable

#Powershell Script Block Logging
Remove-Item HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging -Force -Recurse -erroraction silentlycontinue
#Audit policy logging
auditpol.exe /set /subcategory:'Audit Policy Change' /success:enable /failure:disable
