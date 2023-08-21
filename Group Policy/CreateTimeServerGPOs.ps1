<#
  This script will create the Time Server GPOs and WMI Filters for the Domain Controllers
  to ensure your time server hierarchy remains correct for transfer and seizure of the PDC(e)
  emulator FSMO role holder. The policies will apply on the next policy refresh or by forcing
  a group policy refresh.

  WMI Filters are created via the New-ADObject cmdlet in the Active Directory module, which
  makes them of type "Microsoft.ActiveDirectory.Management.ADObject". However, the Group
  Policy module requires that you use an object of type "Microsoft.GroupPolicy.WmiFilter"
  when adding a wmifilter using the New-GPO cmdlet. Therefore there is no default way to use
  the Group Policy PowerShell cmdlets to add WMI Filters to GPOs without a bit or trickery.
  As Carl documented there is a "Group Policy WMI filter cmdlet module" available for download
  from here: http://gallery.technet.microsoft.com/scriptcenter/Group-Policy-WMI-filter-38a188f3
  But if you reverse engineer the code Bin Yi from Microsoft created, you'll see that he has
  simply and cleverly converted a "Microsoft.ActiveDirectory.Management.ADObject" object type
  to a "Microsoft.GroupPolicy.WmiFilter" object type. I didn't want to include the whole module
  for the simple task I needed, so have directly used the ConvertTo-WmiFilter function from the
  GPWmiFilter.psm1 module and tweaked it for my requirements. Many thanks to Bin.

  If your Active Directory is based on Windows 2003 or has been upgraded from Windows 2003, you
  may may have an issue with System Owned Objects. If you receive an error message along the
  lines of "The attribute cannot be modified because it is owned by the system", you'll need to
  set the following registry value:
    Key: HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\NTDS\Parameters
    Type: REG_DWORD
    Value: Allow System Only Change
    Data: 1

  Disable the Hyper-V time synchronization integration service:
  - The time source of "VM IC Time Synchronization Provider" (vmictimeprovider.dll) is enabled
    on Virtual Machines as part of the Hyper-V Integration Services. The following articles
    explain it in more depth and how it should be configured:
    - Time Sync Recommendations For Virtual DCs On Hyper-V � Change In Recommendations (AGAIN)
      http://jorgequestforknowledge.wordpress.com/2013/11/17/time-sync-recommendations-for-virtual-dcs-on-hyper-v-change-in-recommendations-again/
    - Time Synchronization in Hyper-V:
      http://blogs.msdn.com/b/virtual_pc_guy/archive/2010/11/19/time-synchronization-in-hyper-v.aspx
    - Hyper V Time Synchronization on a Windows Based Network:
      http://kevingreeneitblog.blogspot.com.au/2011/01/hyper-v-time-synchronization-on-windows.html

  Recommended Default Values for:
  - MaxPosPhaseCorrection: 172800
  - MaxNegPhaseCorrection: 172800

  Recommended Default Values for Domain Controllers:
  - SpecialPollInterval: 3600
    This is only initiated on workgroup servers and the PDCe when a flag of 0x1 or 0�9 is
    specified against any of the manually specified NTP servers.
    References:
    - KB2638243 to understand more about when SpecialPollInterval is used.
    - https://nchrissos.wordpress.com/2013/04/26/configuring-time-on-windows-2008-r2-servers/

  Even after a GPUpdate has occurred and a restart of the Windows Time (W32Time) service you
  may find that the output of a "w32tm /query /source" and "w32tm /query /status" shows that
  it's source is the "Local CMOS Clock". Simply run the "w32tm /resync /rediscover" command
  to force the system to rediscover from its configured sources. This seems to address the
  issue immediately.

  Script Name: CreateTimeServerGPOs.ps1
  Release 1.2
  Written by Jeremy@jhouseconsulting.com 19/10/2015

  Original script was written by Carl Webster:
  - Carl Webster, CTP and independent consultant
  - webster@carlwebster.com
  - @carlwebster on Twitter
  - http://www.CarlWebster.com
  - It can be found here:
    http://carlwebster.com/creating-a-group-policy-using-microsoft-powershell-to-configure-the-authoritative-time-server/

#>

#-------------------------------------------------------------
param([switch]$whatif)

Set-StrictMode -Version 2.0

$VerbosePreference = 'Continue'
$WarningPreference = 'Continue'
$ErrorPreference = 'Continue'

if ($whatif.IsPresent) { 
  $WhatIfPreference = $True
  Write-Verbose "WhatIf Enabled" 
}
Else {
  $WhatIfPreference = $False
}

#-------------------------------------------------------------
# Define variables specific to your Active Directory environment

# Set this to the NTP Servers the PDCe will sync with
#$TimeServers = "0.au.pool.ntp.org,0x8 1.au.pool.ntp.org,0x8 2.au.pool.ntp.org,0x8 3.au.pool.ntp.org,0x8"
$TimeServers = "0.us.pool.ntp.org,0x8 1.us.pool.ntp.org,0x8 2.us.pool.ntp.org,0x8 3.us.pool.ntp.org,0x8"


# This is the name of the GPO for the PDCe policy
$PDCeGPOName = "+ SERVER Set PDCe Domain Controller as Authoritative Time Server v1.0"

# This is the WMI Filter for the PDCe Domain Controller
$PDCeWMIFilter = @("PDCe Domain Controller",
  "Queries for the domain controller that holds the PDC emulator FSMO role",
  "root\CIMv2",
  "Select * from Win32_ComputerSystem where DomainRole=5")

# This is the name of the GPO for the non-PDCe policy
$NonPDCeGPOName = "+ SERVER Set Time Settings on non-PDCe Domain Controllers v1.0"

# This is the WMI Filter for the non-PDCe Domain Controllers
$NonPDCeWMIFilter = @("Non-PDCe Domain Controllers",
  "Queries for all domain controllers except for the one that holds the PDC emulator FSMO role",
  "root\CIMv2",
  "Select * from Win32_ComputerSystem where DomainRole=4")

# This is the name of the GPO for the Domain Member policy
$DomainMembersGPOName = "+ COMPUTER Set Time Settings on all Domain Members v1.0"

# Set this to True to include the registry value to disable the Virtual Host Time Synchronization provider (VMICTimeProvider)
$DisableVirtualHostTimeSynchronization = $True

# Set this to true to set the Allow System Only Change registry value
$EnableAllowSystemOnlyChange = $True

# Set this to the number of seconds you would like to wait for Active Directory replication
# to complete before retrying to add the WMI filter to the Group Policy Object (GPO).
$SleepTimer = 10

#-------------------------------------------------------------

# Import the Active Directory Module
Import-Module ActiveDirectory -WarningAction SilentlyContinue
if ($Error.Count -eq 0) {
  Write-Verbose "Successfully loaded Active Directory Powershell's module"
}
else {
  Write-Error "Error while loading Active Directory Powershell's module : $Error"
  exit
}

# Import the Group Policy Module
Import-Module GroupPolicy -WarningAction SilentlyContinue
if ($Error.Count -eq 0) {
  Write-Verbose "Successfully loaded Group Policy Powershell's module"
}
else {
  Write-Error "Error while loading Group Policy Powershell's module : $Error"
  exit
}

#-------------------------------------------------------------

# Get the Current Domain & Forest Information
$DomainInfo = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
$DomainName = $DomainInfo.Name
$ForestName = $DomainInfo.Forest.Name

# Get AD Distinguished Name
$DomainDistinguishedName = $DomainInfo.GetDirectoryEntry() | select -ExpandProperty DistinguishedName  

If ($DomainName -eq $ForestName) {
  $IsForestRoot = $True
}
Else {
  $IsForestRoot = $False
}

#-------------------------------------------------------------

function ConvertTo-WmiFilter([Microsoft.ActiveDirectory.Management.ADObject[]] $ADObject) {
  # The concept of this function has been taken directly from the GPWmiFilter.psm1 module
  # written by Bin Yi from Microsoft. I have modified it to allow for the challenges of
  # Active Directory replication. It will return the WMI filter as an object of type
  # "Microsoft.GroupPolicy.WmiFilter".
  $gpDomain = New-Object -Type Microsoft.GroupPolicy.GPDomain
  $ADObject | ForEach-Object {
    $path = 'MSFT_SomFilter.Domain="' + $gpDomain.DomainName + '",ID="' + $_.Name + '"'
    $filter = $NULL
    try {
      $filter = $gpDomain.GetWmiFilter($path)
    }
    catch {
      write-Error "The WMI filter could not be found."
    }
    if ($filter) {
      [Guid]$Guid = $_.Name.Substring(1, $_.Name.Length - 2)
      $filter | Add-Member -MemberType NoteProperty -Name Guid -Value $Guid -PassThru | Add-Member -MemberType NoteProperty -Name Content -Value $_."msWMI-Parm2" -PassThru
    }
    else {
      write-Warning "Waiting $SleepTimer seconds for Active Directory replication to complete."
      start-sleep -s $SleepTimer
      write-warning "Trying again to retrieve the WMI filter."
      ConvertTo-WmiFilter $ADObject
    }
  }
}
#-------------------------------------------------------------

function Enable-ADSystemOnlyChange([switch] $disable) {
  # This function has been taken directly from the GPWmiFilter.psm1
  # module written by Bin Yi from Microsoft.
  $valueData = 1
  if ($disable) {
    $valueData = 0
  }
  $key = Get-Item HKLM:\System\CurrentControlSet\Services\NTDS\Parameters -ErrorAction SilentlyContinue
  if (!$key) {
    New-Item HKLM:\System\CurrentControlSet\Services\NTDS\Parameters -ItemType RegistryKey | Out-Null
  }
  $kval = Get-ItemProperty HKLM:\System\CurrentControlSet\Services\NTDS\Parameters -Name "Allow System Only Change" -ErrorAction SilentlyContinue
  if (!$kval) {
    New-ItemProperty HKLM:\System\CurrentControlSet\Services\NTDS\Parameters -Name "Allow System Only Change" -Value $valueData -PropertyType DWORD | Out-Null
  }
  else {
    Set-ItemProperty HKLM:\System\CurrentControlSet\Services\NTDS\Parameters -Name "Allow System Only Change" -Value $valueData | Out-Null
  }
}

#-------------------------------------------------------------

Function Create-Policy {
  param($GPOName, $TargetOU, $NtpServer, $AnnounceFlags, $Type, $MaxPosPhaseCorrection, $MaxNegPhaseCorrection, $SpecialPollInterval, $WMIFilter)

  If ($WMIFilter -ne "none") {
    $UseAdministrator = $False
    If ($UseAdministrator -eq $False) {
      $msWMIAuthor = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
    }
    Else {
      $msWMIAuthor = "Administrator@" + [System.DirectoryServices.ActiveDirectory.Domain]::getcurrentdomain().name
    }

    # Create WMI Filter
    $WMIGUID = [string]"{" + ([System.Guid]::NewGuid()) + "}"
    $WMIDN = "CN=" + $WMIGUID + ",CN=SOM,CN=WMIPolicy,CN=System," + $DomainDistinguishedName
    $WMICN = $WMIGUID
    $WMIdistinguishedname = $WMIDN
    $WMIID = $WMIGUID

    $now = (Get-Date).ToUniversalTime()
    $msWMICreationDate = ($now.Year).ToString("0000") + ($now.Month).ToString("00") + ($now.Day).ToString("00") + ($now.Hour).ToString("00") + ($now.Minute).ToString("00") + ($now.Second).ToString("00") + "." + ($now.Millisecond * 1000).ToString("000000") + "-000" 
    $msWMIName = $WMIFilter[0]
    $msWMIParm1 = $WMIFilter[1] + " "
    $msWMIParm2 = "1;3;10;" + $WMIFilter[3].Length.ToString() + ";WQL;" + $WMIFilter[2] + ";" + $WMIFilter[3] + ";"

    # msWMI-Name: The friendly name of the WMI filter
    # msWMI-Parm1: The description of the WMI filter
    # msWMI-Parm2: The query and other related data of the WMI filter
    $Attr = @{"msWMI-Name" = $msWMIName; "msWMI-Parm1" = $msWMIParm1; "msWMI-Parm2" = $msWMIParm2; "msWMI-Author" = $msWMIAuthor; "msWMI-ID" = $WMIID; "instanceType" = 4; "showInAdvancedViewOnly" = "TRUE"; "distinguishedname" = $WMIdistinguishedname; "msWMI-ChangeDate" = $msWMICreationDate; "msWMI-CreationDate" = $msWMICreationDate } 
    $WMIPath = ("CN=SOM,CN=WMIPolicy,CN=System," + $DomainDistinguishedName) 

    $array = @()
    $SearchRoot = [adsi]("LDAP://CN=SOM,CN=WMIPolicy,CN=System," + $DomainDistinguishedName)
    $search = new-object System.DirectoryServices.DirectorySearcher($SearchRoot)
    $search.filter = "(objectclass=msWMI-Som)"
    $results = $search.FindAll()
    ForEach ($result in $results) {
      $array += $result.properties["mswmi-name"].item(0)
    }

    if ($array -notcontains $msWMIName) {
      write-Verbose "Creating the $msWMIName WMI Filter..."
      If ($EnableAllowSystemOnlyChange) {
        Enable-ADSystemOnlyChange
      }
      $SOMContainer = [adsi]("LDAP://CN=SOM,CN=WMIPolicy,CN=System," + $DomainDistinguishedName)
      $NewWMIFilter = $SOMContainer.create('msWMI-Som', "CN=" + $WMIGUID)
      $NewWMIFilter.put("msWMI-Name", $msWMIName)
      $NewWMIFilter.put("msWMI-Parm1", $msWMIParm1)
      $NewWMIFilter.put("msWMI-Parm2", $msWMIParm2)
      $NewWMIFilter.put("msWMI-Author", $msWMIAuthor)
      $NewWMIFilter.put("msWMI-ID", $WMIID)
      $NewWMIFilter.put("instanceType", 4)
      $NewWMIFilter.put("showInAdvancedViewOnly", "TRUE")
      $NewWMIFilter.put("distinguishedname", $WMIdistinguishedname)
      $NewWMIFilter.put("msWMI-ChangeDate", $msWMICreationDate)
      $NewWMIFilter.put("msWMI-CreationDate", $msWMICreationDate)
      If ($WhatIfPreference -eq $False) {
        $NewWMIFilter.setinfo()
      }
      write-Verbose "Waiting $SleepTimer seconds for Active Directory replication to complete."
      start-sleep -s $SleepTimer
    }
    Else {
      write-Warning "The $msWMIName WMI Filter already exists"
    }

    # Get WMI filter
    <#
    $SearchRoot = [adsi]("LDAP://CN=SOM,CN=WMIPolicy,CN=System,"+$DomainDistinguishedName)
    $search = new-object System.DirectoryServices.DirectorySearcher($SearchRoot)
    $search.filter = "(&(objectclass=msWMI-Som)(mswmi-name=$msWMIName))"
    $results = $search.FindAll()
    ForEach ($result in $results) {
      # To create a WmiFilter object using the ConvertTo-WmiFilter function we need to
      # first create an object with the following 7 properties:
      # DistinguishedName, msWMI-Name, msWMI-Parm1, msWMI-Parm2, Name, ObjectClass, ObjectGUID
      #$WMIFilterADObject = New-Object -TypeName Microsoft.ActiveDirectory.Management.ADObject
      # There is an Get-ADSIResult function written by Warren Frame that will achieve this:
      # - https://github.com/RamblingCookieMonster/PowerShell/blob/master/Get-ADSIObject.ps1
      # - https://gallery.technet.microsoft.com/scriptcenter/Get-ADSIObject-Portable-ae7f9184
      #$WMIFilterADObject | Add-Member -MemberType NoteProperty -Name "DistinguishedName" -value $result.properties["distinguishedname"].item(0)
      #$WMIFilterADObject | Add-Member -MemberType NoteProperty -Name "msWMI-Name" -value $result.properties["mswmi-name"].item(0)
      #$WMIFilterADObject | Add-Member -MemberType NoteProperty -Name "msWMI-Parm1" -value $result.properties["mswmi-parm1"].item(0)
      #$WMIFilterADObject | Add-Member -MemberType NoteProperty -Name "msWMI-Parm2" -value $($result.properties["mswmi-parm2"].item(0))
      #$WMIFilterADObject | Add-Member -MemberType NoteProperty -Name "Name" -value $result.properties["name"].item(0)
      #$WMIFilterADObject | Add-Member -MemberType NoteProperty -Name "ObjectClass" -value "msWMI-Som"
      ## Convert the ObjectGUID property byte array to a GUID
      #[GUID]$GUID = $result.properties["ObjectGUID"].item(0)
      #$WMIFilterADObject | Add-Member -MemberType NoteProperty -Name "ObjectGUID" -value $GUID

      $WMIFilterADObject = New-Object -TypeName Microsoft.ActiveDirectory.Management.ADObject
      $WMIFilterADObject.DistinguishedName = $result.properties["distinguishedname"].item(0)
      $WMIFilterADObject."msWMI-Name" = $result.properties["mswmi-name"].item(0)
      $WMIFilterADObject."msWMI-Parm1" = $result.properties["mswmi-parm1"].item(0)
      $WMIFilterADObject."msWMI-Parm2" = ($result.properties["mswmi-parm2"].item(0)).ToString()
      #$WMIFilterADObject.Name = $result.properties["name"].item(0)
      $WMIFilterADObject.ObjectClass = "msWMI-Som"
      # Convert the ObjectGUID property byte array to a GUID
      [GUID]$GUID = $result.properties["ObjectGUID"].item(0)
      $WMIFilterADObject.ObjectGUID = $GUID
    }
#>
    $WMIFilterADObject = Get-ADObject -Filter 'objectClass -eq "msWMI-Som"' -Properties "msWMI-Name", "msWMI-Parm1", "msWMI-Parm2" | 
    Where { $_."msWMI-Name" -eq "$msWMIName" }
    #$WMIFilterADObject
    #$WMIFilterADObject | gm �Force
    #ConvertTo-WmiFilter $WMIFilterADObject
  }

  $ExistingGPO = get-gpo $GPOName -ea "SilentlyContinue"
  If ($ExistingGPO -eq $NULL) {
    write-Verbose "Creating the $GPOName Group Policy Object..."

    If ($WhatIfPreference -eq $False) {
      $GPO = New-GPO -Name $GPOName

      write-verbose "Disabling User Settings"
      $GPO.GpoStatus = "UserSettingsDisabled"
    }

    If ($WMIFilter -ne "none") {
      If ($WhatIfPreference -eq $False) {
        Write-Verbose "Adding the WMI Filter"
        $GPO.WmiFilter = ConvertTo-WmiFilter $WMIFilterADObject
      }
    }

    If ($WhatIfPreference -eq $False) {
      write-verbose "Setting the registry keys in the Preferences section of the new GPO"

      Set-GPPrefRegistryValue -Name $GPOName -Action Update -Context Computer `
        -Key "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Config" `
        -Type DWord -ValueName "AnnounceFlags" -Value $AnnounceFlags | out-null
      Write-Verbose "Set AnnounceFlags to a value of $AnnounceFlags"

      If ($MaxPosPhaseCorrection -ne "default") {
        Set-GPPrefRegistryValue -Name $GPOName -Action Update -Context Computer `
          -Key "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Config" `
          -Type DWord -ValueName "MaxPosPhaseCorrection" -Value $MaxPosPhaseCorrection | out-null
        Write-Verbose "Set MaxPosPhaseCorrection to a value of $MaxPosPhaseCorrection"
      }

      If ($MaxNegPhaseCorrection -ne "default") {
        Set-GPPrefRegistryValue -Name $GPOName -Action Update -Context Computer `
          -Key "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Config" `
          -Type DWord -ValueName "MaxNegPhaseCorrection" -Value $MaxNegPhaseCorrection | out-null
        Write-Verbose "Set MaxNegPhaseCorrection to a value of $MaxNegPhaseCorrection"
      }

      If ($SpecialPollInterval -ne "default") {
        Set-GPPrefRegistryValue -Name $GPOName -Action Update -Context Computer `
          -Key "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\NtpClient" `
          -Type DWord -ValueName "SpecialPollInterval" -Value $SpecialPollInterval | out-null
        Write-Verbose "Set SpecialPollInterval to a value of $SpecialPollInterval"
      }

      Set-GPPrefRegistryValue -Name $GPOName -Action Update -Context Computer `
        -Key "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Parameters" `
        -Type String -ValueName "NtpServer" -Value "$NtpServer" | out-null
      Write-Verbose "Set NtpServer to a value of $NtpServer"

      Set-GPPrefRegistryValue -Name $GPOName -Action Update -Context Computer `
        -Key "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\Parameters" `
        -Type String -ValueName "Type" -Value "$Type" | out-null
      Write-Verbose "Set Type to a value of $Type"

      If ($DisableVirtualHostTimeSynchronization) {
        # Disable the Hyper-V/ESX time synchronization integration service.
        Set-GPPrefRegistryValue -Name $GPOName -Action Update -Context Computer `
          -Key "HKLM\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\VMICTimeProvider" `
          -Type DWord -ValueName "Enabled" -Value 0 -Disable | out-null
        Write-Verbose "Disabled the VMICTimeProvider"
      }

      # Link the new GPO to the specified OU
      write-Verbose "Linking the $GPOName Group Policy Object to the $TargetOU OU..."
      New-GPLink -Name $GPOName -Target "$TargetOU" | out-null
    }
  }
  Else {
    write-Warning "The $GPOName Group Policy Object already exists."
    If ($WMIFilter -ne "none") {
      write-Verbose "Adding the $msWMIName WMI Filter..."
      If ($WhatIfPreference -eq $False) {
        $ExistingGPO.WmiFilter = ConvertTo-WmiFilter $WMIFilterADObject
      }
      write-Verbose "Linking the $GPOName Group Policy Object to the $TargetOU OU..."
      If ($WhatIfPreference -eq $False) {
        Try {
          New-GPLink -Name $GPOName -Target "$TargetOU" -errorAction Stop | out-null
        }
        Catch {
          write-verbose "The GPO is already linked"
        }
      }
    }
  }
  write-Verbose "Completed."
  $ObjectExists = $NULL
}

#-------------------------------------------------------------

If ($IsForestRoot) {
  $PDCeType = "NTP"
}
Else {
  $PDCeType = "AllSync"
}

$TargetDCOU = "OU=Domain Controllers," + $DomainDistinguishedName

# Syntax:
# Create-Policy <GPOName> <TargetOU> <NtpServer> <AnnounceFlags> <Type> <MaxPosPhaseCorrection> <MaxNegPhaseCorrection> <SpecialPollInterval> <WMIFilter>

Write-Verbose "Creating the WMI Filters and Policies..."

Create-Policy "$PDCeGPOName" "$TargetDCOU" "$TimeServers" 5 $PDCeType 172800 172800 3600 $PDCeWMIFilter
Create-Policy "$NonPDCeGPOName" "$TargetDCOU" "time.windows.com,0x9" 10 "NT5DS" 172800 172800 "default" $NonPDCeWMIFilter
Create-Policy "$DomainMembersGPOName" "$DomainDistinguishedName" "time.windows.com,0x9" 10 "NT5DS" 172800 172800 "default" "none"
