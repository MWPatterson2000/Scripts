<#
	
	.NOTES
		===========================================================================

		Created on:   	2016-09-15 4:38 AM
		Created by:   	John@Onenote4exchange.com
		Organization: 	Onenote4exchange.com
		Filename:
		===========================================================================

	.SYNOPSIS
		This Script has been created to backup the AD FS 3.0 configuration in case you apply any change and you would like to reverse back.
	
	.DESCRIPTION
		 this script will assist you to get a copy of the following configuration & Settings:
			Retreive every information of your ADFS environment using any get & Export CMDLet from ADFS powershell Module
		Information like would be collect:
			Custom Configuration of an External AUthentication provider
			WebContent object
			Theme
			Certificate information (the certificate won t be export as pfx)
			Claims: Description, Provider trust
			Device registration
			relying party
			Collect Service Account use by Federation Service
		This script need to be run on the Primary node
			
		 

#>


###############################################################################################################################################################################
########################################################             Module & Variable & Folders                ###############################################################
###############################################################################################################################################################################


####################  Import ADFS Module  ####################

Import-module ADFS -ErrorAction 'Stop' -ErrorVariable Error_ImportModule_ADFS
# Check if loading the Active Directory module failed
If ($Error_ImportModule_ADFS)
{
	Write-Log Error $LogFile "Failed to load ADFS Module"
	Write-Log Error $LogFile "Failed with Error:$Error_ImportModule_ADFS"
	Write-Host "Failed to Load the ADFS Module" -ForegroundColor 'Red'
	Write-host "Script Failed during an Attempt to Load the ADFS Module" -ForegroundColor 'Red' -BackgroundColor 'Yellow'
}
####################  Variables  ####################
$Date = $Date = get-date -UFormat %d%m%Y
$DateFull = Get-Date -Format "ddMMyyyy_HH-mm-ss"
$Themes = @()
$ServerName = [Environment]::MachineName
###### Root Folder
$RootFolder = $psscriptRoot + "\Backup_ADFS"

###### Create folder for Progress log Folder
$LogPathFolder = $RootFolder + "\Log\"
$LogFile = $LogPathFolder + "Progress_" + $Date + ".log"

###### Backup Folder Path
$RootBackupFolder = $RootFolder + "\Backup_" + "$DateFull"
$BackupPathFolder = $RootBackupFolder + "\ADFS_Backup_Configuration\"
$ThemeRootFolder = $RootBackupFolder + "\Themes\"
$ProviderFolder = $RootBackupFolder + "\Custom_Authentication_Providers\"
$ArchivePathFolder = $RootFolder + "\Archives\"




###############################################################################################################################################################################
####################################################################               Function               #####################################################################
###############################################################################################################################################################################

Function Create-Folder
{
	param
	(
		[Parameter(Mandatory = $true,
				   Position = 1)]
		[string]$Path,
		[Parameter(Mandatory = $true,
				   Position = 2)]
		[String]$LogFile
	)
	
	If (!(Test-Path $Path))
	{ New-Item $Path -Type Directory -ErrorVariable FolderCreationFailed }
	Else
	{
		Write-Host  "The folder $Path is already created" -ForegroundColor Yellow
	
	}
	
	# Check if no error occurs during the folder creation
	If ($FolderCreationFailed)
	{
		
		Write-Host  "The folder $Path failed to be created" -ForegroundColor Red -BackgroundColor Yellow
		Write-Host  "Folder creation failed with error: $FolderCreationFailed" -ForegroundColor Red -BackgroundColor Yellow
	}
}

Function Write-Log
{
	[CmdletBinding()]
	Param ([Parameter(Mandatory = $true)]
		[string]$Level,
		[Parameter(Mandatory = $true)]
		[string]$LogPath,
		[Parameter(Mandatory = $true)]
		[string]$Message)
	
	
	If ($Level -eq "Warning")
	{
		# Write warning log
		Write-Output "[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")]  WARNING: $Message" | Out-File -FilePath $LogPath -Append
		Write-Host "[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")]" -nonewline; Write-host "  WARNING: " -ForegroundColor Yellow -NoNewline; Write-Host $Message
	}
	Else
	{
		If ($Level -eq "Error")
		{
			# Write Error log
			Write-Output "[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")]  Error: $Message" | Out-File -FilePath $LogPath -Append
			Write-Host "[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")]" -nonewline; Write-host "  Error: " -ForegroundColor Red -NoNewline; Write-Host $Message
		}
		Else
		{
			# Write Information log
			Write-Output "[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")]  INFO: $Message" | Out-File -FilePath $LogPath -Append
			Write-Host "[$(Get-Date -Format "yyyy-MM-dd HH:mm:ss")]" -nonewline; Write-host "  INFO: " -ForegroundColor White -NoNewline; Write-Host $Message
		}
	}
}

###############################################################################################################################################################################
####################################################################               Main Script           #####################################################################
###############################################################################################################################################################################

########### Create the required folders
Create-Folder $RootFolder $LogFile
Create-Folder $LogPathFolder $LogFile
Create-Folder $RootBackupFolder $LogFile
Create-Folder $BackupPathFolder $LogFile
Create-Folder $ThemeRootFolder $LogFile
Create-Folder $ProviderFolder $LogFile
Create-Folder $ArchivePathFolder $LogFile

########### Initiate the Process log file when the script started ############
$Initiat_LogA = "#################### starting the Script #####################"
$Startat = "### The Script has been launch at $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")"
$Startwith = "The Script has been start with the following Account:" + [Environment]::UserName
$Starton = "The Script has been start on the following Computer:" + [Environment]::MachineName
$Initiat_LogB = "##############################################################"
$Initiat_LogB | Out-File -FilePath $LogFile -Append
$Initiat_LogB | Out-File -FilePath $LogFile -Append
$Initiat_LogA | Out-File -FilePath $LogFile -Append
$Startat | Out-File -FilePath $LogFile -Append
$Startwith | Out-File -FilePath $LogFile -Append
$Starton | Out-File -FilePath $LogFile -Append
$Initiat_LogB | Out-File -FilePath $LogFile -Append
$Initiat_LogB | Out-File -FilePath $LogFile -Append

###############################################################################################################################################################################
########################################################               Get CMDLet - ADFS Configuration                #########################################################
###############################################################################################################################################################################
$ADFSCMDLets = get-command get-adfs*
foreach ($CMDLet in $ADFSCMDLets)
{
	$GetCMDLet = $CMDLet.Name
	$GetXML = $BackupPathFolder + $GetCMDLet + ".xml"
	Invoke-Command -ScriptBlock {$GetCMDLet | Export-Clixml $GetXML}
	Write-Log WARNING $LogFile "the script to run the following CMD let: $GetCMDLet"
	Write-Log INFO $LogFile "the script export the result to the following location: $GetXML"
}

###############################################################################################################################################################################
########################################################                Export CMDLet - ADFS Configuration                #########################################################
###############################################################################################################################################################################


####################  Export-ADFSWebTheme  ####################
Write-Log INFO $LogFile "Get the list of ADFS theme create on this AD FS Server"
$Themes = Get-ADFSWebTheme -errorvariable ErrorGetThemes
If ($ErrorGetThemes)
{
	Write-Log ERROR $LogFile "Failed to find the list of themes"
	Write-Log ERROR $LogFile "Failed with error: $ErrorGetThemes"
}

Else
{
	foreach ($Theme in $Themes)
	{
		$Name = $Theme.Name
		$ThemeFolder = $ThemeRootFolder + $Name
		##### test and Create subfolder to backup the theme
		Create-Folder $ThemeFolder $LogFile
		##### Export Theme to Subfolder	
		Export-ADFSWebTheme -Name $Name -Directory $ThemeFolder -errorvariable FailedExportTheme
		# Check if no error occurs while exporting the theme
		If ($FolderCreationFailed)
		{
			Write-Log ERROR $LogFile "Failed to export the Theme: $Name to $ThemeFolder"
			Write-Log ERROR $LogFile "Export failed with error: $FolderCreationFailed"
		}
		Else
		{ Write-Log INFO $LogFile "the Theme $Name has been exported to $ThemeFolder"}
	}
}

####################  Export-AdfsWebContent  ####################
# This command can be use to export customization base on the user location. will be update on next version if it s required
# Source: https://technet.microsoft.com/en-us/library/dn479396(v=wps.630).aspx


####################   Export-AdfsAuthenticationProviderConfigurationData  ####################
# Export All the custom configuration of an external authentication provide to a file
$ADFSAuthenProviders = @()
$ADFSAuthenProviders = Get-AdfsAuthenticationProvider | where { $_.IsCustom -match "True" } -ErrorVariable ErrorGetADFSAuthenProviders
$Number_Provider = $ADFSAuthenProviders | measure
$Number = $Number_Provider.count
Write-Log WARNING $LogFile " $Number of ADFS Authentication Provider"
If ($ErrorGetADFSAuthenProviders)
{
	Write-Log ERROR $LogFile "Failed to find the list of custom ADFS Authentication Providers"
	Write-Log ERROR $LogFile "Failed with error: $ErrorGetADFSAuthenProviders"
}
Else
{
	
	foreach ($ADFSAuthenProvider in $ADFSAuthenProviders)
	{
		$Provider = $ADFSAuthenProvider.Name
		$ProviderFile = $ProviderFolder + $Provider + ".txt"
		##### Export Provider to Subfolder	
		Export-AdfsAuthenticationProviderConfigurationData -name $Provider -FilePath $ProviderFile -ErrorVariable FailedExportProvider
		If ($FailedExportProvider)
			{
			Write-Log ERROR $LogFile "Failed to export the Provider: $Provider to $ProviderFile"
			Write-Log ERROR $LogFile "Export failed with error: $FailedExportProvider"
			}
		Else
		{ Write-Log INFO $LogFile "the Provider $Provider has been exported to $ProviderFile" }
	}
}

###############################################################################################################################################################################
#######################################################                ADFS Federation Service Account                #########################################################
###############################################################################################################################################################################

$ADFS_Service = Get-WmiObject win32_service | where {$_.Name -eq "adfssrv"} | select StartName
$Federation_Service_Account = $ADFS_Service.StartName
Write-Log INFO $LogFile "Federation Service is runnning with the following account:$Federation_Service_Account "
# Export to txt file
$ADFS_ServiceAccount_Path = $BackupPathFolder + "Service_Account.txt"
$Federation_Service_Account | Out-File $ADFS_ServiceAccount_Path -ErrorVariable FailedtoExportServiceAccount
If ($FailedtoExportServiceAccount)
{
	Write-Log ERROR $LogFile "Failed to export Service Account $Federation_Service_Account  to : $ADFS_ServiceAccount_Path"
	Write-Log ERROR $LogFile "Export failed with error: $FailedtoExportServiceAccount"
}

###############################################################################################################################################################################
#####################################################                Compress the backup folder to zip                #########################################################
###############################################################################################################################################################################
$SourceZip = $RootBackupFolder
$DestinationZip = $ArchivePathFolder + "ADFS_Configuration_" + $ServerName + $DateFull + ".zip"
Write-Log INFO $LogFile "The Script will try to generate the Archive (Zip) at the following location: $DestinationZip"
Try
{	

	Add-Type -assembly "system.io.compression.filesystem"
	[io.compression.zipfile]::CreateFromDirectory($SourceZip, $DestinationZip)
	
}
Catch
{
	Write-Log ERROR $LogFile "The Script Failed to generate the Archive (Zip) at the following location: $DestinationZip"
	Write-Log ERROR $LogFile "Failed to Zip the folder with the following error Message: $_.Exception.Message"
}

Write-Log ERROR $LogFile "End of Script"
