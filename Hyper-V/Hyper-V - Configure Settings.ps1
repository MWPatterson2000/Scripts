# Get list of VM(s)
Write-Host "Getting List of VM(s) on the computer" -ForegroundColor Green
$vmList = Get-VM | Select-Object *

# Work through each VM
foreach ($vm in $vmList) {
    #Write-Host "Changing Settings for VM:"($vm).Name -ForegroundColor Green
    Write-Host "Changing Settings for VM:" $vm.Name -ForegroundColor Green

    Set-VM -Name ($vm).Name -AutomaticStartAction Nothing

    Set-VM -Name ($vm).Name -CheckpointType Disabled

    Set-VMMemory  -VM ($vm).Name -DynamicMemoryEnabled $False
    Set-VMMemory  -VMName ($vm).Name -DynamicMemoryEnabled $False

    #Set-VMMemory  -VM ($vm).Name -Priority 50
    #Set-VMMemory  -VMName ($vm).Name -Priority 50

    Set-VMBios -VMName ($vm).Name -DisableNumLock

    Set-VMBios -VMName ($vm).Name -StartupOrder @("VHD", "CD", "LegacyNetworkAdapter", "Floppy", "IDE")
        
    Set-VMFirmware -VMName ($vm).Name -BootOrder $vmHardDiskDrive, $vmNetworkAdapter
    Set-VMFirmware -VM ($vm).Name -BootOrder $vmHardDiskDrive, $vmNetworkAdapter
    #Write-Host "Finished Changing Settings for VM:"($vm).Name -ForegroundColor Green
    Write-Host "Finished Changing Settings for VM:" $vm.Name -ForegroundColor Green
}

# End