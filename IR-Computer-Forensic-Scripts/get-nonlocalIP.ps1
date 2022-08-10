<#

.SYNOPSIS

Looks through all csv and txt files in the current directory and all subdirectories for non-local IP addresses.

.DESCRIPTION

Looks through all csv and txt files in the current directory and all subdirectories for non-local IP addresses.
Excludes 127.0.0.0/8
10.0.0.0/8
172.16.0.0/12
192.168.0.0/16

.NOTES
	
 Author: Tom Willett
 Date: 8/10/2022
#>

get-childitem *.csv,*.txt -r |%{$out = $_.fullname + ': ' + (get-content $_ | select-string -allmatches '(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)' | sls -notmatch '10\.\d{1,3}\.\d{1,3}\.\d{1,3}|192\.168\.\d{1,3}\.\d{1,3}|172\.1[6-9]\.\d{1,3}\.\d{1,3}|172\.2[0-9]\.\d{1,3}\.\d{1,3}|172\.3[0-1]\.\d{1,3}\.\d{1,3}|127\.\d{1,3}\.\d{1,3}\.\d{1,3}').matches.groups.captures[0].value; $out} | select -unique
