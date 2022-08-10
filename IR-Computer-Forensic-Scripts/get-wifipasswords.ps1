<#

.SYNOPSIS

Get Wifi Passwords for localhost

.DESCRIPTION

Get Wifi Passwords for localhost

.PARAMETER inFile

.OUTPUTS

Wifi SSID and Password

.EXAMPLE     
    .\get-wifipasswords

.NOTES
	
 Author: Tom Willett

#>
$profiles= (netsh wlan show profiles) | %{if ($_ -match 'User Profile\s*: (.*)') {$matches[1]}}
foreach ($profile in $profiles) {
    $p = netsh wlan show profiles name="$profile" key=clear
    $p | %{if ($_ -match 'Key Content\s*: (.*)') {($profile + ':' +$matches[1])}}
}