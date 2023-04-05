﻿$EnterUser = Read-Host "Enter Alias" 
 
$ADaccount = Get-User "$EnterUser" 
 
$FullDistinguishName = "LDAP://" + $ADaccount.distinguishedName 
 
$AccountEntry = New-Object DirectoryServices.DirectoryEntry $FullDistinguishName 
$AccountEntry.PutEx(1, "mail", $null) 
$AccountEntry.PutEx(1, "HomeMDB", $null) 
$AccountEntry.PutEx(1, "HomeMTA", $null) 
$AccountEntry.PutEx(1, "legacyExchangeDN", $null) 
$AccountEntry.PutEx(1, "msExchMailboxAuditEnable", $null) 
$AccountEntry.PutEx(1, "msExchAddressBookFlags", $null) 
$AccountEntry.PutEx(1, "msExchArchiveQuota", $null) 
$AccountEntry.PutEx(1, "msExchArchiveWarnQuota", $null) 
$AccountEntry.PutEx(1, "msExchBypassAudit", $null) 
$AccountEntry.PutEx(1, "msExchDumpsterQuota", $null) 
$AccountEntry.PutEx(1, "msExchDumpsterWarningQuota", $null)  
$AccountEntry.PutEx(1, "msExchHomeServerName", $null) 
$AccountEntry.PutEx(1, "msExchMailboxAuditEnable", $null) 
$AccountEntry.PutEx(1, "msExchMailboxAuditLogAgeLimit", $null) 
$AccountEntry.PutEx(1, "msExchMailboxGuid", $null) 
$AccountEntry.PutEx(1, "msExchMDBRulesQuota", $null) 
$AccountEntry.PutEx(1, "msExchModerationFlags", $null) 
$AccountEntry.PutEx(1, "msExchPoliciesIncluded", $null) 
$AccountEntry.PutEx(1, "msExchProvisioningFlags", $null) 
$AccountEntry.PutEx(1, "msExchRBACPolicyLink", $null) 
$AccountEntry.PutEx(1, "msExchRecipientDisplayType", $null) 
$AccountEntry.PutEx(1, "msExchRecipientTypeDetails", $null) 
$AccountEntry.PutEx(1, "msExchTransportRecipientSettingsFlags", $null) 
$AccountEntry.PutEx(1, "msExchUMDtmfMap", $null) 
$AccountEntry.PutEx(1, "msExchUMEnabledFlags2", $null) 
$AccountEntry.PutEx(1, "msExchUserAccountControl", $null) 
$AccountEntry.PutEx(1, "msExchVersion", $null)  
$AccountEntry.PutEx(1, "proxyAddresses", $null)  
$AccountEntry.PutEx(1, "showInAddressBook", $null)  
$AccountEntry.PutEx(1, "mailNickname", $null) 
 
$AccountEntry.SetInfo()