<#

.SYNOPSIS

Decodes a base64 encoded and gzipped string

.DESCRIPTION

Decodes a base64 encoded and gzipped string
Often PowerShell malware gzips the code and then base64 encodes the gzipped code.
This will decode the base64 and then ungzip it

.EXAMPLE

DecodeGzip.ps1 'b64string'

.NOTES

Author: Tom Willett 
Date: 4/10/2014

#>
param([string]$b64string)
Add-Type -assembly "System.IO.Compression"
$wor = [IO.MemoryStream][Convert]::FromBase64String($b64string)
$boo = New-Object System.IO.Compression.GzipStream($wor,[IO.Compression.CompressionMode]::Decompress)
$foo = New-Object IO.StreamReader($boo,[Text.Encoding]::ASCII)
write-host( $foo.ReadToEnd())

