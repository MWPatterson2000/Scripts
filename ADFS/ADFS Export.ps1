<#
Name: ADFS Export.ps1

This script is for Exporting All ADFS Settings.

Michael Patterson
scripts@mwpatterson.com

Revision History
    YYYY-MM-DD - Initial Release
    2023-04-06 - Added Variables where to put the Exports

#>

# Start Function(s)
# Clear Varables
function Get-UserVariable ($Name = '*') {
    # these variables may exist in certain environments (like ISE, or after use of foreach)
    $special = 'ps','psise','psunsupportedconsoleapplications', 'foreach', 'profile'

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

# Clear Screen
Clear-Host

<#
# Self-elevate the script if required
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { 
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}
#>

<#
# Check For Admin Mode
#Requires -RunAsAdministrator
#>

# PowerShell 5.x required. The version of PowerShell included with Windows 10
#Requires -Version 5.0

# Write Output
Write-Host "Export All ADFA Data" -ForegroundColor Green

# Get Date & Backup Locations
#$date = get-date -Format "yyyy-MM-dd-HH-mm"
#$date = get-date -Format "yyyy-MM-dd-HH"
$date = get-date -Format "yyyy-MM-dd"
$backupRoot = "C" #Can use another drive if available
$backupFolder = "ADFSBackup"
$backupFolderPath = $backupRoot + ":\" + $backupFolder + "\"
$backupPath = $backupFolderPath + $date

# Verify ADFS BackupFolder
Write-Host "`tPlease Wait - Checking for Backup Directory" -ForegroundColor Yellow
if ((Test-Path $backupFolderPath) -eq $false) {
    New-Item -Path $backupFolderPath -ItemType directory
}

# Verify ADFS Date BackupPath
Write-Host "`tPlease Wait - Creating Backup Directory" -ForegroundColor Yellow
if ((Test-Path $backupPath) -eq $false) {
    New-Item -Path $backupPath -ItemType directory
}

# Export ADFS Settings
Get-AdfsAdditionalAuthenticationRule | Export-CSV "($backupPath)$env:COMPUTERNAME - ADFSAdditionalAuthenticationRule.csv"
Get-AdfsAttributeStore | Export-CSV "($backupPath)$env:COMPUTERNAME - ADFSAttributeStore.csv"
Get-AdfsAuthenticationProvider | Export-CSV "($backupPath)$env:COMPUTERNAME - ADFSAuthenticationProvider.csv"
Get-AdfsAuthenticationProviderWebContent | Export-CSV "($backupPath)$env:COMPUTERNAME - ADFSAuthenticationProviderWebContent.csv"
Get-AdfsCertificate | Export-CSV "($backupPath)$env:COMPUTERNAME - ADFSCertificate.csv"
Get-AdfsClaimDescription | Export-CSV "($backupPath)$env:COMPUTERNAME - ADFSClaimDescription.csv"
Get-AdfsClaimsProviderTrust | Export-CSV "($backupPath)$env:COMPUTERNAME - ADFSClaimsProviderTrust.csv"
Get-AdfsClient | Export-CSV "($backupPath)$env:COMPUTERNAME - ADFSClient.csv"
Get-AdfsDeviceRegistration | Export-CSV "($backupPath)$env:COMPUTERNAME - ADFSDeviceRegistration .csv"
Get-AdfsDeviceRegistrationUpnSuffix | Export-CSV "($backupPath)$env:COMPUTERNAME - ADFSDeviceRegistrationUpnSuffix .csv"
Get-AdfsEndpoint | Export-CSV "($backupPath)$env:COMPUTERNAME - ADFSEndpoint.csv"
Get-AdfsGlobalAuthenticationPolicy | Export-CSV "($backupPath)$env:COMPUTERNAME - ADFSGlobalAuthenticationPolicy.csv"
Get-AdfsGlobalWebContent | Export-CSV "($backupPath)$env:COMPUTERNAME - ADFSGlobalWebContent.csv"
Get-AdfsNonClaimsAwareRelyingPartyTrust | Export-CSV "($backupPath)$env:COMPUTERNAME - ADFSNonClaimsAwareRelyingPartyTrust.csv"
Get-AdfsProperties | Export-CSV "($backupPath)$env:COMPUTERNAME - ADFSProperties.csv"
Get-AdfsRegistrationHosts | Export-CSV "($backupPath)$env:COMPUTERNAME - ADFSRegistrationHosts.csv"
Get-AdfsRelyingPartyTrust | Export-CSV "($backupPath)$env:COMPUTERNAME - ADFSRelyingPartyTrust.csv"
Get-AdfsRelyingPartyWebContent | Export-CSV "($backupPath)$env:COMPUTERNAME - ADFSRelyingPartyWebContent.csv"
Get-AdfsSslCertificate | Export-CSV "($backupPath)$env:COMPUTERNAME - ADFSSslCertificate.csv"
Get-AdfsSyncProperties | Export-CSV "($backupPath)$env:COMPUTERNAME - ADFSSyncProperties.csv"
Get-AdfsWebApplicationProxyRelyingPartyTrust | Export-CSV "($backupPath)$env:COMPUTERNAME - ADFSWebApplicationProxyRelyingPartyTrust .csv"
Get-AdfsWebConfig | Export-CSV "($backupPath)$env:COMPUTERNAME - ADFSWebConfig.csv"
Get-AdfsWebTheme | Export-CSV "($backupPath)$env:COMPUTERNAME - ADFSWebTheme.csv"

# Clear Variables
Get-UserVariable | Remove-Variable

# End
