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
    If ($xmldata.GPO.LinksTo -eq $null) {
        Return $true
    }
    
    Return $false
}

$unlinkedGPOs = @()

Get-GPO -All | ForEach { $gpo = $_ ; $_ | Get-GPOReport -ReportType xml | ForEach { If(IsNotLinked([xml]$_)){$unlinkedGPOs += $gpo} }}

If ($unlinkedGPOs.Count -eq 0) {
    "No Unlinked GPO's Found"
}
Else{
    $unlinkedGPOs | sort GpoStatus,DisplayName | Select DisplayName,ID,GpoStatus,CreationTime,ModificationTime | Export-Csv -Delimiter ',' -Path $backupFolderPath$backupFileName-UnlinkedGPOReport.csv -NoTypeInformation
}