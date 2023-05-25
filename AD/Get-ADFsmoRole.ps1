<#
.SYNOPSIS
Gets the domain and forest Active Directory FSMO (Flexible Single Master Operation) roles for a domain.

.DESCRIPTION
The Get-ADFsmoRole command gets the Active Directory FSMO Roles for the domain and the forest of the domain specified by the parameters. You can specify the domain by setting the Identity or Current parameters. By default, all roles are returned, but using a switch parameter for the individual roles will cause only that role to be returned instead.

This command uses both Get-ADDomain and Get-ADForest cmdlets to retrieve its information. The parameters of this command match the behavior and accept the same inputs as the parameters for these cmdlets. Refer to their individual help files for full details.
.PARAMETER AuthType
Specifies the authentication method to use. Possible values include:
    Negotiate or 0
    Basic or 1

The default is Negotiate.
Refer to the help of Get-ADDomain or Get-ADForest for more information.

.PARAMETER Credential
Specifies the user account credentials to use to perform this task. The default credentials are the credentials of the currently logged on user.

Refer to the help of Get-ADDomain or Get-ADForest for more information.

.PARAMETER Current
Specifies whether to return the domain of the local computer or the current logged on user (CLU). Possible values include:
    LocalComputer or 0
    LoggedOnUser or 1

The default is LoggedOnUser

Refer to the help of Get-ADDomain or Get-ADForest for more information.

.PARAMETER Identity
Specifies an Active Directory domain object by providing one of the following property values: Distinguished Name, GUID, SID, DNS Name, or NetBIOS Name.

Refer to the help of Get-ADDomain or Get-ADForest for more information.

.PARAMETER Server
Specifies the Active Directory Domain Services instance to connect to.

Refer to the help of Get-ADDomain or Get-ADForest for more information and the full list of availble options.

.PARAMETER DomainNamingMaster
Outputs the Domain Naming Master instead of all roles.

.PARAMETER SchemaMaster
Outputs the Schema Master instead of all roles.

.PARAMETER RIDMaster
Outputs the RID Master instead of all roles.

.PARAMETER PDCEmulator
Outputs the PDC Emulator instead of all roles.

.PARAMETER InfrastructureMaster
Outputs the Infrastructure Master instead of all roles.

.INPUTS
None or Microsoft.ActiveDirectory.Management.ADDomain

A domain object is received by the Identity Parameter.

.OUTPUTS
System.Management.Automation.PSCustomObject or System.String

Returns one or more PSCustomObjects that contains properties for the domain name, and each FSMO role.
Using one of the switch parameters for individual roles will output a string of the server occupying that role.

.EXAMPLE
The following command will get the FSMO roles for the domain of the current logged on user.

PS C:\> Get-ADFsmoRole
.EXAMPLE
The following command will get the FSMO roles for the domain provided by the pipeline.

PS C:\> 'sub.example.com' | Get-ADFsmoRole
.EXAMPLE
The following command will get the FSMO roles for the domain provided by the pipeline with user provided credentials using the server 'dc01'.

PS C:\> 'sub.example.com' | Get-ADFsmoRole -Credential (Get-Credential) -Server 'dc01.sub.example.com' 
.EXAMPLE
The following command will get the Domain Naming master role for the domain of the current logged on user.

PS C:\> Get-ADFsmoRole -DomainNamingMaster
.NOTES
This script uses the ActiveDirectory PowerShell Module. This module is automatically installed on domain controllers and workstations or member servers that have installed the Remote Server Administration Tools (RSAT).  If you are not on a machine that meets this criteria, the script will fail to work.

.LINK
Get-ADDomain
.LINK
Get-ADForest
#>

#Requires -Version 3.0

[CmdletBinding(DefaultParameterSetName = "Current", HelpURI = "https://gallery.technet.microsoft.com/Get-the-FSMO-Flexible-2c784676")]

Param(
    [Parameter(ParameterSetName = "Current")]
    [Parameter(ParameterSetName = "CurrentDN")]
    [Parameter(ParameterSetName = "CurrentSC")]
    [Parameter(ParameterSetName = "CurrentRI")]
    [Parameter(ParameterSetName = "CurrentPD")]
    [Parameter(ParameterSetName = "CurrentIN")]
    [ValidateSet("LoggedOnUser", "LocalComputer")]
    [String]
    $Current = "LoggedOnUser",

    [Parameter(ParameterSetName = "Identity", Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
    [Parameter(ParameterSetName = "IdentityDN", Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
    [Parameter(ParameterSetName = "IdentitySC", Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
    [Parameter(ParameterSetName = "IdentityRI", Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
    [Parameter(ParameterSetName = "IdentityPD", Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
    [Parameter(ParameterSetName = "IdentityIN", Position = 0, Mandatory = $true, ValueFromPipeline = $true)]
    [Object[]]
    $Identity,

    [ValidateSet("Basic", "Negotiate")]
    [String]
    $AuthType = "Negotiate",

    [PSCredential]
    $Credential,

    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [String]
    $Server,
    
    [Parameter(ParameterSetName = "CurrentDN")]
    [Parameter(ParameterSetName = "IdentityDN")]
    [Alias("Naming")]    
    [Switch]$DomainNamingMaster,
        
    [Parameter(ParameterSetName = "CurrentSC")]
    [Parameter(ParameterSetName = "IdentitySC")]
    [Alias("Schema", "SM")]    
    [Switch]$SchemaMaster,
        
    [Parameter(ParameterSetName = "CurrentRI")]
    [Parameter(ParameterSetName = "IdentityRI")]
    [Alias("RID", "RM")]
    [Switch]$RIDMaster,
        
    [Parameter(ParameterSetName = "CurrentPD")]
    [Parameter(ParameterSetName = "IdentityPD")]
    [Alias("PDC")]    
    [Switch]$PDCEmulator,
        
    [Parameter(ParameterSetName = "CurrentIN")]
    [Parameter(ParameterSetName = "IdentityIN")]
    [Alias("IM")]   
    [Switch]$InfrastructureMaster
)

Begin {
    #Test that the Active Directory Module is installed
    if (!(Import-Module ActiveDirectory -PassThru)) {
        Write-Error "The ActiveDirectory Module is not installed and this command cannot be use."
        exit
    }

    #Splat the paramters as they exist for passing to Cmdlets
    $paramSplat = @{AuthType = $AuthType }
    switch ($true) {
        { $Credential } { $paramSplat.Credential = $Credential }
        { $Server } { $paramSplat.Server = $Server }
    }

    #Create a PSCustomObject that contains the FSMO Roles and the domain and forest names from the ADDomain and ADForest objects
    Function New-ResultObject ([Microsoft.ActiveDirectory.Management.ADDomain]$Domain, [Microsoft.ActiveDirectory.Management.ADForest]$Forest) {
        $props = @{DomainName = $Domain.Name; ForestName = $Forest.Name; DomainNamingMaster = $Forest.DomainNamingMaster;
            SchemaMaster = $Forest.SchemaMaster; PDCEmulator = $Domain.PDCEmulator; RIDMaster = $Domain.RIDMaster;
            InfrastructureMaster = $Domain.InfrastructureMaster
        }
        
        #If individual role switches use, output their values and verbose domain header. If not, then create custom object
        switch ($true) {
            { $DomainNamingMaster -or $SchemaMaster -or $RIDMaster -or $PDCEmulator -or $InfrastructureMaster }
            { Write-Verbose "`n    Domain: $($Domain.Name)`n" }
            { $DomainNamingMaster } { $Forest.DomainNamingMaster }
            { $SchemaMaster } { $Forest.SchemaMaster }
            { $RIDMaster } { $Domain.RIDMaster }
            { $PDCEmulator } { $Domain.PDCEmulator }
            { $InfrastructureMaster } { $Domain.InfrastructureMaster }
            default { New-Object psobject -Property $props }
        }
    }
}

Process {
    #Process as pipeline or array input if the Identity parameter is used
    if ($PSCmdlet.ParameterSetName -like "*Identity*") {
        foreach ($i in $Identity) {
            #Get the domain and the forest objects by passing provided credentials
            #Any that do not exist in the hash will use the Cmdlet defaults
            $domain = Get-ADDomain -Identity $i @paramSplat
            $forest = Get-ADForest -Identity $i @paramSplat

            #Send the domain and forest objects to create an output object
            New-ResultObject -Domain $domain -Forest $forest
        }
    }
    else {
        #Get the domain and the forest objects by passing provided credentials
        #Any that do not exist in the hash will use the Cmdlet defaults
        $domain = Get-ADDomain -Current $Current @paramSplat
        $forest = Get-ADForest -Current $Current @paramSplat

        #Send the domain and forest objects to create an output object
        New-ResultObject -Domain $domain -Forest $forest
    }
}