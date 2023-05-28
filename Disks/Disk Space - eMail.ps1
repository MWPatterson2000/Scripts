<#
Name: Disk Space = eMail.ps1

This script is for checking the Disk info and emailing a report.

Michael Patterson
Mike.Patterson@mfa.net

Revision History
    2018-10-26 - Initial Release

#>

# Clear Screen
Clear-Host

<#
# Check For Admin Mode
#Requires -RunAsAdministrator
#>

# Set Variables
$Header = @"
<style>
TABLE {border-width: 1px; border-style: solid; border-color: black; border-collapse: collapse;}
TH {border-width: 1px; padding: 3px; border-style: solid; border-color: black; background-color: #6495ED;}
TD {border-width: 1px; padding: 3px; border-style: solid; border-color: black;}
</style>
"@

# Get Disk Info
$volumes = Get-WmiObject win32_volume -Filter "DriveType='3'" # Single Local Server
#$volumes = Get-WmiObject win32_volume -computername mfambx1, mfambx2 -Filter "DriveType='3'" # Multiple Server/Remote Server
$Body = $volumes | Select-Object SystemName, Name, Label, DriveLetter, FileSystem,  `
    @{Name="Capacity(GB)";expression={[math]::round(($_.Capacity/ 1073741824),2)}}, `
    @{Name="Used Space(GB)";expression={[math]::round((($_.Capacity / 1073741824)-($_.FreeSpace / 1073741824)),2)}}, `
    @{Name="Free Space(GB)";expression={[math]::round(($_.FreeSpace / 1073741824),2)}}, `
    @{Name="Free(%)";expression={[math]::round(((($_.FreeSpace / 1073741824)/($_.Capacity / 1073741824)) * 100),2)}} `
    | Sort-Object SystemName, DriveLetter, Name | ConvertTo-Html -Head $Header

# Email Report
$emailFrom = "<Sender Email Address>" 
$emailTo = "<Recipient(s) Email Address>"
#$subject = "Disk Size $env:COMPUTERNAME" 
$subject = "Disk Size" 
$smtpServer = "<SMTP Server>"
$smtp = new-object Net.Mail.SmtpClient($smtpServer)
$MailMessage = new-object Net.Mail.MailMessage($emailFrom, $emailTo, $subject, $body)
$MailMessage.IsBodyHtml = $true
#$MailMessage.IsBodyHtml = $false
$MailMessage.ReplyTo = "<Reply Email Address>"
$smtp.Send($MailMessage)

# End
