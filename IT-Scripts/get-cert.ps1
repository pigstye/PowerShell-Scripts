<#

.SYNOPSIS

Get Certificate Information from a website

.DESCRIPTION

Get Certificate Information from a website

.OUTPUTS

Basic Certificate Information

.EXAMPLE     
    .\get-cert.ps1 www.pigstye.net

.NOTES
	
 Author: Tom Willett
 Date: 4/7/2020

#>
param([parameter(Mandatory=$true)][string]$computername) 

$ErrorActionPreference = "SilentlyContinue"
$website = $computername -replace "http://", ""
$website = $website -replace "https://", ""
$site = $website
$port = [int]443
$tcpsocket = New-Object Net.Sockets.TcpClient($site, $port) 
if($tcpsocket)
{
	#Set it up for bad certs
add-type @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class TrustAllCertsPolicy : ICertificatePolicy {
public bool CheckValidationResult(
	ServicePoint srvPoint, X509Certificate certificate,
	WebRequest request, int certificateProblem) {
	return true;
}
}
"@
	[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
	#Socket Got connected get the tcp stream ready to read the certificate
	$tcpstream = $tcpsocket.GetStream()
	#Create an SSL Connection 
	$sslStream = New-Object System.Net.Security.SslStream($tcpstream,$false)
	#Force the SSL Connection to send us the certificate
	$sslStream.AuthenticateAsClient($site) 
	#Read the certificate
	$certinfo = New-Object system.security.cryptography.x509certificates.x509certificate2($sslStream.RemoteCertificate)
	$certOK = test-certificate $certinfo
} 
$hostinfo = [System.Net.Dns]::GetHostEntry($site)
$website = "https://" + $website
[Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}
$timeoutMilliseconds = 10000
$req = [Net.HttpWebRequest]::Create($website)
$req.Timeout = $timeoutMilliseconds
$req.UserAgent="Mozilla/5.0 (compatible; MSIE 10.0; Windows NT 6.1; Trident/6.0)"
$res = $req.GetResponse()
if ($req) {
	[datetime]$expiration = $req.ServicePoint.Certificate.GetExpirationDateString()
	$certName = $req.ServicePoint.Certificate.GetName()
	$certPublicKeyString = $req.ServicePoint.Certificate.GetPublicKeyString()
	$certSerialNumber = $req.ServicePoint.Certificate.GetSerialNumberString()
	$certEffectiveDate = $req.ServicePoint.Certificate.GetEffectiveDateString()
	$certIssuer = $req.ServicePoint.Certificate.GetIssuerName()
	$certHash = $req.ServicePoint.Certificate.GetCertHash()
	$certHashString = $req.ServicePoint.Certificate.GetCertHashString()
	$certFormat = $req.ServicePoint.Certificate.GetFormat()
	$certHashCode = $req.ServicePoint.Certificate.getHashCode()
	$certKeyAlgoritym = $req.ServicePoint.Certificate.GetKeyAlgorithm()
	$certSubject = $req.ServicePoint.Certificate.Subject
	write-output 'HostName:'
	write-output $site
	write-output 'IP List:'
	foreach($i in $hostinfo.addresslist) { write-output $i.tostring()}
	write-output "-------------------------------------------"
	write-output "Certificate Information:"
	write-output "-------------------------------------------"
	if ($certOK) {
		write-output 'Certificate Chain is valid'
	} else {
		write-output 'Certificate Chain is invalid.'
	}
	write-output "Certificate valid from: $certEffectiveDate"
	write-output "Certificate expires: $expiration"
	write-output "Issuer: $certIssuer"
	write-output "Subject $certSubject"
} else {
	write-output "Unable to connect to host."
}