# Source Group
$ADGroupSource = "Pre-Windows 2000 Compatible Access"
#$ADGroupSource = ""
#$ADGroupSource = ""
#$ADGroupSource = ""
#$ADGroupSource = ""
#$ADGroupSource = ""
#$ADGroupSource = ""
#$ADGroupSource = ""
#$ADGroupSource = ""
#$ADGroupSource = ""
#$ADGroupSource = ""
#$ADGroupSource = ""
#$ADGroupSource = ""
#$ADGroupSource = ""

# Temp Group
$ADGroupTarget = "Temp - Move Group"

# Export AD Group Users Pre Cleanup
Get-ADGroupMember -identity $ADGroupSource -recursive | select Name, SamAccountName | Export-CSV "c:\Temp\$(get-date -f yyyy-MM-dd-HH-mm) - AD Group Cleanup Pre - $ADGroupSource.csv" -NoTypeInformation
Exit

# Verify Temp AD Group is empty
$ADGroupTargetCount1 = (Get-ADGroupMember $ADGroupTarget).Count
Write-Host "Initial - Temp AD Group Members: $ADGroupTargetCount1"
#Exit

# Cleanup Temp AD Group
Get-ADGroupMember -Identity $ADGroupTarget | ForEach-Object {Remove-ADGroupMember -Identity $ADGroupTarget -Members $_ -Confirm:$false}
#Exit

# Verify Temp AD Group is empty
$ADGroupTargetCount2 = (Get-ADGroupMember $ADGroupTarget).Count
Write-Host "Post Cleanup - Temp AD Group Members: $ADGroupTargetCount2"
#Exit

# Copy Group to Temp Group
Get-ADGroupMember -Identity $ADGroupSource | foreach {Add-ADGroupMember -Identity $ADGroupTarget -Members $($_.DistinguishedName)}

# Verify Counts match between the 2 groups
$ADGroupSourceCount3 = (Get-ADGroupMember $ADGroupSource).Count
$ADGroupTargetCount3 = (Get-ADGroupMember $ADGroupTarget).Count
Write-Host "After Copy 1 - Base AD Group Members: $ADGroupSourceCount3"
Write-Host "After Copy 1 - Temp AD Group Members: $ADGroupTargetCount3"
#Exit

# Cleanup Origional AD Group
Get-ADGroupMember -Identity $ADGroupSource | ForEach-Object {Remove-ADGroupMember -Identity $ADGroupSource -Members $_ -Confirm:$false}
#Exit

# Verify Origional AD Group is empty
$ADGroupSourceCount4 = (Get-ADGroupMember $ADGroupSource).Count
Write-Host "Post Cleanup - Base AD Group Members: $ADGroupSourceCount4"
#Exit

# Copy Group Back to Group
Get-ADGroupMember -Identity $ADGroupTarget |
foreach {
    Add-ADGroupMember -Identity $ADGroupSource -Members $($_.DistinguishedName)
}
#Exit

# Verify Counts match between the 2 groups
$ADGroupSourceCount5 = (Get-ADGroupMember $ADGroupSource).Count
$ADGroupTargetCount5 = (Get-ADGroupMember $ADGroupTarget).Count
Write-Host "After Copy 2 - Base AD Group Members: $ADGroupSourceCount5"
Write-Host "After Copy 2 - Temp AD Group Members: $ADGroupTargetCount5"
#Exit

# Export AD Group Users Post Cleanup
Get-ADGroupMember -identity $ADGroupSource -recursive | select Name, SamAccountName | Export-CSV "c:\Temp\$(get-date -f yyyy-MM-dd-HH-mm) - AD Group Cleanup Post - $ADGroupSource.csv" -NoTypeInformation
#Exit

# Cleanup Temp AD Group
Get-ADGroupMember -Identity $ADGroupTarget | ForEach-Object {Remove-ADGroupMember -Identity $ADGroupTarget -Members $_ -Confirm:$false}
#Exit

# Verify Temp AD Group is empty
$ADGroupTargetCount6 = (Get-ADGroupMember $ADGroupTarget).Count
Write-Host "Post Copy Cleanup - Temp AD Group Members: $ADGroupTargetCount6"
Exit