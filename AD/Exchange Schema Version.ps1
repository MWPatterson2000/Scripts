# Get Forest Schema Version$RootDSE= ([ADSI]"").distinguishedName#([ADSI]"LDAP://CN=ms-Exch-Schema-Version-Pt,CN=Schema,CN=Configuration,$RootDSE").rangeUpper#([ADSI]"LDAP://cn=mfa,cn=Microsoft Exchange,cn=Services,cn=Configuration,$RootDSE").objectVersion
$ForestrangeUpper = ([ADSI]"LDAP://CN=ms-Exch-Schema-Version-Pt,CN=Schema,CN=Configuration,$RootDSE").rangeUpper$ForestobjectVersion = ([ADSI]"LDAP://cn=Medical Facilities of America,cn=Microsoft Exchange,cn=Services,cn=Configuration,$RootDSE").objectVersion
# Get Domain Schem Version$RootDSE= ([ADSI]"").distinguishedName#([ADSI]"LDAP://CN=Microsoft Exchange System Objects,$RootDSE").objectVersion
$DomainobjectVersion = ([ADSI]"LDAP://CN=Microsoft Exchange System Objects,$RootDSE").objectVersion

# Write Data to Screen
Write-Host "Forest rangeUpper:`t`t$ForestrangeUpper"
Write-Host "Forest objectVersion:`t$ForestobjectVersion"
Write-Host "Domain objectVersion:`t$DomainobjectVersion"