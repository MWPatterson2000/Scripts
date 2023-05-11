# Bulk VHDX Files Modifing PhysicalSectorSizeBytes to 4096 (4 K)

#Disable error reporting - comment out the following line if you need to troubleshoot the script
$ErrorActionPreference = "SilentlyContinue"

# Clear Screen
Clear-Host

# Get list of VM(s)
Write-Host "Getting List of VM(s) on the computer" -ForegroundColor Green
$vmList = Get-VM | Select-Object *

# Work through each VM
foreach ($VMName in $vmList) {
    #Write-Host "Checking VM: $($VMName.Name)" -ForegroundColor Green
    Write-Host "Checking VM:" $VMName.Name -ForegroundColor Green
    $VM = Get-VM $($VMName.Name)
    $VMStatus = $VM.State

    if ($NULL -ne $VM.VMid) {
        #Get the disks in the VM
        #$AllVHD = Get-VMHardDiskDrive $($VMName.Name)
        $AllVHD = Get-VMHardDiskDrive $VMName.Name

        if ($NULL -eq $AllVHD) {
            Write-Host "`tThere are no virtual hard disks to convert" -ForegroundColor Green
            Exit
        }

        foreach ($VHDX in $AllVHD) {
            #Get the VM path and create a VHDX file path
            [string]$VHDXFile = Get-Item $VHDX.Path
            $VHDXFormat = (Get-VHD $VHDXFile).VhdFormat
            if ($VHDXFormat -eq "VHDX") {
                # Check to see if VM is running
                if ($VMStatus -eq "Running") {  
                    #Shut down the VM if it is running
                    #Write-Host "Shutting down" $($VMName.Name)
                    #Write-Host "Shutting down $($VMName.Name)" -ForegroundColor Yellow
                    Write-Host "`tShutting down" $VMName.Name -ForegroundColor Yellow
                    Stop-VM $VMName.Name
                }

                # Modify VMDX File PhysicalSectorSizeBytes
                #Reconfigure the Physical Sector Size of the VHDX file to 4 K
                #Write-Host "Modifing PhysicalSectorSizeBytes of: $VHDXFile" -ForegroundColor Yellow
                Write-Host "`tModifing PhysicalSectorSizeBytes of: " $VHDXFile -ForegroundColor Yellow
                Set-VHD -Path $VHDXFile -PhysicalSectorSizeBytes 4096
                Start-Sleep 10

            }
            else {
                # Disk already in VHDX format
                Write-Host "`t$VHDFile is already a VHDX file: skipping" -ForegroundColor Green
            }

            # Check to see if VM was running prior to Disk Conversion
            if ($VMStatus -eq "Running") {  
                #Restart the VM if it was running before the conversion
                #Write-Host "Starting" $($VMName.Name)
                Write-Host "`tStarting" $VMName.Name -ForegroundColor Yellow
                #Start-VM $($VMName.Name)
                Start-VM $VMName.Name
                #Wait for 10 seconds
                Write-Host "`tWaiting for 10 seconds to verify the virtual machine ..." -ForegroundColor Yellow
                Start-Sleep 10
                $VMStatus = $VM.State
                if ($VMStatus -ne "Running") {
                    #Something went wrong
                    Write-Host "`t$($VMName.Name) could not reboot - please restore the VM from backup" -ForegroundColor Red
                }
            }
        }
    }
    else {
        #Write-Host $($VMName.Name) "does not exist on this host"
        #Write-Host $VMName.Name "does not exist on this host" -ForegroundColor Red
        Write-Host "`t $($VMName.Name) does not exist on this host" -ForegroundColor Red
        Exit
    }
    # Complete Process for VM
    Write-Host "Processing of $($VMName.Name) has completed" -ForegroundColor Green
}

# End
