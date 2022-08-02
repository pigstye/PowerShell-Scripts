<#

.SYNOPSIS

Collect advanced logging information from a computer

.DESCRIPTION

This script collects advanced logging information from a computer and presents suggestions for increasing logging.
There is a companion script set-logging.ps1 that sets all of these settings according to recommendations.

.OUTPUTS

Displays the report on screen which can be redirected to a file.

.EXAMPLE

PS>.\get-loggingReport.ps1

.NOTES

 Author: Tom Willett 
 Date:  8/17/2016
 Ver 1.0

#>

function Format-HumanReadable {
	param ($size)
	if ($size -ge 1PB) {
		$hsize = [string][math]::round(($size/1PB),0) + "P"
	} elseif ($size -ge 1TB) {
		$isize=[math]::round(($size/1TB),0)
		$hsize=[string]$isize + "T"
	} elseif ($size -ge 1GB) {
		$isize=[math]::round(($size/1GB),0)
		$hsize=[string]$isize + "G"
	} elseif ($size -ge 1MB) {
		$isize=[math]::round(($size/1MB),0)
		$hsize=[string]$isize + "M"
	} elseif ($size -ge 1KB) {
		$isize=[math]::round(($size/1KB),0)
		$hsize=[string]$isize + "K"
	}
	$hsize += "B"
	return $hsize
}
write-host 'Logging report for computer:'(get-item env:computername).value
write-host '-------------'
write-host 'Default log size for Application, Security and System logs is 20MB.'
write-host 'If these logs are not collected on another server, the recommendation is to increase max log size to 40mb.'
write-host 'Current Log File Maximum Sizes:'
$logs = get-childitem Hklm:\system\currentcontrolset\services\eventlog\
$rpt = @()
foreach($log in $logs) {
	$tmp = "" | Select Log,Size
	$tmp.log = $log.pschildname
	$tmp.size = format-humanreadable((get-itemproperty ($log.name -replace 'HKEY_LOCAL_MACHINE', 'HKLM:')).maxsize)
	$rpt += $tmp
}
$rpt | out-host
write-host '-------------'
write-host 'Audit policy for registry keys:'
write-host 'It is recommended to audit the HKLM and HKCR run keys.'
auditpol.exe /get /subcategory:registry
write-host ''
write-host 'Logging for common registry keys:'
write-host 'HKLM Run Key'
(get-acl hklm:\software\microsoft\windows\currentversion\run -audit).audit | out-host
write-host 'HKLM RunOnce Key'
(get-acl hklm:\software\microsoft\windows\currentversion\runonce -audit).audit | out-host
write-host 'HKCU Run Key'
(get-acl hkcu:\software\microsoft\windows\currentversion\run -audit).audit | out-host
write-host 'HKCU RunOnce Key'
(get-acl hkcu:\software\microsoft\windows\currentversion\runonce -audit).audit | out-host
write-host '-------------'
write-host 'Logon/Logoff Audit policy:'
write-host 'Recommendation is to log Success/Failure for Logon and Success for Logoff.'
auditpol.exe /get /category:'Logon/Logoff'
write-host '-------------'
write-host 'Account Management Audit Policy:'
write-host 'Recommendation -- log Success/Failure for Account Management.'
auditpol.exe /get /category:'account management'
write-host '-------------'
write-host 'Firewall Events Policy:'
write-host 'Recommendation -- Log Success/Failure for Connections.'
write-host 'On a busy computer this can create a log of entries.'
auditpol.exe /get /subcategory:'Filtering Platform Connection'
write-host '-------------'
write-host 'Process Creation and Termination Policy:'
write-host 'On critical workstations/servers Log Success/Failure on Creation and Success on Termination.'
auditpol.exe /get /subcategory:'Process Creation'
auditpol.exe /get /subcategory:'Process Termination'
write-host '-------------'
write-host 'Powershell Script Block Logging: (1 means enabled)'
write-host 'Recommendation -- turn on ScriptBlockLogging.'
(get-itemproperty "HKLM:\Software\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging").enablescriptblocklogging
write-host '-------------'
write-host 'Audit Policy Auditing:'
write-host 'Recommendation -- Turn on Audit Policy Changes Auditing.'
auditpol.exe /get /subcategory:'Audit Policy Change'

