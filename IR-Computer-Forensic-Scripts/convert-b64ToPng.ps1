<#

.SYNOPSIS

Convert base64 encoded png to png

.DESCRIPTION

Convert base64 encoded png to png

.PARAMETER File

Base64 encoded png

.OUTPUTS

Creates a png with the same basename as the input file with the .png extension

.EXAMPLE     
    .\convert-b64ToPng.ps1 file.b64

.NOTES
	
 Author: Tom Willett
 Date: 4/7/2020

#>
param([string]$file)
$ff = get-childitem $file
$out = $ff.directoryname + '\' + $ff.basename + '.png'
$b64 = get-content $ff
$bytes = [convert]::fromBase64string($b64)
[IO.File]::WriteAllBytes($out,$bytes)
