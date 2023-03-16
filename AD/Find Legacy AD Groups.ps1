<#
Name: Find Legacy AD Groups.ps1

This script locates the Legacy AD Groups.

Michael Patterson
scripts@mwpatterson.com

Revision History
    2018-05-21 - Initial Release

#>

# Clear Screen
#cls
Clear-Host

<#
# Check For Admin Mode
#Requires -RunAsAdministrator
#>

# Set Variables


#<#
# Get Date & Log Locations
$date = get-date -Format "yyyy-MM-dd-HH-mm"
$logRoot = "C:\"
$logFolder = "Temp\"
#$logFolderPath = $logRoot +$logFolder
$logFile = "Legacy AD Groups.csv"
#$logFileName = $date +"-" +$logFile 
$logPath = $logRoot +$logFolder +$date +"-" +$logFile
#>

Get-ADGroup -Filter * -Server mfadomain.mfa.net | `
    Get-ADReplicationAttributeMetadata -Server <Domain Controller> -Properties Member -ShowAllLinkedValues | `
    #Where-Object {$_.Version -eq 0} | Select-Object @{n="Group";e={$_.Object}} -Unique | `
    Where-Object {$_.Version -eq 0} | Select-Object @{n="LEGACY";e={$_.AttributeValue}},@{n="Group";e={$_.Object}} | `
    Export-Csv "$logPath" -NoTypeInformation -Encoding UTF8
