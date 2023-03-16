<#
Name: Mailbox Report - xx.ps1

This generate Mailbox Reports for Comparing Mailboxes to check for consistancy.

Michael Patterson
scripts@mwpatterson.com

Revision History
    2020-09-30 - Initial Release
    2020-10-12 - Added Run the Group Report for Licensing
        

Notes:
    File Output / Logging
        *> $logPath
        *>> $logPath
        | Out-File $logPath
        | Out-File $logPath -Append

#>

#
#Get Date & Log Locations
$date = get-date -Format "yyyy-MM-dd-HH-mm"
$logRoot = "<Drive>:\"
$logFolder = "<Folder>\"
$logFolderPath = $logRoot + $logFolder
$logFile = "<File>"
$logFileName = $date + "-" + $logFile 
$logPath = $logRoot + $logFolder + $date + "-" + $logFile
#>

#<#
# Select Key File
$KeyFile = "C:\Scripts\KeyFile\AES.key"
$Key = Get-Content $KeyFile

# Get Service Account Password
#$Pass = get-content "C:\Scripts\Password\CloudScripts@mfoa.onmicrosoft.com.txt" | ConvertTo-SecureString -Key $Key
$PasswordFile = "C:\Scripts\Password\CloudScripts@mfoa.onmicrosoft.com.txt"
$Pass = get-content $PasswordFile | ConvertTo-SecureString -key $Key

# Set Connection Information
$AdminName = "CloudScripts@mfoa.onmicrosoft.com"
$Cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $AdminName, $Pass

# Connect to O365
#Import-Module MSOnline
Connect-MsolService -Credential $Cred

# Connect to Exchange Online
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $cred -Authentication Basic -AllowRedirection
Import-PSSession $Session
#>

#<#
# Get Users with Mailbox in O365
Write-Host "`n`nPlease Wait - Getting O365 Mailbox Users" -Fore Yellow
#Get-Mailbox -ResultSize Unlimited | Select-Object DisplayName,UserPrincipalName,PrimarySmtpAddress | Export-Csv "C:\Temp\$(get-date -f yyyy-MM-dd-HH-mm) - O365 Users Email.csv" -Encoding UTF8 -NoTypeInformation
Get-Mailbox -ResultSize Unlimited | Select-Object DisplayName, UserPrincipalName, PrimarySmtpAddress | Export-Csv "C:\Temp\$date - O365 Users Email.csv" -Encoding UTF8 -NoTypeInformation
#Get-EXOMailbox -ResultSize Unlimited | Select-Object DisplayName,UserPrincipalName,PrimarySmtpAddress | Export-Csv "C:\Temp\$(get-date -f yyyy-MM-dd-HH-mm) - O365 Users Email.csv" -Encoding UTF8 -NoTypeInformation
#>

#<#
# Use the if in Hybrid - Start
# Call Exchange PowerShell SnapIn
Add-PSSnapin Microsoft.Exchange.Management.PowerShell.SnapIn;
Write-Host "`nPlease Wait Loading Exchange PowerShell SnapIn" -Fore Yellow

Write-Host "`nPlease Wait - Getting Hybrid Mailbox Users" -Fore Yellow
#Get-RemoteMailbox -ResultSize Unlimited | Select-Object DisplayName,UserPrincipalName,PrimarySmtpAddress | Export-Csv "C:\Temp\$(get-date -f yyyy-MM-dd-HH-mm) - Hybrid Users Email.csv" -Encoding UTF8 -NoTypeInformation
Get-RemoteMailbox -ResultSize Unlimited | Select-Object DisplayName, UserPrincipalName, PrimarySmtpAddress | Export-Csv "C:\Temp\$date - Hybrid Users Email.csv" -Encoding UTF8 -NoTypeInformation
#>

#<#
# Get AD Users
Write-Host "`nPlease Wait - Getting AD Users" -Fore Yellow
#Get-ADUser -Filter * -Properties * | Select-Object DisplayName, SamAccountName, UserPrincipalName, EmailAddress, Enabled, distinguishedName, Company, Division, Department, Description | Export-Csv "C:\Temp\$(get-date -f yyyy-MM-dd-HH-mm) - Users - All.csv" -Encoding UTF8 -NoTypeInformation
Get-ADUser -Filter * -Properties * | Select-Object DisplayName, SamAccountName, UserPrincipalName, EmailAddress, Enabled, distinguishedName, Company, Division, Department, Description | Export-Csv "C:\Temp\$date - Users - All.csv" -Encoding UTF8 -NoTypeInformation
#>

#<#
# Get Group Membership for Licensing"
Write-Host "`nPlease Wait - Getting AD Licensed Users" -Fore Yellow
#Invoke-Expression -Command 'D:\Downloads\Scripts\AD\Group Members - O365 F1-E3 - 10.ps1'
#Start-Process -FilePath powershell 'D:\Downloads\Scripts\AD\Group Members - O365 F1-E3 - 10.ps1' -Wait
& 'D:\Downloads\Scripts\AD\Group Members - O365 F1-E3 - 10.ps1'
#Invoke-Item 'D:\Downloads\Scripts\AD\Group Members - O365 F1-E3 - 10.ps1'
#>

# END
