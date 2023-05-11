# .\Convert-VM-VMDtoVMDX.ps1 -VMName 'VM'


#Disable error reporting - comment out the following line if you need to troubleshoot the script
$ErrorActionPreference = "SilentlyContinue"

Clear-Host

$vmList = Get-VM | Select-Object *

foreach ($VMName in $vmList) {
    $VM = Get-VM $($VMName.Name)
    $VMStatus = $VM.State

    if ($NULL -ne $VM.VMid) {
        #Get the disks in the VM
        #$AllVHD = Get-VMHardDiskDrive $($VMName.Name)
        $AllVHD = Get-VMHardDiskDrive $VMName.Name

        if ($NULL -eq $AllVHD) {
            Write-Host "There are no virtual hard disks to convert"
            Exit
        }

        foreach ($VHD in $AllVHD) {
            #Get the VM path and create a VHDX file path
            [string]$VHDFile = Get-Item $VHD.Path
            $VHDFormat = (Get-VHD $VHDFile).VhdFormat
            if ($VHDFormat -eq "VHD") {
                if ($VMStatus -eq "Running") {  
                    #Shut down the VM if it is running
                    #Write-Host "Shutting down" $($VMName.Name)
                    Write-Host "Shutting down" $VMName.Name
                    Stop-VM $VMName.Name
                }
        
                [string]$VHDXFile = $VHDFile + "x"

                [string]$ControllerType = $VHD.ControllerType
                [string]$ControllerNumber = $VHD.ControllerNumber
                [string]$ControllerLocation = $VHD.ControllerLocation

                Write-Host "Converting: " $VHDFile "to" $VHDXFile
                Convert-VHD -Path $VHDFile -DestinationPath $VHDXFile
                Start-Sleep 10

                #Reconfigure the Physical Sector Size of the VHDX file to 4 K
                Write-Host "Modifing PhysicalSectorSizeBytes of: " $VHDXFile
                Set-VHD -Path $VHDXFile -PhysicalSectorSizeBytes 4096
                Start-Sleep 10

                #Remove the old VHD
                Write-Host "Removing $VHDFile from $($VMName.Name)"
                Remove-VMHardDiskDrive $VHD
                Start-Sleep 10
                #Replace the VHD with the VHDX
                Write-Host "Adding $VHDXFile to $($VMName.Name)"
                #Add-VMHardDiskDrive -VMName $($VMName.Name) -Path $VHDXFile -ControllerType $ControllerType -ControllerNumber $ControllerNumber -ControllerLocation $ControllerLocation
                Add-VMHardDiskDrive -VMName $VMName.Name -Path $VHDXFile -ControllerType $ControllerType -ControllerNumber $ControllerNumber -ControllerLocation $ControllerLocation

                #Danger Will Robinson – we are going to delete the original VHD – we hope you have a tested VM backup!
                Write-Host "Deleting $VHDFile"
                Remove-Item $VHDFile -Force

                if ($VMStatus -eq "Running") {  
                    #Restart the VM if it was running before the conversion
                    #Write-Host "Starting" $($VMName.Name)
                    Write-Host "Starting" $VMName.Name
                    #Start-VM $($VMName.Name)
                    Start-VM $VMName.Name
                    #Wait for 10 seconds
                    Write-Host "Waiting for 10 seconds to verify the virtual machine ..."
                    Start-Sleep 10
                    $VMStatus = $VM.State
                    if ($VMStatus -ne "Running") {
                        #Something went wrong
                        Write-Host "$($VMName.Name) could not reboot - please restore the VM from backup"
                    }
                }
            }
            else {
                Write-Host "$VHDFile is already a VHDX file: skipping"
            }
        }
    }
    else {
        #Write-Host $($VMName.Name) "does not exist on this host"
        Write-Host $VMName.Name "does not exist on this host"
        Exit
    }

    Write-Host "Processing of $($VMName.Name) has completed"
}