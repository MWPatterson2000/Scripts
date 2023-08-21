# https://azurecloudai.blog/2019/12/20/cleaning-up-the-mess-in-your-group-policy-gpo-environment/

Function Get-GPDisabledGPOs ($ReadOnlyMode = $True) {
    ""
    "Looking for disabled GPOs..."
    $DisabledGPOs = @()
    Get-GPO -All | ForEach-Object {
        if ($_.GpoStatus -eq "AllSettingsDisabled") {
            Write-Host "Group Policy " -NoNewline; Write-Host $_.DisplayName -f Yellow -NoNewline; Write-Host " is configured with 'All Settings Disabled'"
            $DisabledGPOs += $_
        }
        Else {
            Write-Host "Group Policy " -NoNewline; Write-Host $_.DisplayName -f Green -NoNewline; Write-Host " is enabled"         
        }
    }
    Write-Host "Total GPOs with 'All Settings Disabled': $($DisabledGPOs.Count)" -f Yellow
    $GPOsToRemove = $DisabledGPOs | Select Id, DisplayName, ModificationTime, GpoStatus | Out-GridView -Title "Showing disabled Group Policies. Select GPOs you would like to delete" -OutputMode Multiple
    if ($ReadOnlyMode -eq $False -and $GPOsToRemove) {
        $GPOsToRemove | ForEach-Object { Remove-GPO -Guid $_.Id -Verbose }
    }
    if ($ReadOnlyMode -eq $True -and $GPOsToRemove) {
        Write-Host "Read-Only mode in enabled. Change 'ReadOnlyMode' parameter to 'False' in order to allow the script make changes" -ForegroundColor Red 
    }
}