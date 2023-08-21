# https://azurecloudai.blog/2019/12/20/cleaning-up-the-mess-in-your-group-policy-gpo-environment/

Function Get-GPUnlinkedGPOs ($ReadOnlyMode = $True) { 
    ""
    "Looking for unlinked GPOs..."
    $UnlinkedGPOs = @()
    Get-GPO -All | ForEach-Object {
        If ($_ | Get-GPOReport -ReportType XML | Select-String -NotMatch "<LinksTo>" ) {
            Write-Host "Group Policy " -NoNewline; Write-Host $_.DisplayName -f Yellow -NoNewline; Write-Host " is not linked to any object (OU/Site/Domain)"
            $UnlinkedGPOs += $_
        }
        Else {
            Write-Host "Group Policy " -NoNewline; Write-Host $_.DisplayName -f Green -NoNewline; Write-Host " is linked"         
        }
    }
    Write-Host "Total of unlinked GPOs: $($UnlinkedGPOs.Count)" -f Yellow
    $GPOsToRemove = $UnlinkedGPOs | Select Id, DisplayName, ModificationTime | Out-GridView -Title "Showing unlinked Group Policies. Select GPOs you would like to delete" -OutputMode Multiple
    if ($ReadOnlyMode -eq $False -and $GPOsToRemove) {
        $GPOsToRemove | ForEach-Object { Remove-GPO -Guid $_.Id -Verbose }
    }
    if ($ReadOnlyMode -eq $True -and $GPOsToRemove) {
        Write-Host "Read-Only mode in enabled. Change 'ReadOnlyMode' parameter to 'False' in order to allow the script make changes" -ForegroundColor Red 
    }
}