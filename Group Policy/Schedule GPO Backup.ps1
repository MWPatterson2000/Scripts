# https://azurecloudai.blog/2019/12/20/cleaning-up-the-mess-in-your-group-policy-gpo-environment/

Function Create-GPScheduleBackup {
    $Message = "Please enter the credentials of the user which will run the schedule task"; 
    $Credential = $Host.UI.PromptForCredential("Please enter username and password", $Message, "$env:userdomain\$env:username", $env:userdomain)
    $SchTaskUsername = $credential.UserName
    $SchTaskPassword = $credential.GetNetworkCredential().Password
    $SchTaskScriptCode = '$Date = Get-Date -Format "yyyy-MM-dd_hh-mm"
    $BackupDir = "C:\Backup\GPO\$Date"
    $BackupRootDir = "C:\Backup\GPO"
    if (-Not (Test-Path -Path $BackupDir)) {
        New-Item -ItemType Directory -Path $BackupDir
    }
    $ErrorActionPreference = "SilentlyContinue" 
    Get-ChildItem $BackupRootDir | Where-Object {$_.CreationTime -le (Get-Date).AddMonths(-3)} | Foreach-Object { Remove-Item $_.FullName -Recurse -Force}
    Backup-GPO -All -Path $BackupDir'
    $SchTaskScriptFolder = "C:\Scripts\GPO"
    $SchTaskScriptPath = "C:\Scripts\GPO\GPOBackup.ps1"
    if (-Not (Test-Path -Path $SchTaskScriptFolder)) {
        New-Item -ItemType Directory -Path $SchTaskScriptFolder
    }
    if (-Not (Test-Path -Path $SchTaskScriptPath)) {
        New-Item -ItemType File -Path $SchTaskScriptPath
    }
    $SchTaskScriptCode | Out-File $SchTaskScriptPath
    $SchTaskAction = New-ScheduledTaskAction -Execute 'PowerShell.exe' -Argument "-ExecutionPolicy Bypass $SchTaskScriptPath"
    $Frequency = "Daily", "Weekly"
    $SelectedFrequnecy = $Frequency | Out-GridView -OutputMode Single -Title "Please select the required frequency"
    Switch ($SelectedFrequnecy) {
        Daily {
            $SchTaskTrigger = New-ScheduledTaskTrigger -Daily -At 1am
        }
        Weekly {
            $Days = "Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"
            $SelectedDays = $Days | Out-GridView -OutputMode Multiple -Title "Please select the relevant days in which the schedule task will run"
            $SchTaskTrigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek $SelectedDays -At 1am
        }
    }  
    Try {
        Register-ScheduledTask -Action $SchTaskAction -Trigger $SchTaskTrigger -TaskName "Group Policy Schedule Backup" -Description "Group Policy $SelectedFrequnecy Backup" -User $SchTaskUsername -Password $SchTaskPassword -RunLevel Highest -ErrorAction Stop
    }
    Catch {
        $ErrorMessage = $_.Exception.Message
        Write-Host "Schedule Task regisration was failed due to the following error: $ErrorMessage" -f Red
    }
}