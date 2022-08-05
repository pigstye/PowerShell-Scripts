<#

.SYNOPSIS

Library of text file handling routines using dot net routines for speed.

.DESCRIPTION

Library of file handling routines using dot net routines for speed.
out-UTF8 -- outputs file in UTF8 no BOM -- always appends.
append-file -- appends one file to another
split-file -- splits a file by line into smaller sizes
count-lines -- counts the lines in a file
sort-file -- sort the lines in a file
unique-file -- remove duplicates from a file 
sortunique-file -- sort and remove duplicate lines from a file 
get-fileEncoding -- reads the bom of a file to get the encoding

.NOTES
	
 Author: Tom Willett
 Date: 7/25/2016

#>

# Global variables
#desired size of split file - this reads by line so it might be a little larger.
$splitSize = 500000000


function out-utf8 {
<#

.SYNOPSIS

Output to a file utf8 no bom

.DESCRIPTION

This uses the dot net file writing routines to write the file utf8 no bom always append

.PARAMETER outFile

The file to which the data will be appended

.EXAMPLE     
    type text.txt | out-utf8 c:\example.txt
	takes the text from text.txt and writes it to example.txt encoded utf8 no bom

.NOTES
	
 Author: Tom Willett
 Date: 7/22/2016

#>

Param([Parameter(Mandatory=$True,ValueFromPipeline=$False,ValueFromPipelinebyPropertyName=$False,Position=0)][string]$outFile,
  [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)][AllowEmptyString()][string]$stuff,
  [switch]$append, [switch]$lf)
begin {
	[Environment]::CurrentDirectory = $pwd.path -replace 'Microsoft\.PowerShell\.Core\\FileSystem::',''
	$outFile = [IO.Path]::GetFullPath($outFile)
	if ($append) {
		$mode = [System.IO.FileMode]::Append
	} else {
		$mode = [System.IO.FileMode]::Create
	}
	$access = [System.IO.FileAccess]::Write
	$sharing = [IO.FileShare]::Read
	$fs = New-Object System.IO.FileStream($outFile, $mode, $access, $sharing)
	$streamOut = new-object System.IO.StreamWriter($fs) 
	if ($lf) {
		$streamOut.newline = "`n"
	}
}
process
{
	$streamOut.WriteLine($stuff)
}

end {
	$streamOut.Close()
}
}

function append-file {
<#

.SYNOPSIS

Join two files

.DESCRIPTION

Append inFile to outFile

.PARAMETER inFile

The file to appended (required)

.PARAMETER outFile

The file to which inFile will be appended

.EXAMPLE     
    .\append-file.ps1 c:\example1.txt c:\example2.txt
	Appends example1.txt to example2.txt

.NOTES
	
 Author: Tom Willett
 Date: 7/21/2016

#>

Param([Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)][string]$inFile,
  [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)][string]$outFile)
process {
$inFile = (dir $inFile).fullname
$outFile = (dir $outFile).fullname
$streamIn = new-object System.IO.StreamReader($inFile)
$mode = [System.IO.FileMode]::Append
$access = [System.IO.FileAccess]::Write
$sharing = [IO.FileShare]::Read
$fs = New-Object System.IO.FileStream($outFile, $mode, $access, $sharing)
$streamOut = new-object System.IO.StreamWriter($fs) 
write-host "Appending $infile to $outfile"
while($streamIn.peek() -ge 0)
{
	$line = $streamIn.ReadLine()
	$streamOut.WriteLine($line)
}

$streamIn.Close()
$streamOut.Close()
}
}

function count-lines {
<#

.SYNOPSIS

Count the lines in a file

.DESCRIPTION

Count the lines in a file

.PARAMETER inFile

The file to count(required)


.EXAMPLE     
    .\count-lines.ps1 c:\example.txt 
	Counts the lines in example.txt

.NOTES
	
 Author: Tom Willett
 Date: 7/22/2016

#>

Param([Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)][string]$inFile)
$inFile = (dir $inFile).fullname
$streamIn = new-object System.IO.StreamReader($inFile)
$lines = 0
while($streamIn.peek() -ge 0)
{
	$line = $streamIn.ReadLine()
	$lines += 1
}
$lines
$streamIn.Close()
}

function split-file {
<#

.SYNOPSIS

Split a file into smaller sized files

.DESCRIPTION

Split a file. This uses the .net file routines.  By default it splits it into 200mb chuncks.  You can change the size by altering the $bufSize variable.
The parts are named by adding 1 2 3 etc to the file name.

.PARAMETER inFile

The file to split (required)

.EXAMPLE     
    .\split.ps1 c:\image.mem
    Splits c:\image.mem into 200MB chuncks c:\image1.mem, c:\image2.mem, c:\image3.mem

.NOTES
	
 Author: Tom Willett
 Date: 7/21/2016

#>

Param([Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)][string]$inFile)
$inFile = (dir $inFile).fullname
$streamIn = new-object System.IO.StreamReader($inFile)
$basename = $inFile.substring(0,$inFile.lastindexof("."))
$ext = $inFile.substring($inFile.lastindexof("."))
#desired size of split file - this reads by line so it might be a little larger.
#$splitSize = 900000000
$cnt = 0
$chk = 1
write-host "Splitting $inFile into chunks of size $splitSize"
while($streamIn.peek() -ge 0)
{
	$line = $streamIn.ReadLine()
	if ($cnt -le 0) {
		$t = 0
		$cnt = $splitSize
		$outFile = "$basename$chk$ext"
		$streamOut = new-object System.IO.StreamWriter($outFile)
	}
	$streamOut.WriteLine($line)
	$cnt -= ($line.length + 2)
	$t += 1
	if ($cnt -le 0) {
		$streamOut.Close()
		$chk += 1
		write-host "Wrote $outFile - $t lines"
	}
}

$streamIn.Close()
$streamOut.Close()
write-host "Wrote $outFile"
}

function sortunique-file {
<#

.SYNOPSIS

Sort a file and remove duplicates from it.

.DESCRIPTION

Sort a file and remove duplicates from it.
This uses the dot net routines to drastically speed up the process

.PARAMETER inFile

The input file name.

.PARAMETER outFile

The file to create with sorted and de duped content.

.EXAMPLE     
    .\sortUnique-file.ps1 bigfile.txt bigfilesorted.txt
    Sorts and de dups bigfile.txt and puts the result in bigfilesorted.txt

.NOTES
	
 Author: Tom Willett
 Date: 7/25/2016

#>

Param([Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)][string]$inFile,
  [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)][string]$outFile)

$inFile = (dir $inFile).fullname
[Environment]::CurrentDirectory = $pwd.path -replace 'Microsoft\.PowerShell\.Core\\FileSystem::',''
$outFile = [IO.Path]::GetFullPath($outFile)

#read it into list and sort
$ls = new-object system.collections.generic.List[string]
$reader = [System.IO.File]::OpenText($inFile)
try {
    while ($reader.peek() -ge 0)
    {
		$line = $reader.ReadLine()
        $t = $ls.Add($line)
    }
}
finally {
    $reader.Close()
}
write-host 'Read file into memory'
$ls.Sort();
write-host 'Sorted file'
#Convert to hash to make unique
$hs = new-object System.Collections.Generic.HashSet[string]$ls
write-host 'Duplicates removed'
try
{
    $f = New-Object System.IO.StreamWriter $outFile;
    foreach ($s in $hs)
    {
        $f.WriteLine($s);
    }
}
finally
{
    $f.Close();
}
[GC]::Collect()
}

function unique-file {
<#

.SYNOPSIS

Removes duplicates from a file.

.DESCRIPTION

Removes duplicates from a file.
This uses the hashset dot net routines to drastically speed up the process
Maximun size of a hashset is 47,995,853 items

.PARAMETER inFile

The input file name.

.PARAMETER outFile

The file to create with de duped content.

.EXAMPLE     
    .\Unique-file.ps1 bigfile.txt bigfilesorted.txt
    De dups bigfile.txt and puts the result in bigfilesorted.txt

.NOTES
	
 Author: Tom Willett
 Date: 7/25/2016

#>

Param([Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)][string]$inFile,
  [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)][string]$outFile)

#Read file into hash to make unique
$inFile = (dir $inFile).fullname
[Environment]::CurrentDirectory = $pwd.path -replace 'Microsoft\.PowerShell\.Core\\FileSystem::',''
$outFile = [IO.Path]::GetFullPath($outFile)
write-host "Reading File $infile and deduping it."
$hs = new-object System.Collections.Generic.HashSet[string]
$reader = [System.IO.File]::OpenText($inFile)
$t = 0
try {
    while ($reader.peek() -ge 0)
    {
		$line = $reader.ReadLine()
        $t1 = $hs.Add($line)
		$t += 1
		if (($t % 1000000) -eq 0) {
			write-host "$t items"
		}
    }
}
finally {
    $reader.Close()
}
write-host "Writing deduped file $outFile - $t items"
try
{
    $f = New-Object System.IO.StreamWriter $outFile;
    foreach ($s in $hs)
    {
        $f.WriteLine($s);
    }
}
finally
{
    $f.Close();
}
[GC]::Collect()
}

function sort-file {
<#

.SYNOPSIS

Removes duplicates from a file.

.DESCRIPTION

Removes duplicates from a file.
This uses the dot net routines to drastically speed up the process
Limited to 2,146,435,071 items to sort at once with memory limitations.
On a 32GB machine the limit is about 5,000,000,000 -- each time the array 
is expanded the allocation is twice the array size.

.PARAMETER inFile

The input file name.

.PARAMETER outFile

The file to create with de duped content.

.EXAMPLE     
    .\Unique-file.ps1 bigfile.txt bigfilesorted.txt
    De dups bigfile.txt and puts the result in bigfilesorted.txt

.NOTES
	
 Author: Tom Willett
 Date: 7/25/2016

#>
 
Param([Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)][string]$inFile,
  [Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)][string]$outFile)

#Read file into list and sort
$inFile = (dir $inFile).fullname
[Environment]::CurrentDirectory = $pwd.path -replace 'Microsoft\.PowerShell\.Core\\FileSystem::',''
$outFile = [IO.Path]::GetFullPath($outFile)
write-host "Reading file $inFile"
$ls = new-object system.collections.generic.List[string]
$reader = [System.IO.File]::OpenText($inFile)
$t = 0
try {
    while ($reader.peek() -ge 0)
    {
		$line = $reader.ReadLine()
        $t1 = $ls.Add($line)
		$t += 1
		if (($t % 1000000) -eq 0) {
			write-host "$t items"
		}
    }
}
finally {
    $reader.Close()
}
write-host "Sorting File $t items"
$ls.Sort();
write-host "Writing file $outFile"
try
{
    $f = New-Object System.IO.StreamWriter $outFile;
    foreach ($s in $ls)
    {
        $f.WriteLine($s);
    }
}
finally
{
    $f.Close();
}

}

function Get-FileEncoding {
<#
.SYNOPSIS
Gets file encoding.
.DESCRIPTION
The Get-FileEncoding function determines encoding by looking at Byte Order Mark (BOM).
.EXAMPLE
Get-ChildItem  *.ps1 | select FullName, @{n='Encoding';e={Get-FileEncoding $_.FullName}} | where {$_.Encoding -ne 'ASCII'}
This command gets ps1 files in current directory where encoding is not ASCII
.EXAMPLE
Get-ChildItem  *.ps1 | select FullName, @{n='Encoding';e={Get-FileEncoding $_.FullName}} | where {$_.Encoding -ne 'ASCII'} | foreach {(get-content $_.FullName) | set-content $_.FullName -Encoding ASCII}
Same as previous example but fixes encoding using set-content
#>
	[CmdletBinding()] Param (
	[Parameter(Mandatory = $True, ValueFromPipelineByPropertyName = $True)] [string]$Path
	)

	[byte[]]$byte = get-content -Encoding byte -ReadCount 4 -TotalCount 4 -Path $Path
	
	if ( $byte[0] -eq 0xef -and $byte[1] -eq 0xbb -and $byte[2] -eq 0xbf )
	{ Write-Output 'UTF8' }
	elseif ($byte[0] -eq 0xfe -and $byte[1] -eq 0xff)
	{ Write-Output 'UTF16 - little endian - UCS-2 LE BOM' }
	elseif ($byte[0] -eq 0xff -and $byte[1] -eq 0xfe)
	{ Write-Output 'UTF-16 - big endian (UCS-2 BE BOM)' }
	elseif ($byte[0] -eq 0 -and $byte[1] -eq 0 -and $byte[2] -eq 0xfe -and $byte[3] -eq 0xff)
	{ Write-Output 'UTF32 - big endian' }
	elseif ($byte[0] -eq 0xfe -and $byte[1] -eq 0xff -and $byte[2] -eq 0 -and $byte[3] -eq 0)
	{ Write-Output 'UTF32 - little endian' }
	elseif ($byte[0] -eq 0x2b -and $byte[1] -eq 0x2f -and $byte[2] -eq 0x76)
	{ Write-Output 'UTF7'}
	else
	{ Write-Output 'ASCII' }
}
