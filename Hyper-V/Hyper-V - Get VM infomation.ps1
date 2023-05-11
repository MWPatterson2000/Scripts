<#
Name: Hyper-V - Get VM infomation - ##.ps1

This script is get Hyper-V Host and Client Info

Michael Patterson
Mike.Patterson@mfa.net

Revision History
    2018-11-23 - Initial Release

#>

# Clear Screen
Clear-Host

<#
# Check For Admin Mode
#Requires -RunAsAdministrator
#>

# Set Variables


#<#
# Get Date & Log Locations
$date = get-date -Format "yyyy-MM-dd-HH-mm"
$logRoot = "C:\"
$logFolder = "Scripts\"
$logFolderPath = $logRoot +$logFolder
$logFile = "Hyper-V VMs.csv"
$logFile1 = "Hyper-V VMs.txt"
$logFileName = $date +"-" +$logFile 
$logFileName1 = $date +"-" +$logFile1 
$logPath = $logRoot +$logFolder +$date +"-" +$logFile
$logPath1 = $logRoot +$logFolder +$date +"-" +$logFile1
#>

# Get VM's on Hosts
$EduVirHosts = Get-ClusterNode

$vms = foreach($VirHost in $EduVirHosts) {
    Get-VM -ComputerName $VirHost |
        #Select-Object | select -ExpandProperty networkadapters | select ComputerName, VMName, MacAddress, SwitchName, IPAddresses | Sort-Object VMName
        #Select-Object | select -ExpandProperty networkadapters | select ComputerName, VMName, MacAddress, SwitchName, IPAddresses
        #Select-Object | select -ExpandProperty networkadapters | select ComputerName, VMName, MacAddress, SwitchName, @{Name="IPAddresses";Expression={[string]::join(“;”, ($_.IPAddresses))}} | Sort-Object VMName
        Select-Object | Select-Object -ExpandProperty networkadapters | Select-Object ComputerName, VMName, MacAddress, SwitchName, @{Name="IPAddresses";Expression={[string]::join(“;”, ($_.IPAddresses))}}
}			

# Write Output to Screen
#$vms | Sort-Object ComputerName, VMName| Format-Table -AutoSize

# Write Output to File
$vms | Sort-Object ComputerName, VMName | Export-Csv $logPath -NoTypeInformation
#$vms | Sort-Object ComputerName, VMName | Out-File $logPath1
#| Sort-Object vmname | Format-Table -AutoSize
