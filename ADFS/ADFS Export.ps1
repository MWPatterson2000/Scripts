<#
Name: ADFS Export.ps1

This script is for Exporting All ADFS Settings.

Michael Patterson
scripts@mwpatterson.com

Revision History
    YYYY-MM-DD - Initial Release
    2023-04-06 - Added Variables where to put the Exports
    2023-06-14 - Added Additional Commands for ADFS 4.x
                    Added Export as JSON as well
    2023-11-22 - Converting to Advanced

#>
[CmdletBinding()]
[Alias()]
[OutputType([int])]
Param(
    # Parameter help description
    #[Parameter(AttributeValues)]
    #[ParameterType]
    #$ParameterName
)

Begin {
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


    # Clear Varables
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

    # Get Date & Backup Locations
    $date = get-date -Format 'yyyy-MM-dd-HH-mm'
    $backupRoot = 'C' #Can use another drive if available
    $backupFolder = "Temp\Mike\$date"
    $backupFolderPath = $backupRoot + ':\' + $backupFolder + '\'
    $backupPath = $backupFolderPath + $date
}

Process {
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

    # Export ADFS Settings as CSV Files
    Get-AdfsAccessControlPolicy | Export-CSV "$backupPath\$env:COMPUTERNAME - ADFSAccessControlPolicy.csv"
    Get-AdfsAdditionalAuthenticationRule | Export-CSV "$backupPath\$env:COMPUTERNAME - ADFSAdditionalAuthenticationRule.csv"
    Get-AdfsApplicationGroup  | Export-CSV "$backupPath\$env:COMPUTERNAME - ADFSApplicationGroup.csv"
    Get-AdfsApplicationPermission  | Export-CSV "$backupPath\$env:COMPUTERNAME - ADFSApplicationPermission.csv"
    Get-AdfsAttributeStore | Export-CSV "$backupPath\$env:COMPUTERNAME - ADFSAttributeStore.csv"
    Get-AdfsAuthenticationProvider | Export-CSV "$backupPath\$env:COMPUTERNAME - ADFSAuthenticationProvider.csv"
    Get-AdfsAuthenticationProviderWebContent | Export-CSV "$backupPath\$env:COMPUTERNAME - ADFSAuthenticationProviderWebContent.csv"
    Get-AdfsAzureMfaConfigured | Export-CSV "$backupPath\$env:COMPUTERNAME - ADFSAzureMfaConfigured.csv"
    Get-AdfsCertificate | Export-CSV "$backupPath\$env:COMPUTERNAME - ADFSCertificate.csv"
    Get-AdfsCertificateAuthority | Export-CSV "$backupPath\$env:COMPUTERNAME - ADFSCertificateAuthority.csv"
    Get-AdfsClaimDescription | Export-CSV "$backupPath\$env:COMPUTERNAME - ADFSClaimDescription.csv"
    Get-AdfsClaimsProviderTrust | Export-CSV "$backupPath\$env:COMPUTERNAME - ADFSClaimsProviderTrust.csv"
    Get-AdfsClaimsProviderTrustsGroup | Export-CSV "$backupPath\$env:COMPUTERNAME - ADFSClaimsProviderTrustsGroup.csv"
    Get-AdfsClient | Export-CSV "$backupPath\$env:COMPUTERNAME - ADFSClient.csv"
    Get-AdfsDeviceRegistration | Export-CSV "$backupPath\$env:COMPUTERNAME - ADFSDeviceRegistration .csv"
    Get-AdfsDeviceRegistrationUpnSuffix | Export-CSV "$backupPath\$env:COMPUTERNAME - ADFSDeviceRegistrationUpnSuffix .csv"
    Get-AdfsEndpoint | Export-CSV "$backupPath\$env:COMPUTERNAME - ADFSEndpoint.csv"
    Get-AdfsFarmInformation | Export-CSV "$backupPath\$env:COMPUTERNAME - ADFSFarmInformation.csv"
    Get-AdfsGlobalAuthenticationPolicy | Export-CSV "$backupPath\$env:COMPUTERNAME - ADFSGlobalAuthenticationPolicy.csv"
    Get-AdfsGlobalWebContent | Export-CSV "$backupPath\$env:COMPUTERNAME - ADFSGlobalWebContent.csv"
    Get-AdfsLocalClaimsProviderTrust | Export-CSV "$backupPath\$env:COMPUTERNAME - ADFSLocalClaimsProviderTrust.csv"
    Get-AdfsNativeClientApplication | Export-CSV "$backupPath\$env:COMPUTERNAME - ADFSNativeClientApplication.csv"
    Get-AdfsNonClaimsAwareRelyingPartyTrust | Export-CSV "$backupPath\$env:COMPUTERNAME - ADFSNonClaimsAwareRelyingPartyTrust.csv"
    Get-AdfsProperties | Export-CSV "$backupPath\$env:COMPUTERNAME - ADFSProperties.csv"
    Get-AdfsRegistrationHosts | Export-CSV "$backupPath\$env:COMPUTERNAME - ADFSRegistrationHosts.csv"
    Get-AdfsRelyingPartyTrust | Export-CSV "$backupPath\$env:COMPUTERNAME - ADFSRelyingPartyTrust.csv"
    Get-AdfsRelyingPartyTrustsGroup | Export-CSV "$backupPath\$env:COMPUTERNAME - ADFSRelyingPartyTrustsGroup.csv"
    Get-AdfsRelyingPartyWebContent | Export-CSV "$backupPath\$env:COMPUTERNAME - ADFSRelyingPartyWebContent.csv" ConvertTo-Json | Out-File 
    Get-AdfsRelyingPartyWebTheme | Export-CSV "$backupPath\$env:COMPUTERNAME - ADFSRelyingPartyWebTheme.csv"
    Get-AdfsResponseHeaders | Export-CSV "$backupPath\$env:COMPUTERNAME - ADFSResponseHeaders.csv"
    Get-AdfsScopeDescription | Export-CSV "$backupPath\$env:COMPUTERNAME - ADFSScopeDescription.csv"
    Get-AdfsServerApplication | Export-CSV "$backupPath\$env:COMPUTERNAME - ADFSServerApplication.csv"
    Get-AdfsSslCertificate | Export-CSV "$backupPath\$env:COMPUTERNAME - ADFSSslCertificate.csv"
    Get-AdfsSyncProperties | Export-CSV "$backupPath\$env:COMPUTERNAME - ADFSSyncProperties.csv"
    Get-AdfsTrustedFederationPartner | Export-CSV "$backupPath\$env:COMPUTERNAME - ADFSSyncTrustedFederationPartner.csv"
    Get-AdfsWebApiApplication | Export-CSV "$backupPath\$env:COMPUTERNAME - ADFSSyncWebApiApplication.csv"
    Get-AdfsWebApplicationProxyRelyingPartyTrust | Export-CSV "$backupPath\$env:COMPUTERNAME - ADFSWebApplicationProxyRelyingPartyTrust .csv"
    Get-AdfsWebConfig | Export-CSV "$backupPath\$env:COMPUTERNAME - ADFSWebConfig.csv"
    Get-AdfsWebTheme | Export-CSV "$backupPath\$env:COMPUTERNAME - ADFSWebTheme.csv"

    # Export ADFS Settings as JSON Files
    Get-AdfsAccessControlPolicy | ConvertTo-Json | Out-File  "$backupPath\$env:COMPUTERNAME - ADFSAccessControlPolicy.json "
    Get-AdfsAdditionalAuthenticationRule | ConvertTo-Json | Out-File  "$backupPath\$env:COMPUTERNAME - ADFSAdditionalAuthenticationRule.json "
    Get-AdfsApplicationGroup  | ConvertTo-Json | Out-File  "$backupPath\$env:COMPUTERNAME - ADFSApplicationGroup.json "
    Get-AdfsApplicationPermission  | ConvertTo-Json | Out-File  "$backupPath\$env:COMPUTERNAME - ADFSApplicationPermission.json "
    Get-AdfsAttributeStore | ConvertTo-Json | Out-File  "$backupPath\$env:COMPUTERNAME - ADFSAttributeStore.json "
    Get-AdfsAuthenticationProvider | ConvertTo-Json | Out-File  "$backupPath\$env:COMPUTERNAME - ADFSAuthenticationProvider.json "
    Get-AdfsAuthenticationProviderWebContent | ConvertTo-Json | Out-File  "$backupPath\$env:COMPUTERNAME - ADFSAuthenticationProviderWebContent.json "
    Get-AdfsAzureMfaConfigured | ConvertTo-Json | Out-File  "$backupPath\$env:COMPUTERNAME - ADFSAzureMfaConfigured.json "
    Get-AdfsCertificate | ConvertTo-Json | Out-File  "$backupPath\$env:COMPUTERNAME - ADFSCertificate.json "
    Get-AdfsCertificateAuthority | ConvertTo-Json | Out-File  "$backupPath\$env:COMPUTERNAME - ADFSCertificateAuthority.json "
    Get-AdfsClaimDescription | ConvertTo-Json | Out-File  "$backupPath\$env:COMPUTERNAME - ADFSClaimDescription.json "
    Get-AdfsClaimsProviderTrust | ConvertTo-Json | Out-File  "$backupPath\$env:COMPUTERNAME - ADFSClaimsProviderTrust.json "
    Get-AdfsClaimsProviderTrustsGroup | ConvertTo-Json | Out-File  "$backupPath\$env:COMPUTERNAME - ADFSClaimsProviderTrustsGroup.json "
    Get-AdfsClient | ConvertTo-Json | Out-File  "$backupPath\$env:COMPUTERNAME - ADFSClient.json "
    Get-AdfsDeviceRegistration | ConvertTo-Json | Out-File  "$backupPath\$env:COMPUTERNAME - ADFSDeviceRegistration .json "
    Get-AdfsDeviceRegistrationUpnSuffix | ConvertTo-Json | Out-File  "$backupPath\$env:COMPUTERNAME - ADFSDeviceRegistrationUpnSuffix .json "
    Get-AdfsEndpoint | ConvertTo-Json | Out-File  "$backupPath\$env:COMPUTERNAME - ADFSEndpoint.json "
    Get-AdfsFarmInformation | ConvertTo-Json | Out-File  "$backupPath\$env:COMPUTERNAME - ADFSFarmInformation.json "
    Get-AdfsGlobalAuthenticationPolicy | ConvertTo-Json | Out-File  "$backupPath\$env:COMPUTERNAME - ADFSGlobalAuthenticationPolicy.json "
    Get-AdfsGlobalWebContent | ConvertTo-Json | Out-File  "$backupPath\$env:COMPUTERNAME - ADFSGlobalWebContent.json "
    Get-AdfsLocalClaimsProviderTrust | ConvertTo-Json | Out-File  "$backupPath\$env:COMPUTERNAME - ADFSLocalClaimsProviderTrust.json "
    Get-AdfsNativeClientApplication | ConvertTo-Json | Out-File  "$backupPath\$env:COMPUTERNAME - ADFSNativeClientApplication.json "
    Get-AdfsNonClaimsAwareRelyingPartyTrust | ConvertTo-Json | Out-File  "$backupPath\$env:COMPUTERNAME - ADFSNonClaimsAwareRelyingPartyTrust.json "
    Get-AdfsProperties | ConvertTo-Json | Out-File  "$backupPath\$env:COMPUTERNAME - ADFSProperties.json "
    Get-AdfsRegistrationHosts | ConvertTo-Json | Out-File  "$backupPath\$env:COMPUTERNAME - ADFSRegistrationHosts.json "
    Get-AdfsRelyingPartyTrust | ConvertTo-Json | Out-File  "$backupPath\$env:COMPUTERNAME - ADFSRelyingPartyTrust.json "
    Get-AdfsRelyingPartyTrustsGroup | ConvertTo-Json | Out-File  "$backupPath\$env:COMPUTERNAME - ADFSRelyingPartyTrustsGroup.json "
    Get-AdfsRelyingPartyWebContent | ConvertTo-Json | Out-File  "$backupPath\$env:COMPUTERNAME - ADFSRelyingPartyWebContent.json "
    Get-AdfsRelyingPartyWebTheme | ConvertTo-Json | Out-File  "$backupPath\$env:COMPUTERNAME - ADFSRelyingPartyWebTheme.json "
    Get-AdfsResponseHeaders | ConvertTo-Json | Out-File  "$backupPath\$env:COMPUTERNAME - ADFSResponseHeaders.json "
    Get-AdfsScopeDescription | ConvertTo-Json | Out-File  "$backupPath\$env:COMPUTERNAME - ADFSScopeDescription.json "
    Get-AdfsServerApplication | ConvertTo-Json | Out-File  "$backupPath\$env:COMPUTERNAME - ADFSServerApplication.json "
    Get-AdfsSslCertificate | ConvertTo-Json | Out-File  "$backupPath\$env:COMPUTERNAME - ADFSSslCertificate.json "
    Get-AdfsSyncProperties | ConvertTo-Json | Out-File  "$backupPath\$env:COMPUTERNAME - ADFSSyncProperties.json "
    Get-AdfsTrustedFederationPartner | ConvertTo-Json | Out-File  "$backupPath\$env:COMPUTERNAME - ADFSSyncTrustedFederationPartner.json "
    Get-AdfsWebApiApplication | ConvertTo-Json | Out-File  "$backupPath\$env:COMPUTERNAME - ADFSSyncWebApiApplication.json "
    Get-AdfsWebApplicationProxyRelyingPartyTrust | ConvertTo-Json | Out-File  "$backupPath\$env:COMPUTERNAME - ADFSWebApplicationProxyRelyingPartyTrust .json "
    Get-AdfsWebConfig | ConvertTo-Json | Out-File  "$backupPath\$env:COMPUTERNAME - ADFSWebConfig.json "
    Get-AdfsWebTheme | ConvertTo-Json | Out-File  "$backupPath\$env:COMPUTERNAME - ADFSWebTheme.json "

}

End {
    # Clear Variables
    Write-Host "`nScript Cleanup"
    Get-UserVariable | Remove-Variable -ErrorAction SilentlyContinue

    # End
    Exit
}
