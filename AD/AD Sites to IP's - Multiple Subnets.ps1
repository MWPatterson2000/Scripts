<#
Name: AD Sites to IP's - Multiple Subnets.ps1

This script list out Subnets in each AD Site.

Michael Patterson
scripts@mwpatterson.com

Revision History
    2018-07-19 - Initial Release

#>

# Clear Screen
cls

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
$logFolderPath = $logRoot +$logFolder
$logFile = "AD Sites to Subnets.csv"
$logFileName = $date +"-" +$logFile 
$logPath = $logRoot +$logFolder +$date +"-" +$env:USERDNSDOMAIN +"-" +$logFile
#>

Get-ADReplicationSubnet -Filter * `
    | Select-Object Name,site `
    | Group-Object site `
    | Select-Object @{Name='Name';Expression={$_.Name.Split(',')[0].Trim('CN=')}},@{Name='Subnets';Expression={$_.Group.Name}} `
    | Export-Csv $logPath -NoTypeInformation -Encoding UTF8