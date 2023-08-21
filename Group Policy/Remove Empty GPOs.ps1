# https://azurecloudai.blog/2019/12/20/cleaning-up-the-mess-in-your-group-policy-gpo-environment/

Function Get-GPEmptyGPOs ($ReadOnlyMode = $True) {
    ""
    "Looking for empty GPOs..."
    $EmptyGPOs = @()
    Get-GPO -All | ForEach-Object {
        $IsEmpty = $False
        If ($_.User.DSVersion -eq 0 -and $_.Computer.DSVersion -eq 0) {
            Write-Host "The Group Policy " -nonewline; Write-Host $_.DisplayName -f Yellow -NoNewline; Write-Host " is empty (no settings configured - User and Computer versions are both '0')"
            $EmptyGPOs += $_
            $IsEmpty = $True
        }
        Else {
            [xml]$Report = $_ | Get-GPOReport -ReportType Xml
            If ($Report.GPO.Computer.ExtensionData -eq $NULL -and $Report.GPO.User.ExtensionData -eq $NULL) {
                Write-Host "The Group Policy " -nonewline; Write-Host $_.DisplayName -f Yellow -NoNewline; Write-Host " is empty (no settings configured - No data exist)"
                $EmptyGPOs += $_
                $IsEmpty = $True
            }
        }
        If (-Not $IsEmpty) {
            Write-Host "Group Policy " -NoNewline; Write-Host $_.DisplayName -f Green -NoNewline; Write-Host " is not empty (contains data)"        
        }
    }
    Write-Host "Total of empty GPOs: $($EmptyGPOs.Count)" -f Yellow
    $GPOsToRemove = $EmptyGPOs | Select Id, DisplayName, ModificationTime | Out-GridView -Title "Showing empty Group Policies. Select GPOs you would like to delete" -OutputMode Multiple
    if ($ReadOnlyMode -eq $False -and $GPOsToRemove) {
        $GPOsToRemove | ForEach-Object { Remove-GPO -Guid $_.Id -Verbose }
    }
    if ($ReadOnlyMode -eq $True -and $GPOsToRemove) {
        Write-Host "Read-Only mode in enabled. Change 'ReadOnlyMode' parameter to 'False' in order to allow the script make changes" -ForegroundColor Red 
    }
}