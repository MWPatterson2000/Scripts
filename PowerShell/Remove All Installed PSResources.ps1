# Oneliner
Get-InstalledPSResource | ForEach-Object { Uninstall-PSResource -Name $_.Name -Force }

