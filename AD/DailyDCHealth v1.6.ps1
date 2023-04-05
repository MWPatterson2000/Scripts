#region Help
# ----------

<#
	.SYNOPSIS
	DailyDCHealth.ps1
	Daily Active Directory Health Report Tool v 1.6 
	
	This script will pull all DCs from the environment and run a DCDiag against each one.
		This will perform basic health checks in the Active Directory Environment.  The script is generic until it reaches the DNS
		tests which remove forest root level servers due to access issues.  An email can be delivered to any address deemed necessary
		
		The Following tests are performed:
			0	Basic Domain Information Report  *
			0   AD Sycronization and KCC functionality Test  *
			0	DCDIAG - against all servers in the domain  %
			0	DNS Health Report  %
			0	Replication Summary Report  %
			0	Domain Time Offset Report  %
			0   ISTG Report  %
		
		Notes:	* HTML Report build full header/data/tail in one set
				% HTML Report built with seperate header, a looped area to gather and build data, and a tail to complete the table after 
				data is gathered.

	.REQUIRED INPUT
	
		[x] SMTP server, sender, and reciever information is on lines: 65-70
		[x] Top Level (Forest) DNS Health Report tests may or may not fail pending access to the domain if run from a child domain.   In this instance, 
		uncomment lines 1368, 1369, and 1522.  Change the server names on line 1368 to match those of the forest root (or other child domains) that 
		you get false readings (fails) on.

	.CREDITS
	This script was compiled using the initial HTML output format and color schemes using the following script
	Get-Hyper-VReport	http://www.serhatakinci.com  https://gallery.technet.microsoft.com/Hyper-V-Reporting-Script-4adaf5d0
	
	Jatinbhai Patel provided excellent guidance and assistance in creating hash tables to extract dcdiag information when faced with multiple simliar source tags.
	
	v1.1  Initial Build including Basic Domain Info Report and DCDIAG  3/12/15
	V1.2  Added DNS Health Report  3/20/15
	V1.3  Added Replication Tables and Time Offset 3/25/15
	V1.4  Added AD Syncronization/KCC and ISTG Report  4/9/15
	V1.5  Changed email function so multiple people can be added via a variable in the variable section
	V1.6  Removed manual DC list and configured to pull DCs from AD and run against full list after James Hillard pointed out a bug in the program when a missing dc
	      existed in the manual list.
#
#Kevin J. Cobb  2015
#>
#endregion

#Verify proper directory structure to run this script
$Dirpath = "c:\scripts\dc"
if ((Test-Path $Dirpath) -eq 0) {
	$ValidateDir = new-object -comobject wscript.shell
	$TestStructure = $ValidateDir.popup(“Please create the directory c:\scripts\dc.“, 0, ”Warning”, 1)
	Exit
}

#Cleanup Log from Previous Day if Exists
$strFileName = "C:\scripts\DC\AD health Review-*.html"
If (Test-Path $strFileName) {
	Remove-Item $strFileName
}

#region Variables
#----------------

#email parameters
$smtpServer = "smtp.yourdomain.com"
$MailAdmin = "Admin@yourdomain.com"
$Recipients = @("user1@yourdomain.com", "user2@yourdomain.com", "Group@yourdomain.com")
$MsgSubject = "Daily Active Directory Health Report"
$MsgBody = "Daily Active Directory Health Report Attached"

# State Colors
[array]$BkgrdColor = "", "#ACFA58", "#E6E6E6", "#FB7171", "#FBD95B", "#BDD7EE"
[array]$ForegrdColor = "", "#298A08", "#848484", "#A40000", "#9C6500", "#204F7A", "#FFFFFF"

#Working Files required to process script
$logfile = "c:\scripts\dc\Diag.txt"
$logfiletemp = "c:\scripts\dc\istg.txt"
$filepath = "c:\scripts\DC\"
Out-File $logfile -encoding Unicode
Out-File $logfiletemp -Encoding unicode

#HTML Table Captions
$ADTableCaption = "Domain Information"
$adSystemTableCaption = "Active Directory System Checks"
$adConnTableCaption = "Active Directory Connectivity Checks"
$adrepTableCaption = "Active Directory Replication Checks"
$adEntTableCaption = "Active Directory Enterprise Checks"
$DNSTableCaption = "DNS Diagnostic Summary"
$adTimeTableCaption = "Domain Time Offset"
$RepSummarySourceCaption = "Replication Summary by Source"
$RepSummaryDestCaption = "Replication Summary by Destination"
$DomTestsTableCaption = "ADSync and KCC Verification"
$ISTGTableCaption = "ISTG (Inter-Site Topology Generator) Assignments"

# Gather Date/Time and Create Report File Variable
$Date = Get-Date -Format d/MMM/yyyy
$Time = Get-Date -Format "hh:mm:ss tt"

$ReportFilePath = "c:\scripts\DC\"
$ReportFile = $ReportFilePath + "\" + $ReportFileNamePrefix + "Daily Active Directory Health Report.html"
#endregion

#region Load Active Directory Module

import-module activedirectory

#endregion

#region HTML Start
# HTML Head
$RptHtmlStart = "<html>
	<head>
	<title>Active Directory Health Report</title>
	<style>
	/*Reset CSS*/
html, body, div, span, object, h1, h2, h3, p, a, table, tbody, tr, header
{margin: 0;padding: 0;border: 0;font-size: 100%;font: inherit;vertical-align: baseline;}
{quotes: none;}
table {border-collapse: collapse;border-spacing: 0;}

/*Reset CSS*/
	body{
		width:100%;
		min-width:1024px;
		font-family: Futura, sans-serif;
		font-size:14px;
		/*font-weight:300;*/
		line-height:1.5;
		color:#222222;
		background-color:#fcfcfc;
		}

	p{
		color:222222;
		}

	strong{
		font-weight:600;
		}

	h1{
		font-size:30px;
		font-weight:300;
		}

	h2{
		font-size:20px;
		font-weight:300;
		mso-margin-bottom-alt:10pt;
		mso-margin-top-alt:25pt;
		}

	#ReportBody{
		width:95%;
		height:500;
		/*border: 1px solid;*/
		margin: 0 auto;
		}
		
	.ADBaseInfo{
		width:100%;
		/*height:200px;*/
		/*border: 1px solid;*/
		line-height:.8;
		float:left;
		mso-margin-top-alt:0pt;
		mso-margin-bottom-alt:0pt;
		margin-bottom:30px;
		}
		table#ADBase-Table tr:nth-child(odd){
			background:#CEE3F6;
			}

	.DomTests{
		width:100%;
		/*height:200px;*/
		/*border: 1px solid;*/
		line-height:.5;
		float:left;
		mso-margin-top-alt:0pt;
		mso-margin-bottom-alt:0pt;
		margin-bottom:30px;
		}
		table#DomTest-Table tr:nth-child(odd){
			background:#F9F9F9;
			}
	.DomCSystem{
		width:100%;
		/*height:200px;*/
		/*border: 1px solid;*/
		line-height:.5;
		float:left;
		mso-margin-top-alt:0pt;
		mso-margin-bottom-alt:0pt;
		margin-bottom:30px;
		}
		table#DCSystem-Table tr:nth-child(odd){
			background:#F9F9F9;
			}

	.DomCConn{
		width:100%;
		/*height:200px;*/
		/*border: 1px solid;*/
		line-height:.5;
		float:left;
		mso-margin-top-alt:0pt;
		mso-margin-bottom-alt:0pt;
		margin-bottom:30px;
		}
		table#DCConn-Table tr:nth-child(odd){
			background:#F9F9F9;
			}

	.DomCRep{
		width:100%;
		/*height:200px;*/
		/*border: 1px solid;*/
		line-height:.5;
		float:left;
		mso-margin-top-alt:0pt;
		mso-margin-bottom-alt:0pt;
		margin-bottom:30px;
		}
		table#DCRep-Table tr:nth-child(odd){
			background:#F9F9F9;
			}

	.DomCEnt{
		width:100%;
		/*height:200px;*/
		/*border: 1px solid;*/
		font-family: ""Times New Roman"", Times, serif;
		line-height:.5;
		float:left;
		mso-margin-top-alt:0pt;
		mso-margin-bottom-alt:0pt;
		margin-bottom:30px;
		}
		table#DCEnt-Table tr:nth-child(odd){
			background:#F9F9F9;
			}

	.DNSEntries{
		width:100%;
		/*height:200px;*/
		/*border: 1px solid;*/
		line-height:.5;
		float:left;
		mso-margin-top-alt:0pt;
		mso-margin-bottom-alt:0pt;
		margin-bottom:30px;
		}
		table#DNS-Table tr:nth-child(odd){
			background:#CEE3F6;
			}
		table#DCTime-Table tr:nth-child(odd){
			background:#CEECF5;
			}

	.DomTime{
		width:100%;
		/*height:200px;*/
		/*border: 1px solid;*/
		line-height:.5;
		float:left;
		mso-margin-top-alt:0pt;
		mso-margin-bottom-alt:0pt;
		margin-bottom:30px;
		}
		table#RepsummarySource-Table tr:nth-child(odd){
			background:#F9F9F9;
			}

	.domISTG{
		width:100%;
		/*height:200px;*/
		/*border: 1px solid;*/
		line-height:.5;
		float:left;
		mso-margin-top-alt:0pt;
		mso-margin-bottom-alt:0pt;
		margin-bottom:30px;
		}
		table#domISTG-Table tr:nth-child(odd){
			background:#F9F9F9;
			}

	.RepSource{
		width:50%;
		/*height:200px;*/
		/*border: 1px solid;*/
		line-height:.5;
		float:left;
		mso-margin-top-alt:0pt;
		mso-margin-bottom-alt:0pt;
		margin-bottom:30px;
		}
		table#RepsummaryDest-Table tr:nth-child(odd){
			background:#F9F9F9;
			}

	.RepDestination{
		width:50%;
		/*height:200px;*/
		/*border: 1px solid;*/
		line-height:.5;
		float:right;
		mso-margin-top-alt:0pt;
		mso-margin-bottom-alt:0pt;
		margin-bottom:30px;
		}

	/*Row*/
	tr{
		font-size: 12px;
		}

	/*Column*/
	td {
		padding:10px 8px 10px 8px;
		font-size: 12px;
		border: 1px solid #CCCCCC;
		text-align:center;
		vertical-align:middle;
		}

	/*Table Heading*/
	th {
		background: #f3f3f3;
		border: 1px solid #CCCCCC;
		font-size: 11px;
		font-weight:normal;
		padding:12px;
		text-align:center;
		vertical-align:middle;
		}
	</style>
	</head>
	<body>
	<br/><br/>
	<center><h1>TICAUTH2 Active Directory Health Report</h1></center>
	<center><font face=""Verdana,sans-serif"" size=""3"" color=""#222222"">Generated on $($Date) at $($Time)</font></center>
	<br/>
	<div id=""ReportBody""><!--Start ReportBody-->"

#endregion

#region functions
function Get-RIDsRemaining($domainDN) {
	$RidRem = [ADSI]"LDAP://CN=RID Manager$,CN=System,$domainDN"
	$return = new-object system.DirectoryServices.DirectorySearcher($RidRem)
	$pool = ($return.FindOne()).properties.ridavailablepool

	[int32]$totalSIDS = $($pool) / ([math]::Pow(2, 32))
	[int64]$intval = $totalSIDS * ([math]::Pow(2, 32))
	[int32]$currentRIDPoolCount = $($pool) - $intval

	#Create an hashtable variable 
	[hashtable]$Return = @{} 
	$ridsremaining = $totalSIDS - $currentRIDPoolCount
	$Return.Current = $currentRidPoolCount
	$Return.Remaining = $ridsremaining

	#Return the hashtable
	Return $Return 
}
#endregion

#region Gather AD Basic Information

#Get Forest Information
$ForestInfo = Get-ADForest
$ForestLevel = $ForestInfo.ForestMode 
$SchemaM = $ForestInfo.SchemaMaster
$DomainNamingM = $ForestInfo.DomainNamingMaster

#Get Domain Information
$DomainInfo = Get-ADDomain
$DomainLevel = $DomainInfo.DomainMode
$ForestName = $DomainInfo.Forest
$DomainName = $DomainInfo.DNSRoot
$Infra = $DomainInfo.InfrastructureMaster
$PDCE = $DomainInfo.PDCEmulator
$RIDM = $DomainInfo.RIDMaster
$DistN = $DomainInfo.DistinguishedName

#Get Domain Shortname for use later
$Dshortname = $domainname.split(".")
$domainonly = $Dshortname[0]

#Get Number of Domain Controllers
$localdomain = [System.DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain()
$localdomain | % { $_.DomainControllers }
$dcNumber = $localdomain.Domaincontrollers
$TotalDCs = $dcnumber.count

#Get RID Information

$RID = Get-RIDsRemaining $DistN
$RidC = $RID.Current
$RidR = $RID.Remaining

#endregion

#region Create Active Directory Basic Information HTML

# Create HTML Report for the current System being looped through
$RptADTable = "
		<div class=""ADBaseInfo""><!--Start ADBaseInfo Class-->
					<h3><b>$($ADTableCaption)</b></h3><br>
		<table id=""ADBase-Table"">

        <tbody>
		<tr>
		<td><p style=""text-align:left;"">Forest Root Name:</td>
		<td><p style=""text-align:left;"">$ForestName</td>
		</tr>
		<tr>
		<td><p style=""text-align:left;"">Domain Name</td>
		<td><p style=""text-align:left;"">$DomainName</td>
		</tr>
		<tr>
		<td><p style=""text-align:left;"">Forest Functional Level:</td>
		<td><p style=""text-align:left;"">$ForestLevel</td>
		</tr>
		<tr>
		<td><p style=""text-align:left;"">Domain Functional Level:</td>
		<td><p style=""text-align:left;"">$DomainLevel</td>
		</tr>
		<tr>
		<td><p style=""text-align:left;"">Total Domain Controllers:</td>
		<td><p style=""text-align:left;"">$TotalDCs</td>
		</tr>
		<tr>
		<td><p style=""text-align:right;"">Schema Master:</td>
		<td><p style=""text-align:left;"">$SchemaM</td>
		</tr>
		<tr>
		<td><p style=""text-align:right;"">Domain Naming Master:</td>
		<td><p style=""text-align:left;"">$DomainNamingM</td>
		</tr>
		<tr>
		<td><p style=""text-align:right;"">Infrastructure Master:</td>
		<td><p style=""text-align:left;"">$Infra</td>
		</tr>
		<tr>
		<td><p style=""text-align:right;"">PDC Emulator:</td>
		<td><p style=""text-align:left;"">$PDCE</td>
		</tr>
		<tr>
		<td><p style=""text-align:right;"">Rid Master:</td>
		<td><p style=""text-align:left;"">$RIDM</td>
		</tr>
		<tr>
		<td></td>
		<td><p style=""text-align:left;"">RIDs issued: $RIDC</td>
		</tr>
		<tr>
		<td></td>
		<td><p style=""text-align:left;"">RIDs remaining: $RIDR</td>
		</tr>              
		</table>
	<p><br></p>"
#endregion

#region Gathering Active Directory Health Information from DCDiag

#DCSystem-Table Header
$RptDCSystemTableBegin = "
		<div class=""DomCSystem""><!--Start DomCSystem Class-->
					<h3><b>$($adSystemTableCaption)</b></h3><br>
        <table id=""DCSystem-Table"">
        <tbody>
            <tr><!--Header Line-->
                <th><p style=""text-align:left;margin-left:-4px"">Name</p></th>
                <th><p>CheckSecurityError</p></th>
                <th><p>DNS</p></th>
				<th><p>LocatorCheck</p></th>
                <th><p>MachineAccount</p></th>
                <th><p>Services</p></th>
                <th><p>SystemLog</p></th>
				<th><p>VerifyEnterpriseReferences</p></th>
				<th><p>VerifyReferences</p></th>
				<th><p>VerifyReplicas</p></th>
            </tr>"
			
#DCConn-Table Header
$RptDCConnTableBegin = "
		<div class=""DomCConn""><!--Start DomCConn Class-->
					<h3><b>$($adConnTableCaption)</b></h3><br>
        <table id=""DCConn-Table"">
        <tbody>
            <tr><!--Header Line-->
                <th><p style=""text-align:left;margin-left:-4px"">Name</p></th>
                <th><p>Advertising</p></th>
				<th><p>Connectivity</p></th>
                <th><p>FSMOCheck</p></th>
                <th><p>KccEvent</p></th>
				<th><p>KnowsOfRoleHolders</p></th>
				<th><p>OutboundSecureChannels</p></th>
				<th><p>RidManager</p></th>
				<th><p>Topology</p></th>
            </tr>"
			
#DCRep-Table Header
$RptDCRepTableBegin = "
		<div class=""DomCRep""><!--Start DomCRep Class-->
					<h3><b>$($adrepTableCaption)</b></h3><br>
        <table id=""DCRep-Table"">
        <tbody>
            <tr><!--Header Line-->
                <th><p style=""text-align:left;margin-left:-4px"">Name</p></th>
				<th><p>Replications</p></th>
                <th><p>CutoffServers</p></th>
                <th><p>FrsEvent</p></th>
				<th><p>FrsSysVol</p></th>
                <th><p>DFSREvent</p></th>
                <th><p>SysVolCheck</p></th>
                <th><p>Intersite</p></th>
				<th><p>NCSecDesc</p></th>
				<th><p>NetLogons</p></th>
				<th><p>ObjectsReplicated</p></th>

            </tr>"

#DCEnt-Table Header
$RptDCEntTableBegin = "
		<div class=""DomCEnt""><!--Start DomCEnt Class-->
					<h3><b>$($adEntTableCaption)</b></h3><br>
        <table id=""DCRep-Table"">
        <tbody>
            <tr><!--Header Line-->
                <th colspan=""2"" style=""background-color:#fcfcfc;border: 0px""><p style=""line-height:.4;""> </p></th>
                <th colspan=""2""><p style=""line-height:.4;"">Schema</p></th>
                <th colspan=""2""><p style=""line-height:.4;"">Configuration</p></th>
				<th colspan=""2""><p style=""line-height:.4;"">Domain</p></th>
                <th colspan=""2""><p style=""line-height:.4;"">DomainDnsZones</p></th>
                <th colspan=""2""><p style=""line-height:.4;"">ForestDNSZones</p></th>
			</tr>
			<tr>
				<th><p style=""text-align:left;margin-left:-4px"">Name</p></th>
				<th><p>DNS</p></th>
                <th><p>CheckSDRefDom</p></th>
				<th><p>CrossRefValidation</p></th>
                <th><p>CheckSDRefDom</p></th>
				<th><p>CrossRefValidation</p></th>
                <th><p>CheckSDRefDom</p></th>
				<th><p>CrossRefValidation</p></th>
				<th><p>CheckSDRefDom</p></th>
				<th><p>CrossRefValidation</p></th>
				<th><p>CheckSDRefDom</p></th>
				<th><p>CrossRefValidation</p></th>
            </tr>"

#Clear Html Tables
$RptdcSystemTable = $Null
$RptDCconnectivityTable = $Null
$RptdcreplicaitonTable = $Null
$RptdcEntTable = $Null
$RptISTGTable = $Null

$ADs = [DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().DomainControllers | ForEach-Object { $_.Name }  

#Loop through Domain Controllers and gather time data
for ($i = 0; $i -lt $ADs.Count; $i++) {  
	$System = $ADs[$i]

	if ($System) {
		Clear-Content $logfile
		#Clear variables
		$dcname = $Null
		$dcconnectivity = $Null
		$dcadvertising = $Null
		$dcerror = $Null
		$dccuttservers = $Null
		$dcevent = $Null
		$dcdfsrevent = $Null
		$dcsysvcheck = $Null
		$dcfrsvol = $Null
		$dckccevent = $Null
		$dcholders = $Null
		$dcaccount = $Null
		$dcdesc = $Null
		$dclogons = $Null
		$dcreplicated = $Null
		$dcchannels = $Null
		$dcreplications = $Null
		$dcmanager = $Null
		$dcservices = $Null
		$dcsyslog = $Null
		$dctopology = $Null
		$dcEntreferences = $Null
		$dcreferences = $Null
		$dcreplicas = $Null
		$dcdom = $Null
		$dcvalidation = $Null
		$dcdns = $Null
		$dclcheck = $Null
		$dccheck = $Null
		$dcintersite = $Null
		$dcDFSREvent = $Null
		$dcSysVolCheck = $Null		
		$dcFrsSysVol = $Null		
		$dcKccEvent = $Null		
		$dcObjectsR = $Null		
		$dcReplications = $Null
		$dcEntDNS = $Null
		$Schdcdom = $Null
		$Schdcvalid = $Null
		$Confdcdom = $Null
		$Confdcvalid = $Null
		$Domdcdom = $Null
		$Domdcvalid = $Null
		$Dnsdcdom = $Null
		$Dnsdcvalid = $Null		
		$FDnsdcdom = $Null
		$FDnsdcvalid = $Null

		#Begin gathering health data
		CMD /c "mode con:cols=512 && DCDIAG /s:$System /c /f:$Logfile && mode con:cols=120"
		$file = Get-Content $Logfile | ForEach-Object { $_.trim() } | Where-Object { $_ }

		$hash = @{}
		$hash["server"] = $System
		foreach ($item in $file) {
			if ($item -like "Doing*") {
				$ai = $($item.split()[1])
				$hash["$ai"] = @{}
				continue
			}
			else {
				switch -regex -casesensitive ($item) {
					"Testing" { $bi = "server"; $hash["$ai"]["$bi"] = @{} }
					"Running" { $bi = $($_ -Replace ".*tests on : "); $hash["$ai"]["$bi"] = @{} }
					"Starting" { $ci = $($_ -Replace ".*Starting Test: "); $hash["$ai"]["$bi"]["$ci"] = @{} }
					"failed" { $hash["$ai"]["$bi"]["$ci"] = "Fail" }
					"passed" { $hash["$ai"]["$bi"]["$ci"] = "Pass" }
					default { continue }
				}
			}
		}

		#Generate Data
		$dcname = ($hash["server"])
		$dcconnectivity = ($hash["initial"]["server"]["connectivity"])
		$dcadvertising = ($hash["primary"]["server"]["Advertising"]) 
		$dcerror = ($hash["primary"]["server"]["CheckSecurityError"])
		$dccuttservers = ($hash["primary"]["server"]["CutoffServers"])  
		$dcevent = ($hash["primary"]["server"]["FrsEvent"])
		$dcholders = ($hash["primary"]["server"]["KnowsOfRoleHolders"])
		$dcaccount = ($hash["primary"]["server"]["MachineAccount"])
		$dcdesc = ($hash["primary"]["server"]["NCSecDesc"])
		$dclogons = ($hash["primary"]["server"]["NetLogons"])
		$dcchannels = ($hash["primary"]["server"]["OutboundSecureChannels"])
		$dcmanager = ($hash["primary"]["server"]["RidManager"])
		$dcservices = ($hash["primary"]["server"]["Services"])
		$dcsyslog = ($hash["primary"]["server"]["SystemLog"])
		$dctopology = ($hash["primary"]["server"]["Topology"])  
		$dcEntreferences = ($hash["primary"]["server"]["VerifyEnterpriseReferences"])
		$dcreferences = ($hash["primary"]["server"]["VerifyReferences"]) 
		$dcreplicas = ($hash["primary"]["server"]["VerifyReplicas"])
		$dcdns = ($hash["primary"]["server"]["DNS"])         
		$dclcheck = ($hash["primary"][$forestname]["LocatorCheck"])
		$dccheck = ($hash["primary"][$forestname]["FsmoCheck"])
		$dcintersite = ($hash["primary"][$forestname]["Intersite"])
		$dcDFSREvent = ($hash["primary"]["server"]["DFSREvent"])
		$dcSysVolCheck = ($hash["primary"]["server"]["SysVolCheck"])
		$dcFrsSysVol = ($hash["primary"]["server"]["FrsSysVol"])
		$dcKccEvent = ($hash["primary"]["server"]["KccEvent"])
		$dcObjectsR = ($hash["primary"]["server"]["ObjectsReplicated"])
		$dcReplications = ($hash["primary"]["server"]["Replications"])

		#Enterprise References Check
		$dcEntDNS = ($hash["primary"][$forestname]["DNS"])
		#Schema
		$Schdcdom = ($hash["primary"]["schema"]["CheckSDRefDom"])
		$Schdcvalid = ($hash["primary"]["schema"]["CrossRefValidation"])
		#Configuration
		$Confdcdom = ($hash["primary"]["configuration"]["CheckSDRefDom"])
		$Confdcvalid = ($hash["primary"]["configuration"]["CrossRefValidation"])
		#DomainReference
		$Domdcdom = ($hash["primary"][$domainonly]["CheckSDRefDom"])
		$Domdcvalid = ($hash["primary"][$domainonly]["CrossRefValidation"])
		#DomainDNSZones
		$Dnsdcdom = ($hash["primary"]["DomainDnsZones"]["CheckSDRefDom"])
		$Dnsdcvalid = ($hash["primary"]["DomainDnsZones"]["CrossRefValidation"])		
		#ForestDNSZones
		$FDnsdcdom = ($hash["primary"]["ForestDnsZones"]["CheckSDRefDom"])
		$FDnsdcvalid = ($hash["primary"]["ForestDnsZones"]["CrossRefValidation"])	

		$dcSystemTable = $null
		$dcconnectivitydaTable = $null
		$dcreplicaitonTable = $null

		#Check Connectivity
		if ($dcconnectivity -eq "Pass") {
			$Rptdcconnectivity = "Pass", $BkgrdColor[0], $ForegrdColor[1]
		}
		else {
			$Rptdcconnectivity = "Fail", $BkgrdColor[0], $ForegrdColor[3]
		}

		#Check Advertising
		if ($dcadvertising -eq "Pass") {
			$Rptdcadvertising = "Pass", $BkgrdColor[0], $ForegrdColor[1]
		}
		else {
			$Rptdcadvertising = "Fail", $BkgrdColor[0], $ForegrdColor[3]
		}

		#Check CheckSecurityError
		if ($dcerror -eq "Pass") {
			$Rptdcerror = "Pass", $BkgrdColor[0], $ForegrdColor[1]
		}
		else {
			$Rptdcerror = "Fail", $BkgrdColor[0], $ForegrdColor[3]
		}

		#Check CutoffServers
		if ($dccuttservers -eq "Pass") {
			$Rptdccuttservers = "Pass", $BkgrdColor[0], $ForegrdColor[1]
		}
		else {
			$Rptdccuttservers = "Fail", $BkgrdColor[0], $ForegrdColor[3]
		}

		#Check FRSEvent
		if ($dcevent -eq "Pass") {
			$Rptdcevent = "Pass", $BkgrdColor[0], $ForegrdColor[1]
		}
		else {
			$Rptdcevent = "Fail", $BkgrdColor[0], $ForegrdColor[3]
		}

		#Check DFSREvent
		if ($dcDFSREvent -eq "Pass") {
			$RptdcDFSREvent = "Pass", $BkgrdColor[0], $ForegrdColor[1]
		}
		else {
			$RptdcDFSREvent = "Fail", $BkgrdColor[0], $ForegrdColor[3]
		}

		#Check SysVolCheck
		if ($dcSysVolCheck -eq "Pass") {
			$RptdcSysVolCheck = "Pass", $BkgrdColor[0], $ForegrdColor[1]
		}
		else {
			$RptdcSysVolCheck = "Fail", $BkgrdColor[0], $ForegrdColor[3]
		}

		#Check FrsSysVol
		if ($dcFrsSysVol -eq "Pass") {
			$RptdcFrsSysVol = "Pass", $BkgrdColor[0], $ForegrdColor[1]
		}
		else {
			$RptdcFrsSysVol = "Fail", $BkgrdColor[0], $ForegrdColor[3]
		}

		#Check KCCEvent
		if ($dcKccEvent -eq "Pass") {
			$RptdcKccEvent = "Pass", $BkgrdColor[0], $ForegrdColor[1]
		}
		else {
			$RptdcKccEvent = "Fail", $BkgrdColor[0], $ForegrdColor[3]
		}

		#Check KnowsOfRoleHolders
		if ($dcholders -eq "Pass") {
			$Rptdcholders = "Pass", $BkgrdColor[0], $ForegrdColor[1]
		}
		else {
			$Rptdcholders = "Fail", $BkgrdColor[0], $ForegrdColor[3]
		}

		#Check MachineAccount
		if ($dcaccount -eq "Pass") {
			$Rptdcaccount = "Pass", $BkgrdColor[0], $ForegrdColor[1]
		}
		else {
			$Rptdcaccount = "Fail", $BkgrdColor[0], $ForegrdColor[3]
		}

		#Check NCSecDesc 
		if ($dcdesc -eq "Pass") {
			$Rptdcdesc = "Pass", $BkgrdColor[0], $ForegrdColor[1]
		}
		else {
			$Rptdcdesc = "Fail", $BkgrdColor[0], $ForegrdColor[3]
		}

		#Check NetLogons
		if ($dclogons -eq "Pass") {
			$Rptdclogons = "Pass", $BkgrdColor[0], $ForegrdColor[1]
		}
		else {
			$Rptdclogons = "Fail", $BkgrdColor[0], $ForegrdColor[3]
		}

		#Check ObjectsReplicated			
		if ($dcObjectsR -eq "Pass") {
			$RptdcObjectsR = "Pass", $BkgrdColor[0], $ForegrdColor[1]
		}
		else {
			$RptdcObjectsR = "Fail", $BkgrdColor[0], $ForegrdColor[3]
		}

		#Check OutboundSecureChannels
		if ($dcchannels -eq "Pass") {
			$Rptdcchannels = "Pass", $BkgrdColor[0], $ForegrdColor[1]
		}
		else {
			$Rptdcchannels = "Fail", $BkgrdColor[0], $ForegrdColor[3]
		}

		#Check Replication
		if ($dcReplications -eq "Pass") {
			$RptdcReplications = "Pass", $BkgrdColor[0], $ForegrdColor[1]
		}
		else {
			$RptdcReplications = "Fail", $BkgrdColor[0], $ForegrdColor[3]
		}

		#Check RidManager
		if ($dcmanager -eq "Pass") {
			$Rptdcmanager = "Pass", $BkgrdColor[0], $ForegrdColor[1]
		}
		else {
			$Rptdcmanager = "Fail", $BkgrdColor[0], $ForegrdColor[3]
		}

		#Check Services
		if ($dcservices -eq "Pass") {
			$Rptdcservices = "Pass", $BkgrdColor[0], $ForegrdColor[1]
		}
		else {
			$Rptdcservices = "Fail", $BkgrdColor[0], $ForegrdColor[3]
		}

		#Check SystemLog
		if ($dcsyslog -eq "Pass") {
			$Rptdcsyslog = "Pass", $BkgrdColor[0], $ForegrdColor[1]
		}
		else {
			$Rptdcsyslog = "Fail", $BkgrdColor[0], $ForegrdColor[3]
		}

		#Check Topology
		if ($dctopology -eq "Pass") {
			$Rptdctopology = "Pass", $BkgrdColor[0], $ForegrdColor[1]
		}
		else {
			$Rptdctopology = "Fail", $BkgrdColor[0], $ForegrdColor[3]
		}

		#Check VerifyEnterpriseReferences
		if ($dcEntreferences -eq "Pass") {
			$RptdcEntreferences = "Pass", $BkgrdColor[0], $ForegrdColor[1]
		}
		else {
			$RptdcEntreferences = "Fail", $BkgrdColor[0], $ForegrdColor[3]
		}

		#Check VerifyReferences
		if ($dcreferences -eq "Pass") {
			$Rptdcreferences = "Pass", $BkgrdColor[0], $ForegrdColor[1]
		}
		else {
			$Rptdcreferences = "Fail", $BkgrdColor[0], $ForegrdColor[3]
		}

		#Check VerifyReplicas
		if ($dcreplicas -eq "Pass") {
			$Rptdcreplicas = "Pass", $BkgrdColor[0], $ForegrdColor[1]
		}
		else {
			$Rptdcreplicas = "Fail", $BkgrdColor[0], $ForegrdColor[3]
		}

		#Check DNS
		if ($dcdns -eq "Pass") {
			$Rptdcdns = "Pass", $BkgrdColor[0], $ForegrdColor[1]
		}
		else {
			$Rptdcdns = "Fail", $BkgrdColor[0], $ForegrdColor[3]
		}

		#Check LocatorCheck
		if ($dclcheck -eq "Pass") {
			$Rptdclcheck = "Pass", $BkgrdColor[0], $ForegrdColor[1]
		}
		else {
			$Rptdclcheck = "Fail", $BkgrdColor[0], $ForegrdColor[3]
		}

		#Check FsmoCheck
		if ($dccheck -eq "Pass") {
			$Rptdccheck = "Pass", $BkgrdColor[0], $ForegrdColor[1]
		}
		else {
			$Rptdccheck = "Fail", $BkgrdColor[0], $ForegrdColor[3]
		}

		#Check Intersite
		if ($dcintersite -eq "Pass") {
			$Rptdcintersite = "Pass", $BkgrdColor[0], $ForegrdColor[1]
		}
		else {
			$Rptdcintersite = "Fail", $BkgrdColor[0], $ForegrdColor[3]
		}

		#Enterprise Checks
		if ($dcEntDNS -eq "Pass") {
			$RptdcEntDNS = "Pass", $BkgrdColor[0], $ForegrdColor[1]
		}
		else {
			$RptdcEntDNS = "Fail", $BkgrdColor[0], $ForegrdColor[3]
		}

		#Schema
		if ($Schdcdom -eq "Pass") {
			$RptSchdcdom = "Pass", $BkgrdColor[0], $ForegrdColor[1]
		}
		else {
			$RptSchdcdom = "Fail", $BkgrdColor[0], $ForegrdColor[3]
		}

		if ($Schdcvalid -eq "Pass") {
			$RptSchdcvalid = "Pass", $BkgrdColor[0], $ForegrdColor[1]
		}
		else {
			$RptSchdcvalid = "Fail", $BkgrdColor[0], $ForegrdColor[3]
		}

		#Configuration
		if ($Confdcdom -eq "Pass") {
			$RptConfdcdom = "Pass", $BkgrdColor[0], $ForegrdColor[1]
		}
		else {
			$RptConfdcdom = "Fail", $BkgrdColor[0], $ForegrdColor[3]
		}

		if ($Confdcvalid -eq "Pass") {
			$RptConfdcvalid = "Pass", $BkgrdColor[0], $ForegrdColor[1]
		}
		else {
			$RptConfdcvalid = "Fail", $BkgrdColor[0], $ForegrdColor[3]
		}

		#Domain
		if ($Domdcdom -eq "Pass") {
			$RptDomdcdom = "Pass", $BkgrdColor[0], $ForegrdColor[1]
		}
		else {
			$RptDomdcdom = "Fail", $BkgrdColor[0], $ForegrdColor[3]
		}

		if ($Domdcvalid -eq "Pass") {
			$RptDomdcvalid = "Pass", $BkgrdColor[0], $ForegrdColor[1]
		}
		else {
			$RptDomdcvalid = "Fail", $BkgrdColor[0], $ForegrdColor[3]
		}

		#DomainDnsZones
		if ($Dnsdcdom -eq "Pass") {
			$RptDnsdcdom = "Pass", $BkgrdColor[0], $ForegrdColor[1]
		}
		else {
			$RptDnsdcdom = "Fail", $BkgrdColor[0], $ForegrdColor[3]
		}

		if ($Dnsdcvalid -eq "Pass") {
			$RptDnsdcvalid = "Pass", $BkgrdColor[0], $ForegrdColor[1]
		}
		else {
			$RptDnsdcvalid = "Fail", $BkgrdColor[0], $ForegrdColor[3]
		}

		#ForestDnsZones
		if ($FDnsdcdom -eq "Pass") {
			$RptFDnsdcdom = "Pass", $BkgrdColor[0], $ForegrdColor[1]
		}
		else {
			$RptFDnsdcdom = "Fail", $BkgrdColor[0], $ForegrdColor[3]
		}

		if ($FDnsdcvalid -eq "Pass") {
			$RptFDnsdcvalid = "Pass", $BkgrdColor[0], $ForegrdColor[1]
		}
		else {
			$RptFDnsdcvalid = "Fail", $BkgrdColor[0], $ForegrdColor[3]
		}

		#BuildTable System
		$dcSystemTable = "
						<tr><!--Data Line-->
					<td><p style=""text-align:left;"">$($dcname)</p></td>
					<td bgcolor=""$($Rptdcerror[1])""><p style=""color:$($Rptdcerror[2])"">$($Rptdcerror[0])</p></td>
					<td bgcolor=""$($Rptdcdns[1])""><p style=""color:$($Rptdcdns[2])"">$($Rptdcdns[0])</p></td>
					<td bgcolor=""$($Rptdclcheck[1])""><p style=""color:$($Rptdclcheck[2])"">$($Rptdclcheck[0])</p></td>
					<td bgcolor=""$($Rptdcaccount[1])""><p style=""color:$($Rptdcaccount[2])"">$($Rptdcaccount[0])</p></td>
					<td bgcolor=""$($Rptdcservices[1])""><p style=""color:$($Rptdcservices[2])"">$($Rptdcservices[0])</p></td>
					<td bgcolor=""$($Rptdcsyslog[1])""><p style=""color:$($Rptdcsyslog[2])"">$($Rptdcsyslog[0])</p></td>
					<td bgcolor=""$($RptdcEntreferences[1])""><p style=""color:$($RptdcEntreferences[2])"">$($RptdcEntreferences[0])</p></td>
					<td bgcolor=""$($Rptdcreferences[1])""><p style=""color:$($Rptdcreferences[2])"">$($Rptdcreferences[0])</p></td>
					<td bgcolor=""$($Rptdcreplicas[1])""><p style=""color:$($Rptdcreplicas[2])"">$($Rptdcreplicas[0])</p></td>
					</tr>"
		$RptdcSystemTable += $dcSystemTable

		#BuildTable Connectivity
		$dcconnectivitydaTable = "
						<tr><!--Data Line-->
					<td><p style=""text-align:left;"">$($dcname)</p></td>
					<td bgcolor=""$($Rptdcadvertising[1])""><p style=""color:$($Rptdcadvertising[2])"">$($Rptdcadvertising[0])</p></td>
					<td bgcolor=""$($Rptdcconnectivity[1])""><p style=""color:$($Rptdcconnectivity[2])"">$($Rptdcconnectivity[0])</p></td>
					<td bgcolor=""$($Rptdccheck[1])""><p style=""color:$($Rptdccheck[2])"">$($Rptdccheck[0])</p></td>
					<td bgcolor=""$($RptdcKccEvent[1])""><p style=""color:$($RptdcKccEvent[2])"">$($RptdcKccEvent[0])</p></td>
					<td bgcolor=""$($Rptdcholders[1])""><p style=""color:$($Rptdcholders[2])"">$($Rptdcholders[0])</p></td>
					<td bgcolor=""$($Rptdcchannels[1])""><p style=""color:$($Rptdcchannels[2])"">$($Rptdcchannels[0])</p></td>
					<td bgcolor=""$($Rptdcmanager[1])""><p style=""color:$($Rptdcmanager[2])"">$($Rptdcmanager[0])</p></td>
					<td bgcolor=""$($Rptdctopology[1])""><p style=""color:$($Rptdctopology[2])"">$($Rptdctopology[0])</p></td>
					</tr>"
		$RptDCconnectivityTable += $dcconnectivitydaTable

		#BuildTable Replication
		$dcreplicaitonTable = "
						<tr><!--Data Line-->
					<td><p style=""text-align:left;"">$($dcname)</p></td>
					<td bgcolor=""$($RptdcReplications[1])""><p style=""color:$($RptdcReplications[2])"">$($RptdcReplications[0])</p></td>
					<td bgcolor=""$($Rptdccuttservers[1])""><p style=""color:$($Rptdccuttservers[2])"">$($Rptdccuttservers[0])</p></td>
					<td bgcolor=""$($Rptdcevent[1])""><p style=""color:$($Rptdcevent[2])"">$($Rptdcevent[0])</p></td>
					<td bgcolor=""$($RptdcFrsSysVol[1])""><p style=""color:$($RptdcFrsSysVol[2])"">$($RptdcFrsSysVol[0])</p></td>
					<td bgcolor=""$($RptdcDFSREvent[1])""><p style=""color:$($RptdcDFSREvent[2])"">$($RptdcDFSREvent[0])</p></td>
					<td bgcolor=""$($RptdcSysVolCheck[1])""><p style=""color:$($RptdcSysVolCheck[2])"">$($RptdcSysVolCheck[0])</p></td>
					<td bgcolor=""$($Rptdcintersite[1])""><p style=""color:$($Rptdcintersite[2])"">$($Rptdcintersite[0])</p></td>
					<td bgcolor=""$($Rptdcdesc[1])""><p style=""color:$($Rptdcdesc[2])"">$($Rptdcdesc[0])</p></td>
					<td bgcolor=""$($Rptdclogons[1])""><p style=""color:$($Rptdclogons[2])"">$($Rptdclogons[0])</p></td>
					<td bgcolor=""$($RptdcObjectsR[1])""><p style=""color:$($RptdcObjectsR[2])"">$($RptdcObjectsR[0])</p></td>
					</tr>"
		$RptdcreplicaitonTable += $dcreplicaitonTable

		#BuildTable Enterprise References
		$dcentTable = "
						<tr><!--Data Line-->
					<td><p style=""text-align:left;"">$($dcname)</p></td>
					<td bgcolor=""$($RptdcEntDNS[1])""><p style=""color:$($RptdcEntDNS[2])"">$($RptdcEntDNS[0])</p></td>
					<td bgcolor=""$($RptSchdcdom[1])""><p style=""color:$($RptSchdcdom[2])"">$($RptSchdcdom[0])</p></td>
					<td bgcolor=""$($RptSchdcvalid[1])""><p style=""color:$($RptSchdcvalid[2])"">$($RptSchdcvalid[0])</p></td>
					<td bgcolor=""$($RptConfdcdom[1])""><p style=""color:$($RptConfdcdom[2])"">$($RptConfdcdom[0])</p></td>
					<td bgcolor=""$($RptConfdcvalid[1])""><p style=""color:$($RptConfdcvalid[2])"">$($RptConfdcvalid[0])</p></td>
					<td bgcolor=""$($RptDomdcdom[1])""><p style=""color:$($RptDomdcdom[2])"">$($RptDomdcdom[0])</p></td>
					<td bgcolor=""$($RptDomdcvalid[1])""><p style=""color:$($RptDomdcvalid[2])"">$($RptDomdcvalid[0])</p></td>
					<td bgcolor=""$($RptDnsdcdom[1])""><p style=""color:$($RptDnsdcdom[2])"">$($RptDnsdcdom[0])</p></td>
					<td bgcolor=""$($RptDnsdcvalid[1])""><p style=""color:$($RptDnsdcvalid[2])"">$($RptDnsdcvalid[0])</p></td>
					<td bgcolor=""$($RptFDnsdcdom[1])""><p style=""color:$($RptFDnsdcdom[2])"">$($RptFDnsdcdom[0])</p></td>
					<td bgcolor=""$($RptFDnsdcvalid[1])""><p style=""color:$($RptFDnsdcvalid[2])"">$($RptFDnsdcvalid[0])</p></td>
					</tr>"
		$RptdcentTable += $dcentTable	

	}
}

# End DCHealth-Table

# End DCSystem-Table
$RptdcsystemEnd = "
        </tbody>
        </table>
    </div><!--End DomCSystem Class-->"

$CompleteDCsysTable = $RptDCSystemTableBegin + $RptdcSystemTable + $RptdcsystemEnd

# End DCConn-Table
$RptdcconnEnd = "
        </tbody>
        </table>
    </div><!--End DomCConn Class-->"

$CompleteDCConnTable = $RptDCConnTableBegin + $RptDCconnectivityTable + $RptdcconnEnd

# End DCRep-Table
$RptdcrepEnd = "
        </tbody>
        </table>
    </div><!--End DomCRep Class-->"

$CompleteDCrepTable = $RptDCRepTableBegin + $RptdcreplicaitonTable + $RptdcrepEnd

# End DCEnt-Table
$RptdcentEnd = "
        </tbody>
        </table>
    </div><!--End DomCEnt Class-->"

$CompleteDCentTable = $RptDCentTableBegin + $RptdcEntTable + $Rptdcentend
#endregion

#region Sync-KCC

# Create SYNC and KCC Header

# Perform KCC Failcache Verification

Clear-Content $logfile
repadmin /failcache > $Logfile

$patt = 'KCC CONNECTION'
$indx = Select-String $patt $logfile | ForEach-Object { $_.LineNumber }
$conchk = (Get-Content $logfile)[$indx]

$patt = 'KCC LINK'
$indx = Select-String $patt $logfile | ForEach-Object { $_.LineNumber }
$Linkchk = (Get-Content $logfile)[$indx]


If ($Test = '(none)') {
	$kccCon = "Pass", $BkgrdColor[0], $ForegrdColor[1]
}
Else {
	$kccCon = "Error", $BkgrdColor[0], $ForegrdColor[3]
}
If ($TestLink = '(none)') {
	$kcclink = "Pass", $BkgrdColor[0], $ForegrdColor[1]
}
Else {
	$kcclink = "Error", $BkgrdColor[0], $ForegrdColor[3]
}

# Perform Syncall Verification

$syncvalid = "SyncAll terminated with no errors."
Clear-Content $logfile
repadmin /syncall > $Logfile

if ((Get-Content $logfile).contains($syncvalid)) {
	$SyncStatus = "No Errors", $BkgrdColor[0], $ForegrdColor[1]
}
Else {
	$SyncStatus = "Errors Present", $BkgrdColor[0], $ForegrdColor[3]
}

# Build Data into HTML
$CompleteDomTestTable = "
		<div class=""DomTests""><!--Start DomTests Class-->
					<h3><b>$($DomTestsTableCaption)</b></h3><br>
        <table id=""DomTest-Table"">
        <tbody>
        <tr><!--Header Line-->
        <th><p style=""text-align:left;margin-left:-4px"">Test</p></th>
        <th><p>Status</p></th>
        </tr>
		<tr>
		<td><p style=""text-align:left;"">Sync Replication:</td>
		<td bgcolor=""$($SyncStatus[1])""><p style=""color:$($SyncStatus[2])"">$($SyncStatus[0])</p></td>
		</tr>
		<tr>
		<td><p style=""text-align:left;"">KCC Connection Failures:</td>
		<td bgcolor=""$($kccCon[1])""><p style=""color:$($kccCon[2])"">$($kccCon[0])</p></td>
		</tr>
		<tr>
		<td><p style=""text-align:left;"">KCC Link Failures:</td>
		<td bgcolor=""$($kcclink[1])""><p style=""color:$($kcclink[2])"">$($kcclink[0])</p></td>
		</tr>
		</tbody>
        </table>
    </div><!--End DomTests Class-->"

#endregion

#region ISTG Test
#------------------------------------Build class for Inter-Site Topology Generator coverage
Clear-Content $logfile
Clear-Content $logfiletemp
$istgtest = $null
$istgclean = $null
$istgdata = $null
$site = $null
$data = $null
	
#DomISTG-Table Header
$DomISTGtableBegin = "
			<div class=""DomISTG""><!--Start DomISTG Class-->
					<h3><b>$($ISTGTableCaption)</b></h3><br>
        <table id=""DomISTG-Table"">
        <tbody>
            <tr><!--Header Line-->
                <th><p style=""text-align:left;margin-left:-4px"">Site</p></th>
                <th><p>ISTG Server</p></th>
            </tr>"

#Gather Data
repadmin /istg >$Logfile
$istgtest = $Logfile
Get-Content $istgtest | Where-Object { $_.Trim() -ne '' } | Select-Object -Skip 4 | ForEach-Object { $_ -replace '  +', "`t" } | 
set-content $Logfiletemp

$istgclean = Get-Content $Logfiletemp
$istgdata = $istgclean.trimstart("`t")

foreach ($site in $istgdata) {
	$data = $site.split( "`t" )

	$sitename = $data[0]
	$istgsvr = $data[1]
	$ISTGTable = "
							<tr><!--Data Line-->
						<td><p style=""text-align:left;"">$sitename</p></td>
						<td><p style=""text-align:left;"">$istgsvr</p></td>
						</tr>"
	$RptISTGTable += $ISTGTable
}
# End ISTG-Table
$DomISTGTableEnd = "
        </tbody>
        </table>
    </div><!--End ISTG Class-->"

$CompletedISTGTable = $DomISTGtableBegin + $RptISTGTable + $domISTGTableEnd

#endregion

#region Get DNS Information
#------------------------------------Build class for DNSEntries
#DNS-Table Header
$RptDNSTableBegin = "
		<div class=""DNSEntries""><!--Start DNSEntries Class-->
					<h3><b>$($DNSTableCaption)</b></h3><br>
        <table id=""DNS-Table"">
        <tbody>
            <tr><!--Header Line-->
                <th><p style=""text-align:left;margin-left:-4px"">DC</p></th>
                <th><p>Authentication</p></th>
                <th><p>Basic</p></th>
				<th><p>Forwarders</p></th>
                <th><p>Delegation</p></th>
                <th><p>DynamicUpdate</p></th>
                <th><p>RecordRegistration</p></th>
				<th><p>ExternalNameResolution</p></th>
            </tr>"
			
#Run the DCDiag

#Note:  This uses the PDC Emulator discovered above.
#Note:  /x outputs XML for DCDIAG.  This only works for the DNS test.
$Result = $Null

DCDiag.exe /test:dns /s:$PDCE /x:$filePath\dcdiag.xml /e

#Now pull the XML output into an object and start manipulating it
[System.Xml.XmlDocument] $XD = new-object System.Xml.XmlDocument
$XD.Load("$filePath\dcdiag.xml")

#Loop through all the domain controllers and get the results of the test - tests are dynamically added to 
#the object
$Result = ForEach ($Element in $XD.DCDIAGTestResults.DNSEnterpriseTestResults.Summary.Domain.DC) {
	$Tests = New-Object PSObject -Property @{
		DC = $Element.Name
	}
	$Fields = @("DC")
	ForEach ($Test in $Element.Test) {
		Add-Member -InputObject $Tests -MemberType NoteProperty -Name $Test.Name -Value $Test.Status
		$Fields += $Test.Name
	}
	$Tests
}



#Create the HTML and save it to a file
$HTML = $Result | Select-Object $Fields 
$RptdnsTable = $Null
foreach ($dnssvr in $HTML) {
	$DSvr = ($dnssvr.DC)
		
	#This IF statement is specific to DOJ because we cannot access the Root domain with this test.
	#If ($DSvr -ne "jcon-dc-348" -AND $DSvr -ne "jcon-dc-349" -And $DSvr -ne "JCON-DC-148" -And $DSvr -ne "coar-dc-351" -And $DSvr -ne "COAR-DC-350" -And $DSvr -ne "JCD-DC-RCK03" -And $DSvr -ne "JCD-DC-RCK04" -And $DSvr -ne "SRD-DC-111" -And $DSvr -ne "SRD-DC-311")
	#{
	$DAuth = ($dnssvr.Authentication)
	$DBasic = ($dnssvr.Basic)
	$DForw = ($dnssvr.Forwarders)
	$DDel = ($dnssvr.Delegation)
	$DDyn = ($dnssvr.DynamicUpdate)
	$DRecR = ($dnssvr.RecordRegistration)
	$DExtN = ($dnssvr.ExternalNameResolution)
			
	$DNSTable = $null
			
	#Check DNS Authentication
	if ($DAuth -eq "PASS") {
		$RptDAuth = "PASS", $BkgrdColor[0], $ForegrdColor[1]
	}
	elseif ($DAuth -eq "WARN") {
		$RptDAuth = "WARN", $BkgrdColor[0], $ForegrdColor[4]
	}
	elseif ($DAuth -eq "FAIL") {
		$RptDAuth = "FAIL", $BkgrdColor[0], $ForegrdColor[3]
	}
	else {
		$RptDAuth = "N/A", $BkgrdColor[0], $ForegrdColor[5]	
	}
				
	#Check Basic DNS Test
	if ($DBasic -eq "PASS") {
		$RptDBasic = "PASS", $BkgrdColor[0], $ForegrdColor[1]
	}
	elseif ($DBasic -eq "WARN") {
		$RptDBasic = "WARN", $BkgrdColor[0], $ForegrdColor[4]
	}
	elseif ($DBasic -eq "FAIL") {
		$RptDBasic = "FAIL", $BkgrdColor[0], $ForegrdColor[3]
	}
	else {
		$RptDBasic = "N/A", $BkgrdColor[0], $ForegrdColor[5]	
	}

	#Check DNS Forwarders
	if ($DForw -eq "PASS") {
		$RptDForw = "PASS", $BkgrdColor[0], $ForegrdColor[1]
	}
	elseif ($DForw -eq "WARN") {
		$RptDForw = "WARN", $BkgrdColor[0], $ForegrdColor[4]
	}
	elseif ($DForw -eq "FAIL") {
		$RptDForw = "FAIL", $BkgrdColor[0], $ForegrdColor[3]
	}
	else {
		$RptDForw = "N/A", $BkgrdColor[0], $ForegrdColor[5]	
	}	

	#Check DNS Delegation
	if ($DDel -eq "PASS") {
		$RptDDel = "PASS", $BkgrdColor[0], $ForegrdColor[1]
	}
	elseif ($DDel -eq "WARN") {
		$RptDDel = "WARN", $BkgrdColor[0], $ForegrdColor[4]
	}
	elseif ($DDel -eq "FAIL") {
		$RptDDel = "FAIL", $BkgrdColor[0], $ForegrdColor[3]
	}
	else {
		$RptDDel = "N/A", $BkgrdColor[0], $ForegrdColor[5]	
	}		

	#Check DNS Dynamic Update
	if ($DDyn -eq "PASS") {
		$RptDDyn = "PASS", $BkgrdColor[0], $ForegrdColor[1]
	}
	elseif ($DDyn -eq "WARN") {
		$RptDDyn = "WARN", $BkgrdColor[0], $ForegrdColor[4]
	}
	elseif ($DDyn -eq "FAIL") {
		$RptDDel = "FAIL", $BkgrdColor[0], $ForegrdColor[3]
	}
	else {
		$RptDDyn = "N/A", $BkgrdColor[0], $ForegrdColor[5]	
	}		

	#Check DNS Record Registration
	if ($DRecR -eq "PASS") {
		$RptDRecR = "PASS", $BkgrdColor[0], $ForegrdColor[1]
	}
	elseif ($DRecR -eq "WARN") {
		$RptDRecR = "WARN", $BkgrdColor[0], $ForegrdColor[4]
	}
	elseif ($DRecR -eq "FAIL") {
		$RptDRecR = "FAIL", $BkgrdColor[0], $ForegrdColor[3]
	}
	else {
		$RptDRecR = "N/A", $BkgrdColor[0], $ForegrdColor[5]	
	}		

	#Check DNS External Name Resolution
	if ($DExtN -eq "PASS") {
		$RptDExtN = "PASS", $BkgrdColor[0], $ForegrdColor[1]
	}
	elseif ($DExtN -eq "WARN") {
		$RptDExtN = "WARN", $BkgrdColor[0], $ForegrdColor[4]
	}
	elseif ($DExtN -eq "FAIL") {
		$RptDExtN = "FAIL", $BkgrdColor[0], $ForegrdColor[3]
	}
	else {
		$RptDExtN = "N/A", $BkgrdColor[0], $ForegrdColor[5]	
	}		

				
	#Check 
	#BuildTable

	$dnsTable = "
							<tr><!--Data Line-->
						<td><p style=""text-align:left;"">$($DSvr)</p></td>
						<td bgcolor=""$($RptDAuth[1])""><p style=""color:$($RptDAuth[2])"">$($RptDAuth[0])</p></td>
						<td bgcolor=""$($RptDBasic[1])""><p style=""color:$($RptDBasic[2])"">$($RptDBasic[0])</p></td>
						<td bgcolor=""$($RptDForw[1])""><p style=""color:$($RptDForw[2])"">$($RptDForw[0])</p></td>
						<td bgcolor=""$($RptDDel[1])""><p style=""color:$($RptDDel[2])"">$($RptDDel[0])</p></td>
						<td bgcolor=""$($RptDDyn[1])""><p style=""color:$($RptDDyn[2])"">$($RptDDyn[0])</p></td>
						<td bgcolor=""$($RptDRecR[1])""><p style=""color:$($RptDRecR[2])"">$($RptDRecR[0])</p></td>
						<td bgcolor=""$($RptDExtN[1])""><p style=""color:$($RptDExtN[2])"">$($RptDExtN[0])</p></td>
						</tr>"
	$RptdnsTable += $dnsTable
	#}
}

# End DNS-Table
$RptDNSTableEnd = "
        </tbody>
        </table>
    </div><!--End DNSEntries Class-->"



	
$CompletedDNSTable = $RptDNSTableBegin + $RptDnsTable + $RptDNSTableEnd
#endregion

#region Get Time Offset
#Create Time output and manipulation file and Clean up Previous Files if exists

if (Test-Path -path C:\Scripts\DC\TimeOut.txt) {  
	Remove-Item C:\Scripts\DC\TimeOut.txt -Force 
}  
if (Test-Path -path C:\Scripts\DC\Timeadj.txt) {  
	Remove-Item C:\Scripts\DC\Timeadj.txt -Force 
}
if (Test-Path -path C:\Scripts\DC\Time.txt) {  
	Remove-Item C:\Scripts\DC\Time.txt -Force 
}  

#Create table header

$RptdcTimeTable = $Null

#DCtime-Table Header
$RptDCtimeTableBegin = "
		<div class=""DomTime""><!--Start DomTime Class-->
			        <h3><b>$($adTimeTableCaption)</b></h3><br>
        <table id=""DCTime-Table"">
        <tbody>
            <tr><!--Header Line-->
                <th><p style=""text-align:left;margin-left:-4px"">Name</p></th>
                <th><p>Time Offset</p></th>
				<th><p>Reference Server</p></th>
            </tr>"
			
#Gather Domain Controllers
$ADs = [DirectoryServices.ActiveDirectory.Domain]::GetCurrentDomain().DomainControllers | ForEach-Object { $_.Name }  

#Loop through Domain Controllers and gather time data
for ($i = 0; $i -lt $ADs.Count; $i++) {  
	$dcName = $ADs[$i]  

	w32tm /monitor /computers:$dcName | Format-Table fullname | out-file C:\Scripts\DC\Time.txt -append 
}  

#Create Time output
(Get-Content C:\Scripts\DC\Time.txt) -notmatch "and may not" -notmatch "Warning" -notmatch "Stratum" -notmatch "Reverse" -notmatch "time packets" -notmatch "delayoffset" -notmatch "analyzing" -notmatch "                        " | out-file C:\Scripts\DC\Time.txt  

$InputFile = "C:\Scripts\DC\Time.txt" 
$AdjustedFile = "C:\Scripts\DC\Timeadj.txt"
$RptputFile = "C:\Scripts\DC\TimeOut.txt" 

#Write time output to a new file in a format which can be manipulated
#NOTE:  Adjustedfile is created to remove any icmp errors which will throw off the output.
    
Get-Content $InputFile | Where-Object { $_ -notmatch 'error' -and $_ -notmatch 'offset' } | Set-Content $AdjustedFile
$Writer = New-Object IO.StreamWriter "$RptputFile" 
$Writer.Write( [String]::Join("", $(Get-Content $AdjustedFile)) )  
$Writer.Close()  

#Replace unwanted character strings in the Text File so we can obtain data
	(Get-Content C:\Scripts\DC\TimeOut.txt) | Foreach-Object { $_ -replace ":    ICMP", "`tICMP" } | Set-Content C:\Scripts\DC\TimeOut.txt  
	(Get-Content C:\Scripts\DC\TimeOut.txt) | Foreach-Object { $_ -replace "     NTP: ", "`t" } | Set-Content C:\Scripts\DC\TimeOut.txt  
	(Get-Content C:\Scripts\DC\TimeOut.txt) | Foreach-Object { $_ -replace "s         RefID: ", "`t" } | Set-Content C:\Scripts\DC\TimeOut.txt  
	(Get-Content C:\Scripts\DC\TimeOut.txt) | Foreach-Object { $_ -replace "]        ", "]|`r`n" } | Set-Content C:\Scripts\DC\TimeOut.txt  

#Open completed text file as content
[string] $NTPData = (Get-Content C:\Scripts\DC\TimeOut.txt)  

$PartsNTPData = $NTPData.Split( "|" )  
$Count = 0  

(Get-Content C:\Scripts\DC\TimeOut.txt) | Where-Object { $_.trim() -ne "" } | set-content C:\Scripts\DC\TimeOut.txt 

#Loop through each Server and obtain required data parts
foreach ($Server in $PartsNTPData) {  
	$ServerParts = $Server.Split( "`t" )

	#Build the Server Name
	$Name = $ServerParts[0]  
	$Name = $Name.trim()

	#Remove FDQN and IP addresses
	If ($Name -match ".") {
		$pos = $name.IndexOf(".")
		$Hostname = $name.Substring(0, $pos)
		#$rightPart = $name.Substring($pos+1)
	}

	$ICMP = $ServerParts[1]  
	#Get the Time Offset
	[double] $Time = $ServerParts[2]  

	#Get the Referring Domain Controller without the IP
	$RefID = $ServerParts[3]  
	$RefID = ($RefID -Split ' ')[0]

	#Strip any empty lines and create data output	  
	If ($name -ne "") {
		$dctimeTable = "
					<tr><!--Data Line-->
                <td><p style=""text-align:left;"">$($hostname)</p></td>
                <td><p style=""text-align:left;"">$($time)</p></td>
				<td><p style=""text-align:left;"">$($RefID)</p></td>
				</tr>"
		$RptdctimeTable += $dctimeTable
	}
}  

# End DCTime-Table
$RptdctimeEnd = "
        </tbody>
        </table>
    </div><!--End DomTime Class-->"

$CompleteDCTimeTable = $RptDCtimeTableBegin + $RptdctimeTable + $RptdctimeEnd
	
#endregion

#region replication summary

$RepSrcTable = $Null
$RptRepSrcTable = $Null
$RepdestTable = $Null
$RptRepdestTable = $Null

$myRepInfo = @(repadmin /replsum * /bysrc /bydest /sort:delta)

# Initialize our array.
$cleanRepInfo = @() 
# Start @ #10 because all the previous lines are junk formatting
# and strip off the last 4 lines because they are not needed.
for ($i = 10; $i -lt ($myRepInfo.Count - 4); $i++) {
	if ($myRepInfo[$i] -ne "") {
		# Remove empty lines from our array.
		$myRepInfo[$i] -replace '\s+', " "            
		$cleanRepInfo += $myRepInfo[$i]             
	}
} 

$finalRepInfo = @()   
foreach ($line in $cleanRepInfo) {
	$splitRepInfo = $line -split '\s+', 8
	if ($splitRepInfo[0] -eq "Source") { $repType = "Source" }
	if ($splitRepInfo[0] -eq "Destination") { $repType = "Destination" }

	if ($splitRepInfo[1] -notmatch "DSA") {       
		# Create an Object and populate it with our values.
		$objRepValues = New-Object System.Object 
		$objRepValues | Add-Member -type NoteProperty -name DSAType -value $repType # Source or Destination DSA
		$objRepValues | Add-Member -type NoteProperty -name Hostname  -value $splitRepInfo[1] # Hostname
		$objRepValues | Add-Member -type NoteProperty -name Delta  -value $splitRepInfo[2] # Largest Delta
		$objRepValues | Add-Member -type NoteProperty -name Fails -value $splitRepInfo[3] # Failures
		#$objRepValues | Add-Member -type NoteProperty -name Slash  -value $splitRepInfo[4] # Slash char
		$objRepValues | Add-Member -type NoteProperty -name Total -value $splitRepInfo[5] # Totals
		$objRepValues | Add-Member -type NoteProperty -name PctError  -value $splitRepInfo[6] # % errors   
		$objRepValues | Add-Member -type NoteProperty -name ErrorMsg  -value $splitRepInfo[7] # Error code
		
		# Add the Object as a row to our array    
		$finalRepInfo += $objRepValues
		
	}
}


#ReplicationSummarySource-Table Header
$RptRepSrcTableBegin = "
		<div class=""RepSource""><!--Start RepSource Class-->
					<h3><b>$($RepSummarySourceCaption)</b></h3><br>
        <table id=""RepsummarySource-Table"">
        <tbody>
            <tr><!--Header Line-->
                <th><p style=""text-align:left;margin-left:-4px"">Server Name</p></th>
                <th><p>Delta</p></th>
				<th><p>Fails</p></th>
				<th><p>Total</p></th>
				<th><p>%-Error</p></th>
				<th><p>Err Msg</p></th>
            </tr>"
			
#Get Data
$finalRepInfo | ForEach-Object { If ($_.DSAType -eq "Source") {
		$RepHost = $_.Hostname
		$RepDelta = $_.Delta
		$RepFails = $_.Fails
		$RepTotal = $_.Total
		$RepPctE = $_.PctError
		$RepErrMsg = $_.ErrorMsg
	
	if ($RepFails -gt 0) {
			$Rptrepfail = $repfails, $BkgrdColor[0], $ForegrdColor[3]
		}
		Else {
			$Rptrepfail = $repfails, $BkgrdColor[0], $ForegrdColor[1]
		}   

		$RepSrcTable = "
							<tr><!--Data Line-->
						<td><p style=""text-align:left;"">$($rephost)</p></td>
						<td><p style=""text-align:left;"">$($RepDelta)</p></td>
                        <td bgcolor=""$($Rptrepfail[1])""><p style=""text-align:right;color:$($Rptrepfail[2])"">$($Rptrepfail[0])</p></td>
						<td><p style=""text-align:center;"">$($RepTotal)</p></td>
						<td><p style=""text-align:left;"">$($RepPctE)</p></td>
						<td><p style=""text-align:left;"">$($RepErrMsg)</p></td>
						</tr>"
		$RptRepSrcTable += $RepSrcTable
	}
}

#End Table
		
$RptRepSrcTableEnd = "
        </tbody>
        </table>
    </div><!--End RepSource Class-->"

$CompleteRepSrcTable = $RptRepSrcTableBegin + $RptRepSrcTable + $RptRepSrcTableEnd

#RepsummaryDest-Table Header

$RptRepDestTableBegin = "
		<div class=""RepDestination""><!--Start RepDestination Class-->
					<h3><b>$($RepSummaryDestCaption)</b></h3><br>
        <table id=""RepsummaryDest-Table"">
        <tbody>
            <tr><!--Header Line-->
                <th><p style=""text-align:left;margin-left:-4px"">Server Name</p></th>
                <th><p>Delta</p></th>
				<th><p>Fails</p></th>
				<th><p>Total</p></th>
				<th><p>%-Error</p></th>
				<th><p>Err Msg</p></th>
            </tr>"

#Get Data
$finalRepInfo | ForEach-Object { If ($_.DSAType -eq "Destination") {
	$RepHost = $_.Hostname
	$RepDelta = $_.Delta
	$RepFails = $_.Fails
	$RepTotal = $_.Total
	$RepPctE = $_.PctError
	$RepErrMsg = $_.ErrorMsg
	
	if ($RepFails -gt 0) {
		$Rptrepfail = $repfails, $BkgrdColor[0], $ForegrdColor[3]
	}
	Else {
		$Rptrepfail = $repfails, $BkgrdColor[0], $ForegrdColor[1]
	}

	$RepdestTable = "
							<tr><!--Data Line-->
						<td><p style=""text-align:left;"">$($rephost)</p></td>
						<td><p style=""text-align:left;"">$($RepDelta)</p></td>
                        <td bgcolor=""$($Rptrepfail[1])""><p style=""text-align:right;color:$($Rptrepfail[2])"">$($Rptrepfail[0])</p></td>
						<td><p style=""text-align:center;"">$($RepTotal)</p></td>
						<td><p style=""text-align:left;"">$($RepPctE)</p></td>
						<td><p style=""text-align:left;"">$($RepErrMsg)</p></td>
						</tr>"
		$RptRepdestTable += $RepdestTable
	}
}

#End Table
		
$RptRepdestTableEnd = "
        </tbody>
        </table>
    </div><!--End RepDestination Class-->"

$CompleteRepdestTable = $RptRepdestTableBegin + $RptRepdestTable + $RptRepdestTableEnd


#endregion


#region HTML End

$RptHtmlEnd = '
<P></P>
<P><em><center><font face="times new roman" size 1 color="#357EC7">Refer to the following <a href="https://technet.microsoft.com/en-us/library/cc731968.aspx"> Technet Article cc731968</a> for more information on the DCDiag test and meanings of each test performed</em></P>
<br><br/><center><p style=""font-size:12px;color:#BDBDBD"">Modified ScriptVersion: 1.5 | Active Directory Health Check</p></center>
<br/>
</body>
</html>'


$RptFullHTML = $RptHtmlStart + $RptADTable + $CompleteDomTestTable + $CompleteDCsysTable + $CompleteDCConnTable + $CompleteDCrepTable + $CompleteDCentTable + $CompletedDNSTable + $CompleteRepSrcTable + $CompleteRepdestTable + $CompleteDCTimeTable + $CompletedISTGTable + $RptHtmlEnd

$RptFullHTML | Out-File $ReportFile
#endregion

#region Send email

#send-mailmessage -from $MailAdmin -to $Recipients -subject $MsgSubject -body $MsgBody -Attachments $ReportFile -smtpServer $smtpServer


#endregion

Clear-Content $logfile
Clear-Content $filePath\dcdiag.xml
Clear-Content $RptputFile
if (Test-Path -path C:\Scripts\DC\Timeadj.txt) {  
	Remove-Item C:\Scripts\DC\Timeadj.txt -Force 
}
if (Test-Path -path C:\Scripts\DC\Time.txt) {  
	Remove-Item C:\Scripts\DC\Time.txt -Force 
} 
if (Test-Path -path C:\Scripts\DC\TimeOut.txt) {  
	Remove-Item C:\Scripts\DC\TimeOut.txt -Force 
}
if (Test-Path -path $logfile) {  
	Remove-Item $logfile -Force
}
if (Test-Path -path C:\Scripts\DC\dcdiag.xml) {  
	Remove-Item C:\Scripts\DC\dcdiag.xml -Force
}
if (Test-Path -path $logfiletemp) {  
	Remove-Item $logfiletemp -Force
}