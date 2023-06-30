# Check for Open AD Ports on all DC's

# Get Domain Controllers
$DomainName = (Get-ADDomain).DNSRoot
#$DCList = Get-ADDomainController -Filter * -Server $DomainName | Select-Object Hostname, Site, OperatingSystem
$DCList = Get-ADDomainController -Filter * -Server $DomainName | Select-Object Hostname, Name, Site, Domain, Forest, Enabled, `
    IsGlobalCatalog, LdapPort, SslPort, IPv4Address, IPv6Address, OperatingSystem

# Check Domain Controllers
foreach ($DC in $DCList) {
    Write-Host "Checking Domain Controller:" $DC.Hostname
    #$Ports = "464", "389", "636", "3268", "3269", "53", "88", "49152"
    #$Ports = 53, 88, 137, 139, 389, 445, 464, 636, 3268, 3269
    #$Ports = "53", "88", "137", "139", "389", "445", "464", "636", "3268", "3269"
    $Ports = "53", "88", "139", "389", "445", "464", "636", "3268", "3269"
    Foreach ($Port in $Ports) {
        $Test = (Test-NetConnection $DC.Hostname -Port $Port)
        if ($Test.TcpTestSucceeded -ne $True) {
            Write-Host “`t$($DC.Name) $Port Closed - Failed" -ForegroundColor Red
        }
        else {
            Write-Host “`t$($DC.Name) $Port Open - OK" -ForegroundColor Green
        }
    }
}

