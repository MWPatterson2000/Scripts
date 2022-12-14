# Build Variables
# Get Date & Data Locations
#$date = get-date -Format "yyyy-MM-dd-HH-mm"
#$date = get-date -Format "yyyy-MM-dd-HH"
$date = get-date -Format "yyyy-MM-dd"

$rootPath = "C" # Can use another drive if available
$folder = "Temp" # Data Location
$folderPath = $rootPath + ":\" + $folder + "\"

# Output Files
$Script:ouReportFile = $folderPath + $date + ' - AD OU Object Counts.csv'

# Build Array for OU Reporting
$Script:ouReporting = [System.Collections.ArrayList]::new()

# Get AD OU's
Write-Host "Getting AD OU's" -Fore Yellow
$ous= Get-ADOrganizationalUnit -filter 'Name -like "*"'

# Get Count of Objects in each OU
Write-Host "Getting Object Count for each of the AD OU's" -Fore Yellow
Foreach ($ou in $ous) {
    <#
    Get-ADObject -Filter * -SearchBase $ou.distingishedname -SearchScope OneLevel |
        Group-Object -Property ObjectClass |
            Select-Object @{N='OUName';E={$ou.Name}},@{N='OUDN';E={$ou.DistinguishedName}},Name,Count
    #>
    Write-Host "`tGetting Object Count for:" $ou.DistinguishedName -Fore Yellow
    # Get Counts
    $countObjects = @(Get-ADObject -SearchBase $ou -SearchScope OneLevel -Filter *).Count
    $countComputer = @(Get-ADObject -SearchBase $ou -SearchScope OneLevel -Filter {(objectClass -eq "user") -and (objectCategory -eq "computer")}).Count
    $countUser = @(Get-ADObject -SearchBase $ou -SearchScope OneLevel -Filter {(objectClass -eq "user") -and (objectCategory -eq "user")}).Count
    #$countSecGroups = @(Get-ADObject -SearchBase $ou -SearchScope OneLevel -Filter {(objectClass -eq "group") -and (groupCategory -eq 'Security')}).Count
    #$countDistGroups = @(Get-ADObject -SearchBase $ou -SearchScope OneLevel -Filter {(objectClass -eq "group") -and (groupCategory -eq 'Distribution')}).Count
    $countSecGroups = @(Get-ADGroup -SearchBase $ou -SearchScope OneLevel -Filter {groupCategory -eq 'Security'}).Count
    $countDistGroups = @(Get-ADGroup -SearchBase $ou -SearchScope OneLevel -Filter {groupCategory -eq 'Distribution'}).Count
    $countContacts = @(Get-ADObject -SearchBase $ou -SearchScope OneLevel -Filter 'objectClass -eq "contact"').Count
    #$countObjects = @(Get-ADObject -SearchBase $ou -SearchScope OneLevel -Filter *).Count

    # Build Output
    #"Objects in $ou : $Count"
    $ouReportingT = New-Object System.Object
    $ouReportingT | Add-Member -type noteproperty -Name 'OU' -value $ou
    $ouReportingT | Add-Member -type noteproperty -Name 'Objects' -value $countObjects
    $ouReportingT | Add-Member -type noteproperty -Name 'Computers' -value $countComputer
    $ouReportingT | Add-Member -type noteproperty -Name 'Users' -value $countUser
    $ouReportingT | Add-Member -type noteproperty -Name 'Security Groups' -value $countSecGroups
    $ouReportingT | Add-Member -type noteproperty -Name 'Distribution Groups' -value $countDistGroups
    $ouReportingT | Add-Member -type noteproperty -Name 'Contacts' -value $countContacts
    #$ouReportingT | Add-Member -type noteproperty -Name 'Objects' -value $countO
    [void]$Script:ouReporting.Add($ouReportingT)
} 

# Export OU Object Count Report
$Script:ouReporting | Export-Csv -Path $Script:ouReportFile -Encoding utf8 -NoTypeInformation