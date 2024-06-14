# Ref URL https://bdwyertech.net/2013/01/22/how-to-empty-the-active-directory-recycling-bin/

# Get Count of Objects in Recycle Bin
(Get-ADObject -Filter 'isDeleted -eq $true -and Name -like "*DEL:*"' -IncludeDeletedObjects).Count
(Get-ADObject -Filter 'isDeleted -eq $true -and Name -like "*DEL:*" -and ObjectClass -like "user"' -IncludeDeletedObjects).Count
(Get-ADObject -Filter 'isDeleted -eq $true -and Name -like "*DEL:*" -and ObjectClass -like "group"' -IncludeDeletedObjects).Count
(Get-ADObject -Filter 'isDeleted -eq $true -and Name -like "*DEL:*" -and ObjectClass -like "container"' -IncludeDeletedObjects).Count
(Get-ADObject -Filter 'isDeleted -eq $true -and Name -like "*DEL:*" -and ObjectClass -like "organizationalUnit"' -IncludeDeletedObjects).Count
(Get-ADObject -Filter 'isDeleted -eq $true -and Name -like "*DEL:*" -and ObjectClass -like "serviceConnectionPoint"' -IncludeDeletedObjects).Count

# Empty Recycle Bin
Get-ADObject -Filter 'isDeleted -eq $true -and Name -like "*DEL:*"' -IncludeDeletedObjects | Remove-ADObject -Confirm:$false
Get-ADObject -Filter 'isDeleted -eq $true -and Name -like "*DEL:*" -and ObjectClass -like "user"' -IncludeDeletedObjects | Remove-ADObject -Confirm:$false
Get-ADObject -Filter 'isDeleted -eq $true -and Name -like "*DEL:*" -and ObjectClass -like "group"' -IncludeDeletedObjects | Remove-ADObject -Confirm:$false
Get-ADObject -Filter 'isDeleted -eq $true -and Name -like "*DEL:*" -and ObjectClass -like "container"' -IncludeDeletedObjects | Remove-ADObject -Confirm:$false
Get-ADObject -Filter 'isDeleted -eq $true -and Name -like "*DEL:*" -and ObjectClass -like "organizationalUnit"' -IncludeDeletedObjects | Remove-ADObject -Confirm:$false
Get-ADObject -Filter 'isDeleted -eq $true -and Name -like "*DEL:*" -and ObjectClass -like "serviceConnectionPoint"' -IncludeDeletedObjects | Remove-ADObject -Confirm:$false


