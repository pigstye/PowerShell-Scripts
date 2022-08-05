
<#

.SYNOPSIS

Gets the System, Security and Application Logs and compresses them into a zip file

.DESCRIPTION

Gets the System, Security and Application Logs from the computers listed in a file and compresses them 
into a zip file

.PARAMETER comps

A file with the list of computers one to a line (required)

.OUTPUTS

Creates a zip file named after each computer

.EXAMPLE     
    .\gather-logs.ps1 comps.txt

.NOTES
	
 Author: Tom Willett
 Date: 4/7/2018

#>

param([string]$comps)
$cmps = gc $comps
Add-Type -assembly "system.io.compression.filesystem"
$ScriptPath = $MyInvocation.MyCommand.Path
$ScriptDir = split-path -parent $ScriptPath
$ErrorActionPreference = "SilentlyContinue"

foreach ($cmp in $cmps) {
	echo "Processing $cmp"
	if (test-connection -count 1 -computername $cmp) {
		mkdir $cmp
		#create paths
		$pth = $ScriptDir + '\' + $cmp
		$zip = $pth + '.zip'
		#Copy log files
		copy \\$cmp\c$\Windows\System32\winevt\Logs\system.evtx $pth
		copy \\$cmp\c$\Windows\System32\winevt\Logs\security.evtx $pth
		copy \\$cmp\c$\Windows\System32\winevt\Logs\application.evtx $pth
		#add log files to zip
		[io.compression.zipfile]::CreateFromDirectory($pth,$zip)
		rmdir -force -recurse -confirm:$false $pth
	
		#remove computer from array
		$tmp = $cmps | where-object {$_ -notmatch $cmp}
		$cmps = $tmp
	}
}
$cmps | set-content $comps
