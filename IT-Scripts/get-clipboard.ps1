<#

.SYNOPSIS

Get Clipboard contents

.DESCRIPTION

Get Clipboard contents

.OUTPUTS

clipboard contents

.EXAMPLE     
    .\get-clipboard.ps1

.NOTES
	
 Date: 4/7/2018

#>

function Get-Clipboard()
{
    Add-Type -AssemblyName System.Windows.Forms
    $tb = New-Object System.Windows.Forms.TextBox
    $tb.Multiline = $true
    $tb.Paste()
    $tb.Text
}

