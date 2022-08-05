<#

.SYNOPSIS

Reads all the users from the current domain and returns information about them

.DESCRIPTION

This reads all the users from the current domain and returns name, SID, scriptpath, 
pwdlastset, lastlogontimestamp, memberof, whencreated, lastlogon, homedirectory, 
samaccountname, and mail.  It uses .net routines not the AD extensions.

LastLogonTimestamp is more accurate than lastlogon.

This only returns a small portion of the properties available.  At least the following
properties are available: givenname, codepage, objectcategory, scriptpath, dscorepropagationdata, 
adspath, usnchanged, instancetype, homedrive, logoncount, mailnickname, name, pwdlastset, 
objectclass, samaccounttype, lastlogontimestamp, usncreated, sn, proxyaddresses, msexchversion, 
objectguid, memberof, whencreated, homemta, mdbusedefaults, useraccountcontrol, cn, countrycode, 
primarygroupid, whenchanged, legacyexchangedn, lockouttime, lastlogon, showinaddressbook, 
distinguishedname, protocolsettings, admincount, homedirectory, samaccountname, objectsid, 
mail, displayname, homemdb, accountexpires, userprincipalname. Exchange also adds a lot of properties. 


.NOTES

Author: Tom Willett 
Date: 2/13/2012

#>

$strCategory = "user"

$objDomain = New-Object System.DirectoryServices.DirectoryEntry
 
$objSearcher = New-Object System.DirectoryServices.DirectorySearcher
$objSearcher.SearchRoot = $objDomain
$objSearcher.Filter = "(objectCategory=$strCategory)"
$objSearcher.PageSize = 1000
$colResults = $objSearcher.FindAll()
$ErrorActionPreference = "SilentlyContinue"
$objUsers = @()
foreach ($objResult in $colResults)
	{
		$temp = "" | Select name, SID, scriptpath, pwdlastset, lastlogontimestamp, memberof, whencreated, lastlogon, homedirectory, samaccountname, mail, passwordnotrequired
		$temp.name = $objResult.properties.name
		$temp.SID = (New-Object System.Security.Principal.SecurityIdentifier($objResult.properties["ObjectSID"][0],0)).Value
		$temp.scriptpath = $objResult.properties.scriptpath
		$temp.pwdlastset = [datetime]::fromfiletime($objResult.properties.pwdlastset[0])
		$temp.lastlogontimestamp = [datetime]::fromfiletime($objResult.properties.lastlogontimestamp[0])
		$temp.memberof = $objResult.properties.memberof
		$temp.whencreated = $objResult.properties.whencreated
		$temp.lastlogon = [datetime]::fromfiletime($objResult.properties.lastlogon[0])
		$temp.homedirectory = $objResult.properties.homedirectory
		$temp.samaccountname = $objResult.properties.samaccountname
		if (($objresult.properties.useraccountcontrol -band 32) -eq 32) {
			$temp.passwordnotrequired = "True"
		} else {
			$temp.passwordnotrequired = "False"
		}
		$temp.mail = $objResult.properties.mail
		$objUsers += $temp
	}
$objUsers