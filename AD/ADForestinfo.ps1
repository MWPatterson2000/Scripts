<# 
.SCRIPT NAME
Forestinfo.ps1

.VERSION
    1.0
    1.1 Added Updated Servers & Update Report File Name
    1.1 Added Change Schema Info
    1.2 Added Sort for Output
    1.3 Added Count for Domain Admins, Cleanup
    1.4 Added Funcional Level & Modes, Fixed issues with null in OS Version

#>

# Set Domain
$domain = $env:USERDNSDOMAIN
#$domain = $env:USERDOMAIN

# Get Date & Log Locations
$date = get-date -Format 'yyyy-MM-dd-HH-mm'
$logRoot = 'C:\'
$logFolder = 'Temp\'
$logFolderPath = $logRoot + $logFolder
$logFile = 'AD Status.html'
#$logFileName = $date +"-" +$logFile 
$logPath = $logRoot + $logFolder + $date + '-' + $domain + '-' + $logFile

Import-Module ActiveDirectory
import-module grouppolicy 
#---------------------------------------------------------------------------------------------------------------------------------------------------
$a = '<style>'
$a = $a + 'TABLE{border-width: 1px;border-style: solid;border-color: black;border-collapse: collapse;}'
$a = $a + 'TH{border-width: 1px;padding: 0px;border-style: solid;border-color: black;background-color:thistle}'
$a = $a + 'TD{border-width: 1px;padding: 0px;border-style: solid;border-color: black;background-color:palegoldenrod}'
$a = $a + '.odd  { background-color:#ffffff; }'
$a = $a + '.even { background-color:#dddddd; }'
$a = $a + '</style>'
#---------------------------------------------------------------------------------------------------------------------------------------------------
#Write-Host "Processing Forest Information: $domainname" -ForegroundColor Green
$ForestInfo = Get-ADForest
$forest = $ForestInfo.RootDomain
[Array]$allDomains = $ForestInfo.Domains
[Array]$ForestGC = $ForestInfo.GlobalCatalogs
[Array]$UPNsuffix = $ForestInfo.UPNSuffixes
$ffl = $ForestInfo.ForestMode
$FSMODomainNaming = $ForestInfo.DomainNamingMaster
$FSMOSchema = $ForestInfo.SchemaMaster
$ADRecBinSupport = 'feature not supported'
#---------------------------------------------------------------------------------------------------------------------------------------------------
# AD RecycleBin
if ($ffl -like 'Windows2008R2Forest' -or $ffl -like 'Windows2012Forest' -or $ffl -like 'Windows2012R2Forest' -or $ffl -like 'Windows2016Forest' -or $ffl -like 'Windows2019Forest' -or $ffl -like 'Windows2022Forest' -or $ffl -like 'Windows2025Forest') {
    $ADRecBin = (Get-ADOptionalFeature -Server $forest -Identity 766ddcd8-acd0-445e-f3b9-a7f9b6744f2a).EnabledScopes | Measure-Object
    if ($ADRecBin.Count -ne 0 ) {
        $ADRecBinSupport = 'Enabled'
    }
    else {
        $ADRecBinSupport = 'Disabled'
    }
}
#---------------------------------------------------------------------------------------------------------------------------------------------------
# Define Schema Partition Variables
$SchemaPartition = $ForestInfo.PartitionsContainer.Replace('CN=Partitions', 'CN=Schema')
$configPartition = $ForestInfo.PartitionsContainer.Replace('CN=Partitions,', '')
#---------------------------------------------------------------------------------------------------------------------------------------------------
# Get Forest AD Functional Levels
$domainControllerFunctionality = (Get-ADRootDSE).domainControllerFunctionality
$domainFunctionality = (Get-ADRootDSE).domainFunctionality
$forestFunctionality = (Get-ADRootDSE).forestFunctionality

# To get the Schema Version
#Write-Host "Processing Forest Schema Information: $domainname" -ForegroundColor Green
$SchemaVersion = Get-ADObject -Server $forest -Identity $SchemaPartition -Properties * | Select-Object objectVersion
switch ($SchemaVersion.objectVersion) {
    13 { $Sc_os_name = 'Windows 2000 Server' }
    30 { $Sc_os_name = 'Windows Server 2003' }
    31 { $Sc_os_name = 'Windows Server 2003 R2' }
    44 { $Sc_os_name = 'Windows Server 2008' }
    47 { $Sc_os_name = 'Windows Server 2008 R2' }
    51 { $Sc_os_name = 'Windows Server 8 Developers Preview' }
    52 { $Sc_os_name = 'Windows Server 8 Beta' }
    56 { $Sc_os_name = 'Windows Server 2012' }
    69 { $Sc_os_name = 'Windows Server 2012 R2' }
    72 { $Sc_os_name = 'Windows Server Technical Preview' }
    87 { $Sc_os_name = 'Windows Server 2016' }
    88 { $Sc_os_name = 'Windows Server 2019/2022' }
    90 { $Sc_os_name = 'Windows Server 2025' }
    default { $Sc_os_name = 'Unknow' + '-' + $SchemaVersion.objectVersion }
}
#---------------------------------------------------------------------------------------------------------------------------------------------------
#Write-Host "Processing Forest Admin Group Information: $domainname" -ForegroundColor Green
# No of Schema Admins
$schemaGroupID = ((Get-ADDomain(Get-ADForest).name).domainSID).value + '-518'
[array]$schemaAdminsNo = Get-ADGroup -Server $forest -Identity $schemaGroupID | Get-ADGroupMember -Recursive
# No of Enterprise Admins
$entGroupID = ((Get-ADDomain(Get-ADForest).name).domainSID).value + '-519'
[array]$enterpriseAdminsNo = Get-ADGroup -Server $forest -Identity $entGroupID | Get-ADGroupMember -Recursive
<#
# No of Domain Admins
$domAdminGroupID = ((Get-ADDomain(Get-ADForest).name).domainSID).value + "-512"
[array]$domainAdminsNo = Get-ADGroup -Server $forest -Identity $domAdminGroupID | Get-ADGroupMember -Recursive
#>
#---------------------------------------------------------------------------------------------------------------------------------------------------
# Get the TombstoneLifetime
$tombstoneLifetime = (Get-ADobject -Server $forest -Identity "cn=Directory Service,cn=Windows NT,cn=Services,$configPartition" -Properties tombstoneLifetime).tombstoneLifetime
#---------------------------------------------------------------------------------------------------------------------------------------------------
$ConfigurationPart = ($ForestInfo.PartitionsContainer -Replace 'CN=Partitions,', '')
[Array]$AllSites = Get-ADObject -Server $forest -Filter { objectClass -eq 'site' } -SearchBase $ConfigurationPart -Properties *
[Array]$AllSubnets = Get-ADObject -Server $forest -Filter { objectClass -eq 'subnet' } -SearchBase $ConfigurationPart -Properties *
[Array]$siteLinks = Get-ADObject -Server $forest -Filter { objectClass -eq 'siteLink' } -SearchBase $ConfigurationPart -Properties name, cost, replInterval, siteList | Sort-Object replInterval
#---------------------------------------------------------------------------------------------------------------------------------------------------
#Write-Host "Processing Forest Exchange Information: $domainname" -ForegroundColor Green
# Get Exchange Information
If (Test-Path "AD:$SchemaPathExchange") {
    $SchemaVersionExchange = Get-ADObject "CN=ms-Exch-Schema-Version-Pt,$((Get-ADRootDSE).schemaNamingContext)" -Property * | Select-Object rangeUpper
} 
Else {
    $SchemaVersionExchange.rangeUpper = 0
}
switch ($SchemaVersionExchange.rangeUpper) {
    0 { $Sc_ex_name = 'No Exchange' }
    # Exchange 2000
    4397 { $Sc_ex_name = 'Exchange Server 2000 RTM' }
    4406 { $Sc_ex_name = 'Exchange Server 2000 SP3' }
    # Exchange 2003
    6870 { $Sc_ex_name = 'Exchange Server 2003 RTM' }
    6936 { $Sc_ex_name = 'Exchange Server 2003 SP3' }
    # Exchange 2007
    10628 { $Sc_ex_name = 'Exchange Server 2007 RTM' }
    10637 { $Sc_ex_name = 'Exchange Server 2007 RTM' }
    11116 { $Sc_ex_name = 'Exchange 2007 SP1' }
    14622 { $Sc_ex_name = 'Exchange 2007 SP2 or Exchange Server 2007 RTM' }
    14625 { $Sc_ex_name = 'Exchange 2007 SP3' }
    # Exchange 2010
    #14622 { $Sc_ex_name = "Exchange Server 2007 RTM" }
    14726 { $Sc_ex_name = 'Exchange 2010 SP1' }
    14732 { $Sc_ex_name = 'Exchange 2010 SP2' }
    14734 { $Sc_ex_name = 'Exchange 2010 SP3' }
    # Exchange 2013
    15137 { $Sc_ex_name = 'Exchange 2013 RTM' }
    15254 { $Sc_ex_name = 'Exchange 2013 CU1' }
    15281 { $Sc_ex_name = 'Exchange 2013 CU2' }
    15283 { $Sc_ex_name = 'Exchange 2013 CU3' }
    15292 { $Sc_ex_name = 'Exchange 2013 SP1' } 
    15300 { $Sc_ex_name = 'Exchange 2013 CU5' }
    15303 { $Sc_ex_name = 'Exchange 2013 CU6' }
    15312 { $Sc_ex_name = 'Exchange 2013 CU7-CU23' }
    # Exchange 2016
    15317 { $Sc_ex_name = 'Exchange 2016 Preview/RTM' }
    15323 { $Sc_ex_name = 'Exchange 2016 CU1' }
    15325 { $Sc_ex_name = 'Exchange 2016 CU2' }
    15326 { $Sc_ex_name = 'Exchange 2016 CU3-CU5' }
    15330 { $Sc_ex_name = 'Exchange 2016 CU6' }
    15332 { $Sc_ex_name = 'Exchange 2016 CU7-CU18' }
    15333 { $Sc_ex_name = 'Exchange 2016 CU19-CU20' }
    15334 { $Sc_ex_name = 'Exchange 2016 CU21-CU23' }
    # Exchange 2019
    17000 { $Sc_ex_name = 'Exchange 2019 RTM/CU1' }
    17001 { $Sc_ex_name = 'Exchange 2019 CU2-CU7' }
    17002 { $Sc_ex_name = 'Exchange 2019 CU8-CU9' }
    17003 { $Sc_ex_name = 'Exchange 2019 CU10-CU14' }
    default { $Sc_ex_name = 'Unknown Exchange' }
}

#Write-Host $SchemaVersionExchange.rangeUpper
#Write-Host $Sc_ex_name
#Pause
#---------------------------------------------------------------------------------------------------------------------------------------------------
$props = @{'AD RecycleBin'               = $ADRecBinSupport
    'Tombstone Lifetime'                 = $tombstoneLifetime
    'Directory Controller Functionality' = $domainControllerFunctionality
    'Active Directory Forest Mode'       = $forestFunctionality
    'Active Directory Domain Mode'       = $domainFunctionality
    #'Schema Version'=$Sc_os_name +"-"+$SchemaVersion.objectversion
    'Schema Version'                     = $Sc_os_name + ' : ' + $SchemaVersion.objectversion
    'Exchange Schema Version'            = $Sc_ex_name + ' : ' + $SchemaVersionExchange.rangeUpper
    #'Exchange Schema Version'=$SchemaVersionExchange.rangeUpper
    #'Exchange Version'=$Sc_ex_name
    'DomainNaming Master'                = $FSMODomainNaming
    'Schema Master'                      = $FSMOSchema
    'Total Sites'                        = $AllSites.count
    'Total Subnets'                      = $AllSubnets.count
    'Forest Root Domain'                 = $forest
    'Forest Name'                        = $forestinfo.name
    'Total Domains in Forest'            = $allDomains.count
    'Total Global Catalog Servers'       = $ForestGC.count
    'Forest Functional Level'            = $ffl
    'Total Sitelinks'                    = $siteLinks.count
    'Number of Schema Admins'            = $schemaAdminsNo.count
    'Number of Enterprise Admins'        = $enterpriseAdminsNo.count
    #'Number of Domain Admins'      = $domainAdminsNo.count
}
$obj = New-Object -TypeName PSObject -Property $props
$allsites = $allsites | Sort-Object name
$frag1 = $obj | ConvertTo-Html -As LIST -Fragment -PreContent '<center><h1>FOREST LEVEL INFORMATION </h1></center>' | Out-String
$frag3 = $allsites | Select-Object name | ConvertTo-Html -property Name -head $a -PreContent '<h2>Sites information</h2>' | Out-String
#---------------------------------------------------------------------------------------------------------------------------------------------------
#Write-Host "Processing Forest Subnet Information: $domainname" -ForegroundColor Green
[Array]$AllSubnet = $null
## Get a list of all domain controllers in the forest
$DcList = (Get-ADForest).Domains | ForEach-Object { Get-ADDomainController -Discover -DomainName $_ } | ForEach-Object { Get-ADDomainController -Server $_.Name -filter * } | Select-Object Site, Name, Domain

## Get all replication subnets from Sites & Services
$Subnets = Get-ADReplicationSubnet -filter * -Properties * | Select-Object Name, Site, Location, Description

## Loop through all subnets and build the list
ForEach ($Subnet in $Subnets) {
    $SiteName = ''
    If ($null -ne $Subnet.Site) { $SiteName = $Subnet.Site.Split(',')[0].Trim('CN=') }

    $DcInSite = $False
    If ($DcList.Site -Contains $SiteName) { $DcInSite = $True }

    $member = New-Object PSObject
    $member | Add-Member -type NoteProperty -name 'Subnet'   -Value $Subnet.Name
    $member | Add-Member -type NoteProperty -name 'SiteName' -Value $SiteName
    $member | Add-Member -type NoteProperty -name 'DcInSite' -Value $DcInSite
    $member | Add-Member -type NoteProperty -name 'SiteLoc'  -Value $Subnet.Location
    $member | Add-Member -type NoteProperty -name 'SiteDesc' -Value $Subnet.Description
    $AllSubnet += $member
}

$AllSubnet = $AllSubnet | Sort-Object SiteName, Subnet, DcInSite, SiteLoc, SiteDesc
$frag4 = $AllSubnet | Select-Object Subnet, SiteName, DcInSite, SiteLoc, SiteDesc | ConvertTo-Html -property Subnet, SiteName, DcInSite, SiteLoc, SiteDesc -head $a -PreContent '<h2>Subnets information</h2>' | Out-String

<#
foreach ($site in $allsites) {
    $Sitename = $Site.name
    [Array]$subnets = $Site.siteObjectBL
    if ($subnets.length -gt 0) {
        foreach ($subnet in $subnets) {
            $DcInSite = $False
            If ($DcList.Site -Contains $SiteName) { $DcInSite = $True }
            $SubnetSplit = $Subnet.Split(",")
            $Subnetname = $SubnetSplit[0].Replace("CN=","")
            $member = New-Object PSObject
            $member | Add-Member -MemberType NoteProperty -Name "Site" -Value $Sitename
            $member | Add-Member -MemberType NoteProperty -Name "Subnet" -Value $Subnetname
            $member | Add-Member -MemberType NoteProperty -Name "DcInSite" -Value $DcInSite
            $AllSubnet += $member
        }
    }
    else {
        $DcInSite = $False
        If ($DcList.Site -Contains $SiteName) { $DcInSite = $True }

        $member = New-Object PSObject
        $member | Add-Member -MemberType NoteProperty -Name "Site" -Value $Sitename
        $member | Add-Member -MemberType NoteProperty -Name "Subnet" -Value $Null
        $member | Add-Member -MemberType NoteProperty -Name "DcInSite" -Value $DcInSite
        $AllSubnet += $member
    }
}

$frag4 = $AllSubnet | Select Site,Subnet,DcInSite | ConvertTo-Html -property Site,Subnet,DcInSite -head $a -PreContent '<h2>Subnets information</h2>' | Out-String
#>
#---------------------------------------------------------------------------------------------------------------------------------------------------
#Write-Host "Processing Forest Site Information: $domainname" -ForegroundColor Green
# Site links information
[Array]$siteLinks = Get-ADObject -Server $forest -Filter { objectClass -eq 'siteLink' } -SearchBase $ConfigurationPart -Properties name, cost, replInterval, siteList | Sort-Object replInterval
[Array]$siteLinksdetails = $null
foreach ($sitelink in $siteLinks) {
    [string]$ss = $null
    $member = New-Object PSObject
    $member | Add-Member -MemberType NoteProperty -Name 'name' -Value $sitelink.name
    $member | Add-Member -MemberType NoteProperty -Name 'cost' -Value $sitelink.cost
    $member | Add-Member -MemberType NoteProperty -Name 'replInterval' -Value $sitelink.replInterval
    foreach ($sitelink in $sitelink.siteList) {
        $siteName = Get-ADObject -Identity $sitelink -Properties Name
        $sitenName = $siteName.name
        $ss += ';'
        $ss += $sitenName
    }
    $ss1 = $null
    $ss1 = $ss.Split(';', 2)[1]
    $member | Add-Member -MemberType NoteProperty -Name 'Site Names' -Value $ss1
    $siteLinksdetails += $member
}
$siteLinksdetails = $siteLinksdetails | Sort-Object name, Cost, replInterval
$frag5 = $siteLinksdetails | Select-Object name, Cost, replInterval, 'Site Names' | ConvertTo-Html -head $a -PreContent '<h2>Site links information </h2>' | Out-String
#---------------------------------------------------------------------------------------------------------------------------------------------------

$precontent11 = '<center><h1>DOMAIN LEVEL INFORMATION </h1></center>'
$frag11 = ConvertTo-Html -head $a -PreContent $precontent11 | Out-String
#---------------------------------------------------------------------------------------------------------------------------------------------------
# Get Domains information
[String]$fra9 = $null
$allDomains | ForEach-Object {
    $domainname = $_
    Write-Host "Processing Domain Information: $domainname" -ForegroundColor Green
    $DomainReachability = $null
    $DomainReachability = get-addomain $domainname

    if ($DomainReachability -ne $null) {
        Write-Host "`t$domainname is reachable" -ForegroundColor Green
        [Array]$dcsdetails = $null
        [Array]$Domaincontrollersdetails = $null
        [Array]$allDomaincontrollersdetails = $null
        [Array]$allDomainsdetails = $null
        [Array]$dnsserver = $null
        [Array]$Trustdetails = $null
        [Array]$AllComputers = $null
        [Array]$Allgroups = $null
        [Array]$AllUsers = $null
                
        $nn = $null
        $nn1 = $null
        $nn2 = $null
        $nn3 = $null
        $nn4 = $null
        $nn5 = $null
        $nn6 = $null
        $nn7 = $null
        $nn8 = $null

        # SYSVOLREPLICATION Method
        $defaultNamingContext = (([ADSI]"LDAP://$domainname/rootDSE").defaultNamingContext)
        $searcher = New-Object DirectoryServices.DirectorySearcher
        $searcher.Filter = "(&(objectClass=computer)(dNSHostName=$domainname))"
        $searcher.SearchRoot = 'LDAP://' + $domainname + '/OU=Domain Controllers,' + $defaultNamingContext
        $dcObjectPath = $searcher.FindAll() | ForEach-Object { $_.Path }

        # DFSR
        $searchDFSR = New-Object DirectoryServices.DirectorySearcher
        $searchDFSR.Filter = '(&(objectClass=msDFSR-Subscription)(name=SYSVOL Subscription))'
        $searchDFSR.SearchRoot = $dcObjectPath
        $dfsrSubObject = $searchDFSR.FindAll()

        # FRS
        $searchFRS = New-Object DirectoryServices.DirectorySearcher
        $searchFRS.Filter = '(&(objectClass=nTFRSSubscriber)(name=Domain System Volume (SYSVOL share)))'
        $searchFRS.SearchRoot = $dcObjectPath
        $frsSubObject = $searchFRS.FindAll()
        if ($dfsrSubObject) {
            $Sysvol_repl_method = 'DFS-R'
        }
        elseif ($frsSubObject) {
            $Sysvol_repl_method = 'FRS'
        }
        else {
            $Sysvol_repl_method = 'UNKNOWN'
        }

        # DNS Servers in Domain
        $partitions = Get-ADObject -Server $forest -Filter * -SearchBase $ForestInfo.PartitionsContainer -SearchScope OneLevel -Properties name, nCName, msDS-NC-Replica-Locations | Select-Object name, nCName, msDS-NC-Replica-Locations | Sort-Object name
        [Array]$DNSServers1 = $null
        foreach ($part in $partitions) {
            $DNSServers = $part.'msDS-NC-Replica-Locations' | Sort-Object
            if ($DNSServers -ne $nul) {
                foreach ($DNSServer in $DNSServers) {
                    $DNSServers1 += ($DNSServer -Split ',')[1] -Replace 'CN=', ''
                }
            }
        }

        # Domain Admins
        $domaindetails = $null
        $domaindetails = get-addomain $domainname
        $domainSID = $domaindetails.DomainSID
        [int]$domainadmins = (Get-ADGroup -Identity $domainSID-512 -Server $domainname | Get-ADGroupMember -Recursive | Measure-Object).Count
        
        # Domain Mode
        $member = New-Object PSObject
        $member | Add-Member -MemberType NoteProperty -Name 'DomainName' -Value $domaindetails.DNSRoot
        if ($domaindetails.DomainMode -like '*win*') {
            $member | Add-Member -MemberType NoteProperty -Name 'DomainMode' -Value $domaindetails.DomainMode
        }
        else {
            switch ($domaindetails.DomainMode) {
                0 { $Domainmode = 'Windows 2000 Domain' }
                1 { $Domainmode = 'Windows Server 2003 Domain' }
                2 { $Domainmode = 'Windows Server 2003 R2 Domain' }
                3 { $Domainmode = 'Windows Server 2008 Domain' }
                4 { $Domainmode = 'Windows Server 2008 R2 Domain' }
                5 { $Domainmode = 'Windows Server 2012 Domain' }
                6 { $Domainmode = 'Windows Server 2012 R2 Domain' }
                7 { $Domainmode = 'Windows Server 2016 Domain' }
                #8 { $Domainmode = 'Windows Server 2019 Domain' } # Not used, No Changes
                #9 { $Domainmode = "Windows Server 2022 Domain" } # Not used, No Changes
                10 { $Domainmode = 'Windows Server 2025 Domain' }
                default { $Domainmode = 'Unknown' + '-' + $domaindetails.DomainMode }
            }
            $member | Add-Member -MemberType NoteProperty -Name 'DomainMode' -Value $DomainMode
        }
        $member | Add-Member -MemberType NoteProperty -Name 'NetBIOSName' -Value $domaindetails.NetBIOSName
        $member | Add-Member -MemberType NoteProperty -Name 'ParentDomain' -Value $domaindetails.ParentDomain
        $member | Add-Member -MemberType NoteProperty -Name 'PDCEmulator' -Value $domaindetails.PDCEmulator
        $member | Add-Member -MemberType NoteProperty -Name 'RIDMaster' -Value $domaindetails.RIDMaster
        $member | Add-Member -MemberType NoteProperty -Name 'InfrastructureMaster' -Value $domaindetails.InfrastructureMaster
        $member | Add-Member -MemberType NoteProperty -Name 'TotalREADandWRITEDCs' -Value ($domaindetails.ReplicaDirectoryServers).count
        $member | Add-Member -MemberType NoteProperty -Name 'TotalREADOnlyDCs' -Value ($domaindetails.ReadOnlyReplicaDirectoryServers).count
        $member | Add-Member -MemberType NoteProperty -Name 'sysvolReplMethod' -Value $Sysvol_repl_method
        $member | Add-Member -MemberType NoteProperty -Name 'DomainAdmins' -Value $domainadmins
        $allDomainsdetails += $member
        $dcsdetails = Get-ADDomainController -Filter * -Server $domainname
        $ADDomainTrusts = $null
        $ADDomainTrusts = Get-ADObject -Filter { ObjectClass -eq 'trustedDomain' } -Server $Domainname -Properties *
        $oslist = $null
        $oslist = Get-ADObject -ldapFilter '(ObjectClass=computer)' -Properties operatingsystem -server $domainname | Select-Object operatingsystem -Unique
        $Grouplist = $null
        $Grouplist = Get-ADGroup -Filter * -Properties GroupScope -server $domainname | Select-Object GroupScope -Unique

        # Domain Controller(s) Details
        Write-Host "Processing Domain Controllers Information: $domainname" -ForegroundColor Green
        foreach ($dcdetails in $dcsdetails) {
            $member = New-Object PSObject
            $member | Add-Member -MemberType NoteProperty -Name 'DomainName' -Value $dcdetails.Domain
            $member | Add-Member -MemberType NoteProperty -Name 'Sitename' -Value $dcdetails.Site
            $member | Add-Member -MemberType NoteProperty -Name 'HostName' -Value $dcdetails.HostName
            $member | Add-Member -MemberType NoteProperty -Name 'IPv4Address' -Value $dcdetails.IPv4Address
            $member | Add-Member -MemberType NoteProperty -Name 'IPv6Address' -Value $dcdetails.IPv6Address
            $member | Add-Member -MemberType NoteProperty -Name 'IsReadOnly' -Value $dcdetails.IsReadOnly
            $member | Add-Member -MemberType NoteProperty -Name 'IsGlobalCatalog' -Value $dcdetails.IsGlobalCatalog
            $dns = $null
            $dns = $dcdetails.Name
            if ($DNSServers1 -like "*$dns*") {
                $isDNS = 'True'
            }
            else {
                $isDNS = 'False'
            }
            $member | Add-Member -MemberType NoteProperty -Name 'isDNS' -Value $isDNS
            $member | Add-Member -MemberType NoteProperty -Name 'OperatingSystem' -Value $dcdetails.OperatingSystem
            $Domaincontrollersdetails += $member
        }

        # Trust Details
        Write-Host "Processing Domain Trust Information: $domainname" -ForegroundColor Green
        ForEach ($Trust in $ADDomainTrusts) { 
            Switch ($Trust.TrustAttributes) { 
                1 { $TrustAttributes = 'Non-Transitive' } 
                2 { $TrustAttributes = 'Uplevel Clients Only (Windows 2000 or newer' } 
                4 { $TrustAttributes = 'External' } 
                8 { $TrustAttributes = 'Forest Trust' } 
                16 { $TrustAttributes = 'Cross-Organizational Trust (Selective Authentication)' } 
                32 { $TrustAttributes = 'Intra-Forest Trust (trust within the forest)' } 
                64 { $TrustAttributes = 'Inter-Forest Trust (trust with another forest)' } 
                Default { $TrustAttributes = 'UNKNOWN' }
            } 
            switch ($Trust.trustDirection) {
                0 { $trustInfo = ($Trust.CanonicalName).Replace('/System/', '  Disabled  ') }
                3 { $trustInfo = ($Trust.CanonicalName).Replace('/System/', '  <<Bidirectional>>  ') }
                2 { $trustInfo = ($Trust.CanonicalName).Replace('/System/', '  <==Outbound (TrustED domain)==  ') }
                1 { $trustInfo = ($Trust.CanonicalName).Replace('/System/', '  ==Inbound (TrustING domain)==>>  ') }
                Default { $trustInfo = 'Unknown' }
            }
            $member = New-Object PSObject
            $member | Add-Member -MemberType NoteProperty -Name 'trustInfo' -Value $trustInfo
            $member | Add-Member -MemberType NoteProperty -Name 'TrustType' -Value $TrustAttributes
            $Trustdetails += $member
        }

        # Operating System Details
        Write-Host "Processing Domain Operating System Information: $domainname" -ForegroundColor Green
        foreach ($os in $oslist) {
            $osoperatingsystem = $null
            $osoperatingsystem = $os.operatingsystem
            if ($osoperatingsystem -ne $null) {
                [Array]$dd = $null
                #[Array]$dd = Get-Adobject -ldapFilter "(&(Objectclass=computer)(operatingsystem=$osoperatingsystem))"
                [Array]$dd = Get-Adobject -ldapFilter "(&(Objectclass=computer)(operatingsystem=$osoperatingsystem))" -server $domainname
                $member = New-Object PSObject
                $member | Add-Member -MemberType NoteProperty -Name 'OperatingSystem' -Value $osoperatingsystem
                $member | Add-Member -MemberType NoteProperty -Name 'Count' -Value $dd.count
                $AllComputers += $member
            }
        }
        $AllComputers = $AllComputers | Sort-Object OperatingSystem, Count

        # Group(s) Details
        Write-Host "Processing Domain Group Information: $domainname" -ForegroundColor Green
        foreach ($Groups in $Grouplist) {
            $Groupss = $null
            $Groupss = $Groups.GroupScope
            [Array]$Groupsdetails = $null
            [Array]$Groupsdetails = Get-ADgroup -Filter { GroupScope -eq $Groupss } -server $domainname
            $member = New-Object PSObject
            $member | Add-Member -MemberType NoteProperty -Name 'GroupType' -Value $Groupss
            $member | Add-Member -MemberType NoteProperty -Name 'Count' -Value $Groupsdetails.count
            $Allgroups += $member
        }

        # User(s) Details
        Write-Host "Processing Domain User Information: $domainname" -ForegroundColor Green
        [Array]$Userslist = $null
        [Array]$enabledUsers = $null
        [Array]$DisabledUsers = $null
        [Array]$Userslist = Get-ADObject -ldapFilter '(ObjectCategory=user)' -server $domainname
        [Array]$enabledUsers = Get-ADuser -Filter { enabled -eq 'TRUE' } -server $domainname
        [Array]$DisabledUsers = Get-ADuser -Filter { enabled -eq 'FALSE' } -server $domainname
        $member = New-Object PSObject
        $member | Add-Member -MemberType NoteProperty -Name 'TotalUsers' -Value $Userslist.count
        $member | Add-Member -MemberType NoteProperty -Name 'EnabledUsers' -Value $enabledUsers.count
        $member | Add-Member -MemberType NoteProperty -Name 'DisabledUsers' -Value $DisabledUsers.count
        $AllUsers += $member

        # Group Policy Details
        Write-Host "Processing Domain GPO Information: $domainname" -ForegroundColor Green
        [Array]$unlinkedGPOs = $null
        [Array]$GPOstatus = $null
        function IsNotLinked($xmldata) { 
            If ($null -eq $xmldata.GPO.LinksTo) { 
                Return $true 
            } 
            Return $false 
        } 
        Get-GPO -All -domain $domainname | ForEach-Object { 
            $gpo = $_  
            $_ | Get-GPOReport -domain $domainname -ReportType xml | ForEach-Object { If (IsNotLinked([xml]$_)) { [Array]$unlinkedGPOs += $gpo } } 
            $GPOstatus += $gpo.gpostatus
        }
        If ($unlinkedGPOs.Count -eq 0) {
            [int]$ULGPO = '0'
        } 
        Else {
            [int]$ULGPO = $unlinkedGPOs.Count
        }

        [Array]$AllSettingsDisabled = $null
        [Array]$UserSettingsDisabled = $null
        [Array]$AllSettingsEnabled = $null
        [Array]$ComputerSettingsDisabled = $null

        [Array]$AllSettingsDisabled = $GPOstatus | Where-Object { $_ -eq 'AllSettingsDisabled' }
        [Array]$UserSettingsDisabled = $GPOstatus | Where-Object { $_ -eq 'UserSettingsDisabled' }
        [Array]$AllSettingsEnabled = $GPOstatus | Where-Object { $_ -eq 'AllSettingsEnabled' }
        [Array]$ComputerSettingsDisabled = $GPOstatus | Where-Object { $_ -eq 'ComputerSettingsDisabled' }  

        [int]$AllSettingsDisabled1 = $AllSettingsDisabled.count
        [int]$UserSettingsDisabled1 = $UserSettingsDisabled.count
        [int]$AllSettingsEnabled1 = $AllSettingsEnabled.count
        [int]$ComputerSettingsDisabled1 = $ComputerSettingsDisabled.count
        $props = @{'Total Group Policies' = $GPOstatus.count
            'Unlinked Policies'           = $ULGPO
            'AllSettingsDisabled'         = $AllSettingsDisabled1
            'UserSettingsDisabled'        = $UserSettingsDisabled1
            'AllSettingsEnabled'          = $AllSettingsEnabled1
            'ComputerSettingsDisabled'    = $ComputerSettingsDisabled1
        }
        $obj1 = New-Object -TypeName PSObject -Property $props

        # Build Report
        $dnname = $domainname.toupper()
        $precontent8 = "<center><h1>DOMAIN: $dnname </h1></center>"
        $nn8 = ConvertTo-Html -head $a -PreContent $precontent8 | Out-String
        $precontent = '<h2> Domains Controllers Details</h2>'
        $precontent1 = '<h2> Trust Details</h2>'
        $precontent2 = '<h2> Operating System Details</h2>'
        $precontent3 = '<h2> Groups Details</h2>'
        $precontent4 = '<h2> Users Details</h2>'
        $precontent5 = '<h2> Group Policy Details</h2>'
        $precontent6 = '<h2> Domain Wide Information</h2>'
        $precontent7 = '<h2> Domain Wide Information - Contd</h2>'
        $nn = $Domaincontrollersdetails | Select-Object DomainName, Sitename, HostName, IPv4Address, IPv6Address, IsReadOnly, IsGlobalCatalog, isDNS, OperatingSystem | ConvertTo-Html -head $a -PreContent $precontent | Out-String
        $nn1 = $Trustdetails | Select-Object trustInfo, TrustType | ConvertTo-Html -head $a -PreContent $precontent1 | Out-String
        $nn2 = $AllComputers | Select-Object OperatingSystem, Count | ConvertTo-Html -head $a -PreContent $precontent2 | Out-String
        $nn3 = $Allgroups | Select-Object GroupType, Count | ConvertTo-Html -head $a -PreContent $precontent3 | Out-String
        $nn4 = $AllUsers | Select-Object TotalUsers, enabledUsers, DisabledUsers | ConvertTo-Html -head $a -PreContent $precontent4 | Out-String
        $nn5 = $obj1 | ConvertTo-Html -As LIST -Fragment -PreContent $precontent5 | Out-String
        $nn6 = $allDomainsdetails | Select-Object DomainName, DomainMode, NetBIOSName, ParentDomain, PDCEmulator, RIDMaster, InfrastructureMaster | ConvertTo-Html -head $a -PreContent $precontent6 | Out-String
        $nn7 = $allDomainsdetails | Select-Object DomainName, TotalREADandWRITEDCs, TotalREADOnlyDCs, sysvolReplMethod, DomainAdmins | ConvertTo-Html -head $a -PreContent $precontent7 | Out-String
        $fra9 += $nn8
        $fra9 += $nn6
        $fra9 += $nn7
        $fra9 += $nn
        $fra9 += $nn1
        $fra9 += $nn2
        $fra9 += $nn3
        $fra9 += $nn4
        $fra9 += $nn5
    }
    else {
        Write-Host "$domainname is NOT reachable" -ForegroundColor Green
        $dnname = $domainname.toupper()
        $precontent8 = "<center><h1>DOMAIN: $dnname </h1></center>"
        $nn8 = ConvertTo-Html -head $a -PreContent $precontent8 | Out-String
        $fra9 += $nn8
        $pre = '<h2> Unable to fetch domain information. Please run the script locally </h2>'
        $fra9 += ConvertTo-Html -head $a -PreContent $pre | Out-String
    }
}
#---------------------------------------------------------------------------------------------------------------------------------------------------
$fname = $forest.TOUPPER()
$timing = "<BR><i>Report generated on $((Get-Date).ToString()) from $($Env:Computername)</i>"
$precontenteND = '<center><h1>ACTIVE DIRECTORY FOREST OVERALL REPORT </h1></center>'

#ConvertTo-HTML -head $a -PostContent $frag1,$frag3,$frag4,$frag5,$frag11,$fra9,$timing -PreContent $precontenteND | Out-File .\status.html
ConvertTo-HTML -head $a -PostContent $frag1, $frag3, $frag4, $frag5, $frag11, $fra9, $timing -PreContent $precontenteND | Out-File $logPath
