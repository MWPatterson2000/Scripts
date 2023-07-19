<#
Name: Get AD Groups - Select Groups.ps1

Gets a list of AD Groups based off of Search String

Michael Patterson
mike@mwpatterson.com

Revision History
    2023-07-19 - Initial Release

#>


# Start Function(s)
function GetADGroupInfo {

}

# End Function(s)

# Get Application Name 
$grpNm = Read-Host -Prompt "Application Name Contains"

# Set Variables
# Get Date & Log Locations
$date = get-date -Format "yyyy-MM-dd-HH-mm"
$logRoot = "C:\"
$logFolder = "Temp\"
#$logFolderPath = $logRoot + $logFolder
$logFile = "AD Groups - Select.csv"
#$logFileName = $date + "-" + $logFile 
$logPath = $logRoot + $logFolder + $date + "-" + $grpNm + "-" + $logFile
$grpNm = "*$grpNm*"

# Get AD Groups Matching
$Groups = Get-AdGroup -filter * -Properties * | Where-Object {$_.name -like "$grpNm"} | Select-Object Name, Description

# Export the array as a CSV file
$Groups | Sort-Object 'Name' | Select-Object Name, Description | Export-Csv -Path $logPath -NoTypeInformation -Encoding UTF8

#End Script
