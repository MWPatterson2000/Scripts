<#
Name: AD\Group AD Membership Count.ps1

This script is Count the users in AD Groups.

Michael Patterson
scripts@mwpatterson.com

Revision History
    2018-06-20 - Initial Release

#>

# Clear Screen
cls

<#
# Check For Admin Mode
#Requires -RunAsAdministrator
#>

# Progress Bar Variables
$Activity = "AD Group Membership Count Report"
$UserActivity = "Processing Groups"
$Id = 1
$TotalSteps = 4
#$TotalSteps = 3
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
#$totalGroups = (Get-AdGroup -filter "GroupCategory -eq 'Security'" | Where {$_.name -like "**"} | select name -ExpandProperty name).Count
$totalGroups = (Get-AdGroup -filter * | Where {$_.name -like "**"} | select name -ExpandProperty name).Count

# Setup Progress Bar - Step 3
$Step  = 3
$StepText = "Getting AD Groups & Count Part 1"
$StatusText = "Step $($Step) of $TotalSteps | $StepText"
$StatusBlock = [ScriptBlock]::Create($StatusText)
Write-Progress -Id $Id -Activity $Activity -Status ($StatusBlock) -CurrentOperation $Task -PercentComplete "100"

# Get AD Groups
#Get-ADGroup -filter "GroupCategory -eq 'Security'" –properties Member,name,distinguishedName,description,info,Created,Modified | 
#Get-ADGroup -filter "GroupCategory -eq 'Security'" –properties * | 
$Groups = (Get-ADGroup -filter * –properties * | 
Select Name,@{Name="Members";
#Expression={($_.member | Measure-Object).count}},description,info,Created,Modified,GroupCategory,GroupScope,distinguishedName)
Expression={($_.member | Measure-Object).count}},description,info,Created,Modified,GroupCategory,GroupScope,distinguishedName,CN,Mail)
#Expression={($_.member | Measure-Object).count}},description,info,Created,Modified,GroupCategory,GroupScope,distinguishedName, |
#Export-CSV -Path $logPath -NoTypeInformation -Encoding UTF8

$Table = @()

$Record = @{
    "Group Name" = ''
    "Group Count" = ''
    }

# Setup Progress Bar - Step 4
$Step = 4
$StepText = "Counting AD Group Members Part 2 - Recursive Members"
$StatusText = "Step $($Step) of $TotalSteps | $StepText"
$StatusBlock = [ScriptBlock]::Create($StatusText)
Write-Progress -Id $Id -Activity $Activity -Status ($StatusBlock) -CurrentOperation $Task -PercentComplete ($i / $totalGroups * 100)

Foreach ($Group in $Groups) {
    $i++
    $groupCount = ''
    #$groupCount = (Get-ADGroupMember -identity $Group.name -recursive).Count
    $groupCount = (Get-ADGroupMember -identity $Group.CN -recursive).Count
    $reportObj = New-Object PSObject
    $reportObj | Add-Member NoteProperty -Name "Name" -Value $Group.name
    $reportObj | Add-Member NoteProperty -Name "Member Count" -Value $Group.Members
    $reportObj | Add-Member NoteProperty -Name "Recursive Count" -Value $groupCount
    $reportObj | Add-Member NoteProperty -Name "Email" -Value $Group.Mail
    $reportObj | Add-Member NoteProperty -Name "Description" -Value $Group.description
    $reportObj | Add-Member NoteProperty -Name "Info" -Value $Group.info
    $reportObj | Add-Member NoteProperty -Name "Created" -Value $Group.Created
    $reportObj | Add-Member NoteProperty -Name "Modified" -Value $Group.Modified
    $reportObj | Add-Member NoteProperty -Name "GroupCategory" -Value $Group.GroupCategory
    $reportObj | Add-Member NoteProperty -Name "GroupScope" -Value $Group.GroupScope
    $reportObj | Add-Member NoteProperty -Name "CN" -Value $Group.CN
    $reportObj | Add-Member NoteProperty -Name "Distinguished Name" -Value $Group.distinguishedName
    $report += $reportObj
    Write-Progress -Id $Id -Activity $Activity -Status ($StatusBlock) -CurrentOperation $Task -PercentComplete ($i / $totalGroups * 100)
    }

$report | Export-CSV -Path $logPath -NoTypeInformation -Encoding UTF8
#>
