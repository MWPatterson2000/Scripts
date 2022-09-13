﻿# Get Forest Schema Version
$ForestrangeUpper = ([ADSI]"LDAP://CN=ms-Exch-Schema-Version-Pt,CN=Schema,CN=Configuration,$RootDSE").rangeUpper

$DomainobjectVersion = ([ADSI]"LDAP://CN=Microsoft Exchange System Objects,$RootDSE").objectVersion

# Write Data to Screen
Write-Host "Forest rangeUpper:`t`t$ForestrangeUpper"
Write-Host "Forest objectVersion:`t$ForestobjectVersion"
Write-Host "Domain objectVersion:`t$DomainobjectVersion"