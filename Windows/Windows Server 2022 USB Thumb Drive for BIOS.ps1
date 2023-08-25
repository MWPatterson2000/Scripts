# Ref URL: https://www.thomasmaurer.ch/2021/11/create-an-usb-drive-for-windows-server-2022-installation/

# Define Path to the Windows Server 2022 ISO
$ISOFile = "C:\Temp\WindowsServer2022.iso"

# Get the USB Drive you want to use, copy the friendly name
Get-Disk | Where-Object BusType -eq "USB"

# Get the right USB Drive (You will need to change the FriendlyName)
$USBDrive = Get-Disk | Where-Object FriendlyName -eq "Kingston DT Workspace"

# Replace the Friendly Name to clean the USB Drive (THIS WILL REMOVE EVERYTHING)
$USBDrive | Clear-Disk -RemoveData -Confirm:$true -PassThru

# Convert Disk to MBR
$USBDrive | Set-Disk -PartitionStyle MBR

# Create partition primary and format to NTFS
$Volume = $USBDrive | New-Partition -UseMaximumSize -AssignDriveLetter | Format-Volume -FileSystem NTFS -NewFileSystemLabel WS2022

# Set Partiton to Active
$Volume | Get-Partition | Set-Partition -IsActive $true

# Mount ISO
$ISOMounted = Mount-DiskImage -ImagePath $ISOFile -StorageType ISO -PassThru

# Driver letter
$ISODriveLetter = ($ISOMounted | Get-Volume).DriveLetter

# Copy Files to USB
Copy-Item -Path ($ISODriveLetter +":\*") -Destination ($Volume.DriveLetter + ":\") -Recurse

# Dismount ISO
Dismount-DiskImage -ImagePath $ISOFile