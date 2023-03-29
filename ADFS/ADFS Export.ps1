<#
Name: .ps1

This script is for .

Michael Patterson
scripts@mwpatterson.com

Revision History
    YYYY-MM-DD - Initial Release

#>

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
function Get-UserVariable ($Name = '*')
{
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

# Set Variables
#$today = Get-Date
#$today = $today.ToString("dddd MMMM-dd-yyyy hh:mm tt")

# Export ADFS SEttings

Get-AdfsAdditionalAuthenticationRule | Export-CSV "C:\Temp\$(get-date -f yyyy-MM-dd) - $env:COMPUTERNAME - ADFSAdditionalAuthenticationRule.csv"
Get-AdfsAttributeStore | Export-CSV "C:\Temp\$(get-date -f yyyy-MM-dd) - $env:COMPUTERNAME - ADFSAttributeStore.csv"
Get-AdfsAuthenticationProvider | Export-CSV "C:\Temp\$(get-date -f yyyy-MM-dd) - $env:COMPUTERNAME - ADFSAuthenticationProvider.csv"
Get-AdfsAuthenticationProviderWebContent | Export-CSV "C:\Temp\$(get-date -f yyyy-MM-dd) - $env:COMPUTERNAME - ADFSAuthenticationProviderWebContent.csv"
Get-AdfsCertificate | Export-CSV "C:\Temp\$(get-date -f yyyy-MM-dd) - $env:COMPUTERNAME - ADFSCertificate.csv"
Get-AdfsClaimDescription | Export-CSV "C:\Temp\$(get-date -f yyyy-MM-dd) - $env:COMPUTERNAME - ADFSClaimDescription.csv"
Get-AdfsClaimsProviderTrust | Export-CSV "C:\Temp\$(get-date -f yyyy-MM-dd) - $env:COMPUTERNAME - ADFSClaimsProviderTrust.csv"
Get-AdfsClient | Export-CSV "C:\Temp\$(get-date -f yyyy-MM-dd) - $env:COMPUTERNAME - ADFSClient.csv"
Get-AdfsDeviceRegistration | Export-CSV "C:\Temp\$(get-date -f yyyy-MM-dd) - $env:COMPUTERNAME - ADFSDeviceRegistration .csv"
Get-AdfsDeviceRegistrationUpnSuffix | Export-CSV "C:\Temp\$(get-date -f yyyy-MM-dd) - $env:COMPUTERNAME - ADFSDeviceRegistrationUpnSuffix .csv"
Get-AdfsEndpoint | Export-CSV "C:\Temp\$(get-date -f yyyy-MM-dd) - $env:COMPUTERNAME - ADFSEndpoint.csv"
Get-AdfsGlobalAuthenticationPolicy | Export-CSV "C:\Temp\$(get-date -f yyyy-MM-dd) - $env:COMPUTERNAME - ADFSGlobalAuthenticationPolicy.csv"
Get-AdfsGlobalWebContent | Export-CSV "C:\Temp\$(get-date -f yyyy-MM-dd) - $env:COMPUTERNAME - ADFSGlobalWebContent.csv"
Get-AdfsNonClaimsAwareRelyingPartyTrust | Export-CSV "C:\Temp\$(get-date -f yyyy-MM-dd) - $env:COMPUTERNAME - ADFSNonClaimsAwareRelyingPartyTrust.csv"
Get-AdfsProperties | Export-CSV "C:\Temp\$(get-date -f yyyy-MM-dd) - $env:COMPUTERNAME - ADFSProperties.csv"
Get-AdfsRegistrationHosts | Export-CSV "C:\Temp\$(get-date -f yyyy-MM-dd) - $env:COMPUTERNAME - ADFSRegistrationHosts.csv"
Get-AdfsRelyingPartyTrust | Export-CSV "C:\Temp\$(get-date -f yyyy-MM-dd) - $env:COMPUTERNAME - ADFSRelyingPartyTrust.csv"
Get-AdfsRelyingPartyWebContent | Export-CSV "C:\Temp\$(get-date -f yyyy-MM-dd) - $env:COMPUTERNAME - ADFSRelyingPartyWebContent.csv"
Get-AdfsSslCertificate | Export-CSV "C:\Temp\$(get-date -f yyyy-MM-dd) - $env:COMPUTERNAME - ADFSSslCertificate.csv"
Get-AdfsSyncProperties | Export-CSV "C:\Temp\$(get-date -f yyyy-MM-dd) - $env:COMPUTERNAME - ADFSSyncProperties.csv"
Get-AdfsWebApplicationProxyRelyingPartyTrust | Export-CSV "C:\Temp\$(get-date -f yyyy-MM-dd) - $env:COMPUTERNAME - ADFSWebApplicationProxyRelyingPartyTrust .csv"
Get-AdfsWebConfig | Export-CSV "C:\Temp\$(get-date -f yyyy-MM-dd) - $env:COMPUTERNAME - ADFSWebConfig.csv"
Get-AdfsWebTheme | Export-CSV "C:\Temp\$(get-date -f yyyy-MM-dd) - $env:COMPUTERNAME - ADFSWebTheme.csv"

# Clear Variables
Get-UserVariable | Remove-Variable