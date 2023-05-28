function Get-DiskScsiLun {
  <#
  .SYNOPSIS
    Retrieves the SCSI Lun information for a disk.

  .DESCRIPTION
    Retrieves the SCSI Lun information for a disk.

  .PARAMETER  DeviceID
    Specify the disk name for wich the Scsi Lun information should be retrieved.

  .PARAMETER  ComputerName
    Specifies the computer against which you want to run the management operation.
    The value can be a fully qualified domain name, a NetBIOS name, or an IP
    address. Use the local computer name, use localhost, or use a dot (.) to specify the local
    computer. The local computer is the default.
    When the remote computer is in a different domain from the user, you must use a fully
    qualified domain name. This parameter can also be piped to the cmdlet.

    This parameter does not rely on Windows PowerShell remoting, which uses WS-Management.
    You can use the ComputerName parameter of Get-WmiObject even if your computer is not
    configured to run WS-Management remote commands.

  .PARAMETER  Credential
    Specifies a user account that has permission to perform this action. The default is
    the current user. Type a user name, such as "User01", "Domain01\User01",
    or User@Contoso.com. Or, enter a PSCredential object, such as an object that is
    returned by the Get-Credential cmdlet. When you type a user name, you will be prompted
    for a password.

  .EXAMPLE
    PS C:\> Get-DiskScsiLun

  .EXAMPLE
    PS C:\> Get-DiskScsiLun -DeviceID C: -ComputerName Server01 -Credential Domain01\User01

  .EXAMPLE
    PS C:\> "Server01","Server02" | Get-DiskScsiLun -Credential Domain01\User01

  .INPUTS
    System.String,PSCredential

  .OUTPUTS
    PSObject

  .NOTES
    Author: Robert van den Nieuwendijk
    Version: 1.1
    Date: 17-1-2013

  .LINK
    https://rvdnieuwendijk.com/

#>

  [CmdletBinding()]
  param([Parameter(Mandatory = $false,
      Position = 0)]
    [alias("Disk")]
    [string] $DeviceID = '*',
    [Parameter(Mandatory = $false,
      Position = 1,
      ValueFromPipeline = $true,
      ValueFromPipelineByPropertyName = $true)]
    [alias("CN")]
    [String[]] $ComputerName = $env:COMPUTERNAME,
    [Parameter(Mandatory = $false,
      Position = 2)]
    [System.Management.Automation.PSCredential]
    [System.Management.Automation.Credential()] $Credential = [System.Management.Automation.PSCredential]::Empty
  )

  process {
    if ($ComputerName) {
      # Loop through all computers in the parameter list
      foreach ($Computer in $ComputerName) {
        try {
          if ($Computer -eq "$($env:COMPUTERNAME)" -or $Computer -eq "." -or $Computer -eq "localhost") {
            # Define the Get-WmiObject parameter set for the local computer
            $Parameters = @{
              Impersonation = 3
              ErrorAction   = 'Stop'
            }
          }
          else {
            # Define the Get-WmiObject parameter set for remote computers
            $Parameters = @{
              ComputerName = $Computer
              Credential   = $Credential
              ErrorAction  = 'Stop'
            }
          }

          # Test if the computer can be connected
          if (Test-Connection -ComputerName $Computer -Count 1 -Quiet) {         
            # Get the  WMI objects
            $Win32_LogicalDisk = Get-WmiObject -Class Win32_LogicalDisk @Parameters |
            Where-Object { $_.DeviceID -like $DeviceID }
            $Win32_LogicalDiskToPartition = Get-WmiObject -Class Win32_LogicalDiskToPartition @Parameters
            $Win32_DiskDriveToDiskPartition = Get-WmiObject -Class Win32_DiskDriveToDiskPartition @Parameters
            $Win32_DiskDrive = Get-WmiObject -Class Win32_DiskDrive @Parameters

            # Search the SCSI Lun Unit for the disk
            $Win32_LogicalDisk |
            ForEach-Object {
              if ($_) {
                $LogicalDisk = $_
                $LogicalDiskToPartition = $Win32_LogicalDiskToPartition |
                Where-Object { $_.Dependent -eq $LogicalDisk.Path }
                if ($LogicalDiskToPartition) {
                  $DiskDriveToDiskPartition = $Win32_DiskDriveToDiskPartition |
                  Where-Object { $_.Dependent -eq $LogicalDiskToPartition.Antecedent }
                  if ($DiskDriveToDiskPartition) {
                    $DiskDrive = $Win32_DiskDrive |
                    Where-Object { $_.__Path -eq $DiskDriveToDiskPartition.Antecedent }
                    if ($DiskDrive) {
                      # Return the results
                      New-Object -TypeName PSObject -Property @{
                        Computer        = $Computer
                        DeviceID        = $LogicalDisk.DeviceID
                        SCSIBus         = $DiskDrive.SCSIBus
                        SCSIPort        = $DiskDrive.SCSIPort
                        SCSITargetId    = $DiskDrive.SCSITargetId
                        SCSILogicalUnit = $DiskDrive.SCSILogicalUnit
                      }
                    }
                  }
                }
              }
            }
          }
          else {
            Write-Warning "Unable to connect to computer $Computer."
          }
        }
        catch {
          Write-Warning "Unable to get disk information for computer $Computer.`n$($_.Exception.Message)"
        }
      }
    }
  }
}