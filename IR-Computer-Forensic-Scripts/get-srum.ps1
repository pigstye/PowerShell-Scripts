function get-srum {
	<#
	.SYNOPSIS
		Process SRUM data 
	.DESCRIPTION
		Process SRUM data - it uses Nirsoft esedatabaseview.exe
	.Parameter srum
		Path to SRUMDB.DAT
	.PARAMETER nese
		path to exedatabaseview.exe
	.NOTES
	Author: Tom Willett 
	Date: 8/24/2022
	V1.0
	#>	
	Param([Parameter(Mandatory=$True)][string]$srum,
		[Parameter(Mandatory=$True)][string]$nese,
		[Parameter(Mandatory=$True)][string]$Computername)
	
	#Download tables
	write-host "Getting Tables"
	& $nese /table $sdb 'SruDbIDMapTable' /SaveDirect /scomma ($computername + '-SruDbIDMapTable.csv')
	start-sleep -seconds 3
	& $nese /table $sdb '{973F5D5C-1D90-4944-BE8E-24B94231A174}' /SaveDirect /scomma ($computername + '-NetworkUsage.csv')
	start-sleep -seconds 3
	& $nese /table $sdb '{D10CA2FE-6FCF-4F6D-848E-B2E99266FA86}' /SaveDirect /scomma ($computername + '-PushNotification.csv')
	start-sleep -seconds 3
	& $nese /table $sdb '{DD6636C4-8929-4683-974E-22C046A43763}' /SaveDirect /scomma ($computername + '-NetworkConnection.csv')
	start-sleep -seconds 3
	& $nese /table $sdb '{5C8CF1C7-7257-4F13-B223-970EF5939312}' /SaveDirect /scomma ($computername + '-TimelineProvider.csv')
	start-sleep -seconds 3
	& $nese /table $sdb '{D10CA2FE-6FCF-4F6D-848E-B2E99266FA89}' /SaveDirect /scomma ($computername + '-AppResourceInfo.csv')
	start-sleep -seconds 3
	& $nese /table $sdb '{FEE4E14F-02A9-4550-B5CE-5FA2DA202E37}LT' /SaveDirect /scomma ($computername + '-EnergyUsage-LongTerm.csv')
	start-sleep -seconds 3
	& $nese /table $sdb '{FEE4E14F-02A9-4550-B5CE-5FA2DA202E37}' /SaveDirect /scomma ($computername + '-EnergyUsage.csv')
	start-sleep -seconds 3
	& $nese /table $sdb '{7ACBBAA3-D029-4BE4-9A7A-0885927F1D8F}' /SaveDirect /scomma ($computername + '-Vfuprov.csv')
	start-sleep -seconds 3

	write-host "Processing Map Table"
	#Start processing with Map Table
	$tmpdb = import-csv ($computername + '-SruDbIDMapTable.csv')
	$tmpdb | foreach-object {
		if ($_.idType -eq 3){
			# Convert userSID
			[byte[]]$t = $_.idblob -split ' ' | %{[byte]([convert]::toint16($_,16))}
			$_.idblob = (New-Object System.Security.Principal.SecurityIdentifier($t,0)).Value
		} else {
			# Convert UTF-16 Blob
			$s = $_.idblob
			$_.idblob = (($s -split ' ') | %{[char][byte]([convert]::toint16($_,16))}) -join ''
		}
	}
	$tmpdb | export-csv -notype ($computername + '-SruDbIDMapTable.csv')
	#Create Hash Table for easy access
	write-host "Creating Hastable from map table"
	$srudb = $tmpdb | group-object -ashashtable -asstring -property idIndex

	$tables = @('-NetworkUsage.csv','-PushNotification.csv','-NetworkConnection.csv','-TimelineProvider.csv','-AppResourceInfo.csv','-EnergyUsage-LongTerm.csv','-EnergyUsage.csv','-Vfuprov.csv')
	foreach($tbl in $tables){
		$tmp = import-csv ($computername + $tbl)
		write-host "Processing $computername$tbl"
		$tmp | %{
			$id = $_.Userid 
			if (($srudb.$id).idblob) {
				$_.userid = ($srudb.$id).idblob
			}
			$id = $_.AppID 
			if (($srudb.$id).idblob) {
				$_.AppID = ($srudb.$id).idblob
			}
		}
		$tmp | export-csv -notype ($computername + $tbl)
	}
}