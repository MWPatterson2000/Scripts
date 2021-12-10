Import-Module "C:\Program Files (x86)\ADFS Rapid Recreation Tool\ADFSRapidRecreationTool.dll"

Backup-ADFS -StorageType "FileSystem" -StoragePath "C:\ADFSBackup\" -EncryptionPassword "<Password>" -BackupComment "Backup"

Backup-ADFS -StorageType "FileSystem" -StoragePath "C:\ADFSBackup\" -EncryptionPassword "<Password>" -BackupComment "Backup with DK" -BackupDK