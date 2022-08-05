<#

.SYNOPSIS

Rename the Local Admin and Guest accounts and disable the Guest account.

.DESCRIPTION

Rename the Local Admin and Guest accounts and disable the Guest account.

.EXAMPLE

ps> .\rename-localadmin.ps1  servername

Rename the Local Admin and Guest accounts and disable the Guest account on one server

.EXAMPLE

type names.txt | .\rename-localadmin.ps1

Rename the Local Admin and Guest accounts and disable the Guest account on multiple servers listed in names.txt (one server per line)

.NOTES

Author: Tom Willett 
Date: 9/22/2014

#>

Param([Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)][string]$computername)

begin {
	$adminAcct = "jbrown"
	$guestAcct = 'afranklin'
	$out = ""
}
process { 
	$temp = "" | Select Computer, Admin, Guest
	$temp.computer = $computername
	$temp.Admin = $True
	$temp.Guest = $True
	$error.clear()
	$Admin=[adsi]("WinNT://" + $_ + "/Administrator, user")                
	$Admin.PSBase.invokeset("AccountDisabled", $False)
	$Admin.setinfo()
	$Admin.PSBase.rename($adminAcct)
	$Admin.setinfo()
	if ($error) { $temp.Admin = $False }
	$error.clear()
	$Admin=[adsi]("WinNT://" + $_ + "/Guest, user")                
	$Admin.PSBase.invokeset("AccountDisabled", $True)
	$Admin.setinfo()
	$Admin.PSBase.rename($guestAcct)
	$Admin.setinfo()
	if ($error) { $temp.Guest = $False }
}

end {
	$out
}
