﻿<#
Name: .ps1

This script is for .

Michael Patterson
Mike.Patterson@mfa.net

Revision History
    YYYY-MM-DD - Initial Release

#>

# Clear Screen
Clear-Host

<#
# PowerShell 5.x required. The version of PowerShell included with Windows 10
#Requires -Version 5.0
#>

<#
# PowerShell Version Requirements - v7.2 (LTS) Min
#$PSVersionTable
#$PSVersionTable.PSVersion
#Requires -Version 7.2
#>

<#
# Self-elevate the script if required
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { 
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}
#>

<#
# Check For Admin Mode
#Requires -RunAsAdministrator
#>

#<#
# Hide PowerShell Console
$Script:showWindowAsync = Add-Type -MemberDefinition @"
[DllImport("user32.dll")]
public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
"@ -Name "Win32ShowWindowAsync" -Namespace Win32Functions -PassThru

Hide-PowerShell
#>

# Funtions
# Start Functions
# Show PowerShell
Function Show-Powershell() {
    $null = $showWindowAsync::ShowWindowAsync((Get-Process -Id $pid).MainWindowHandle, 10)
}

# Hide Show PowerShell
Function Hide-Powershell() {
    $null = $showWindowAsync::ShowWindowAsync((Get-Process -Id $pid).MainWindowHandle, 2)
}


# Email Function
#function send_email ($exportPath, $email) 
function send_email () {
    $SmtpClient = new-object system.net.mail.smtpClient 
    $mailmessage = New-Object system.net.mail.mailmessage 
    #    $SmtpClient.EnableSsl = $smtpssl
    #    $SmtpClient.Credentials = New-Object System.Net.NetworkCredential("User", "Password"); 
    $SmtpClient.Host = $smtpserver
    $SmtpClient.Port = $smtpport
    $mailmessage.from = $emailfrom 
    $mailmessage.To.add($email1)
    #    $mailmessage.To.add($email2)
    $mailmessage.Subject = $emailSubject
    #    $mailmessage.Priority = 2 # High
    #    $mailmessage.Priority = 1 # Low
    #    $mailmessage.Priority = 0 # Normal
    $mailmessage.IsBodyHtml = $emailIsBodyHtml
    #    $mailmessage.Attachments.Add($emailFile)
    $mailmessage.Body = $Body

    $smtpclient.Send($mailmessage) 
}

# Clear Varables
function Get-UserVariable ($Name = '*') {
    # these variables may exist in certain environments (like ISE, or after use of foreach)
    $special = 'ps', 'psise', 'psunsupportedconsoleapplications', 'foreach', 'profile'

    $ps = [PowerShell]::Create()
    $null = $ps.AddScript('$null=$host;Get-Variable') 
    $reserved = $ps.Invoke() | 
    Select-Object -ExpandProperty Name
    $ps.Runspace.Close()
    $ps.Dispose()
    Get-Variable -Scope Global | 
    Where-Object Name -like $Name |
    Where-Object { $reserved -notcontains $_.Name } |
    Where-Object { $special -notcontains $_.Name } |
    Where-Object Name 
}

# End Functions

# Set Variables
$today = Get-Date
$today = $today.ToString("dddd MMMM-dd-yyyy hh:mm tt")

<#
# Get Date & Log Locations
$date = get-date -Format "yyyy-MM-dd-HH-mm"
$logRoot = "<Drive Letter>:\"
$logFolder = "<Path>\"
$logFolderPath = $logRoot +$logFolder
$logFile = "<File Name>.txt"
$logFileName = $date +"-" +$logFile 
$logPath = $logRoot +$logFolder +$date +"-" +$logFile
#>

#Configure Email notification recipient
#$smtpserver = "outlook.office365.com"
#$smtpport = "587"
#$smtpssl = "True"
$smtpserver = "<SMTP Relay Server>"
$smtpport = "25"
$smtpssl = "False"
$emailSubject = "Sample Subject"
$emailIsBodyHtml = $true
#$emailfrom = "Sender <sender@test.local>"
$emailfrom = "$env:computername <$env:computername@>"
$email1 = "user1@test.local"
#$email2 = "user2@test.local"
#$emailFile = $logPath

<#
#File Logging/Output
 *> $logPath #Create Log File
 *>> $logPath #Append to Log File
 | Out-File $logPath #Create Log File
 | Out-File $logPath -Append #Append to Log File
#>

# Email Body
$Body = @"
<!--<strong>Sample Message $env:USERDOMAIN</strong><br />-->
Sample Message <span style="background-color:yellow;color:black;"><strong>$env:USERDOMAIN</strong></span>.<br /> <br />

Generated on : $today<br /><br />
<br /></font></h5>
"@

# Send email Notification
send_email



# Get Variables
#Get-UserVariable

# Clear Variables
Get-UserVariable | Remove-Variable

# End
