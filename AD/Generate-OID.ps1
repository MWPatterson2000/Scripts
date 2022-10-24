$Prefix = "1.2.840.113556.1.8000.2554"
$GUID = [System.Guid]::NewGuid().ToString()
$GUIDPart = @()
$GUIDPart += [UInt64]::Parse($GUID.SubString(0,4), "AllowHexSpecifier")
$GUIDPart += [UInt64]::Parse($GUID.SubString(4,4), "AllowHexSpecifier")
$GUIDPart += [UInt64]::Parse($GUID.SubString(9,4), "AllowHexSpecifier")
$GUIDPart += [UInt64]::Parse($GUID.SubString(14,4), "AllowHexSpecifier")
$GUIDPart += [UInt64]::Parse($GUID.SubString(19,4), "AllowHexSpecifier")
$GUIDPart += [UInt64]::Parse($GUID.SubString(24,6), "AllowHexSpecifier")
$GUIDPart += [UInt64]::Parse($GUID.SubString(30,6), "AllowHexSpecifier")
$OID = [String]::Format("{0}.{1}.{2}.{3}.{4}.{5}.{6}.{7}", $Prefix, $GUIDPart[0], $GUIDPart[1], $GUIDPart[2], $GUIDPart[3], $GUIDPart[4], $GUIDPart[5], $GUIDPart[6])
Write-Host $OID -ForegroundColor Green 