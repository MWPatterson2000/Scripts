# List VM Disk Files

#Clear-Host
Clear-Host

# Functions - Start

function getVHDFiles {
    # Search for VHD files in subfolders?
    $allVHD = Get-ChildItem *.vhd -Path $path -Recurse -ErrorAction SilentlyContinue
    # Are there any VHD files in the location?
    if ($allVHD.Count -gt 0) {
        Write-Host "It is recommended to change to VHDX Files" -ForegroundColor Red
        Write-Host "VHD files in $($path): $($allVHD.Count)" -ForegroundColor Green
        #Write-Host $allVHD.FullName
        $allVHD.FullName
    }
}

function getVHDXFiles {
    # Search for VHDX files in subfolders?
    $allVHDX = Get-ChildItem *.vhdx -Path $path -Recurse -ErrorAction SilentlyContinue
    # Are there any VHDX files in the location?
    if ($allVHDX.Count -gt 0) {
        Write-Host "VHDX files in $($path): $($allVHDX.Count)" -ForegroundColor Green
        #Write-Host $allVHDX.FullName
        $allVHDX.FullName
        }
}

# Functions - End

Write-Host "Getting list of VM Disk(s)" -ForegroundColor Green

# Get VM Disk Files - VHD
#Get-ChildItem *.vhd -Path D:\Hyper-V\ -Recurse | Select-Object FullName
# Path = "C:\Hyper-V\"
$path = "C:\Hyper-V\"
getVHDFiles
# Path = "D:\Hyper-V\"
$path = "D:\Hyper-V\"
getVHDFiles


# Get VM Disk Files - VHDX
#Get-ChildItem *.vhdx -Path D:\Hyper-V\ -Recurse | Select-Object FullName
# Path = "C:\Hyper-V\"
$path = "C:\Hyper-V\"
getVHDXFiles
# Path = "D:\Hyper-V\"
$path = "D:\Hyper-V\"
getVHDXFiles


# End

