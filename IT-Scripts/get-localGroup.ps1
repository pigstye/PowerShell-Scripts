<#

.SYNOPSIS

Uses LDAP to get local groups

.DESCRIPTION

Uses LDAP to get local groups

.OUTPUTS

GroupName, SID, Description, Guid and Path for each Local Group

.EXAMPLE     
    .\get-localGroup.ps1

.NOTES
	
 Author: Tom Willett

#>

Function Get-Localgroup  {
<#
#>
	[Cmdletbinding()]
	Param(
	[Parameter(ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
	[String[]]$Computername =  $Env:Computername
	)
	Begin {
		Function  ConvertTo-SID {
			Param([byte[]]$BinarySID)
			(New-Object  System.Security.Principal.SecurityIdentifier($BinarySID,0)).Value
		}
	}
	
	Process  {
		ForEach  ($Computer in  $Computername) {
			$adsi  = [ADSI]"WinNT://$Computername"
			$adsi.Children | where {$_.SchemaClassName -eq  'group'} |  ForEach {
				[pscustomobject]@{
					GroupName = $_.Name[0]
					SID = ConvertTo-SID -BinarySID $_.ObjectSID[0]
					Description = $_.Description
					GUID = $_.Guid
					Path = $_.Path
				}
			}
		}
	}
} 
