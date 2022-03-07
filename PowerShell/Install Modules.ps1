<#
    .SYNOPSIS
    Install Baseline PowerShell Modules on Client

    .DESCRIPTION
    This module will install the Baseline Set of PowerShell Modules on a client for use with Microsoft Cloud Services and other services tools.

    .PARAMETER SampleParam
    Name of parameter and an explanation of its purpose

    .EXAMPLE
    '.\Install Modules.ps1'

    .NOTES
    Add additional modules as required.
#>

# PowerShell 5.x required. The version of PowerShell included with Windows 10
#Requires -Version 5.0

# Check for Elevated Permissions
Write-Host "Checking for elevated permissions..."
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
[Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Insufficient permissions to run this script. Open the PowerShell console as an administrator and run this script again."
    Pause
    Break
}

#O365 Modules (Required)
Install-Module -Name MSOnline
Install-Module -Name MSCloudLoginAssistant

#MS Azure AD
Install-Module -Name AzureADPreview

#MS Exchange Online
Install-Module -Name ExchangeOnlineManagement

#Security & Compliance Center PowerShell Module
#Install-Module -Name ExchangeOnlineManagement

#MS SharePoint Online
Install-Module -Name Microsoft.Online.SharePoint.PowerShell
Install-Module -Name SharePointOnline.CSOM
Install-Module -Name SharePointPnPPowerShellOnline

#MS Teams
Install-Module -Name MicrosoftTeams
#Install-Module -Name MicrosoftTeams -AllowPrerelease

#MS Graph
Install-Module -Name Microsoft.Graph

#MS PowerApps
Install-Module -Name Microsoft.PowerApps.Administration.PowerShell
Install-Module -Name Microsoft.PowerApps.PowerShell -AllowClobber

#Microsoft Power BI PowerShell Module(s)
Install-Module -Name MicrosoftPowerBIMgmt

#MS Azure Information Protection
Install-Module -Name AIPService

#MS Commerce
Install-Module -Name MSCommerce

#Microsoft / Office 365 Modules (Optional)
Install-Module -Name Microsoft365DSC
Install-Module -Name MCAS
Install-Module -Name MSAL.PS
Install-Module -Name PoshRSJob
Install-Module -Name M365Documentation
Install-Module -Name O365Essentials
Install-Module -Name O365Troubleshooters
Install-Module -Name MicrosoftGraphSecurity

#MS Azure AD - Optional
Install-Module -Name AzureADIncidentResponse
Install-Module -Name AzureADAssessment
Install-Module -Name AzureADExporter
Install-Module -Name AzureADToolkit
	
#MS Graph - Optional
Install-Module -Name Microsoft.Graph.PlusPlus

#Azure Modules (Required)
Install-Module -Name Az

#Azure Modules - Optional
Install-Module -Name PSRule.Rules.Azure

#Installed Modules (Others)
#Update-Module -Name Pester
Install-Module -Name AADInternals
Install-Module -Name ComputerManagementDsc
Install-Module -Name DSCParser
Install-Module -Name DSInternals
Install-Module -Name NetworkingDsc
Install-Module -Name PnP.PowerShell
#Install-Module -Name PIMTools
Install-Module -Name Posh-SSH
Install-Module -Name ps2exe
Install-Module -Name PSFTP
Install-Module -Name PSReadLine
Install-Module -Name PSRule
Install-Module -Name PSScriptAnalyzer
Install-Module -Name ReportHTML
Install-Module -Name ReverseDSC
Install-Module -Name SqlServer
Install-Module -Name Subnet
Install-Module -Name Terminal-Icons
Install-Module -Name WindowsAutoPilotIntune

Install-Module -Name MsrcSecurityUpdates
Install-Module -Name PSWindowsUpdate
Install-Module -Name PowerShellGet
#Install-Module -Name PowerShellGet -RequiredVersion 2.2.4.1 -Force
Install-Module -Name PendingReboot
Install-Module -Name VSSetup
Install-Module -Name xCertificate





