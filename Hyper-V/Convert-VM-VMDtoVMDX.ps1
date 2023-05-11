#—-

# .\Convert-VM-VMDtoVMDX.ps1 -VMName 'VM'

[CmdletBinding ()]
Param   (
        [Parameter(Mandatory=$True)]
        [string]$VMName
        )

#Disable error reporting – comment out the following line if you need to troubleshoot the script
$ErrorActionPreference = "SilentlyContinue"

Clear-Host

$VM = Get-VM $VMName
$VMStatus = $VM.State

if ($NULL -ne $VM.VMid)
{
    if ($VMStatus -eq "Running")
    {  
        #Shut down the VM if it is running
        Write-Host "Shutting down" $VMName
        Stop-VM $VMName  
    }

    #Get the disks in the VM
    $AllVHD = Get-VMHardDiskDrive $VMName

    if ($NULL -eq $AllVHD)
        {
        Write-Host "There are no virtual hard disks to convert"
        Exit
        }

    foreach ($VHD in $AllVHD)
    {
        #Get the VM path and create a VHDX file path
        [string]$VHDFile = Get-Item $VHD.Path
        $VHDFormat = (Get-VHD $VHDFile).VhdFormat
        if ($VHDFormat -eq "VHD")
            {
            [string]$VHDXFile = $VHDFile + "x"

            [string]$ControllerType = $VHD.ControllerType
            [string]$ControllerNumber = $VHD.ControllerNumber
            [string]$ControllerLocation = $VHD.ControllerLocation

            Write-Host "Converting: " $VHDFile "to" $VHDXFile
            Convert-VHD –Path $VHDFile –DestinationPath $VHDXFile
            Start-Sleep 10

            #Reconfigure the Physical Sector Size of the VHDX file to 4 K
            Set-VHD -Path $VHDXFile -PhysicalSectorSizeBytes 4096
            Start-Sleep 10

            #Remove the old VHD
            Write-Host "Removing $VHDFile from $VMName"
            Remove-VMHardDiskDrive $VHD
            Start-Sleep 10
            #Replace the VHD with the VHDX
            Write-Host "Adding $VHDXFile to $VMName"
            Add-VMHardDiskDrive -VMName $VMName -Path $VHDXFile -ControllerType $ControllerType -ControllerNumber $ControllerNumber -ControllerLocation $ControllerLocation

            #Danger Will Robinson – we are going to delete the original VHD – we hope you have a tested VM backup!
            Write-Host "Deleting $VHDFile"
            Remove-Item $VHDFile -Force
            }
        else
            {
            Write-Host "$VHDFile is already a VHDX file: skipping"
            }
    }

    if ($VMStatus -eq "Running")
    {  
        #Restart the VM if it was running before the conversion
        Write-Host "Starting" $VMName
        Start-VM $VMName  
        #Wait for 10 seconds
        Write-Host "Waiting for 10 seconds to verify the virtual machine …"
        Start-Sleep 10
        $VMStatus = $VM.State
        if ($VMStatus -ne "Running")
        {
            #Something went wrong
            Write-Host "$VMName could not reboot – please restore the VM from backup"     
        }
    }

}
else
{
    Write-Host $VMName "does not exist on this host"
    Exit
}

Write-Host "Processing of $VMName has completed"