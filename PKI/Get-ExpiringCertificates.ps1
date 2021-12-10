# ==============================================================================================
# 
# NAME: Get-ExpiringCertificates.ps1
# 
# AUTHOR: Ragnar Harper
# DATE  : 18.04.2009
# 
# COMMENT: List out expiring certificates. Needs to be run on the Certificate Authority.
# 		   Takes two parameters:
#			InNumberOfdays 
#						   If not given, defaults to 180 days from today. This is the number 
#					       of days to check for expiring certificates
#			 ExcludeAutoEnroll
#						   Excludes certificates that autoenroll from the list
#
# USAGE:
#	.\Get-ExpiringCertificates.ps1 
#	.\Get-ExpiringCertificates.ps1 -InNumberOfDays 30
#	.\Get-ExpiringCertificates.ps1 -InNumberOfDays 30 -ExcludeAutoEnroll
# ==============================================================================================
param(
[int]$InNumberOfDays=180,
[switch]$ExcludeAutoEnroll)

function WriteCertInfo($cert)
{
	#just a lot of code to get the fields into an object
	$certObj = "" | Select RequesterName,RequestType,ExpirationDate,CommonName,EnrollmentFlags
	
	$RequesterName=$cert -match "Requester Name:.*Request Type:"
	$startLength="Requester Name:".Length
	$lineLength=$matches[0].Length -("Request Type:".Length + $startLength)
	$OutRequesterName=$matches[0].SubString($startLength,$lineLength)
	$certObj.RequesterName=$OutRequesterName	
	
	$RequestType=$cert -match "Request Type:.*Certificate Expiration Date:"
	$startLength="Request Type:".Length
	$lineLength=$matches[0].Length - ("Certificate Expiration Date:".Length + $startLength)
	$OutRequestType=$matches[0].SubString($startLength,$lineLength)
	$certObj.RequestType=$OutRequestType	

	$ExpirationDate = $cert -match "Certificate Expiration Date:.*Issued Common Name:"
	$startLength="Certificate Expiration Date:".Length
	$lineLength=$matches[0].Length - ("Issued Common Name:".Length + $startLength)
	$OutExpirationDate=$matches[0].SubString($startLength,$lineLength)
	$certObj.ExpirationDate=$OutExpirationDate

	$IssuedCommonName= $cert -match "Issued Common Name:.*Template Enrollment Flags:"
	$startLength="Issued Common Name:".Length
	$lineLength=$matches[0].Length - ("Template Enrollment Flags:".Length + $startLength)
	$OutCommonName=$matches[0].SubString($startLength,$lineLength)
	$certObj.CommonName=$OutCommonName
	
	$EnrollmentFlags= $cert -match "Template Enrollment Flags:.*"
	$startLength="Template Enrollment Flags:".Length
	$lineLength=$matches[0].Length - ($startLength)
	$OutEnrollmentFlags=$matches[0].SubString($startLength,$lineLength)
	$certObj.EnrollmentFlags=$OutEnrollmentFlags
	
	if($ExcludeAutoEnroll)
	{

		if(($OutEnrollmentFlags -match "CT_FLAG_AUTO_ENROLLMENT") -eq $false)
		{
			$script:CertToList+=$certObj	
		}
	}
	else
	{
		
		$script:CertToList+=$certObj

	}
}
	

$CertToList=@()
$today=Get-Date
$endperiod=$today.AddDays($InNumberOfDays)
#List certificates that expire within 180 days from now
$tester=certutil -view -restrict "NotAfter>=$today,NotAfter<=$endperiod" -out "RequestID,RequesterName,RequestType,NotAfter,CommonName,EnrollmentFlags"
$arr=$tester -match "Row \d*:"

$numberOfCerts=$arr.length

$line=[string]::join(" ",$tester)

for($certNo=0;$certNo -lt $numberOfCerts;$certNo=$certNo+1)
{

	$r1=$arr[$certNo] 
	if($certNo -ne ($numberOfCerts-1))
	{
		$r2=$arr[$certNo+1]
	}
	else
	{
		$r2="Maximum Row Index"
	}	
	$isFound=$line -match "$r1 .* $r2"
	$NumberOfChars=$matches[0].Length - $r2.Length
	$thisCert=$matches[0].SubString(0,$NumberOfChars)
	WriteCertInfo($thisCert)
	
}
$CertToList