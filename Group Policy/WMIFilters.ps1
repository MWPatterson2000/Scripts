$ReferenceFile = 'C:\temp\WMIExport.csv'

$WMIFilters = @()

$Domain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
$DomainName = $Domain.Name
$DomainDistinguishedName = $Domain.GetDirectoryEntry() | Select-Object -ExpandProperty DistinguishedName
$SearchRoot = [adsi]("LDAP://CN=SOM,CN=WMIPolicy,CN=System,"+$DomainDistinguishedName)
$search = new-object System.DirectoryServices.DirectorySearcher($SearchRoot)
$search.filter = "(objectclass=msWMI-Som)"
$results = $search.FindAll()
ForEach ($result in $results) {
    $obj = New-Object -TypeName PSObject
    $obj | Add-Member -MemberType NoteProperty -Name "DistinguishedName" -value $result.properties["distinguishedname"].item(0)
    $obj | Add-Member -MemberType NoteProperty -Name "msWMI-Name" -value $result.properties["mswmi-name"].item(0)
    $obj | Add-Member -MemberType NoteProperty -Name "msWMI-Parm1" -value $result.properties["mswmi-parm1"].item(0)
    $obj | Add-Member -MemberType NoteProperty -Name "msWMI-Parm2" -value $result.properties["mswmi-parm2"].item(0)
    $obj | Add-Member -MemberType NoteProperty -Name "Name" -value $result.properties["name"].item(0)
    $WMIFilters += $obj
    }

$RowCount = $WMIFilters | Measure-Object | Select-Object -expand count

if ($RowCount -ne 0) {
    write-host -ForeGroundColor Green "Exporting $RowCount WMI Filters`n"

    foreach ($WMIFilter in $WMIFilters) {
        write-host -ForeGroundColor Green "Exporting the" $WMIFilter."msWMI-Name" "WMI Filter to $ReferenceFile`n"
        $NewContent = $WMIFilter."msWMI-Name" + "`t" + $WMIFilter."msWMI-Parm1" + "`t" + $WMIFilter."msWMI-Parm2"
        add-content $NewContent -path $ReferenceFile
        }
    write-host -ForeGroundColor Green "An export of the WMI Filters has been stored at $ReferenceFile`n"
    } 

else {
    write-host -ForeGroundColor Green "There are no WMI Filters to export`n"
    } 