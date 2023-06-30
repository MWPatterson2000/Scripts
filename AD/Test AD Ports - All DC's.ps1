
# Get Domain Controllers
$DomainName = (Get-ADDomain).DNSRoot
#$DCList = Get-ADDomainController -Filter * -Server $DomainName | Select-Object Hostname, Site, OperatingSystem
$DCList = Get-ADDomainController -Filter * -Server $DomainName | Select-Object Hostname, Site, Domain, Forest, Enabled, `
    IsGlobalCatalog, LdapPort, SslPort, IPv4Address, IPv6Address, OperatingSystem


$ports | ForEach-Object { Test-NetConnection COMPUTERNAME -port $_ }
foreach ($DC in $DCList) {
    #$Ports = "464", "389", "636", "3268", "3269", "53", "88", "49152"
    $Ports = 53, 88, 137, 139, 389, 445, 464, 636, 3268, 3269
    Foreach ($Port in $Ports) {
        $Test = (Test-NetConnection $Target -Port $Port)
        if ($Test.TcpTestSucceeded -ne $True) {
            Write-Host “$Target $Port Failed"
        }
        else {
            Write-Host “$Target $Port OK"
        }
    }
}

