<#

.SYNOPSIS

Decode a BigIPCookie

.DESCRIPTION

Decode a BigIPCookie.
F5 itself provides the formula. 

.Parameter cookie

The contents of the F5 Big IP Cookie to be decoded

.OUTPUTS

The IP and Port encoded in the cookie

.EXAMPLE

PS>.\decode-BigIPCookie.ps1 '375537930.544.0000'

.NOTES

 Author: Luke Brennan
 Date:  03/11/2012
 Ver 1.0

.LINK

https://blogs.technet.microsoft.com/lukeb/2012/11/03/powershell-decode-an-f5-big-ip-cookie/ 
http://support.f5.com/kb/en-us/solutions/public/6000/900/sol6917.html

#>

param([Parameter(Mandatory=$True)][string]$cookie)

function Decode-Cookie { 
<#

.SYNOPSIS

Decode a BigIPCookie

.DESCRIPTION

Decode a BigIPCookie.
F5 itself provides the formula. 

.Parameter cookie

The contents of the F5 Big IP Cookie to be decoded

.OUTPUTS

The IP and Port encoded in the cookie

.EXAMPLE

PS>.\decode-BigIPCookie.ps1 '375537930.544.0000'

.NOTES

 Author: Luke Brennan
 Date:  03/11/2012
 Ver 1.0

.LINK

https://blogs.technet.microsoft.com/lukeb/2012/11/03/powershell-decode-an-f5-big-ip-cookie/ 
http://support.f5.com/kb/en-us/solutions/public/6000/900/sol6917.html

#>
 param ([string] $ByteArrayCookie)

 if ($ByteArrayCookie -match '^(\d+)\.(\d+)\.0000$') {
   $ipEncoded   = [int64] $matches[1]
   $portEncoded = [int64] $matches[2]

   #  convert ipEnc to Hexadecimal
   $ipEncodedHex = "{0:X8}" -f $ipEncoded
   #  then split into an array of four 
   $ByteArray=@()
   $ipEncodedHex -split '([a-f0-9]{2})' | foreach {if ($_) {$ByteArray += $_.PadLeft(2,"0")}}
   #  now reverse the array (the byte order)
   $ReversedBytes = -join ($ByteArray[$($ByteArray.Length-1)..0])
   #  and convert each 1-byte hex back to decimal
   $ByteArray=@()
   $ReversedBytes -split '([a-f0-9]{2})' | foreach {if ($_) {$ByteArray += $_.PadLeft(2,"0")}}
   # seperated by "."'s.
   $IPstring=""
   $ByteArray | foreach { $IPstring += "$([convert]::ToByte($_,16))." }
   $IP = $IPstring.trimend(".")

   # convert $portEncoded to Hexadecimal
   $portEncodedHex = "{0:X4}" -f $portEncoded
   # reverse the order of the 2 bytes
   $ByteArray=@()
   $portEncodedHex -split '([a-f0-9]{2})' | foreach {if ($_) {$ByteArray += $_.PadLeft(2,"0")}}

   $ReversedBytes = -join ($ByteArray[$($ByteArray.Length-1)..0])
   # and convert to decimal
   $PORT=[convert]::ToUint64($ReversedBytes,16)

   write-output "$IP : $PORT"
 }
 else {
   write-output "cookie string format is invalid."
   write-output "usage:"
   write-output "  .\Decode-BigIPCookie '375537930.544.0000' "
 }
}

Decode-Cookie $cookie
