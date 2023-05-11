<# Retrieve the Virtual Hosts for the current Hyper-V Cluster #>
$EduVirHosts = Get-ClusterNode

foreach($VirHost in $EduVirHosts)
{
    Get-VM -ComputerName $VirHost |
        #Select-Object -Property ComputerName, Name, State, CPUUsage, MemoryAssigned , Uptime Status, Version, ReplicationHealth #| Format-Table
        #Select-Object -Property ComputerName, Name, State, CPUUsage, MemoryAssigned , Status, Version, ReplicationHealth #| Format-Table
        #Select-Object -Property ComputerName, Name, State, CPUUsage, MemoryAssigned , Status, ReplicationHealth #| Format-Table
        #Select-Object -Property ComputerName, Name, State, CPUUsage, MemoryAssigned , ReplicationHealth #| Format-Table
        #Select-Object -Property ComputerName, Name, State, MemoryAssigned , ReplicationHealth #| Format-Table
        Select-Object -Property ComputerName, Name, State, ReplicationHealth #| Format-Table
        #Select-Object -Property ComputerName, Name, State, Status, ReplicationHealth #| Format-Table
}