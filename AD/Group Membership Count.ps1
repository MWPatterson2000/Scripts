<#
Name: Group Membership Count.ps1

This script is Count the users in AD Groups.

Michael Patterson
scripts@mwpatterson.com

Revision History
    2018-06-20 - Initial Release

#>

# Clear Screen
Clear-Host

<#
# Check For Admin Mode
#Requires -RunAsAdministrator
#>

# Progress Bar Variables
$Activity = "AD Group Membership Count Report"
$UserActivity = "Processing Groups"
$Id = 1
$TotalSteps = 4
$Task = "Creating AD Group Membership Count Report"

# Setup Progress Bar - Step 1
$Step = 1
$StepText = "Setting Initial Variables"
$StatusText = "Step $($Step) of $TotalSteps | $StepText"
$StatusBlock = [ScriptBlock]::Create($StatusText)
Write-Progress -Id $Id -Activity $Activity -Status ($StatusBlock) -CurrentOperation $Task -PercentComplete "100"

# Set Variables
$report = @()
$i = 0

# Get Date & Log Locations
$date = get-date -Format "yyyy-MM-dd-HH-mm"
$logRoot = "C:\"
#$logFolder = "Scripts\Logs\"
$logFolder = "Temp\"
$logFolderPath = $logRoot +$logFolder
$logFile = "AD Group Counts.csv"
$logFileName = $date +"-" +$logFile 
$logPath = $logRoot +$logFolder +$date +"-" +$logFile

# Setup Progress Bar - Step 2
$Step = 2
$StepText = "Counting AD Groups"
$StatusText = "Step $($Step) of $TotalSteps | $StepText"
$StatusBlock = [ScriptBlock]::Create($StatusText)
Write-Progress -Id $Id -Activity $Activity -Status ($StatusBlock) -CurrentOperation $Task -PercentComplete "100"

# Get AD Group Count
$totalGroups = (Get-AdGroup -filter * | Where-Object {$_.name -like "**"} | Select-Object name -ExpandProperty name).Count

# Setup Progress Bar - Step 3
$Step  = 3
$StepText = "Getting AD Groups"
$StatusText = "Step $($Step) of $TotalSteps | $StepText"
$StatusBlock = [ScriptBlock]::Create($StatusText)
Write-Progress -Id $Id -Activity $Activity -Status ($StatusBlock) -CurrentOperation $Task -PercentComplete "100"

# Get AD Groups
#$Groups = (Get-AdGroup -filter * | Where {$_.name -like "**"} | select name -ExpandProperty name)
$Groups = (Get-AdGroup -filter * | Where-Object {$_.name -like "**"} | Select-Object name,distinguishedName,description,info)
#$Groups = (Get-AdGroup -filter * -Properties * | Where {$_.name -like "**"} | select name,distinguishedName,description,info -ExpandProperty name,distinguishedName,description,info)
$Groups = (Get-AdGroup -filter * -Properties * | Where-Object {$_.name -like "**"} | Select-Object name,distinguishedName,description,info,Created,Modified)

$Table = @()

$Record = @{
    "Group Name" = ''
    "Group Count" = ''
    }

# Setup Progress Bar - Step 4
$Step = 4
$StepText = "Counting AD Group Members"
$StatusText = "Step $($Step) of $TotalSteps | $StepText"
$StatusBlock = [ScriptBlock]::Create($StatusText)
Write-Progress -Id $Id -Activity $Activity -Status ($StatusBlock) -CurrentOperation $Task -PercentComplete ($i / $totalGroups * 100)

Foreach ($Group in $Groups) {
    $i++
    $groupCount = ''
    #$groupCount = (Get-ADGroupMember -identity $Group -recursive).Count
    $groupCount = (Get-ADGroupMember -identity $Group.name -recursive).Count
    $reportObj = New-Object PSObject
    #$reportObj | Add-Member NoteProperty -Name "Group Name" -Value $Group
    $reportObj | Add-Member NoteProperty -Name "Group Name" -Value $Group.name
    $reportObj | Add-Member NoteProperty -Name "Group Description" -Value $Group.description
    $reportObj | Add-Member NoteProperty -Name "Group Info" -Value $Group.info
    $reportObj | Add-Member NoteProperty -Name "Group Created" -Value $Group.Created
    $reportObj | Add-Member NoteProperty -Name "Group Modified" -Value $Group.Modified
    $reportObj | Add-Member NoteProperty -Name "Group DName" -Value $Group.distinguishedName
    $reportObj | Add-Member NoteProperty -Name "Member Count" -Value $groupCount
    $report += $reportObj
    Write-Progress -Id $Id -Activity $Activity -Status ($StatusBlock) -CurrentOperation $Task -PercentComplete ($i / $totalGroups * 100)
}

$report | Export-CSV -Path $logPath -NoTypeInformation -Encoding UTF8
