Get-ChildItem E:\PS_BACKUP\backupset | Where-Object {$_.Lastwritetime -lt (Get-date).addDays(-15)} | remove-item -recurse -verbose
Get-ChildItem E:\PS_BACKUP\Datapump | Where-Object {$_.Lastwritetime -lt (Get-date).addDays(-15)} | remove-item -verbose
Get-ChildItem E:\LibDB_Backup | Where-Object {$_.Lastwritetime -lt (Get-date).addDays(-15)} | remove-item -verbose