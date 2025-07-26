# Oneliner
Get-InstalledModule | ForEach-Object { Uninstall-Module -Name $_.Name -AllVersions -Force }

# Oneliner
Get-Module -ListAvailable | ForEach-Object { Uninstall-Module -Name $_.Name -Force }

