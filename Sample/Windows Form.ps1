# Load .NET Assemblie(s)
Add-Type -AssemblyName System.Windows.Forms

# Build Windows Form
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ InitialDirectory = [Environment]::GetFolderPath('Desktop') }

# Open Windows Form
$null = $FileBrowser.ShowDialog()

$FileBrowser
$FileBrowser.FileName
