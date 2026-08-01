<#
.SYNOPSIS
    Installs a baseline set of PowerShell modules on a client.

.DESCRIPTION
    This script installs the standard PowerShell modules used for Microsoft 365, Azure, security, and automation workflows. It uses grouped module lists so the installation logic is easier to maintain and avoids repeating the same setup steps.

.NOTES
    Revision History
    2026-07-31 - Reworked the module list into grouped installs and added a header note describing the change.
#>

# PowerShell 5.x required. The version of PowerShell included with Windows 10
#Requires -Version 5.0

$ErrorActionPreference = 'Stop'

Write-Host 'Checking for elevated permissions...'
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
            [Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    Write-Warning 'Insufficient permissions to run this script. Open the PowerShell console as an administrator and run this script again.'
    Pause
    Break
}

$requiredModules = @(
    'MSOnline',
    'MSCloudLoginAssistant',
    'AzureADPreview',
    'ExchangeOnlineManagement',
    'Microsoft.Online.SharePoint.PowerShell',
    'SharePointOnline.CSOM',
    'SharePointPnPPowerShellOnline',
    'MicrosoftTeams',
    'Microsoft.Graph',
    'Microsoft.PowerApps.Administration.PowerShell',
    'Microsoft.PowerApps.PowerShell',
    'MicrosoftPowerBIMgmt',
    'AIPService',
    'MSCommerce',
    'Microsoft365DSC',
    'MCAS',
    'MSAL.PS',
    'PoshRSJob',
    'M365Documentation',
    'O365Essentials',
    'O365Troubleshooters',
    'MicrosoftGraphSecurity',
    'AzureADIncidentResponse',
    'AzureADAssessment',
    'AzureADExporter',
    'AzureADToolkit',
    'Microsoft.Graph.PlusPlus',
    'Az',
    'PSRule.Rules.Azure',
    'AADInternals',
    'ComputerManagementDsc',
    'DSCParser',
    'DSInternals',
    'NetworkingDsc',
    'PnP.PowerShell',
    'Posh-SSH',
    'ps2exe',
    'PSFTP',
    'PSReadLine',
    'PSRule',
    'PSScriptAnalyzer',
    'ReportHTML',
    'ReverseDSC',
    'SqlServer',
    'Subnet',
    'Terminal-Icons',
    'WindowsAutoPilotIntune',
    'MsrcSecurityUpdates',
    'PSWindowsUpdate',
    'PowerShellGet',
    'PendingReboot',
    'VSSetup',
    'xCertificate'
)

foreach ($moduleName in $requiredModules) {
    if ($moduleName -eq 'Microsoft.PowerApps.PowerShell') {
        Install-Module -Name $moduleName -AllowClobber -ErrorAction Stop
    }
    else {
        Install-Module -Name $moduleName -ErrorAction Stop
    }
}

