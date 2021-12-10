<#
  Is there a version match between your Group Policy Object (GPO) containers and templates?
  This script will check that the version of each GPO is consistent in the Active Directory
  Group Policy Container (GPC) and on each Domain Controller in the Group Policy Template
  (GPT).

  All Windows Operating Systems since Windows 2000 will apply the GPO regardless of a
  version mismatch. However, a version mismatch will typically mean that some settings will
  not be applied. Replication issues with good old flaky FRS and perhaps (but rarely) the
  newer DFS-R is often the reason that the GPT gets out of sync and lags behind the GPC.

  However, I've taken this one step further by verifying the GPT on every Domain Controller.
  The output from this script often provides an aha moment, as it will paint the picture for
  why some group policy settings are inconsistently applied across your environment, and
  even within the same site!

  The following article provides an excellent explanation of how the group policy version
  number works:
  - http://technet.microsoft.com/en-us/library/ff730972.aspx

  Syntax examples:

  - To execute the script in the current Domain:
      Get-GPOVersionReport.ps1

  - To execute the script in a trusted Domain:
      Get-GPOVersionReport.ps1 -TrustedDomain mydemosthatrock.com

  Script Name: Get-GPOVersionReport.ps1
  Release: 1.4
  Written by Jeremy@jhouseconsulting.com 23rd April 2014
  Modified by Jeremy@jhouseconsulting.com 7th June 2016

  To be completed:
  - Add an IsLinked column
  - Modularize to remove some duplicate code.
  - Add file checksums for GPT content using a hash algorithm.
  - Get the output into a hash table.
  - Add more command line parameters.
  - Change the presentation of the script output so that it's easier to read for those that
    are color blind.

#>
#-------------------------------------------------------------
param([String]$TrustedDomain)
#-------------------------------------------------------------

# Set this to true to count the files and folders in each GPT
$CountFilesandFolders = $True

# Set this to true to check the SYSVOL on individual Domain
# Controllers. If set to false, it will just check the domain
# SYSVOL.
$CheckIndividualDCs = $True

# Set this value to true if you want verbose output to the console
$VerboseConsoleOutput = $True

#-------------------------------------------------------------
# Get the script path
$ScriptPath = {Split-Path $MyInvocation.ScriptName}
$ScriptName = [System.IO.Path]::GetFilenameWithoutExtension($MyInvocation.MyCommand.Path.ToString())
$ReferenceFile = $(&$ScriptPath) + "\" + $ScriptName + ".csv"

if ([String]::IsNullOrEmpty($TrustedDomain)) {
  # Get the Current Domain Information
  $domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
} else {
  $context = new-object System.DirectoryServices.ActiveDirectory.DirectoryContext("domain",$TrustedDomain)
  Try {
    $domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetDomain($context)
  }
  Catch [exception] {
    write-host -ForegroundColor red $_.Exception.Message
    Exit
  }
}

# Get AD Domain Name
$DomainDNS = $Domain.Name
# Get AD Distinguished Name
$DomainDistinguishedName = $Domain.GetDirectoryEntry() | select -ExpandProperty DistinguishedName  

Write-Host -ForegroundColor green "Domain: $domain`n"

$GPOPoliciesDN = "CN=Policies,CN=System,$DomainDistinguishedName"

Write-Host -ForegroundColor Green "Reading GPO information from Active Directory ($GPOPoliciesDN)..."
$GPOPoliciesADSI = [ADSI]"LDAP://$GPOPoliciesDN"
[array]$GPOPolicies = $GPOPoliciesADSI.psbase.children
$DomainGPOList = @()
ForEach ($GPO in $GPOPolicies) { [array]$DomainGPOList += $GPO.Name }
$DomainGPOList = $DomainGPOList | sort-object 
[int]$DomainGPOListCount = ($DomainGPOList | Measure-Object).Count
If ($DomainGPOListCount -eq 0) {
  Write-Host -ForegroundColor red "No GPOs found in Active Directory!"
  Exit
}
Write-Host -ForegroundColor Green "- Discovered $DomainGPOListCount GPCs (Group Policy Containers) in Active Directory ($GPOPoliciesDN)`n"

If ($CheckIndividualDCs) {
  # Get the names of all the Domain Contollers in $domain
  Write-Host -ForegroundColor green "Getting all Domain Controllers from $domain ..."
  $DomainControllers = $domain | ForEach-Object -Process { $_.DomainControllers } | Select-Object -Property Name
  [int]$DomainControllerCount = ($DomainControllers | Measure-Object).Count
  If ($DomainControllerCount -ne 0) {
    Write-Host -ForegroundColor green "- Found $DomainControllerCount Domain Controllers."
  }
}

$array = @()
$TotalGPCsProcessed = 0

ForEach ($GPC in $DomainGPOList) {
  $GPCADSI = [ADSI]"LDAP://CN=$GPC,$GPOPoliciesDN"
  $name = $GPCADSI.properties.name[0]
  $displayname = $GPCADSI.properties.displayname[0]
  $gPCFileSysPath = $GPCADSI.properties.gPCFileSysPath[0]
  $percent = "{0:P}" -f ($TotalGPCsProcessed/$DomainGPOListCount)
  write-host -ForegroundColor red -backgroundcolor yellow "`n---------- Processing $($TotalGPCsProcessed + 1) of $DomainGPOListCount GPOs = $percent complete ----------"
  write-host -ForegroundColor green "DisplayName: $displayname"
  write-host -ForegroundColor green "- Name: $name"
  write-host -ForegroundColor green "- FilePath: $gPCFileSysPath"
  $gpcVersion = $GPCADSI.properties.versionnumber[0]
  [INT]$UserGPCVersion = "{0:d}" -f [INT]("0x" + [String]::Format("{0:x8}", $gpcVersion).Substring(0,[String]::Format("{0:x8}", $gpcVersion).Length/2))
  [INT]$MachineGPCVersion = "{0:d}" -f [INT]("0x" + [String]::Format("{0:x8}", $gpcVersion).Substring(4,[String]::Format("{0:x8}", $gpcVersion).Length/2))
  write-host -ForegroundColor green "- GPC Version: $gpcVersion"
  write-host -ForegroundColor green "- User GPC Version: $UserGPCVersion"
  write-host -ForegroundColor green "- Machine GPC Version: $MachineGPCVersion"

  $gptVersion = ""
  $UserGPTVersion = ""
  $MachineGPTVersion = ""
  $GPTStatus = ""
  $SizeinBytes = ""
  $FileCount = ""
  $FolderCount = ""

  If ($CheckIndividualDCs) {

    If ($DomainControllerCount -ne 0) {

      $DCsProcessed = 0

      # Review the GPT.ini from each Domain Controller
      Write-Host -ForegroundColor green "`nProcessing each Domain controller..."
      ForEach ($dc in $DomainControllers) {

        $DCName = $($dc.Name)
        $DCsProcessed ++

        write-host -ForegroundColor green "`n$($DCName):"

        # Note that I have changed the Test-Connection count to 3 to cater for a response
        # over slow WAN links and cloud services, otherwise some DCs may fail the "Test"
        # and register as unreachable.
        If (Test-Connection -Cn $DCName -BufferSize 16 -Count 3 -ea 0 -quiet) {

          # GPT.ini path for the current Domain Controller
          [array]$GPTPath = $GPCADSI.properties.gPCFileSysPath -Split [regex]::Escape('\')
          [string]$GPTPath = "\\$DCName\" + ($GPTPath[3..6] -join "\")
          [string]$GPTiniPath = "$GPTPath\gpt.ini"

          # Testing the $GPTPath
          If (Test-Path -Path $GPTPath) {

            # Testing the $GPTiniPath
            If (Test-Path -Path $GPTiniPath) {

              $DCStatus = "Online"

              # Get GPT Version from the gpt.ini file and convert it from a string to an integer.
              If ($VerboseConsoleOutput) {
                Write-Host -ForegroundColor green "- Retrieving contents of $GPTiniPath"
              }
              $TotalTime = measure-command {[int]$gptVersion = (Get-Content "$GPTiniPath" | Where-Object {$_ -like "Version=*"}).Split("=")[1]}
              $TotalSeconds = $TotalTime.TotalSeconds
              If ($VerboseConsoleOutput) {
                Write-Host -ForegroundColor green "  - completed in $TotalSeconds seconds."
              }

              [INT]$UserGPTVersion = "{0:d}" -f [INT]("0x" + [String]::Format("{0:x8}", $gptVersion).Substring(0,[String]::Format("{0:x8}", $gptVersion).Length/2))
              [INT]$MachineGPTVersion = "{0:d}" -f [INT]("0x" + [String]::Format("{0:x8}", $gptVersion).Substring(4,[String]::Format("{0:x8}", $gptVersion).Length/2))

              If ($gpcVersion -eq $gptVersion) {
                If (!($gpcVersion -eq 0 -AND $gptVersion -eq 0)) {
                  $GPTStatus = "Match"
                  $ForegroundColor = "Green"
                } else {
                  $GPTStatus = "Empty"
                  $ForegroundColor = "Yellow"
                }
              } else {
                $GPTStatus = "Mismatch"
                $ForegroundColor = "Red"
              }
              If ($VerboseConsoleOutput) {
                write-host -ForegroundColor $ForegroundColor "- GPT Version: $gptVersion"
                write-host -ForegroundColor $ForegroundColor "- User GPT Version: $UserGPTVersion"
                write-host -ForegroundColor $ForegroundColor "- Machine GPT Version: $MachineGPTVersion"
                Write-host -ForegroundColor $ForegroundColor "- Status: $GPTStatus"
              }

              If ($CountFilesandFolders) {
                # Calculate the size of the GPT in bytes and megabytes as well as getting the folder and file count.
                If ($VerboseConsoleOutput) {
                  Write-Host -ForegroundColor green "- Retrieving contents of $GPTPath"
                }
                $TotalTime = measure-command {$colItems = Get-ChildItem "$GPTPath" –force -recurse}
                $TotalSeconds = $TotalTime.TotalSeconds
                If ($VerboseConsoleOutput) {
                  Write-Host -ForegroundColor green "  - completed in $TotalSeconds seconds."
                }
                $FolderCount = $colItems | where {$_.PSIsContainer} | Measure-Object | Select-Object -Expand Count
                $FileCount = $colItems | where {!$_.PSIsContainer} | Measure-Object | Select-Object -Expand Count
                $size = ($colItems | Measure-Object -property length -sum)
                $SizeinMB = "{0:N2}" -f ($size.sum / 1MB) + " MB"
                $SizeinBytes = "{0:N0}" -f $size.sum + " bytes"
                If ($VerboseConsoleOutput) {
                  write-host -ForegroundColor green "- Size: $SizeinMB ($SizeinBytes)"
                  write-host -ForegroundColor green "- Contains $FileCount Files, $FolderCount Folders"
                }
              }

            } Else {
              If ($VerboseConsoleOutput) {
                Write-Host -ForegroundColor red "- $DCName is not reachable via the $GPTiniPath path."
              }
              $DCStatus = "GPT.ini not reachable"
            }

          } Else {
            If ($VerboseConsoleOutput) {
              Write-Host -ForegroundColor red "- $DCName is not reachable via the $GPTPath path."
            }
            $DCStatus = "GPT path not reachable"
          }

        } Else {
          If ($VerboseConsoleOutput) {
            Write-Host -ForegroundColor red "- $DCName is not reachable or offline."
          }
          $DCStatus = "Not reachable"
        }

        $obj = New-Object -TypeName PSObject
        $obj | Add-Member -MemberType NoteProperty -Name "Name" -value $name
        $obj | Add-Member -MemberType NoteProperty -Name "DisplayName" -value $displayname
        $obj | Add-Member -MemberType NoteProperty -Name "FilePath" -value $gPCFileSysPath
        $obj | Add-Member -MemberType NoteProperty -Name "GPC Version" -value $gpcVersion
        $obj | Add-Member -MemberType NoteProperty -Name "User GPC Version" -value $UserGPCVersion
        $obj | Add-Member -MemberType NoteProperty -Name "Machine GPC Version" -value $MachineGPCVersion
        $obj | Add-Member -MemberType NoteProperty -Name "DC" -value $DCName
        $obj | Add-Member -MemberType NoteProperty -Name "DC Status" -value $DCStatus
        $obj | Add-Member -MemberType NoteProperty -Name "GPT Version" -value $gptVersion
        $obj | Add-Member -MemberType NoteProperty -Name "User GPT Version" -value $UserGPTVersion
        $obj | Add-Member -MemberType NoteProperty -Name "Machine GPT Version" -value $MachineGPTVersion
        $obj | Add-Member -MemberType NoteProperty -Name "GPT Status" -value $GPTStatus
        If ($CountFilesandFolders) {
          $obj | Add-Member -MemberType NoteProperty -Name "Size (Bytes)" -value $SizeinBytes
          $obj | Add-Member -MemberType NoteProperty -Name "Size (MB)" -value $SizeinMB
          $obj | Add-Member -MemberType NoteProperty -Name "File Count" -value $FileCount
          $obj | Add-Member -MemberType NoteProperty -Name "Folder Count" -value $FolderCount
        }
        $array += $obj

        # Reset variables
        [string]$gptVersion = ""
        [string]$UserGPTVersion = ""
        [string]$MachineGPTVersion = ""
        $GPTStatus = ""
        $SizeinBytes = ""
        $FileCount = ""
        $FolderCount = ""

      }#FOREACH

    } Else {
      Write-Host -ForegroundColor red "No Domain Controllers found!"
      Exit
    }

  } else {

    # GPT.ini path for the current Domain Controller
    [string]$GPTPath = $GPCADSI.properties.gPCFileSysPath
    [string]$GPTiniPath = "$GPTPath\gpt.ini"

    # Testing the $GPTPath
    If (Test-Path -Path $GPTPath) {

      # Testing the $GPTiniPath
      If (Test-Path -Path $GPTiniPath) {

        $GPTiniExists = "Exists"

        # Get GPT Version from the gpt.ini file and convert it from a string to an integer.
        If ($VerboseConsoleOutput) {
          Write-Host -ForegroundColor green "- Retrieving contents of $GPTiniPath"
        }
        $TotalTime = measure-command {[int]$gptVersion = (Get-Content "$GPTiniPath" | Where-Object {$_ -like "Version=*"}).Split("=")[1]}
        $TotalSeconds = $TotalTime.TotalSeconds
        If ($VerboseConsoleOutput) {
          Write-Host -ForegroundColor green "  - completed in $TotalSeconds seconds."
        }

        [INT]$UserGPTVersion = "{0:d}" -f [INT]("0x" + [String]::Format("{0:x8}", $gptVersion).Substring(0,[String]::Format("{0:x8}", $gptVersion).Length/2))
        [INT]$MachineGPTVersion = "{0:d}" -f [INT]("0x" + [String]::Format("{0:x8}", $gptVersion).Substring(4,[String]::Format("{0:x8}", $gptVersion).Length/2))

        If ($gpcVersion -eq $gptVersion) {
          If (!($gpcVersion -eq 0 -AND $gptVersion -eq 0)) {
            $GPTStatus = "Match"
            $ForegroundColor = "Green"
          } else {
            $GPTStatus = "Empty"
            $ForegroundColor = "Yellow"
          }
        } else {
          $GPTStatus = "Mismatch"
          $ForegroundColor = "Red"
        }
        If ($VerboseConsoleOutput) {
          write-host -ForegroundColor $ForegroundColor "- GPT Version: $gptVersion"
          write-host -ForegroundColor $ForegroundColor "- User GPT Version: $UserGPTVersion"
          write-host -ForegroundColor $ForegroundColor "- Machine GPT Version: $MachineGPTVersion"
          Write-host -ForegroundColor $ForegroundColor "- Status: $GPTStatus"
        }

        If ($CountFilesandFolders) {
          # Calculate the size of the GPT in bytes and megabytes as well as getting the folder and file count.
          If ($VerboseConsoleOutput) {
            Write-Host -ForegroundColor green "- Retrieving contents of $GPTPath"
          }
          $TotalTime = measure-command {$colItems = Get-ChildItem "$GPTPath" –force -recurse}
          $TotalSeconds = $TotalTime.TotalSeconds
          If ($VerboseConsoleOutput) {
            Write-Host -ForegroundColor green "  - completed in $TotalSeconds seconds."
          }
          $FolderCount = $colItems | where {$_.PSIsContainer} | Measure-Object | Select-Object -Expand Count
          $FileCount = $colItems | where {!$_.PSIsContainer} | Measure-Object | Select-Object -Expand Count
          $size = ($colItems | Measure-Object -property length -sum)
          $SizeinMB = "{0:N2}" -f ($size.sum / 1MB) + " MB"
          $SizeinBytes = "{0:N0}" -f $size.sum + " bytes"
          If ($VerboseConsoleOutput) {
            write-host -ForegroundColor green "- Size: $SizeinMB ($SizeinBytes)"
            write-host -ForegroundColor green "- Contains $FileCount Files, $FolderCount Folders"
          }
        }
      } Else {
        If ($VerboseConsoleOutput) {
          Write-Host -ForegroundColor red "- $DCName is not reachable via the $GPTiniPath path."
        }
        $GPTiniExists = "GPT.ini not reachable"
      }

    } Else {
      If ($VerboseConsoleOutput) {
        Write-Host -ForegroundColor red "- $DCName is not reachable via the $GPTPath path."
      }
      $GPTiniExists = "GPT path not reachable"
    }

    $obj = New-Object -TypeName PSObject
    $obj | Add-Member -MemberType NoteProperty -Name "Name" -value $name
    $obj | Add-Member -MemberType NoteProperty -Name "DisplayName" -value $displayname
    $obj | Add-Member -MemberType NoteProperty -Name "FilePath" -value $gPCFileSysPath
    $obj | Add-Member -MemberType NoteProperty -Name "GPC Version" -value $gpcVersion
    $obj | Add-Member -MemberType NoteProperty -Name "User GPC Version" -value $UserGPCVersion
    $obj | Add-Member -MemberType NoteProperty -Name "Machine GPC Version" -value $MachineGPCVersion
    $obj | Add-Member -MemberType NoteProperty -Name "GPT ini Exists" -value $GPTiniExists
    $obj | Add-Member -MemberType NoteProperty -Name "GPT Version" -value $gptVersion
    $obj | Add-Member -MemberType NoteProperty -Name "User GPT Version" -value $UserGPTVersion
    $obj | Add-Member -MemberType NoteProperty -Name "Machine GPT Version" -value $MachineGPTVersion
    $obj | Add-Member -MemberType NoteProperty -Name "GPT Status" -value $GPTStatus
    If ($CountFilesandFolders) {
      $obj | Add-Member -MemberType NoteProperty -Name "Size (Bytes)" -value $SizeinBytes
      $obj | Add-Member -MemberType NoteProperty -Name "File Count" -value $FileCount
      $obj | Add-Member -MemberType NoteProperty -Name "Folder Count" -value $FolderCount
    }
    $array += $obj

  }#IF

  $TotalGPCsProcessed ++

}#FOREACH

write-host -ForegroundColor red -backgroundcolor yellow "`n---------- Processed all GPOs = 100% complete ----------"

# Write-Output $array | Format-Table
$array | Export-Csv -Path "$ReferenceFile" -Delimiter ';' -NoTypeInformation

# Remove the quotes
(get-content "$ReferenceFile") |% {$_ -replace '"',""} | out-file "$ReferenceFile" -Fo -En ascii
