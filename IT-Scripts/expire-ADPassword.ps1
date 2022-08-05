<#

.SYNOPSIS

Expire a users password through ldap

.DESCRIPTION

This script expires a users password by setting the pwdLastSet to 0
Input is the AD user account

.NOTES

 Author: Tom Willett
 Date: 11/15/2013

#>

Param([Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)][string[]]$aduser)

process {
	$usr = get-aduser $aduser
	$ldapuser = $usr.distinguishedname
	# Bind to user object in AD.
	$ldapstring = "LDAP://$ldapuser"
	$User =  [ADSI]($ldapstring)
	# Expire password immediately.
	$User.pwdLastSet = 0
	# Save change in AD.
	$User.SetInfo()
}