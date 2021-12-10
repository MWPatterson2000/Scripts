<#
	.Synopsis
		Script to get details of GPOs linked to given Organization Unit.
		
	.Description
		Script to get link status, enforcement status, order information of Group policies 
		linked to a OU in active directory. It returns the information in object format which is easy to export or process 
		further.
		
	.Parameter OUName
		Name of the Organization Unit for which you want to query GPO details.
		
	.Example
		Get-GPOsLinkedtoOU.ps1 -OUName LAB
		This will search for OUs named LAB and returns the policies linked to it.
	
	.OUTPUTS
		PS C:\> c:\scripts\Get-GPOsLinkedtoOU.ps1 -OUName LAB


		OUName     : LAB
		OUDN       : OU=LAB,DC=techibee,DC=ad
		GPName     : LogonPolicy
		IsLinked   : True
		IsEnforced : False
		GPOrder    : 2

		OUName     : LAB
		OUDN       : OU=LAB,DC=techibee,DC=ad
		GPName     : ComputerPolicy
		IsLinked   : True
		IsEnforced : False
		GPOrder    : 1


	.Notes
		Author : Sitaram Pamarthi
		WebSite: http://techibee.com
		twitter: https://www.twitter.com/pamarths
		Facebook: https://www.facebook.com/pages/TechIbee-For-Every-Windows-Administrator/134751273229196

#>
[cmdletbinding()]
param(
	[string]$OUName
)
$OUs = @(Get-ADOrganizationalUnit -Filter * -Properties gPlink | ? {$_.Name -eq "$OUName"})
#Return if no OUs found with given name
if(!$OU) { Write-Warning "No such OU found"; return }

foreach($OU in $OUs) {
	$OUName = $OU.Name
	$OUDN = $OU.DistinguishedName
	#Hackey way to get LDAP strings. Regex might be best option here
	$OUGPLinks = $OU.gPlink.split("][")
	#Get rid of all empty entries the array
	$OUGPLinks =  @($OUGPLinks | ? {$_})
	$order = $OUGPLinks.count;
	foreach($GpLink in $OUGPLinks) {
			$GpName = [adsi]$GPlink.split(";")[0] | select -ExpandProperty displayName
			$GpStatus = $GPlink.split(";")[1]
			$EnableStatus = $EnforceStatus = 0
			switch($GPStatus) {
				"1" {$EnableStatus = $false; $EnforceStatus = $false}
				"2" {$EnableStatus = $true; $EnforceStatus = $true}
				"3" {$EnableStatus = $false; $EnforceStatus = $true}
				"0" {$EnableStatus = $true; $EnforceStatus = $false}
			}
			$OutputObj = New-Object -TypeName PSobject
			$OutputObj | Add-Member -MemberType NoteProperty -Name OUName -Value $OUName
			$OutputObj | Add-Member -MemberType NoteProperty -Name OUDN -Value $OUDN
			$OutputObj | Add-Member -MemberType NoteProperty -Name GPName -Value $GPName
			$OutputObj | Add-Member -MemberType NoteProperty -Name IsLinked -Value $EnableStatus
			$OutputObj | Add-Member -MemberType NoteProperty -Name IsEnforced -Value $EnforceStatus
			$OutputObj | Add-Member -MemberType NoteProperty -Name GPOrder -Value $Order
			$OutputObj
			$order--
	}

}



