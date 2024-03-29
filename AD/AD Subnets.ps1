# Get Date & Log Locations
$date = get-date -Format "yyyy-MM-dd-HH-mm"
$logRoot = "C:\"
$logFolder = "Temp\"
$logFolderPath = $logRoot +$logFolder
$logFile = "AD-Subnets.csv"
$logFileName = $date +"-" +$logFile 
#$logPath = $logRoot +$logFolder +$date +"-" +$logFile
$logPath = $logRoot +$logFolder +$date +"-" +$env:USERDNSDOMAIN +"-" +$logFile

## Get a list of all domain controllers in the forest
$DcList = (Get-ADForest).Domains | ForEach-Object { Get-ADDomainController -Discover -DomainName $_ } | ForEach-Object { Get-ADDomainController -Server $_.Name -filter * } | Select-Object Site, Name, Domain

## Get all replication subnets from Sites & Services
#$Subnets = Get-ADReplicationSubnet -filter * -Properties * | Select-Object Name, Site, Location, Description, Created, Modified, whenCreated, whenChanged
$Subnets = Get-ADReplicationSubnet -filter * -Properties * | Select-Object *

## Create an empty array to build the subnet list
$ResultsArray = @()

## Loop through all subnets and build the list
ForEach ($Subnet in $Subnets) {

    $SiteName = ""
    If ($null -ne $Subnet.Site) { $SiteName = $Subnet.Site.Split(',')[0].Trim('CN=') }

    $DcInSite = $False
    If ($DcList.Site -Contains $SiteName) { $DcInSite = $True }

    $RA = New-Object PSObject
    $RA | Add-Member -type NoteProperty -name "Subnet"   -Value $Subnet.Name
    $RA | Add-Member -type NoteProperty -name "SiteName" -Value $SiteName
    $RA | Add-Member -type NoteProperty -name "DcInSite" -Value $DcInSite
    $RA | Add-Member -type NoteProperty -name "SiteLoc"  -Value $Subnet.Location
    $RA | Add-Member -type NoteProperty -name "SiteDesc" -Value $Subnet.Description
    $RA | Add-Member -type NoteProperty -name "Created" -Value $Subnet.Created
    $RA | Add-Member -type NoteProperty -name "Modified" -Value $Subnet.Modified
    #$RA | Add-Member -type NoteProperty -name "whenCreated" -Value $Subnet.whenCreated
    #$RA | Add-Member -type NoteProperty -name "whenChanged" -Value $Subnet.whenChanged

    $ResultsArray += $RA

}

## Export the array as a CSV file
#$ResultsArray | Sort Subnet | Export-Csv .\AD-Subnets.csv -nti
$ResultsArray | Sort-Object Subnet | Export-Csv $logPath -nti
