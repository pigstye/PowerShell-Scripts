<#

.SYNOPSIS

Convert an Excel file to csv

.DESCRIPTION

Convert an Excel file to csv - this does require Excel be installed on system

.PARAMETER File

The file to convert (required)

.OUTPUTS

A csv file or files for each sheet named after the original file

.EXAMPLE     
    .\excel-to-csv.ps1 test.xlsx

.NOTES
	
 Author: Tom Willett
 Date: 4/7/2020

#>
Function ExcelCSV ($File)
{
 
	$f = get-childitem $File
    $excelFile = $f.fullname
    $Excel = New-Object -ComObject Excel.Application
    $Excel.Visible = $false
    $Excel.DisplayAlerts = $false
    $wb = $Excel.Workbooks.Open($excelFile)
    foreach ($ws in $wb.Worksheets)
    {
        $ws.SaveAs($F.directoryname + '\' + $f.basename + ".csv", 6)
    }
    $Excel.Quit()
}
