<#

.SYNOPSIS

Convert all archives in current directory to zips

.DESCRIPTION

Convert all archives in current directory to zips: 7z, gz, tgz, rar, tar

.OUTPUTS

All archives converted to .zip format

.EXAMPLE     
    .\convert-Archivetozip.ps1

.NOTES
	
 Author: Tom Willett
 Date: 4/7/2020

#>
$ds = dir *.7z
$ds += dir *.gz
$ds += dir *.tgz
$ds += dir *.rar
$ds += dir *.tar
if (-not (test-path 'temp')) {
    mkdir 'temp'
}
$tmp = dir 'temp*'
foreach ($d in $ds) {
    cp $d $tmp
    cd $tmp
    if (dir *.tar) {
        $dts = dir *.tar
        foreach ($dt in $dts) {
            7z x $dt *
        }
    }
    7z x $d.name *
    rm $d.name
    $zipname = $d.basename + '.zip'
    7z a $zipname *
    "copying $zipname"
    cp $zipname ..
    rm *
    cd ..
}