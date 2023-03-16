 <#
Name: DNSBackup.ps1

This script is Backup DNS Info.

Michael Patterson
scripts@mwpatterson.com

Revision History
    2018-06-28 - Initial Release

#>

# Clear Screen
cls

<#
# Check For Admin Mode
#Requires -RunAsAdministrator
#>

# Set Variables

#<#
# Get Date & export Locations
$date = get-date -Format "yyyy-MM-dd-HH-mm"
$exportRoot = "C:\"
$exportFolder = "DNSBackups\Exports\" + "\" + $date
$exportFolderPath = $exportRoot + $exportFolder
#$exportFile = "<File Name>.txt"
#$exportFileName = $date +"-" +$exportFile 
#$exportPath = $exportRoot +$exportFolder +$date +"-" +$exportFile
#>

#Set min age of files
$max_days = "-7"

# Verify BackupFolder
if ((Test-Path $exportFolderPath) -eq $false) {
    New-Item -Path $exportFolderPath -ItemType directory
    }

 # Pulls an environment variable to find the server name, queries it for a list of zones, filters only the primary ones, removes the quotes from the exported .csv file, and saves it to the specified folder.
Get-DNSServerZone -ComputerName $env:computername | Where-Object{$_.ZoneType -eq "Primary"} | Select-Object ZoneName | ConvertTo-CSV -NoTypeInformation | ForEach-Object {$_ -replace '"', ""} | Out-File "$exportFolderPath\$date-ZoneTemp.csv"

# Imports the zone list
$ZoneList = Get-Content "$exportFolderPath\$date-ZoneTemp.csv"
# Pulls the date variables in the appropriate formats
$Year = Get-date -Format yyyy
$Month = Get-Date -Format MM
$Day = Get-Date -Format dd
# Starts a loop for each line in the zone list
ForEach ($line in $ZoneList) {
    # Exports the zone info with the desired naming scheme
    Export-DNSServerZone -Name $line -FileName "$date-${line}.txt"
    # Moves the export file from the default location to the Exports folder
    move "C:\Windows\System32\dns\$date-${line}.txt" "$exportFolderPath\$date-${line}.txt"
}
# Removes all files in the Exports folder older than 7 days
#forfiles /p "C:\DNSBackups\Exports" /d -7 /c "cmd /c del @file"
# Delete Old Backup Files
If ($deleteOlder -eq 'Yes') {
    Write-Output 'Deleting older Printer Backup files'
    Get-ChildItem $exportFolderPath -Recurse | Where-Object { $_.LastWriteTime -lt $del_date } | Remove-Item
}

