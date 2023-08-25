# Ref URL: https://www.thomasmaurer.ch/2021/11/create-an-usb-drive-for-windows-server-2022-installation/

# Define Path to the Windows Server 2022 ISO
$ISOFile = "C:\Temp\WindowsServer2022.iso"

# Create temp diectroy for new image
$newImageDir = New-Item -Path 'C:\Temp\newimage' -ItemType Directory

# Mount iso
$ISOMounted = Mount-DiskImage -ImagePath $ISOFile -StorageType ISO -PassThru

# Driver letter
$ISODriveLetter = ($ISOMounted | Get-Volume).DriveLetter

# Copy Files to temporary new image folder 
Copy-Item -Path ($ISODriveLetter + ":\*") -Destination C:\Temp\newimage -Recurse

# Split and copy install.wim (because of the filesize)
dism /Split-Image /ImageFile:C:\Temp\newimage\sources\install.wim /SWMFile:C:\Temp\newimage\sources\install.swm /FileSize:4096

# Get the USB Drive you want to use, copy the disk number
Get-Disk | Where-Object BusType -eq "USB"

# Get the right USB Drive (You will need to change the number)
$USBDrive = Get-Disk | Where-Object Number -eq 2

# Replace the Friendly Name to clean the USB Drive (THIS WILL REMOVE EVERYTHING)
$USBDrive | Clear-Disk -RemoveData -Confirm:$true -PassThru

# Convert Disk to GPT
$USBDrive | Set-Disk -PartitionStyle GPT

# Create partition primary and format to FAT32
$Volume = $USBDrive | New-Partition -Size 8GB -AssignDriveLetter | Format-Volume -FileSystem FAT32 -NewFileSystemLabel WS2022

# Copy Files to USB (Ignore install.wim)
Copy-Item -Path C:\Temp\newimage\* -Destination ($Volume.DriveLetter + ":\") -Recurse -Exclude install.wim

# Dismount ISO
Dismount-DiskImage -ImagePath $ISOFile