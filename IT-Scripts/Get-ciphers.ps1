<#

.SYNOPSIS

Download the SSL Cipher Registry Entries for a Server

.DESCRIPTION

Download the SSL Cipher Registry Entries for a Server - this is intended to work on a local network.
Elevated permissions are required

.PARAMETER Server

Server to query (required)

.OUTPUTS

Lists the Registry Entries for Ciphers

.EXAMPLE     
    .\get-ciphers piglet

.NOTES
	
 Author: Tom Willett

#>
Param([Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)][string]$server)

Function GetPKICipherReg {
<#
Gather Cipher Information from a Server
#>     
	Param([Parameter(Mandatory=$True,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True)][string]$server)

	$InformationCollected = ""
	$OSVersion = Get-WmiObject -Class Win32_OperatingSystem
    $ReturnValues = new-object PSObject 
    $Time = Get-Date 
    #Do Registry data collection. 
 
    #Ciphers 
	$RC4128128Reg = reg query "\\$server\HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 128/128"
	$AES128128Reg = reg query "\\$server\HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\AES 128/128" 
	$AES256256Reg = reg query "\\$server\HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\AES 256/256" 
	$TripleDES168Reg = reg query "\\$server\HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\Triple DES 168/168"
	$RC456128Reg = reg query "\\$server\HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 56/128"
	$DES5656Reg = reg query "\\$server\HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\DES 56/56"
	$RC440128Reg = reg query "\\$server\HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC4 40/128" 
	$AES128Reg = reg query "\\$server\HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\AES 128"
	$AES256Reg = reg query "\\$server\HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\AES 256" 
	$DES56Reg = reg query "\\$server\HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\DES 56"
	$NULLReg = reg query "\\$server\HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\NULL"
	$NCRYPTSChannelReg = reg query "\\$server\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Cryptography\Configuration\Local\SSL\00010002"
	$NCRYPTSChannelSigReg = reg query "\\$server\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Cryptography\Configuration\Local\SSL\00010003"
    #items below are problematic if enabled or disabled. 
	$RC240128Reg = reg query "\\$server\HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC2 40/128"
	$RC2128128Reg = reg query "\\$server\HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\RC2 128/128" 
 
    #hashes 
	$MD5HashReg = reg query "\\$server\HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Hashes\MD5"
	$SHAHashReg = reg query "\\$server\HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Hashes\SHA" 
 
    #Disabling RSA use in KeyExchange PKCS  
	$PKCSKeyXReg = reg query "\\$server\HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\KeyExchangeAlgorithms\PKCS"
 
    #SSL 
	$PCT1ClientReg = reg query "\\$server\HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\PCT 1.0\Client" 
	$PCT1ServerReg = reg query "\\$server\HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\PCT 1.0\Server" 
	$SSL2ClientReg = reg query "\\$server\HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Client" 
	$SSL2ServerReg = reg query "\\$server\HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Server" 
	$SSL3ClientReg = reg query "\\$server\HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Client" 
	$SSL3ServerReg = reg query "\\$server\HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Server" 
 
	$TLS1ClientReg = reg query "\\$server\HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Client" 
	$TLS1ServerReg = reg query "\\$server\HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server" 
 
	$TLS11ClientReg = reg query "\\$server\HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client" 
	$TLS11ServerReg = reg query "\\$server\HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server" 
 
	$TLS12ClientReg = reg query "\\$server\HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client" 
	$TLS12ServerReg = reg query "\\$server\HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server" 
 
 
#problem condition equals <regvalname>.enabled -eq 0 
 
    #Begin adding data to PSObject. 
    $InformationCollected = "Time" + ": " + $Time + '<br/>'
    #If registry values below are populated with specific values then alert the engineer and customer since this will effect SSL/TLS and perhaps other cipher uses. 
 
    if (($FIPSReg.Enabled -ne $null) -or ($PCT1ClientReg.Enabled -eq 0 ) -or ($PCT1ServerReg.Enabled -eq 0 ) -or ($SSL2ClientReg.Enabled -eq 0) -or ($SSL2ServerReg.Enabled -eq 0) -or ($SSL3ClientReg.Enabled -eq 0) -or ($SSL3ClientReg.Enabled -eq 0) -or ($SSL3ServerReg.Enabled -eq 0) -or ($MD5HashReg.Enabled -eq 0) -or ($SHAHashReg.Enabled -eq 0) -or ($PKCSKeyXReg.Enabled -eq 0) -or ($RC4128128Reg.Enabled -eq 0) -or ($AES128128Reg.Enabled -eq 0) -or ($AES256256Reg.Enabled -eq 0) -or ($TripleDES168Reg.Enabled -eq 0) -or ($RC456128Reg.Enabled -eq 0) -or ($DES5656Reg.Enabled -eq 0) -or ($RC440128Reg.Enabled -eq 0) -or ($AES128Reg.Enabled -eq 0) -or ($AES256Reg.Enabled -eq 0) -or ($NULLReg.Enabled -eq 0) -or ($RC240128Reg.Enabled -ne $null) -or ($DES56Reg.Enabled -eq 0) -or ($RC2128128Reg.Enabled -ne $null) ) 
        {$InformationCollected += "Customized Settings" + ": " + $true + '<br/>'} 
	else 
		{$InformationCollected +="Customized Settings" + ": " + $false + '<br/>'} 
     
    $InformationCollected +="SSL Certificate Etypes Allowed" + ": " + $NCRYPTSChannelReg.Functions  + '<br/>'
    $InformationCollected +="SSL Certificate Signature Etypes Allowed" + ": " + $NCRYPTSChannelSigReg.Functions + '<br/>' 
    
	if ($OSVersion.BuildNumber -eq 3790) 
    { 
		if (($PCT1ClientReg.Enabled -eq 1) -or ($PCT1ClientReg.Enabled -eq $null)) 
			{$InformationCollected +="PCT1 Client Setting" + ": " + "Enabled (default)" + '<br/>'} 
		else 
			{$InformationCollected +="PCT1 Client Setting" + ": " + "Disabled (NOT default)" + '<br/>'} 
		if (($PCT1ServerReg.Enabled -eq 1) -or ($PCT1ServerReg.Enabled -eq $null)) 
			{$InformationCollected +="PCT1 Server Setting" + ": " + "Enabled (default)" +'<br/>'} 
		else 
			{$InformationCollected +="PCT1 Server Setting" + ": " + "Disabled (NOT default)" + '<br/>'} 
    } 
 
    if ($OSVersion.BuildNumber -ge 3790) 
    { 
		if (($PCT1ClientReg.Enabled -eq 0) -or ($PCT1ClientReg.Enabled -eq $null)) 
			{$InformationCollected +="PCT1 Client Setting" + ": " + "Disabled (default)" + '<br/>'} 
		else 
			{$InformationCollected +="PCT1 Client Setting" + ": " + "Enabled (NOT default)" + '<br/>'} 
		if (($PCT1ServerReg.Enabled -eq 0) -or ($PCT1ServerReg.Enabled -eq $null)) 
			{$InformationCollected +="PCT1 Server Setting" + ": " + "Disabled (default)" + '<br/>'} 
		else 
			{$InformationCollected +="PCT1 Server Setting" + ": " + "Enabled (NOT default)" + '<br/>'} 
    } 
 
    if (($SSL2ClientReg.Enabled -eq 1) -or ($SSL2ClientReg.Enabled -eq $null)) 
        {$InformationCollected +="SSL2 Client Setting" + ": " + "Enabled (default)" + '<br/>'} 
	else 
		{$InformationCollected +="SSL2 Client Setting" + ": " + "Disabled (NOT default)" + '<br/>'} 
    
	if (($SSL2ServerReg.Enabled -eq 1) -or ($SSL2ServerReg.Enabled -eq $null)) 
        {$InformationCollected +="SSL2 Server Setting" + ": " + "Enabled (default)" + '<br/>'} 
	else 
		{$InformationCollected +="SSL2 Server Setting" + ": " + "Disabled (NOT default)" + '<br/>'} 
	
	if (($SSL3ClientReg.Enabled -eq 1) -or ($SSL3ClientReg.Enabled -eq $null))     
         {$InformationCollected +="SSL3 Client Setting" + ": " + "Enabled (default)" + '<br/>'} 
	else 
		 {$InformationCollected +="SSL3 Client Setting" + ": " + "Disabled (NOT default) for POODLE" + '<br/>'} 
    
	if (($SSL3ServerReg.Enabled -eq 1) -or ($SSL3ServerReg.Enabled -eq $null))     
        {$InformationCollected +="SSL3 Server Setting" + ": " + "Enabled (default) - POODLE still possible" + '<br/>'} 
	else 
        {$InformationCollected +="SSL3 Server Setting" + ": " + "Disabled (NOT Default) for POODLE" + '<br/>'} 
      
    if (($TLS1ClientReg.Enabled -eq 1) -or ($TLS1ClientReg.Enabled -eq $null))     
         {$InformationCollected +="TLS 1.0 Client Setting" + ": " + "Enabled (default)" + '<br/>'} 
	else 
		 {$InformationCollected +="TLS 1.0 Client Setting" + ": " + "Disabled (NOT default)" + '<br/>'} 
    
	if (($TLS1ServerReg.Enabled -eq 1) -or ($TLS1ServerReg.Enabled -eq $null))     
        {$InformationCollected +="TLS 1.0 Server Setting" + ": " + "Enabled (default)" + '<br/>'} 
	else 
        {$InformationCollected +="TLS 1.0 Server Setting" + ": " + "Disabled (NOT Default)" + '<br/>'} 
      
    if (($TLS11ClientReg.Enabled -eq 1) -or ($TLS11ClientReg.Enabled -eq $null))     
         {$InformationCollected +="TLS 1.1 Client Setting" + ": " + "Enabled (default)" + '<br/>'} 
	else 
		 {$InformationCollected +="TLS 1.1 Client Setting" + ": " + "Disabled (NOT default)" + '<br/>'} 
    
	if (($TLS11ServerReg.Enabled -eq 1) -or ($TLS11ServerReg.Enabled -eq $null))     
        {$InformationCollected +="TLS 1.1 Server Setting" + ": " + "Enabled (default)" + '<br/>'} 
	else 
        {$InformationCollected +="TLS 1.1 Server Setting" + ": " + "Disabled (NOT Default)" + '<br/>'} 
      
    if (($TLS12ClientReg.Enabled -eq 1) -or ($TLS12ClientReg.Enabled -eq $null))     
         {$InformationCollected +="TLS 1.2 Client Setting" + ": " + "Enabled (default)" + '<br/>'} 
	else 
		 {$InformationCollected +="TLS 1.2 Client Setting" + ": " + "Disabled (NOT default)" + '<br/>'} 
    
	if (($TLS12ServerReg.Enabled -eq 1) -or ($TLS12ServerReg.Enabled -eq $null))     
        {$InformationCollected +="TLS 1.2 Server Setting" + ": " + "Enabled (default)" + '<br/>'} 
	else 
        {$InformationCollected +="TLS 1.2 Server Setting" + ": " + "Disabled (NOT Default)" + '<br/>'} 
    
	if ($FIPSReg.Enabled -eq 1)     
        {$InformationCollected +="FIPS Setting" + ": " + "Enabled (default)" + '<br/>'} 
	else 
		 {$InformationCollected +="FIPS Setting" + ": " + "Not Enabled (default)" + '<br/>'} 
    
	if (($RC4128128Reg.Enabled -eq 1) -or ($RC4128128Reg.Enabled -eq $null))     
        {$InformationCollected +="Cipher Setting: RC4 128/128 " + ": " + "Enabled (default)" + '<br/>'} 
	else 
		{$InformationCollected +="Cipher Setting: RC4 128/128 " + ": " + "Disabled (NOT default)" + '<br/>'} 
 
    if (($RC456128Reg.Enabled -eq 1) -or ($RC456128Reg.Enabled -eq $null))         
		{$InformationCollected +="Cipher Setting: RC4 56/128" + ": " + "Enabled (default)" + '<br/>'} 
	else 
		{$InformationCollected +="Cipher Setting: RC4 56/128" + ": " + "Disabled (NOT default)" + '<br/>'} 
 
    if (($RC440128Reg.Enabled -eq 1) -or ($RC440128Reg.Enabled -eq $null))         
        {$InformationCollected +="Cipher Setting: RC4 40/128" + ": " + "Enabled (default)" + '<br/>'} 
	else 
		{$InformationCollected +="Cipher Setting: RC4 40/128" + ": " + "Disabled (NOT default)" + '<br/>'} 
     
    if ($OSVersion.BuildNumber -ge 6002) 
    { 
        if (($DES56Reg.Enabled -eq 1) -or ($DES56Reg.Enabled -eq $null))         
			{$InformationCollected +="Cipher Setting: DES 56" + ": " + "Enabled (default)" + '<br/>'} 
		else 
            {$InformationCollected +="Cipher Setting: DES 56" + ": " + "Disabled (NOT default)" + '<br/>'} 
        
		if (($TripleDES168Reg.Enabled -eq 1) -or ($TripleDES168Reg.Enabled -eq $null))     
            {$InformationCollected +="Cipher Setting: Triple DES 168" + ": " + "Enabled (default)" + '<br/>'} 
		else 
            {$InformationCollected +="Cipher Setting: Triple DES 168" + ": " + "Disabled (NOT default)" + '<br/>'} 
        
		if (($AES128Reg.Enabled -eq 1) -or ($AES128Reg.Enabled -eq $null))     
            {$InformationCollected +="Cipher Setting: AES 128" + ": " + "Enabled (default)" + '<br/>'} 
		else 
			{$InformationCollected +="Cipher Setting: AES 128" + ": " + "Disabled (NOT default)" + '<br/>'} 
        
		if (($AES256Reg.Enabled -eq 1) -or ($AES256Reg.Enabled -eq $null))     
            {$InformationCollected +="Cipher Setting: AES 256" + ": " + "Enabled (default)" + '<br/>'} 
		else 
            {$InformationCollected +="Cipher Setting: AES 256" + ": " + "Disabled (NOT default)" + '<br/>'} 
        } 
    if ($OSVersion.BuildNumber -eq 3790) 
    { 
		if (($AES128128Reg.Enabled -eq 1) -or ($AES128128Reg.Enabled -eq $null))         
			{$InformationCollected +="Cipher Setting: AES 128/128" + ": " + "Enabled (default)" +'<br/>'} 
		else 
			{$InformationCollected +="Cipher Setting: AES 128/128" + ": " + "Disabled (NOT default)" +'<br/>'} 
		if (($AES256256Reg.Enabled -eq 1) -or ($AES256256Reg.Enabled -eq $null))         
			{$InformationCollected +="Cipher Setting: AES 256/256" + ": " + "Enabled (default)" +'<br/>'} 
        else 
            {$InformationCollected +="Cipher Setting: AES 256/256" + ": " + "Disabled (NOT default)" +'<br/>'} 
 
        if (($DES5656Reg.Enabled -eq 1) -or ($DES5656Reg.Enabled -eq $null))         
			{$InformationCollected +="Cipher Setting: DES 56/56" + ": " + "Enabled (default)" +'<br/>'} 
		else 
            {$InformationCollected +="Cipher Setting: DES 56/56" + ": " + "Disabled (NOT default)" +'<br/>'} 
    } 
      
     #HashReg Values 
     if (($SHAHashReg.Enabled -eq 1) -or ($SHAHashReg.Enabled -eq $null))     
        {$InformationCollected +="Secure Hash Algorithm (SHA-1) Use" + ": " + "Enabled (default)" +'<br/>'} 
	else 
		{$InformationCollected +="Secure Hash Algorithm (SHA-1) Use" + ": " + "Disabled (NOT default)" +'<br/>'} 
    
	if (($MD5HashReg.Enabled -eq 1) -or ($MD5HashReg.Enabled -eq $null))     
        {$InformationCollected +="MD5 Hash Algorithm Use" + ": " + "Enabled (default)" +'<br/>'} 
	else 
		{$InformationCollected +="MD5 Hash Algorithm Use" + ": " + "Disabled (NOT default)" +'<br/>'} 
     #PKCS Key Exchange use. 
     if (($PKCSKeyXReg.Enabled -eq 1) -or ($PKCSKeyXReg.Enabled -eq $null))     
        {$InformationCollected +="RSA Key Exchange Use" + ": " + "Enabled (default)" +'<br/>'} 
	else 
        {$InformationCollected +="RSA Key Exchange Use" + ": " + "Disabled (NOT default)" +'<br/>'} 
 
     return $InformationCollected
 
} 
 
 
GetPKICipherReg $server

