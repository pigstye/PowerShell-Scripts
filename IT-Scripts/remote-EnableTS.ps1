#=================================================================
#
# remoteEnableTS.ps1
#
# Enable remote desktop on a remote computer(s)
#
# Author:  Tom Willett
#
# 11/17/2011
#
#======================================================================

<# 

.SYNOPSIS 

This script alters a remote registry to allow Remote Desktop Connections

.PARAMETER $server

The Computer name(s) is expected by this script 

.EXAMPLE 

.\remoteEnableTS.ps1 servername1 servername2 ...

.NOTES 

It changes the value of HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\fDenyTSConnections to 0

#>

foreach ($Server in $args) {
	$reg=[Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine',$Server)
	$regkey=$reg.OpenSubKey("SYSTEM\\CurrentControlSet\\Control\\Terminal Server")
	$regkey.setvalue('fDenyTSConnections',0)
}