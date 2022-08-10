# PowerShell-Scripts
A collection of PowerShell scripts I have created during my career - some from IT - most related to Computer Incident Response

I have created PowerShell scripts for everything starting with my career in IT. Many of these scripts are no longer relevant but the ones of value I am dumping here. Hopefully they will help someone.

Most are nothing special but perhaps they can demonstrate a technique you can use. That is how I use most of these. Most were written for a specific task.

## Hawk Support Scripts
* **get-impossibleTravel.ps1** Looks at converted auth logs looking for impossible travel
* **get-allAuthAttempts.ps1** Extracts all authentication attempts
* **get-ipgeoHawk.ps1** Extracts IP addresses from converted auth logs and does a GeoIP lookup.

## Incident Response and Computer Forensics Scripts

### Linux

* **convert-bashhistory.ps1** If dates are turned on in the bash history file this will convert them to normal date/times.
* **get-linuxlogs.ps1 Convert** Linux logs to a PowerShell object enabling export to csv.
* **get-utmp.ps1** Parse btmp, utmp, and wtmp files converting them to csv a PowerShell object.
* **list-timezones.ps1** List the official time zone names required by get-utmp.ps1.

### Windows

* **Convert-IIStoCSV.ps1** Convert IIS logs to CSV files.
* **get-etllog.ps1** Convert etl Logs to a PowerShell object enabling export to csv.
* **get-eventlogs.ps1** Convert event logs (evt and evtx) to a PowerShell object enabling export to csv.
* **get-Teamslog.ps1** The Microsft Teams log contains fragments of Teams chat that can be recovered.
* **parse-emailheaders**.ps1 Parse email headers and return as PowerShell project.
* **DecodeGzip.ps1** Decode Base65 and Gzipped code.
* **gather-logs.ps1** Gather System, Security and Application logs from a remote computer and create a zip containing them named after the computer.
* **get-DHCPLogs.ps1** Retrieves DHCP logs from a MS DHCP server and converts to a PS object.
* **get-dnsDebugLog.ps1** Retrieves DNS Debug Logs from a MS DNS server and converts to PS object.
* **Get-DOLog.ps1** Get Delivery Optimization logs and convert to object.
* **Get-ScheduledTask.ps1** Get XML scheduled task convert to object.

### Penetration Testing

* **decode-BigIPCookie.ps1** Convert BigIP Cookie returns IP and port.
* **decodeURI.ps1** Decodes common uri escape characters and sqli constructs from a uri.
* **escape-string.ps1** Escape common characters in a uri string.
* **get-git.ps1** Retrieve files from an exposed .git directory
* **get-cert.ps1** Get certificate information for a website.
* **get-imapSecurity.ps1** Use OpenSSL to evaluate security of an IMAP server.
* **host-header-poison.ps1** Check a host to see if it's vulnerable to host header poisoning.

### General

* **get-ccns.ps1** Extracts CCN from a file verifies the LUN. If it is valid retrieves the associated bank information and returns a PS Object.
* **get-ipgeo.ps1** Get IPGeo information for an IP address from ip-api.com and return in a PowerShell object.
* **get-shodan.ps1** Get Shodan information for a host returning information in a PowerShell object.
* **Convert-archivetozip.ps1** Convert all archive files in current directory to zips.
* **convert-b64ToPng.ps1** Convert a base64 encoded png to a png.
* **convet-time.ps1** Convert from one timezone to another.
* **disable-usbwriteprotect.ps1** Disable USB Write protect.
* **enable-usbwriteprotect.ps1** Enable USB Write protect.
* **get-ip.ps1** Simple script to extract IP addresses from a text file.

## IT Scripts
* **excel-to-csv.ps1** Convert file from Excel to CSV
* **file-library.ps1** Library of file routines written in .net for speed (PS is so slow): compare, split, unique, count lines, sort ...
* **get-adhealth.ps1** Provides a report about the health of an Active Directory environment.
* **get-AdminPasswordNotRequired.ps1** Check if the Local Admin account requires a password.
* **get-ADuserNoPasswdReq.ps1** Scan all accounts in Active Directory to see if any have the No Password flag set.
* **get-ciphers.ps1** Get which SSL Ciphers are installed on a server.
* **get-clipboard.ps1** Retrieve Clipboard contents.
* **get-ComputerNames.ps1** Retrieve all computer names from Active Directory - no special permissions required.
* **get-LocalComputerUsers.ps1** Get all Local users and approximate time/date they are last active.
* **get-groups.ps1** Uses .net routines to retrieve AD Groups.
* **get-fileinfo.ps1** Retrieves an exhaustive list of file properties in a directory or an entire drive (an entire drive is not a good idea).
* **get-localadmin-wmi.ps1** Get the name of the Local Admin by RID using WMI.
* **get-localgroup.ps1 **Uses LDAP to get local groups
* **Get-MacVendor.ps1** Get Network Card MAC Vendor using mac-to-vendor.herokuapp.com.
* **get-netstat.ps1** Retrieve Netstat like listing of Ports with PowerShell.
* **get-DomainUsers.ps1** Gets all domain users using .net directory searcher.
* **get-wifipasswords.ps1** Uses netsh to retrieve plain text wifi passwords saved on host.
* **mount-vss.ps1** Mount a VSS image.
* **networkfunctions.ps1** Various functions to help with network tasks: ConvertTo-BinaryIP, get-IP2Long, get-Long2IP, get-Mask2Cidr, get-CIDR2Mask, get-Network, get-Broadcast, Get-NetworkSummary, Get-NetworkRange, Get-NumIPS
* **remote-EnableTS.ps1** Enable Terminal Services on a remote computer.
* **sid2user.ps1** Retrieves the Username given a SID.
* **expire-ADPassword.ps1** Expires a Users AD Password requiring a new password.
* **get-fileEncoding.ps1** Determines the file encoding for a text file

## Remediation Scripts
* **disable-anonymousshares.ps1** Disable Anonymous SAM accounts and shares.
* **disable-netbiostcpip.ps1** Disable NetBIOS over TCPIP
* **disable-sslv2.ps1** Disable SSLV2 Ciphers.
* **enable-wins.ps1** Enable Wins service and start it.
* **disable-wins.ps1** Stop Wins service and disable it.
* **disable-winvnc4.ps1** Disable WinVNC v4
* **enable-smbsigning.ps1** Enable SMB Signing
* **rename-localadmin.ps1** Rename Local Admin and Guest Accounts