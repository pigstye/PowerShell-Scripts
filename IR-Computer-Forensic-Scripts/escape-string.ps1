<#

.SYNOPSIS

Escapes a minimal set of characters (\, *, +, ?, |, {, [, (,), ^, $,., #, and white space) by replacing them with their escape codes.

.DESCRIPTION

Escapes a minimal set of characters (\, *, +, ?, |, {, [, (,), ^, $,., #, and white space) by replacing them with their escape codes.


.EXAMPLE

ps> $t | .\escape-string.ps1

Escapes the characters from a string $t

.EXAMPLE

ps> get-content file.txt | .\escape-string.ps1 | add-content decodedfile.txt

Escapes the characters from string's in file.txt and puts them in file decodedfile.txt

.NOTES

Author: Tom Willett 
Date: 7/13/2016

#>

Param([Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)][string]$uri)

process {
	[regex]::escape($uri)
}