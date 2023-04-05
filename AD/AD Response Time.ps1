#####################Variables#####################
$numberoftests = 10
###################################################

#####################Main#####################
import-module activedirectory

Clear-Host

$myForest = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()

$domaincontrollers = $myforest.Sites | % { $_.Servers } | Select-Object Name

foreach ($DomainController in $DomainControllers) {
    $totalmeasurement = 0
    $i = 0
    while ($i -ne $numberoftests) {
        $measurement = (Measure-Command { Get-ADUser Administrator -Server $DomainController.name }).TotalSeconds
        $totalmeasurement += $measurement
        $i += 1
    }
    $totalmeasurement = $totalmeasurement / $numberoftests
    "Domain Controller: " + $DomainController.name + ", Response time: " + $totalmeasurement + " seconds"
}