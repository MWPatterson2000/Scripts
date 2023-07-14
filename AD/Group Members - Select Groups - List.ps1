<#
Name: Group Members - List.ps1

Gets a list of users who are in a list of Groups

Michael Patterson
mike@mwpatterson.com

Revision History
    2023-05-18 - Initial Release

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
$logFile = "AD Groups Members.csv"
#$logFileName = $date + "-" + $logFile 
$logPath = $logRoot + $logFolder + $date + "-" + $grpNm + "-" + $logFile
$grpNm = "*$grpNm*"

# Create Array
$groupMembers = [System.Collections.ArrayList]::new()

# Import Group list
$Groups = import-csv ".\Groups.csv"
#$Groups = import-csv "C:\Temp\Groups.csv"

foreach ($Group in $Groups) {
    if ($Group -like $grpNm ) {
        [array]$members = Get-ADGroup -Identity $Group.Name | Get-ADGroupMember -Recursive
        foreach ($member in $members) {
            $userInfo = Get-ADObject -Identity $member -Property * #| Select-Object displayName
            $user = @{}
            $user | Add-Member -Type NoteProperty -Name 'Group Name' -Value $Group.Name
            $user | Add-Member -Type NoteProperty -Name 'Email' -Value $userInfo.mail
            # Add Info to Table
            [void]$groupMembers.Add($user)
        }
    }
}

# Export the array as a CSV file
$groupMembers | Sort-Object 'Group Name', Email | Select-Object 'Group Name', Email | Export-Csv -Path $logPath -NoTypeInformation -Encoding UTF8

#End Script
