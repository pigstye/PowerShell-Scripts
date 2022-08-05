<#

.SYNOPSIS

Use Openssl to check ciphers of an email server

.DESCRIPTION

Use Openssl to check ciphers of an email server

.PARAMETER computername

Computer to check (required)

.OUTPUTS

List of Ciphers

.EXAMPLE     
    .\get-imapsecurity.ps1 mail.pigstye.net
	
.NOTES
	
 Author: Tom Willett
 Date: 4/7/2020

#>

param([parameter(Mandatory=$true)][string]$computername)

"Imap Security report for $computername"
"Checking SMTP with STARTTLS:"
C:\OpenSSL-Win32\bin\sslscan.exe --no-failed --starttls ($computername + ":25")
"Checking Client Submission SMTP with STARTLS:"
C:\OpenSSL-Win32\bin\sslscan.exe --no-failed --starttls ($computername + ":587")
"Checking Secure IMAP (explicit) on port 143:"
C:\OpenSSL-Win32\bin\openssl.exe s_client -connect ($computername + ":143") -starttls imap
"Checking Secure IMAP (implicit) on port 993:"
C:\OpenSSL-Win32\bin\openssl.exe s_client -connect ($computername + ":993")
"Checking Secure POP (explicit) on port 110:"
C:\OpenSSL-Win32\bin\openssl.exe s_client -connect ($computername + ":110") -starttls pop3
"Checking Secure POP (implicit) on port 995:"
C:\OpenSSL-Win32\bin\openssl.exe s_client -connect ($computername + ":995")

