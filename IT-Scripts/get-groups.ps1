<#

.SYNOPSIS

Reads all the groups from the current domain and returns information about them

.DESCRIPTION

This reads all the groups from the current domain and returns name, adspath, cn, SID,
member, samaccountname, whencreated, description.  It uses .net routines not the 
AD extensions.

This only returns a small portion of the properties available.  At least the following
properties are available: adspath, cn, description, displayname, distinguishedname, 
dscorepropagationdata, grouptype, instancetype, internetencoding, iscriticalsystemobject, 
managedby, managedobjects, member, memberof, msexchaddressbookflags, msexchbypassaudit, 
msexchcomanagedbylink, msexchgroupdepartrestriction, msexchgroupjoinrestriction, 
msexchmailboxauditenable, msexchmailboxauditlogagelimit, msexchmoderationflags, 
msexchprovisioningflags, msexchrecipienttypedetails, msexchuserbl, msexchversion, 
name, objectcategory, objectclass, objectguid, objectsid, samaccountname, samaccounttype, 
systemflags, usnchanged, usncreated, whenchanged, whencreated.


.EXAMPLE

 .\get-groups.ps1

Retrieves groups in a domain.
 
.NOTES

Author: Tom Willett 
Date: 7/17/2019

#>

$strCategory = "group"

$objDomain = New-Object System.DirectoryServices.DirectoryEntry
 
$objSearcher = New-Object System.DirectoryServices.DirectorySearcher
$objSearcher.SearchRoot = $objDomain
$objSearcher.Filter = "(objectCategory=$strCategory)"
$objSearcher.PageSize = 1000
$colResults = $objSearcher.FindAll()
$ErrorActionPreference = "SilentlyContinue"
$objGroups = @()
foreach ($objResult in $colResults)
	{
		$temp = "" | Select name,adspath,cn,SID,member,samaccountname,whencreated,description
		$temp.name = $objResult.properties.name
		$temp.SID = (New-Object System.Security.Principal.SecurityIdentifier($objResult.properties["ObjectSID"][0],0)).Value
		$temp.adspath = $objResult.properties.adspath
		$temp.cn = $objResult.properties.cn
		$temp.member = $objResult.properties.member
		$temp.samaccountname = $objResult.properties.samaccountname
		$temp.whencreated = $objResult.properteis.whencreated
		$temp.description = $objResult.properties.description
		$objGroups += $temp
	}
$objGroups
