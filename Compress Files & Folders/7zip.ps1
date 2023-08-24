
# Path to 7-Zip
$7zipPath = "$env:ProgramFiles\7-Zip\7z.exe"

# Create Alias
Set-Alias Compress-7Zip $7ZipPath

# Set Source & Destination
$Source = "C:\Events\System.txt"
$Destination = "c:\PS\Events.zip"

# Compress Files/Folder
#Compress-7zip a -mx=9 $Destination $Target
#Compress-7zip a -mx9 -r -tzip $Destination $Source # Zip Format
Compress-7zip a -mx9 -r -t7z $Destination $Source # 7Z Format

# End
