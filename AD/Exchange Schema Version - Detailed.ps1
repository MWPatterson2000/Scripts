# Gets Exchange Schema Version and maps it to specific Exchange versions
# Reference: https://learn.microsoft.com/en-us/exchange/plan-and-deploy/prepare-ad-and-domains

function Get-ExchangeVersion {
    # Get Forest Schema Version
    $RootDSE = ([ADSI]'').distinguishedName
    $ForestRangeUpper = ([ADSI]"LDAP://CN=ms-Exch-Schema-Version-Pt,CN=Schema,CN=Configuration,$RootDSE").rangeUpper
    $ForestObjectVersion = ([ADSI]"LDAP://cn=Microsoft Exchange,cn=Services,cn=Configuration,$RootDSE").objectVersion

    # Get Domain Schema Version
    $DomainObjectVersion = ([ADSI]"LDAP://CN=Microsoft Exchange System Objects,$RootDSE").objectVersion

    # Create version mapping hashtables
    $SchemaVersions = @{
        # Exchange Server SE (Subscription Edition)
        15342 = 'Exchange Server SE CU1'
        15341 = 'Exchange Server SE RTM'
        
        # Exchange Server 2019
        15139 = 'Exchange Server 2019 CU15'
        15138 = 'Exchange Server 2019 CU14'
        15137 = 'Exchange Server 2019 CU13'
        15134 = 'Exchange Server 2019 CU12'
        15133 = 'Exchange Server 2019 CU11'
        15132 = 'Exchange Server 2019 CU10'
        15131 = 'Exchange Server 2019 CU9'
        15130 = 'Exchange Server 2019 CU8'
        15129 = 'Exchange Server 2019 CU7'
        15128 = 'Exchange Server 2019 CU6'
        15127 = 'Exchange Server 2019 CU5'
        15126 = 'Exchange Server 2019 CU4'
        15125 = 'Exchange Server 2019 CU3'
        15124 = 'Exchange Server 2019 CU2'
        15123 = 'Exchange Server 2019 CU1'
        15122 = 'Exchange Server 2019 RTM'
        
        # Exchange Server 2016
        15334 = 'Exchange Server 2016 CU23'
        15333 = 'Exchange Server 2016 CU22'
        15332 = 'Exchange Server 2016 CU21'
        15331 = 'Exchange Server 2016 CU20'
        15330 = 'Exchange Server 2016 CU19'
        15329 = 'Exchange Server 2016 CU18'
        15328 = 'Exchange Server 2016 CU17'
        15327 = 'Exchange Server 2016 CU16'
        15326 = 'Exchange Server 2016 CU15'
        15325 = 'Exchange Server 2016 CU14'
        15324 = 'Exchange Server 2016 CU13'
        15323 = 'Exchange Server 2016 CU12'
        15322 = 'Exchange Server 2016 CU11'
        15321 = 'Exchange Server 2016 CU10'
        15320 = 'Exchange Server 2016 CU9'
        15319 = 'Exchange Server 2016 CU8'
        15318 = 'Exchange Server 2016 CU7'
        15317 = 'Exchange Server 2016 CU6'
        15316 = 'Exchange Server 2016 CU5'
        15315 = 'Exchange Server 2016 CU4'
        15314 = 'Exchange Server 2016 CU3'
        15313 = 'Exchange Server 2016 CU2'
        15312 = 'Exchange Server 2016 CU1'
        15311 = 'Exchange Server 2016 RTM'
    }

    $DomainVersions = @{
        # Exchange Server SE
        13242 = 'Exchange Server SE CU1 or later'
        13241 = 'Exchange Server SE RTM'
        
        # Exchange Server 2016/2019
        13240 = 'Exchange Server 2016 CU3 or later'
        13237 = 'Exchange Server 2016 CU2'
        13236 = 'Exchange Server 2016 CU1'
        13235 = 'Exchange Server 2016 RTM'
        13239 = 'Exchange Server 2019 CU2 or later'
        13238 = 'Exchange Server 2019 RTM, CU1'
    }

    # Output results
    Write-Host "`nExchange Schema Version Information" -ForegroundColor Cyan
    Write-Host '=================================' -ForegroundColor Cyan
    Write-Host "Forest Schema Version (rangeUpper):`t$ForestRangeUpper"
    Write-Host "Forest Config Version (objectVersion):`t$ForestObjectVersion"
    Write-Host "Domain Version (objectVersion):`t`t$DomainObjectVersion"
    
    Write-Host "`nVersion Mapping" -ForegroundColor Green
    Write-Host '===============' -ForegroundColor Green
    
    if ($SchemaVersions.ContainsKey($ForestRangeUpper)) {
        Write-Host "Schema Version corresponds to:`t`t$($SchemaVersions[$ForestRangeUpper])"
    }
    else {
        Write-Host 'Schema Version is unknown or custom' -ForegroundColor Yellow
    }

    if ($DomainVersions.ContainsKey($DomainObjectVersion)) {
        Write-Host "Domain Version corresponds to:`t`t$($DomainVersions[$DomainObjectVersion])"
    }
    else {
        Write-Host 'Domain Version is unknown or custom' -ForegroundColor Yellow
    }
}

# Run the function
Get-ExchangeVersion