<#
    .SYNOPSIS
    Force all users to be logged out of M365/O365 Tenant
	  
    .DESCRIPTION
    Logs users out of Azure AD & SharePoint Online/OneDrive
	Requires M365 account account with atleast Exchange Administrator role
    	Dependant on MSOnline PowerShell module
    	Dependant on Azure AD PowerShell module
    	Dependant on MS Graph PowerShell module
    
#>

# Define Variables
#$mfaUsed = 'Yes' # Use if MFA is Not Used
$mfaUsed = 'No' # Use if MFA is Used

# Get Credential
If ($mfaUsed -eq 'No') {
    $cred = Get-Credential
}

# Connect to MSOLService
If ($mfaUsed -eq 'No') {
    Connect-MsolService -Credential $cred
}
Else {
    Connect-MsolService
}

# Connect to AzureAD
If ($mfaUsed -eq 'No') {
    Connect-AzureAD -Credential $cred # Use if MFA is Not Used
}
Else {
    Connect-AzureAD # Use if MFA is Used
}

# Revoke from Azure AD
Get-AzureADUser -All:$true | Revoke-AzureADUserAllRefreshToken
#Get-AzureADUser -All | ForEach-Object{Revoke-AzureADUserAllRefreshToken -ObjectId $_.ObjectId}

# Revoke from SharePoint/OneDrive
# Build Connection String
$TenantName = (Get-MsolDomain | Where-Object {$_.isInitial}).name
$TenantSName = $TenantName.Substring(0,$TenantName.IndexOf('.'))
$sharePTURL = "https://$TenantSName-admin.sharepoint.com"
# Connect to SharePoint Online
If ($mfaUsed -eq 'No') {
    #Connect-SPOService -Url https://<Tenant>-admin.sharepoint.com -Credential $cred
    #Connect-SPOService -Url https://yourdomainname-admin.sharepoint.com -Credential $cred
    Connect-SPOService -Url $sharePTURL -Credential $cred # Use if MFA is Not Used
}
Else {
    #Connect-SPOService -Url https://<Tenant>-admin.sharepoint.com
    #Connect-SPOService -Url https://yourdomainname-admin.sharepoint.com
    Connect-SPOService -Url $sharePTURL # Use if MFA is Used
}

# To get all enabled users
#$users = Get-MsolUser -EnabledFilter EnabledOnly -All

# To get all the users of a Department
#$users = Get-MsolUser -Department ‘Department Name’ -All

# To get all the users
$users = Get-MsolUser -All;

# Revoke All Users Sessions
ForEach ( $user in $users) {
    Revoke-SPOUserSession -user $user.UserPrincipalName -Confirm:$false
}

# End
