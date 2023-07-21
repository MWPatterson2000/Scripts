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
$grpNm = Read-Host -Prompt "AD Group Name Contains"

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

# Create Array
$groupMembers = [System.Collections.ArrayList]::new()

# Get All Groups
$Groups = Get-AdGroup -filter * | Where-Object { $_.name -like "$grpNm" } | Select-Object name 

# Search for Group Names Matching String
foreach ($Group in $Groups) {
    if ($Group -like $grpNm ) {
        $groupName = Get-ADGroup -Identity $Group.Name -Properties * | Select-Object Name, Description
        $groupAdd = @{}
        $groupAdd | Add-Member -Type NoteProperty -Name 'Group Name' -Value $groupName.Name
        $groupAdd | Add-Member -Type NoteProperty -Name 'Group Description' -Value $groupName.Description
        # Add Info to Table
        [void]$groupMembers.Add($groupAdd)
    }
}

# Export the array as a CSV file
$groupMembers | Sort-Object 'Group Name' | Select-Object 'Group Name', 'Group Description' | Export-Csv -Path $logPath -NoTypeInformation -Encoding UTF8

#End Script
