<#

.SYNOPSIS

Get all Server or workstations or all computers in AD.

.DESCRIPTION

This script searches Active Directory using .net for all the computer objects which have been logged into in the last 60 days.

.PARAMETER flg

If flg is set to Server then Servers are returned.  If flg is Workstation then workstation are returned.  
if flg is set to All then all computers are returned. The default is All.

.EXAMPLE

.\get-ComputerNames.ps1
Returns all computers

.EXAMPLE

.\get-computerNames.ps1 Server
Returns all servers

.EXAMPLE

.\get-ComputerNames.ps1 Workstation
Returns all Workstations

.NOTES

 Author: Tom Willett 
 Date: 9/29/2014

The names are returned one per line so they can be used as input to another command.
flg can be shortened to S W or A

#>

Param([string]$flg="All")

$strCategory = "computer"
#Get the date 60 days previous in correct format
$strDate = [system.datetime]::now.touniversaltime().adddays(-60).tofiletime()

$objDomain = New-Object System.DirectoryServices.DirectoryEntry
 
$objSearcher = New-Object System.DirectoryServices.DirectorySearcher
$objSearcher.SearchRoot = $objDomain
$objSearcher.Filter = "(&(objectCategory=$strCategory)(lastlogontimestamp>=$strdate))"
$objSearcher.PageSize = 1000

$colProplist = "name","DNShostname","OperatingSystem","OperatingSystemVersion"

foreach ($i in $colPropList){$tmp  = $objSearcher.PropertiesToLoad.Add($i)}

$colResults = $objSearcher.FindAll()
$objComputers = @()
$flg = $flg.toupper()
foreach ($objResult in $colResults)
	{
		$temp = "" | Select Name,DNShostname,OperatingSystem,OperatingSystemVersion
		$temp.name = [string]$objResult.properties.name
		$temp.DNShostname = [string]$objResult.properties.dnshostname
		$temp.OperatingSystem = [string]$objResult.properties.operatingsystem
		$temp.operatingsystemversion = [string]$objResult.properties.operatingsystemversion
		$temp1 = [string]$objResult.properties.operatingsystem
		$srv = $temp1.contains("Server")
		$flag = $false
		if ($flg.startswith("W") -and ($srv -eq $False)) {
			$flag = $True
		}
		if ($flg.startswith("S") -and $srv) {
			$flag = $True
		}
		if ($flg.startswith("A")) {
			$flag = $True
		}
		if ($flag) {
			$objComputers += $temp
		}
	}
$objComputers
