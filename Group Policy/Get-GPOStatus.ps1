<#
.Synopsis
    Get Group Policy Status
    AUTHOR: Vincent Karunaidas
    Publish: 11/16/2016   
    Update: 11th November  2016
.EXAMPLE
   Get-GPOStatus -All
   Get-GPOStatus -All | Format-Table -AutoSize
   This would get All Group Policy Computer & User Configuration Status
.EXAMPLE
   Get-GPOStatus -DisplayName 'Default Domain Policy'
   This would get 'Default Domain Policy's Computer & User Configuration Status
.EXAMPLE
    Get-GPOStatus -DisplayName 'Default Domain Controllers Policy'
    This would get 'Default Domain Policy's Computer & User Configuration Status
.EXAMPLE
    Get-GPOStatus -DisplayName 'Default Domain Controllers Policy','Default Domain Policy'
    This would get 'Default Domain Policy' & 'Default Domain Policy's Computer & User Configuration Status
.EXAMPLE
    Get-GPOStatus -All | Where {$_.ComputerPolicy -eq 'Nothing Configured'}
    Get-GPOStatus -All | Where {$_.ComputerPolicy -like 'Not*'}
    This would get all Group Policy where nothing is configured in the Computer Configuration
.EXAMPLE
    Get-GPOStatus -All | Where {$_.UserPolicy -like 'Not*'}
    This would get all Group Policy where nothing is configured in the User Configuration
.EXAMPLE
    Get-GPOStatus -All | Where {$_.ComputerPolicy -like '*Security*Registry*'}
    This would get all Group Policy where some Security & Registry Settings is configured in the Computer Configuration
#>

Function Get-GPOStatus {
[Cmdletbinding(DefaultParameterSetName='DisplayName')]
Param(
      [Parameter(ValueFromPipeline,ValueFromPipelineByPropertyName,Position=0,ParameterSetName='DisplayName')]
      [String[]]$DisplayName,
      [Parameter(ParameterSetName='All')]
      [Switch]$All
      )

Begin {$GPR = '';$GPRT= ''}

Process {
If ($ALL) {
    [XML]$GPRT = Get-GPOReport -All -ReportType Xml
    Foreach ($GPR in $GPRT.GPOS.GPO) {
    If ($GPR.Computer.ExtensionData){
           $Computer = $($GPR.Computer.ExtensionData.Name) -join ' & ' 
    }Else {
           $Computer = 'Nothing Configured' 
    }
    If ($GPR.User.ExtensionData){
           $User = $($GPR.User.ExtensionData.Name) -join ' & ' 
    }Else {
           $User = 'Nothing Configured' 
    }
    [PSCustomObject]@{Name = $GPR.Name ; ComputerConfiguration = $Computer ; UserConfiguration = $User ; LastModified = $GPR.ModifiedTime ; CreatedTime = $GPR.CreatedTime}
    }

} Else {
        $DisplayName | ForEach-Object{ [XML]$GPR = Get-GPOReport -Name $_ -ReportType Xml

        If ($GPR.GPO.Computer.ExtensionData){
               $Computer = $($GPR.GPO.Computer.ExtensionData.Name) -join ' & ' 
        }Else {
               $Computer = 'Nothing Configured' 
        }
        If ($GPR.GPO.User.ExtensionData){
               $User = $($GPR.GPO.User.ExtensionData.Name) -join ' & ' 
        }Else {
               $User = 'Nothing Configured' 
        }
        [PSCustomObject]@{Name = $_ ; ComputerConfiguration = $Computer ; UserConfiguration = $User ; LastModified = $GPR.GPO.ModifiedTime ; CreatedTime = $GPR.GPO.CreatedTime }

        }
}
}#Process
End {}
}#Function