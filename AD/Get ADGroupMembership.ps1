<#
Name: Get-ADGroupMembership

This script to Get AD Group Membership for a list of users and export the report

Michael Patterson


Revision History
	2023-09-20 - Initial Release
	
    
#>

# Start Function(s)
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
# End Function(s)

# Load .NET Assemblie(s)
Add-Type -AssemblyName System.Windows.Forms

# Build Array for ADFS Applications
$userGroups = [System.Collections.ArrayList]::new()

# Build Export Info
# Get Date & export Locations
$date = get-date -Format "yyyy-MM-dd-HH-mm"
#$exportRoot = "C:\" #Can use another drive if available
#$exportFolder = "Temp\"
#$exportFolderPath = $exportRoot + $exportFolder
$Script:InitialDirectory = "$env:USERPROFILE\Downloads"
$exportFolder = "\"
$exportFolderPath = $Script:InitialDirectory + $exportFolder

# Import from user file
Write-Host "`tSelect User List File for Group Reporting"
# Build Windows Form
$fileBrowserUsers = New-Object System.Windows.Forms.OpenFileDialog -Property @{ 
	#InitialDirectory = "$env:USERPROFILE\Downloads"; 
	InitialDirectory = "$Script:InitialDirectory"; 
	Filter           = "CSV files (*.csv)|*.csv|All files (*.*)|*.*"; 
	FilterIndex      = 1;
	#Title = "Select CSV File to Import Groups into Okta Environment: $Script:uri"
	Title            = "Select User List File for Group Reporting"
}

# Open Windows Form
$null = $fileBrowserUsers.ShowDialog()

#Base File Name
$fileInfo = Get-ItemProperty $fileBrowserUsers.FileName | Select-Object *

# Build Export Info
$exportFileName = $date + " - " + $fileInfo.BaseName + ".csv"
$exportPath = $exportFolderPath + $exportFileName

# Import Files Selected
$Script:importedUsers = Import-Csv -Path $fileBrowserUsers.FileName

#Write-Host $Script:importedUsers
# Group Information
Write-Host "`n`tPlease Wait - Retrieving Requested Data" -ForegroundColor Green
foreach ($user in $Script:importedUsers) {
    $userInfo = Get-ADUser -Identity $user.Username -Properties *
    $groups = Get-ADPrincipalGroupMembership $user.Username #| Select-Object name
    foreach ($group in $groups) {
        $userGroup = New-Object PSObject
        #$userGroup | Add-Member -type NoteProperty -name "User" -Value $user.Username
        #$userGroup | Add-Member -type NoteProperty -name "Group"  -Value $group.name
        $userGroup | Add-Member -type NoteProperty -name "UserPrincipalName" -Value $userInfo.UserPrincipalName
        $userGroup | Add-Member -type NoteProperty -name "SamAccountName" -Value $userInfo.SamAccountName
        $userGroup | Add-Member -type NoteProperty -name "User Description" -Value $userInfo.Description
        $userGroup | Add-Member -type NoteProperty -name "User DisplayName" -Value $userInfo.DisplayName
        $userGroup | Add-Member -type NoteProperty -name "User DistinguishedName" -Value $userInfo.DistinguishedName
        $userGroup | Add-Member -type NoteProperty -name "Group Name"  -Value $group.name
        $userGroup | Add-Member -type NoteProperty -name "Group Scope"  -Value $group.GroupCategory
        $userGroup | Add-Member -type NoteProperty -name "Group Category"  -Value $group.GroupScope
        #$temp = $($Relay.Identifier) -join ";"
        #$userGroup | Add-Member -type NoteProperty -name "Identifier" -Value $temp
        $userGroups += $userGroup
    }
}

# Export ADFS Report
$userGroups | Sort-Object 'UserPrincipalName', 'Group Name' | Export-Csv -Delimiter ',' -Path $exportPath -NoTypeInformation -Encoding UTF8

# Clear Variables
Write-Host "`nScript Cleanup"
Get-UserVariable | Remove-Variable -ErrorAction SilentlyContinue

# End
Exit
