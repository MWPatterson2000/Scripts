# https://shellgeek.com/list-all-domain-controllers-in-domain/

# Option 1
$DomainName = (Get-ADDomain).DNSRoot
$DCList = Get-ADDomainController -Filter * -Server $DomainName | Select-Object Hostname, Site, OperatingSystem
$DCList = Get-ADDomainController -Filter * -Server $DomainName | Select-Object Hostname, Site, Domain, Forest, Enabled, `
IsGlobalCatalog, LdapPort, SslPort, IPv4Address, IPv6Address, OperatingSystem
Get-ADDomainController -Filter * -Server $DomainName | Select-Object Hostname, Name, Site, Domain, Forest, Enabled, `
    IsGlobalCatalog, LdapPort, SslPort, IPv4Address, IPv6Address, OperatingSystem

    # Option 2
Get-ADGroupMember 'Domain Controllers'

# Option 3
$DCList = (Get-ADForest).Domains | % { Get-ADDomainController -Filter * -Server $_ }

