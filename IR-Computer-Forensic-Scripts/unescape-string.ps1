<#

.SYNOPSIS

Unescapes all escaped characters including unicode from a string

.DESCRIPTION

Unescapes all escaped characters including unicode from a string


.EXAMPLE

ps> $t | .\decode.ps1

Unescapes all escaped characters including unicode from a string $t

.EXAMPLE

ps> get-content file.txt | .\decode.ps1 | out-file -width 9999 decodedfile.txt

Unescapes all escaped characters including unicode from string's in file.txt and puts them in file decodedfile.txt

.NOTES

Author: Tom Willett 
Date: 7/13/2016

#>

Param([Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)][string]$uri)

process {
	[regex]::unescape($uri)
}