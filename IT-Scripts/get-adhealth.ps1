<#

.SYNOPSIS

Gathers information about a domain for audit purposes

.DESCRIPTION

Gathers information about a domain for audit purposes - should be run with elevated permissions

.OUTPUTS

Creates a file called ADHealth.txt

.EXAMPLE     
    .\get-adhealth.ps1

.NOTES
	
 Author: Tom Willett
 Date: 3/7/2018

#>

#Requires -Version 3.0
#This File is in Unicode format.  Do not edit in an ASCII editor.


$ErrorActionPreference = 'SilentlyContinue'

Function Test-RegistryValue($path, $name) {
<#
#http://stackoverflow.com/questions/5648931/test-if-registry-value-exists
# This Function just gets $True or $False
#>
	$key = Get-Item -LiteralPath $path -EA 0
	$key -and $Null -ne $key.GetValue($name, $Null)
}

Function Get-RegistryValue($path, $name) {
<#
# Gets the specified registry value or $Null if it is missing
#>
	$key = Get-Item -LiteralPath $path -EA 0
	If($key)
	{
		$key.GetValue($name, $Null)
	}
	Else
	{
		$Null
	}
}


Function ConvertTo-FQDN {
<#
# converts the name to FQDN
#>
	Param (
	[Parameter( Mandatory = $true )]
	[string] $DomainFQDN
	)

	$result = "DC=" + $DomainFQDN.Replace( ".", ",DC=" )
	Write-Debug "***ConvertTo-FQDN DomainFQDN='$DomainFQDN', result='$result'"
	Return $result
}

Function get-forestInfo {
<#
# get forest info
#>
	[System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()
}

function get-domaininfo {
<#
Get Domain Info
#>
	[System.DirectoryServices.ActiveDirectory.domain]::GetCurrentdomain()
}

Function Get-Domains {
<#
Get all Domains in forest
#>
	( [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest() ).Domains
}

Function Get-ADDomains {
<#
Get AD Domains
#>
	$Domains = Get-Domains
	ForEach($Domain in $Domains)
	{
		$DomainName = $Domain.Name
		$DomainFQDN = ConvertTo-FQDN $DomainName

		$ADObject   = [ADSI]"LDAP://$DomainName"
		$sidObject = New-Object System.Security.Principal.SecurityIdentifier( $ADObject.objectSid[ 0 ], 0 )

		Write-Debug "***Get-AdDomains DomName='$DomainName', sidObject='$($sidObject.Value)', name='$DomainFQDN'"

		$Object = New-Object -TypeName PSObject
		$Object | Add-Member -MemberType NoteProperty -Name 'Name'      -Value $DomainFQDN
		$Object | Add-Member -MemberType NoteProperty -Name 'FQDN'      -Value $DomainName
		$Object | Add-Member -MemberType NoteProperty -Name 'distinguishedName'      -Value $DomainFQDN
		$Object | Add-Member -MemberType NoteProperty -Name 'ObjectSID' -Value $sidObject.Value
		$Object
	}
}

Function Get-PrivilegedGroupsMemberCount {
<#
	Get Count of Privileged Groups Members
	## Jeff W. said this was original code, but until I got ahold of it and
	## rewrote it, it looked only slightly changed from:
	## https://gallery.technet.microsoft.com/scriptcenter/List-Membership-In-bff89703
	## So I give them both credit. :-)

#>
	Param (
		[Parameter( Mandatory = $true, ValueFromPipeline = $true )]
		$Domains
	)

	
	## the $Domains param is the output from Get-AdDomains above
	ForEach( $Domain in $Domains ) 
	{
		$DomainSIDValue = $Domain.ObjectSID
		$DomainName     = $Domain.Name
		$DomainFQDN     = $Domain.FQDN

		Write-Debug "***Get-PrivilegedGroupsMemberCount: domainName='$domainName', domainSid='$domainSidValue'"

		## Carefully chosen from a more complete list at:
		## https://support.microsoft.com/en-us/kb/243330
		## Administrator (not a group, just FYI)    - $DomainSidValue-500
		## Domain Admins                            - $DomainSidValue-512
		## Schema Admins                            - $DomainSidValue-518
		## Enterprise Admins                        - $DomainSidValue-519
		## Group Policy Creator Owners              - $DomainSidValue-520
		## BUILTIN\Administrators                   - S-1-5-32-544
		## BUILTIN\Account Operators                - S-1-5-32-548
		## BUILTIN\Server Operators                 - S-1-5-32-549
		## BUILTIN\Print Operators                  - S-1-5-32-550
		## BUILTIN\Backup Operators                 - S-1-5-32-551
		## BUILTIN\Replicators                      - S-1-5-32-552
		## BUILTIN\Network Configuration Operations - S-1-5-32-556
		## BUILTIN\Incoming Forest Trust Builders   - S-1-5-32-557
		## BUILTIN\Event Log Readers                - S-1-5-32-573
		## BUILTIN\Hyper-V Administrators           - S-1-5-32-578
		## BUILTIN\Remote Management Users          - S-1-5-32-580
		
		## FIXME - we report on all these groups for every domain, however
		## some of them are forest wide (thus the membership will be reported
		## in every domain) and some of the groups only exist in the
		## forest root.
		$PrivilegedGroups = "$DomainSidValue-512", "$DomainSidValue-518",
		                    "$DomainSidValue-519", "$DomainSidValue-520",
							"S-1-5-32-544", "S-1-5-32-548", "S-1-5-32-549",
							"S-1-5-32-550", "S-1-5-32-551", "S-1-5-32-552",
							"S-1-5-32-556", "S-1-5-32-557", "S-1-5-32-573",
							"S-1-5-32-578", "S-1-5-32-580"

		ForEach( $PrivilegedGroup in $PrivilegedGroups ) 
		{
			$source = New-Object DirectoryServices.DirectorySearcher( "LDAP://$DomainName" )
			$source.SearchScope = 'Subtree'
			$source.PageSize    = 1000
			$source.Filter      = "(objectSID=$PrivilegedGroup)"
			
			Write-Debug "***Get-PrivilegedGroupsMemberCount: LDAP://$DomainName, (objectSid=$PrivilegedGroup)"
			
			$Groups = $source.FindAll()
			ForEach( $Group in $Groups )
			{
				$DistinguishedName = $Group.Properties.Item( 'distinguishedName' )
				$groupName         = $Group.Properties.Item( 'Name' )

				Write-Debug "***Get-PrivilegedGroupsMemberCount: searching group '$groupName'"

				$Source.Filter = "(memberOf:1.2.840.113556.1.4.1941:=$DistinguishedName)"
				$Users = $null
				## CHECK: I don't think a try/catch is necessary here - MBS
				try 
				{
					$Users = $Source.FindAll()
				} 
				catch 
				{
					# nothing
				}
				If( $null -eq $users )
				{
					## Obsolete: F-I-X-M-E: we should probably Return a PSObject with a count of zero
					## Write-ToCSV and Write-ToWord understand empty Return results.

					Write-Debug "***Get-PrivilegedGroupsMemberCount: no members found in $groupName"
				}
				Else 
				{
					Function GetProperValue
					{
						Param(
							[Object] $object
						)

						If( $object -is [System.DirectoryServices.SearchResultCollection] )
						{
							Return $object.Count
						}
						If( $object -is [System.DirectoryServices.SearchResult] )
						{
							Return 1
						}
						If( $object -is [Array] )
						{
							Return $object.Count
						}
						If( $null -eq $object )
						{
							Return 0
						}

						Return 1
					}

					[int]$script:MemberCount = GetProperValue $Users

					Write-Debug "***Get-PrivilegedGroupsMemberCount: '$groupName' user count before first filter $MemberCount"

					$Object = New-Object -TypeName PSObject
					$Object | Add-Member -MemberType NoteProperty -Name 'Domain' -Value $DomainFQDN
					$Object | Add-Member -MemberType NoteProperty -Name 'Group'  -Value $groupName

					$Members = $Users | Where-Object { $_.Properties.Item( 'objectCategory' ).Item( 0 ) -like 'cn=person*' }
					$script:MemberCount = GetProperValue $Members

					Write-Debug "***Get-PrivilegedGroupsMemberCount: '$groupName' user count after first filter $MemberCount"

					Write-Debug "***Get-PrivilegedGroupsMemberCount: '$groupName' has $MemberCount members"

					$Object | Add-Member -MemberType NoteProperty -Name 'Members' -Value $MemberCount
					$Object
				}
			}
		}
	}
}

Function Get-AllADDomainControllers {
<#
Get Domain Controllers
#>
	[CmdletBinding()]
	Param (
		[Parameter( Mandatory = $true, ValueFromPipeline = $true )]
		$Domain
	)

	$DomainName = $Domain.Name
	$DomainFQDN = $Domain.FQDN
		
	$adsiSearcher        = New-Object DirectoryServices.DirectorySearcher( "LDAP://$DomainName" )
	$adsiSearcher.Filter = '(&(objectCategory=computer)(userAccountControl:1.2.840.113556.1.4.803:=8192))'
	$Servers             = $adsiSearcher.FindAll() 
	
	ForEach( $Server in $Servers ) 
	{
		$dcName = [string]$Server.Properties.item( 'Name' )

		Write-Debug "***Get-AllAdDomainControllers DomainName='$DomainName', DomainFQDN='$($DomainFQDN)', DCname='$dcName'"

		$Object = New-Object -TypeName PSObject
		$Object | Add-Member -MemberType NoteProperty -Name 'Domain'      -Value $DomainFQDN
		$Object | Add-Member -MemberType NoteProperty -Name 'Name'        -Value $dcName
		$Object | Add-Member -MemberType NoteProperty -Name 'LastContact' -Value $Server.Properties.Item( 'whenchanged' )
		$Object
	}
}

Function get-computernames {
<#
Get Computer Names
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
}

Function get-users {
<#
Get Users
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
			$temp = "" | Select name, scriptpath, pwdlastset, lastlogontimestamp, memberof, whencreated, lastlogon, homedirectory, samaccountname, mail, passnotrequired, passdoesnotexpire, locked, passexpired, disabled
			$temp.name = [string]$objResult.properties.name
			$temp.scriptpath = [string]$objResult.properties.scriptpath
			$temp.pwdlastset = [datetime]::fromfiletime($objResult.properties.pwdlastset[0])
			$temp.lastlogontimestamp = [datetime]::fromfiletime($objResult.properties.lastlogontimestamp[0])
			$temp.memberof = [string]$objResult.properties.memberof
			$temp.whencreated = [string]$objResult.properties.whencreated
			$temp.lastlogon = [datetime]::fromfiletime($objResult.properties.lastlogon[0])
			$temp.homedirectory = [string]$objResult.properties.homedirectory
			$temp.samaccountname = [string]$objResult.properties.samaccountname
			$temp.mail = [string]$objResult.properties.mail
			$s=[string]$objresult.properties.useraccountcontrol
			if ($s -band 32) {
				$temp.passnotrequired = $true
			} else {
				$temp.passnotrequired = $false
			}
			if ($s -band 65536) {
				$temp.passdoesnotexpire = $true
			} else {
				$temp.passdoesnotexpire = $false
			}
			if ($s -band 16) {
				$temp.locked = $true
			} else {
				$temp.locked = $false
			}
			if ($s -band 8388608) {
				$temp.passexpired = $true
			} else {
				$temp.passexpired = $false
			}
			if ($s -band 2) {
				$temp.disabled = $true
			} else {
				$temp.disabled = $false
			}
			$objUsers += $temp
		}
	$objUsers
}

function get-groups {
<#
Get Groups
#>
	$objDomain = New-Object System.DirectoryServices.DirectoryEntry
	 
	$objSearcher = New-Object System.DirectoryServices.DirectorySearcher
	$objSearcher.SearchRoot = $objDomain
	$objSearcher.Filter = "(objectClass=group)"
	$objSearcher.PageSize = 1000
	$colResults = $objSearcher.FindAll()
	$objGroups = @()
	foreach ($res in $colResults) {
		$temp = "" | Select name, description
		$temp.name = [string]$res.properties.name
		$temp.description = [string]$res.properties.description
		$objGroups += $temp
	}
	$objGroups
}

Function get-groupMembers {
<#
Get Group Members
#>
	Param ([Parameter( Mandatory = $true, ValueFromPipeline = $true )]$Group)
	
	$strCategory = "user"

	$objDomain = New-Object System.DirectoryServices.DirectoryEntry
	 
	$objSearcher = New-Object System.DirectoryServices.DirectorySearcher
	$objSearcher.SearchRoot = $objDomain
	$objSearcher.Filter = "(objectCategory=$strCategory)"
	$objSearcher.PageSize = 1000
	$colResults = $objSearcher.FindAll()
	$objUsers = @()
	foreach ($res in $colResults) {
		$member = ($res.properties.memberof -join ',').indexof($Group)
		if ($member -gt 0) {
			$objUsers += $res.properties.name
		}
	}
	$objUsers
}

Function Get-AllADMemberServers {
<#
Get Member Servers
#>
	get-computernames s
}

Function Get-OUGPInheritanceBlocked {
<#
Get OUs with Inheritance Blocked
#>
	[CmdletBinding()]
	Param (
		[Parameter( Mandatory = $true, Position = 0, ValueFromPipeline = $true )]
		$Domain
	)

	$DomainName = $Domain.Name
	$DomainFQDN = $Domain.FQDN
	
	Write-Debug "***Enter: Get-OUGPInheritanceBlocked, DomainName '$DomainName'"

	$source             = New-Object System.DirectoryServices.DirectorySearcher( "LDAP://$DomainName" )
	$source.SearchScope = 'Subtree'
	$source.PageSize    = 1000
	$source.filter      = '(&(objectclass=OrganizationalUnit)(gpoptions=1))'
	try 
	{
		$source.FindAll() | ForEach-Object {
			$ouName = $_.Properties.Item( 'Name' )

			Write-Debug "***Get-OuGpInheritanceBlocked: Inheritance blocked on OU '$ouName' in domain '$DomainName'"

			$Object = New-Object -TypeName PSObject
			$Object | Add-Member -MemberType NoteProperty -Name 'Domain' -Value $DomainFQDN
			$Object | Add-Member -MemberType NoteProperty -Name 'Name'   -Value $ouName 
			$Object
		}
	} 
	catch 
	{
	}
}

Function Get-ADSites {
<#
Get AD Sites
#>
	[CmdletBinding()]
	Param (
		[Parameter( Mandatory = $true, Position = 0, ValueFromPipeline = $true )]
		$Domain
	)

	$DomainName = $Domain.Name
	$DomainFQDN = $Domain.FQDN
	$searchRoot = "LDAP://CN=Sites,CN=Configuration,$DomainName"

	Write-Debug "***Enter: Get-AdSites, DomainName='$($DomainName)', SearchRoot='$searchRoot'"

	$source             = New-Object System.DirectoryServices.DirectorySearcher
	$source.SearchScope = 'Subtree'
	$source.SearchRoot  = $searchRoot
	$source.PageSize    = 1000
	$source.Filter      = '(objectclass=site)'
	
	try 
	{
		$source.FindAll() | ForEach-Object {
			$siteName = $_.Properties.Item( 'Name' )
			$desc     = $_.Properties.Item( 'Description' )

			If( [String]::IsNullOrEmpty( $desc ) )
			{
				$desc = ' '
			}
			
			Write-Debug "***Get-AdSites: domainFQDN='$DomainFQDN', sitename='$sitename', desc='$desc'"

			$subnets = @()
			$siteBL  = $_.Properties.Item( 'siteObjectBL' )
			ForEach( $item in $siteBL )
			{
				$temp = $item.SubString( 0, $item.IndexOf( ',' ) )  ## up to first ","
				$temp = $temp.SubString( 3 )                        ## drop CN=

				Write-Debug "***Get-AdSites: sitename='$sitename', subnet='$temp'"

				$subnets += $temp
			}
			If( $subnets.Count -eq 0 )
			{
				$subnets = $null
			}

			$Object = New-Object -TypeName PSObject
			$Object | Add-Member -MemberType NoteProperty -Name 'Domain'      -Value $DomainFQDN
			$Object | Add-Member -MemberType NoteProperty -Name 'Site'        -Value $siteName
			$Object | Add-Member -MemberType NoteProperty -Name 'Description' -Value $desc
			$Object | Add-Member -MemberType NoteProperty -Name 'Subnets'     -Value $subnets
			$Object
		}
	} 
	catch 
	{
	}
}

Function Get-ADSiteServer {
<#
Get Servers by Site
#>
	[CmdletBinding()]
	Param (
		[Parameter( Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
		$Domain,

		[Parameter( Mandatory = $true )]
		$Site
	)

	$DomainName = $Domain.Name
	$DomainFQDN = $Domain.FQDN
	$searchRoot = "LDAP://CN=Servers,CN=$Site,CN=Sites,CN=Configuration,$DomainName"

	Write-Debug "***Enter: Get-AdSiteServer DomainName='$domainName', DomainFQDN='$domainFQDN', searchRoot='$searchRoot'"

	$source             = New-Object System.DirectoryServices.DirectorySearcher
	$source.SearchRoot  = $searchRoot 
	$source.SearchScope = 'Subtree'
	$source.PageSize    = 1000
	$source.Filter      = '(objectclass=server)'
	
	try 
	{
		$SiteServers = $source.FindAll()
		If( $null -ne $SiteServers ) 
		{
			ForEach( $SiteServer in $SiteServers ) 
			{
				$serverName = $SiteServer.Properties.Item( 'Name' )

				Write-Debug "***Get-AdSiteServer: serverName='$serverName' found in site '$site' in domain '$domainFQDN'"

				$Object = New-Object -TypeName PSObject
				$Object | Add-Member -MemberType NoteProperty -Name 'Domain' -Value $DomainFQDN
				$Object | Add-Member -MemberType NoteProperty -Name 'Site'   -Value $Site
				$Object | Add-Member -MemberType NoteProperty -Name 'Name'   -Value $serverName
				$Object
			}
		} 
		Else 
		{
			Write-Debug "***Get-AdSiteServer: No server found in site '$site' in domain '$domainFQDN'"

			$Object = New-Object -TypeName PSObject
			$Object | Add-Member -MemberType NoteProperty -Name 'Domain' -Value $DomainFQDN
			$Object | Add-Member -MemberType NoteProperty -Name 'Site'   -Value $Site
			$Object | Add-Member -MemberType NoteProperty -Name 'Name'   -Value ' '
			$Object            
		}
	} 
	catch 
	{
	}
}

Function Get-ADSiteConnection {
<#
Get AD Site Connection
#>
	[CmdletBinding()]
	Param (
		[Parameter( Mandatory = $true, Position = 0, ValueFromPipeline = $true )]
		$Domain,

		[Parameter( Mandatory = $true )]
		$Site
	)

	$DomainName = $Domain.Name
	$DomainFQDN = $Domain.FQDN
	$searchRoot = "LDAP://CN=$Site,CN=Sites,CN=Configuration,$DomainName"

	Write-Debug "***Enter: Get-ADSiteConnection DomainName='$DomainName', DomainFQDN='$DomainFQDN', searchRoot='$searchRoot'"

	$source             = New-Object System.DirectoryServices.DirectorySearcher
	$source.SearchRoot  = $searchRoot 
	$source.SearchScope = 'Subtree'
	$source.PageSize    = 1000
	$source.Filter      = '(objectclass=nTDSConnection)'
	
	try 
	{
		$SiteConnections = $source.FindAll()
		If( $null -ne $SiteConnections ) 
		{
			ForEach( $SiteConnection in $SiteConnections ) 
			{
				$connectName   = $SiteConnection.Properties.Item( 'Name' )
				$connectServer = $SiteConnection.Properties.Item( 'FromServer' )

				Write-Debug "***Get-ADSiteConnection DomainFQDN='$DomainFQDN', site='$Site', connectionName='$connectName'"

				$Object = New-Object -TypeName PSObject
				$Object | Add-Member -MemberType NoteProperty -Name 'Domain'     -Value $DomainFQDN
				$Object | Add-Member -MemberType NoteProperty -Name 'Site'       -Value $Site
				$Object | Add-Member -MemberType NoteProperty -Name 'Name'       -Value $connectName
				$Object | Add-Member -MemberType NoteProperty -Name 'FromServer' -Value $($connectServer -split ',' -replace 'CN=','')[3]
				$Object
			}
		} 
		Else 
		{
			Write-Debug "***Get-ADSiteConnection DomainFQDN='$DomainFQDN', site='$Site', no connections"

			$Object = New-Object -TypeName PSObject
			$Object | Add-Member -MemberType NoteProperty -Name 'Domain'     -Value $DomainFQDN
			$Object | Add-Member -MemberType NoteProperty -Name 'Site'       -Value $Site
			$Object | Add-Member -MemberType NoteProperty -Name 'Name'       -Value ' '
			$Object | Add-Member -MemberType NoteProperty -Name 'FromServer' -Value ' '
			$Object        
		}
	} 
	catch 
	{
	}
}

Function Get-ADSiteLink {
<#
Get AD Site Link
#>
	[CmdletBinding()]
	Param (
		[Parameter( Mandatory = $true, Position = 0, ValueFromPipeline = $true )]
		$Domain
	)

	$DomainName = $Domain.Name
	$DomainFQDN = $Domain.FQDN
	$searchRoot = "LDAP://CN=Sites,CN=Configuration,$DomainName"

	Write-Debug "***Enter: Get-AdSiteLink DomainName='$DomainName', DomainFQDN='$DomainFQDN', searchRoot='$searchRoot'"

	$source             = New-Object System.DirectoryServices.DirectorySearcher
	$source.SearchRoot  = $searchRoot
	$source.SearchScope = 'Subtree'
	$source.PageSize    = 1000
	$source.Filter      = '(objectclass=sitelink)'
	
	try 
	{
		$SiteLinks = $source.FindAll()
		ForEach( $SiteLink in $SiteLinks ) 
		{
			$siteLinkName = $SiteLink.Properties.Item( 'Name' )
			$siteLinkDesc = $SiteLink.Properties.Item( 'Description' )
			$siteLinkRepl = $SiteLink.Properties.Item( 'replinterval' )
			$siteLinkSite = $SiteLink.Properties.Item( 'Sitelist' )
			$siteLinkCt   = 0

			If( $siteLinkSite )
			{
				$siteLinkCt = $siteLinkSite.Count
			}

			$sites = @()
			ForEach( $item in $siteLinkSite )
			{
				$temp  = $item.SubString( 0, $item.IndexOf( ',' ) )
				$temp  = $temp.SubString( 3 )
				$sites += $temp
			}
			If( $sites.Count -eq 0 )
			{
				$sites      = $null
				$siteLinkCt = 0
			}

			Write-Debug "***Get-AdSiteLink: Name='$siteLinkName', Desc='$siteLinkDesc', Repl='$siteLinkRepl', Count='$siteLinkCt'"

			If( [String]::IsNullOrEmpty( $siteLinkDesc ) )
			{
				$siteLinkDesc = ' '
			}

			If( $null -ne $sites ) 
			{
				ForEach( $Site in $Sites ) 
				{
					Write-Debug "***Get-AdSiteLink: siteLinkName='$siteLinkName', sitename='$site'"

					$Object = New-Object -TypeName PSObject
					$Object | Add-Member -MemberType NoteProperty -Name 'Domain'               -Value $DomainFQDN
					$Object | Add-Member -MemberType NoteProperty -Name 'Name'                 -Value $siteLinkName
					$Object | Add-Member -MemberType NoteProperty -Name 'Description'          -Value $siteLinkDesc
					$Object | Add-Member -MemberType NoteProperty -Name 'Replication Interval' -Value $siteLinkRepl
					$Object | Add-Member -MemberType NoteProperty -Name 'Site'                 -Value $site
					$Object | Add-Member -MemberType NoteProperty -Name 'Site Count'           -Value $siteLinkCt
					$Object
				}
			} 
			Else 
			{
				Write-Debug "***Get-AdSiteLink: siteLinkName='$siteLinkName', siteName='<empty>'"

				$Object = New-Object -TypeName PSObject
				$Object | Add-Member -MemberType NoteProperty -Name 'Domain'               -Value $DomainFQDN
				$Object | Add-Member -MemberType NoteProperty -Name 'Name'                 -Value $siteLinkName
				$Object | Add-Member -MemberType NoteProperty -Name 'Description'          -Value $siteLinkDesc
				$Object | Add-Member -MemberType NoteProperty -Name 'Replication Interval' -Value $siteLinkRepl
				$Object | Add-Member -MemberType NoteProperty -Name 'Site'                 -Value ' '
				$Object | Add-Member -MemberType NoteProperty -Name 'Site Count'           -Value '0'
				$Object
			}
		}
	} 
	catch 
	{
	}
}

Function Get-ADSiteSubnet {
<#
Get Subnets for each Site
#>
	[CmdletBinding()]
	Param (
		[Parameter( Mandatory = $true, Position = 0, ValueFromPipeline = $true )]
		$Domain
	)

	$DomainName = $Domain.Name
	$DomainFQDN = $Domain.FQDN
	$searchRoot = "LDAP://CN=Subnets,CN=Sites,CN=Configuration,$DomainName"

	Write-Debug "***Enter Get-AdSiteSubnet DomainName='$DomainName', DomainFQDN='$DomainFQDN', searchRoot='$searchRoot'"

	$source             = New-Object System.DirectoryServices.DirectorySearcher
	$source.SearchRoot  = $searchRoot
	$source.SearchScope = 'Subtree'
	$source.PageSize    = 1000
	$source.Filter      = '(objectclass=subnet)'
	
	try 
	{
		$source.FindAll() | ForEach-Object {
			$subnetSite = ($_.Properties.Item( 'SiteObject' ) -split ',' -replace 'CN=','')[0]
			$subnetName = $_.Properties.Item( 'Name' )
			$subnetDesc = $_.Properties.Item( 'Description' )

			Write-Debug "***Get-AdSiteSubnet: site='$subnetSite', name='$subnetName', desc='$subnetDesc'"

			$Object = New-Object -TypeName PSObject
			$Object | Add-Member -MemberType NoteProperty -Name 'Domain'      -Value $DomainFQDN
			$Object | Add-Member -MemberType NoteProperty -Name 'Site'        -Value $subnetSite
			$Object | Add-Member -MemberType NoteProperty -Name 'Name'        -Value $subnetName
			$Object | Add-Member -MemberType NoteProperty -Name 'Description' -Value $subnetDesc
			$Object
		}
	} 
	catch 
	{
	}
}

Function Get-ADEmptyGroups {
<#
Get Empty Groups
#>
	[CmdletBinding()]
	Param (
		[Parameter( Mandatory = $true, Position = 0, ValueFromPipeline = $true )]
		$Domain
	)

	## $exclude includes (punny, aren't I?) the list of groups commonly used as a 
	## 'Primary Group' in Active Directory. While, theoretically, ANY group can be
	## a primary group, that is quite rare. 
	$exclude = 'Domain Users', 'Domain Computers', 'Domain Controllers', 'Domain Guests'
	
	$DomainName = $Domain.Name
	$DomainFQDN = $Domain.FQDN

	Write-Debug "***Enter Get-AdEmptyGroups DomainName='$DomainName', DomainFQDN='$DomainFQDN'"

	$source             = New-Object DirectoryServices.DirectorySearcher( "LDAP://$DomainName" )
	$source.SearchScope = 'Subtree'
	$source.PageSize    = 1000
	$source.Filter      = '(&(objectCategory=Group)(!member=*))'

	try 
	{
		$groups = $source.FindAll()
		$groups = (($groups | ? { $exclude -notcontains $_.Properties[ 'Name' ].Item( 0 ) } ) | % { $_.Properties[ 'Name' ].Item( 0 ) }) | sort
		ForEach( $group in $groups )
		{
			Write-Debug "***Get-AdEmptyGroups: DomainFQDN='$DomainFQDN', empty groupname='$group'"

			$Object = New-Object -TypeName PSObject
			$Object | Add-Member -MemberType NoteProperty -Name 'Domain' -Value $DomainFQDN
			$Object | Add-Member -MemberType NoteProperty -Name 'Name'   -Value $group
			$Object
		}
	}
	catch 
	{
	}
}

Function Get-ADDomainLocalGroups {
<#
Get AD Domain Local Groups
#>
	[CmdletBinding()]
	Param (
		[Parameter( Mandatory = $true, Position = 0, ValueFromPipeline = $true )]
		$Domain
	)

	$DomainName = $Domain.Name
	$DomainFQDN = $Domain.FQDN

	Write-Debug "***Enter Get-AdDomainLocalGroups DomainName='$DomainName', DomainFQDN='$DomainFQDN'"

	$search             = New-Object System.DirectoryServices.DirectorySearcher( "LDAP://$DomainName" )
	$search.SearchScope = 'Subtree'
	$search.PageSize    = 1000
	$search.Filter      = '(&(groupType:1.2.840.113556.1.4.803:=4)(!(groupType:1.2.840.113556.1.4.803:=1)))'
	
	try 
	{
		$search.FindAll() | ForEach-Object {
			$groupName = $_.Properties.Item( 'Name' )
			$groupDN   = $_.Properties.Item( 'Distinguishedname' )

			Write-Debug "***Get-AdDomainLocalGroups groupName='$groupName', dn='$groupDN'"

			$Object = New-Object -TypeName PSObject
			$Object | Add-Member -MemberType NoteProperty -Name 'Domain'            -Value $DomainFQDN
			$Object | Add-Member -MemberType NoteProperty -Name 'Name'              -Value $groupName
			$Object | Add-Member -MemberType NoteProperty -Name 'DistinguishedName' -Value $groupDN
			$Object
		}
	} 
	catch 
	{
	}
}

Function Get-ADUsersInDomainLocalGroups {
<#
Get Users in AD Local Groups
#>
	[CmdletBinding()]
	Param (
		[Parameter( Mandatory = $true, Position = 0, ValueFromPipeline = $true )]
		$Domain
	)

	$DomainName = $Domain.Name
	$DomainFQDN = $Domain.FQDN

	Write-Debug "***Enter Get-AdUsersInDomainLocalGroups DomainName='$DomainName', DomainFQDN='$DomainFQDN'"

	$search             = New-Object DirectoryServices.DirectorySearcher( "LDAP://$DomainName" )
	$search.SearchScope = 'Subtree'
	$search.PageSize    = 1000
	$search.Filter      = '(&(groupType:1.2.840.113556.1.4.803:=4)(!(groupType:1.2.840.113556.1.4.803:=1)))'
	
	try 
	{
		## $search was being used twice.
		$results = $search.FindAll() 
		$results | ForEach-Object {
			$groupName         = $_.Properties.Item( 'Name' )
			$DistinguishedName = $_.Properties.Item( 'DistinguishedName' )

			Write-Debug "***Get-AdUsersInDomainLocalGroups name='$groupName', dn='$distinguishedName'"

			$search.Filter = "(&(memberOf=$DistinguishedName)(objectclass=User))"
			$search.FindAll() | ForEach-Object {
				$userName = $_.Properties.Item( 'Name' )

				Write-Debug "***Get-AdUsersInDomainLocalGroups name='$groupName', user='$userName'" 

				$Object = New-Object -TypeName PSObject
				$Object | Add-Member -MemberType NoteProperty -Name 'Domain' -Value $DomainFQDN
				$Object | Add-Member -MemberType NoteProperty -Name 'Group'  -Value $groupName
				$Object | Add-Member -MemberType NoteProperty -Name 'Name'   -Value $userName
				$Object
			}
		}
	} 
	catch 
	{
	}
}


Function IsInDomain {
<#
Check if a Compute is in a domain
#>
	$computerSystem = Get-CimInstance Win32_ComputerSystem -ErrorAction SilentlyContinue -verbose:$False
	If( !$? -or $null -eq $computerSystem )
	{
		$computerSystem = Get-WmiObject Win32_ComputerSystem -ErrorAction SilentlyContinue
		If( !$? -or $null -eq $computerSystem )
		{
			Write-Error 'IsInDomain: fatal error: cannot obtain Win32_ComputerSystem from CIM or WMI.'
			AbortScript
		}
	}
	
	Return $computerSystem.PartOfDomain
}


$domains = get-ADDomains
$domain = $domains[0]
$domainFQDN = $domain.FQDN
$out = "ADHealth.txt"
"Active Directory Infomation for $domainFQDN" > $out
"-------------------------------------------" >> $out
"Forest Information" >> $out
get-forestInfo >>$out
"Domain Information" >> $out
get-domaininfo >> $out
"Domain Controllers" >> $out
"------------------" >> $out
get-alladdomaincontrollers $domain | fl >> $out
"AD Sites" >> $out
"--------" >> $out
get-adsites $domain >> $out
"Site Links" >> $out
"----------" >> $out
get-adsitelink $domain >> $out
"Site Subnets" >> $out
"------------" >> $out
get-adsitesubnet $domain >> $out
"===========Computer Information========" >> $out
"Servers" >> $out
"-------" >> $out
get-computernames s >> $out
"Workstations" >> $out
"------------" >> $out
get-computernames w >> $out
"===========User Information============" >> $out
"Privileged Group Members">> $out
Get-PrivilegedGroupsMemberCount $domain >> $out
$groups ="Domain Admins","Schema Admins","Enterprise Admins","Group Policy Creator Owners","Administrators","Account Operators","Server Operators","Print Operators","Backup Operators","Replicator","Network Configuration Operations","Incoming Forest Trust Builders","Event Log Readers","Hyper-V Administrators","Remote Management Users"
foreach($group in $groups) {
	$group >> $out
	"-------------" >> $out
	get-groupMembers $group >> $out
	"" >> $out
}
"Group Policy Inheritance Blocked" >> $out
"--------------------------------" >> $out
get-OuGpInheritanceBlocked $domain >> $out
"Domain Local Groups" >> $out
"-------------------" >> $out
Get-ADDomainLocalGroups $domain >> $out
"Domain Local Group Members" >> $out
"--------------------------" >> $out
get-adusersindomainlocalgroups $domain >> $out
"Users" >> $out
"-----" >> $out
get-users >> $out
