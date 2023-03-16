#Set Domain
$domain = $env:USERDNSDOMAIN #Full Domain Name
#$domain = $env:USERDOMAIN #Short Domain Name

#Get Date & Backup Locations
$date = get-date -Format "yyyy-MM-dd-HH-mm"
$backupRoot = "C:\" #Can use another drive if available
$backupFolder = "GPOBackupByName\"
$backupFolderPath = $backupRoot +$backupFolder
$backupFileName = $date +"-" +$domain 

#Unlinked Report
import-module grouppolicy

function IsNotLinked($xmldata){
    If ($null -eq $xmldata.GPO.LinksTo) {
        Return $true
    }
    
    Return $false
}

$unlinkedGPOs = @()

Get-GPO -All | ForEach-Object { $gpo = $_ ; $_ | Get-GPOReport -ReportType xml | ForEach-Object { If(IsNotLinked([xml]$_)){$unlinkedGPOs += $gpo} }}

If ($unlinkedGPOs.Count -eq 0) {
    "No Unlinked GPO's Found"
}
Else{
    $unlinkedGPOs | Sort-Object GpoStatus,DisplayName | Select-Object DisplayName,ID,GpoStatus,CreationTime,ModificationTime | Export-Csv -Delimiter ',' -Path $backupFolderPath$backupFileName-UnlinkedGPOReport.csv -NoTypeInformation
}