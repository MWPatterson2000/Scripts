function Get-FSMO {
    param(
        [Parameter(Mandatory=$True)][string]$forest,
        [Parameter(Mandatory=$True)][string]$domain
    )

    $forestInfo = Get-ADForest -Identity $forest | Select-Object SchemaMaster,DomainNamingMaster
    $domainInfo = Get-ADDomain -Identity $domain | Select-Object PDCEmulator,RIDMaster,InfrastructureMaster

    $fsmo = New-Object -TypeName PSObject -Property @{
        SchemaMaster = $forestInfo.SchemaMaster
        DomainNamingMaster = $forestInfo.DomainNamingMaster
        PDCEmulator = $domainInfo.PDCEmulator
        RIDMaster = $domainInfo.RIDMaster
        InfrastructureMaster = $domainInfo.InfrastructureMaster
    }

    return $fsmo
}

Get-FSMO -forest <FQDN> -domain <DOMAIN>