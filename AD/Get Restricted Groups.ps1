<#
Name: Get Restricted Groups.ps1

This script to get all the Privledged Groups in an AD Forest.

Michael Patterson
scripts@mwpatterson.com

Revision History
    2023-04-04 - Initial Release

#>

# Start Function(s)
function GetGroupInfoForest {
    [array]$members = Get-ADGroup -Server $forest -Identity $groupID | Get-ADGroupMember -Recursive
    $groupName = Get-ADGroup -Server $forest -Identity $groupID | Select-Object Name
    Write-Host "`tGetting $($groupName.Name) from $($forest)" -ForegroundColor Green
    $group = @{}
    $group | Add-Member -Type NoteProperty -Name 'Domain' -Value $forest
    $group | Add-Member -Type NoteProperty -Name 'GroupName' -Value $groupName.Name
    $group | Add-Member -Type NoteProperty -Name 'Members' -Value $(@(Get-ADGroup -Server $forest -Identity $groupID | Get-ADGroupMember).Count)
    # Add Info to Table
    [void]$groupCounts.Add($group)

    # Loop each user in the list
    Foreach ($member in $members) {
        $user = @{}
        $userInfo = Get-ADUser -Identity $member -Property * #| Select-Object displayName
        $lastLogin = [DateTime]::FromFileTime($userInfo.lastLogonTimestamp)
        $user | Add-Member -Type NoteProperty -Name 'Domain' -Value $forest
        $user | Add-Member -Type NoteProperty -Name 'Group' -Value $groupName.Name
        $user | Add-Member -Type NoteProperty -Name 'DisplayName' -Value $userInfo.DisplayName
        $user | Add-Member -Type NoteProperty -Name 'sAMAccountName' -Value $userInfo.sAMAccountName
        $user | Add-Member -Type NoteProperty -Name 'userPrincipalName' -Value $userInfo.userPrincipalName
        $user | Add-Member -Type NoteProperty -Name 'Last Login Timestamp' -Value $lastLogin
        # Add Info to Table
        [void]$groupMembers.Add($user)
    }
}

function GetGroupInfoDomain {
    [array]$members = Get-ADGroup -Server $domainname -Identity $groupID | Get-ADGroupMember -Recursive
    $groupName = Get-ADGroup -Server $domainname -Identity $groupID | Select-Object Name
    Write-Host "`tGetting $($groupName.Name) from $($domainname)" -ForegroundColor Green
    $group = @{}
    $group | Add-Member -Type NoteProperty -Name 'Domain' -Value $domainname
    $group | Add-Member -Type NoteProperty -Name 'GroupName' -Value $groupName.Name
    $group | Add-Member -Type NoteProperty -Name 'Members' -Value $(@(Get-ADGroup -Server $domainname -Identity $groupID | Get-ADGroupMember).Count)
    # Add Info to Table
    [void]$groupCounts.Add($group)
    # Loop each user in the list
    Foreach ($member in $members) {
        $user = @{}
        #$userInfo = Get-ADUser -Identity $member -Property * #| Select-Object displayName
        $userInfo = Get-ADObject -Identity $member -Property * #| Select-Object displayName
        $lastLogin = [DateTime]::FromFileTime($userInfo.lastLogonTimestamp)
        $user | Add-Member -Type NoteProperty -Name 'Domain' -Value $domainname
        $user | Add-Member -Type NoteProperty -Name 'Group' -Value $groupName.Name
        $user | Add-Member -Type NoteProperty -Name 'DisplayName' -Value $userInfo.DisplayName
        $user | Add-Member -Type NoteProperty -Name 'sAMAccountName' -Value $userInfo.sAMAccountName
        $user | Add-Member -Type NoteProperty -Name 'userPrincipalName' -Value $userInfo.userPrincipalName
        $user | Add-Member -Type NoteProperty -Name 'Last Login Timestamp' -Value $lastLogin
        # Add Info to Table
        [void]$groupMembers.Add($user)
    }
}

# End Function(s)

# Clear Screen
Clear-Host

# PowerShell 5.x required. The version of PowerShell included with Windows 10
#Requires -Version 5.0

# Create Array
$groupCounts = [System.Collections.ArrayList]::new()
$groupMembers = [System.Collections.ArrayList]::new()

# Write Output
Write-Host "Getting AD Restricted Groups" -ForegroundColor Green

# Get Forest Information
$ForestInfo = Get-ADForest
$forest = $ForestInfo.RootDomain
[Array]$allDomains = $ForestInfo.Domains

# Get Date & Log Locations
$date = get-date -Format "yyyy-MM-dd-HH-mm"
$logRoot = "C"
$logFolder = "Temp"
#$logFolderPath = $logRoot + ":\" + $logFolder + "\"
$logFile1 = "Group Counts.csv"
$logFile2 = "Group Members.csv"
#$logFileName = $date +"-" +$logFile 
$logPath1 = $logRoot + ":\" + $logFolder + "\" + $date + "-" + $forest + "-" + $logFile1
$logPath2 = $logRoot + ":\" + $logFolder + "\" + $date + "-" + $forest + "-" + $logFile2

<#
# Get Domain Name
$domainName = $env:USERDNSDOMAIN #Full Domain Name 
#$domainName = $env:USERDOMAIN #Short Domain Name

# Get Domain Details
#$domaindetails = $null
$domaindetails = get-addomain $domainName

# Get Domain SID
$domainSID = $domaindetails.DomainSID
#>

# Write Output
Write-Host "`tGetting Forest Information from $($forest)" -ForegroundColor Yellow

# Enterprise Read-only Domain Controllers
$groupID = ((Get-ADDomain(Get-ADForest).name).domainSID).value + "-498"
GetGroupInfoForest

# Schema Admins
$groupID = ((Get-ADDomain(Get-ADForest).name).domainSID).value + "-518"
GetGroupInfoForest

# Enterprise Admins
$groupID = ((Get-ADDomain(Get-ADForest).name).domainSID).value + "-519"
GetGroupInfoForest

# Enterprise Key Admins
$groupID = ((Get-ADDomain(Get-ADForest).name).domainSID).value + "-527"
GetGroupInfoForest

# Loop each Domain in the list
$allDomains | ForEach-Object {
    $domainname = $_

    # Write Output
    Write-Host "`tGetting Domain Information from $($domainname)" -ForegroundColor Yellow

    # Get Domain Details
    $domaindetails = $null
    $domaindetails = get-addomain $domainname
    $domainSID = $domaindetails.DomainSID

    # Domain Admins
    $groupID = ($domainSID).value + "-512"
    GetGroupInfoDomain

    # Domain Controllers
    $groupID = ($domainSID).value + "-516"
    GetGroupInfoDomain

    # Cert Publishers
    $groupID = ($domainSID).value + "-517"
    GetGroupInfoDomain

    # Group Policy Creator Owners
    $groupID = ($domainSID).value + "-520"
    GetGroupInfoDomain

    # Read-only Domain Controllers
    $groupID = ($domainSID).value + "-521"
    GetGroupInfoDomain

    # Cloneable Domain Controllers
    $groupID = ($domainSID).value + "-522"
    GetGroupInfoDomain

    # Key Admins
    $groupID = ($domainSID).value + "-526"
    GetGroupInfoDomain

    # Allowed RODC Password Replication Group
    $groupID = ($domainSID).value + "-571"
    GetGroupInfoDomain

    # Denied RODC Password Replication Group
    $groupID = ($domainSID).value + "-572"
    GetGroupInfoDomain
}

<#
# No of Domain Admins
$domAdminGroupID = ($domainSID).value + "-512"
GetGroupInfoDomain
#>

# Export Data
$groupCounts | Select-Object Domain, GroupName, Members | Export-Csv -Path $logPath1 -NoTypeInformation -Encoding UTF8
$groupMembers | Select-Object Domain, Group, DisplayName, sAMAccountName, userPrincipalName, 'Last Login Timestamp' | Export-Csv -Path $logPath2 -NoTypeInformation -Encoding UTF8
