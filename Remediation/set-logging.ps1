<#

.SYNOPSIS

This script turns up logging on a Windows computer.

.DESCRIPTION

This script turns up logging on a Windows computer.
There is a companion script get-loggingReport.ps1 that reads these settings and offers recommendations.
To turn off or change a setting either edit the settings below or comment them out.

.EXAMPLE

PS>.\set-logging.ps1

.NOTES

	Audit Rule details:
	AuditFlags can have a value of Success, Failure, or none.  Multiple values like “Success,Failure” would be comma separated.

	IdentityReference is just the name or object reference of the user or group that will be audited.

	InheritanceFlags and PropagationFlags determine if the audit settings will be inherited from parent folders or if the audit settings will be propagated to child folders.  I highly recommend that this be left at the default, which is none for both values.   Accidentally propagating auditing settings to sub folders could create an excessive amount of traffic in your logs.  When both values are set to “none”, it shows up under Properties/Security/Advanced/Auditing on the file or registry object as This Folder Only.

	RightsToAudit has different values depending upon if FileSystemAuditRule or RegistryAuditRule is being used.

	RightsToAudit can have the following values when using RegistryAuditRule.

	FullControl
	QueryValues
	SetValue
	CreateSubKey
	EnumerateSubKeys
	Notify
	CreateLink
	Delete
	WriteKey
	ChangePermissions
	TakeOwnership
	ReadPermissions
	 

	RightsToAudit can have the following values when using FileSystemAuditRule

	FullControl
	DeleteSubdirectoriesAndFiles
	Modify
	ChangePermissions
	TakeOwnership
	ExecuteFile
	ReadData
	ReadAttributes
	ReadExtendedAttributes
	CreateFiles
	AppendData
	WriteAttributes
	WriteExtendedAttributes
	Delete
	ReadPermissions
	 
	A comma separated list is used to add auditing for more than one property.

 Author: Tom Willett 
 Date:  8/17/2016
 Ver 1.0

.LINK

get-loggingReport.ps1
reset-logging.ps1

#>

#This script Turns up logging on a windows computer -- comment out what you don't want changed.
#increase log sizes
set-itemproperty hklm:\system\currentcontrolset\services\eventlog\Application -name maxsize -value 41943040
set-itemproperty hklm:\system\currentcontrolset\services\eventlog\System -name maxsize -value 41943040
set-itemproperty hklm:\system\currentcontrolset\services\eventlog\Security -name maxsize -value 41943040

#set audit policy on registry keys
auditpol.exe /set /subcategory:'Registry' /success:enable /failure:enable
#$rule = $acl.getauditrules($true,$true, [System.Security.Principal.NTAccount] )

#HKLM Run key
$acl = get-acl hklm:\software\microsoft\windows\currentversion\run -audit
$rule = New-Object System.Security.AccessControl.RegistryAuditRule ("everyone","ReadPermissions","none","none","success")
$acl.addauditrule($rule)
$rule = New-Object System.Security.AccessControl.RegistryAuditRule ("everyone","ReadPermissions","none","none","failure")
$acl.addauditrule($rule)
$acl | set-acl hklm:\software\microsoft\windows\currentversion\run

#HKLM RunOnce Key
$acl = get-acl hklm:\software\microsoft\windows\currentversion\runonce -audit
$rule = New-Object System.Security.AccessControl.RegistryAuditRule ("everyone","ReadPermissions","none","none","success")
$acl.addauditrule($rule)
$rule = New-Object System.Security.AccessControl.RegistryAuditRule ("everyone","ReadPermissions","none","none","failure")
$acl.addauditrule($rule)
$acl | set-acl hklm:\software\microsoft\windows\currentversion\runonce

#HKCU Run Key
$acl = get-acl hkcu:\software\microsoft\windows\currentversion\run -audit
$rule = New-Object System.Security.AccessControl.RegistryAuditRule ("everyone","ReadPermissions","none","none","success")
$acl.addauditrule($rule)
$rule = New-Object System.Security.AccessControl.RegistryAuditRule ("everyone","ReadPermissions","none","none","failure")
$acl.addauditrule($rule)
$acl | set-acl hkcu:\software\microsoft\windows\currentversion\run

#HKCU RunOnce
$acl = get-acl hklm:\software\microsoft\windows\currentversion\runonce -audit
$rule = New-Object System.Security.AccessControl.RegistryAuditRule ("everyone","ReadPermissions","none","none","success")
$acl.addauditrule($rule)
$rule = New-Object System.Security.AccessControl.RegistryAuditRule ("everyone","ReadPermissions","none","none","failure")
$acl.addauditrule($rule)
$acl | set-acl hkcu:\software\microsoft\windows\currentversion\runonce

#Logon/Logoff Logging
auditpol.exe /set /subcategory:'Logon' /success:enable /failure:enable

#Computer Account Changes Logging
auditpol.exe /set /subcategory:'computer account management' /success:enable /failure:enable

#Security Group changes Logging
auditpol.exe /set /subcategory:'security group management' /success:enable /failure:enable

#User Account Changes Logging
auditpol.exe /set /subcategory:'user account management' /success:enable /failure:enable

#Firewall Events Logging
auditpol.exe /set /subcategory:'Filtering Platform Connection' /success:enable /failure:enable

#Process Creation Logging
auditpol.exe /set /subcategory:'Process Creation' /success:enable /failure:enable

#Process Termination Logging
auditpol.exe /set /subcategory:'Process Termination' /success:enable

#Powershell Script Block Logging
$basePath = 'HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging'
if(-not (Test-Path $basePath))  
{  
	$null = New-Item $basePath -Force  
}
Set-ItemProperty $basePath -Name EnableScriptBlockLogging -Value '1'
Set-ItemProperty $basePath -Name EnableScriptBlockInvocationLogging -Value '1'

#Audit policy logging
auditpol.exe /set /subcategory:'Audit Policy Change' /success:enable /failure:enable
