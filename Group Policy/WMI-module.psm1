Function New-WMIClass {
    <#
     .SYNOPSIS
     This function help to create a new WMI class.
     
     .DESCRIPTION
     The function allows to create a WMI class in the CimV2 namespace.
     Accepts a single string, or an array of strings.
     
     .PARAMETER ClassName
     Specify the name of the class that you would like to create. (Can be a single string, or a array of strings).
     
     .PARAMETER NameSpace
     Specify the namespace where class the class should be created.
     If not specified, the class will automatically be created in "Root\cimv2"
     
     .EXAMPLE
     New-WMIClass -ClassName "PowerShellDistrict"
     Creates a new class called "PowerShellDistrict"
     .EXAMPLE
     New-WMIClass -ClassName "aaaa","bbbb"
     Creates two classes called "aaaa" and "bbbb" in the Root\cimv2
     
     .NOTES
     Version: 1.0
     Author: Stephane van Gulick
     Creation date:16.07.2014
     Last modification date: 16.07.2014
     
     .LINK
     www.powershellDistrict.com
     
     .LINK
     
    http://social.technet.microsoft.com/profile/st%C3%A9phane%20vg/
     
    #>
    [CmdletBinding()]
     Param(
     [Parameter(Mandatory=$true,valueFromPipeLine=$true)][string[]]$ClassName,
     [Parameter(Mandatory=$false)][string]$NameSpace = "root\cimv2"
      
     )
     
     
      
      
     
     foreach ($NewClass in $ClassName){
     if (!(Get-WMIClass -ClassName $NewClass -NameSpace $NameSpace)){
     write-verbose "Attempting to create class $($NewClass)"
     $WMI_Class = ""
     $WMI_Class = New-Object System.Management.ManagementClass($NameSpace, $null, $null)
     $WMI_Class.name = $NewClass
     $WMI_Class.Put() | out-null
      
     write-host "Class $($NewClass) created."
     
     }else{
     write-host "Class $($NewClass) is already present. Skiping.."
     }
     }
     
    }
      
    Function New-WMIProperty {
    <#
     .SYNOPSIS
     This function help to create new WMI properties.
     
     .DESCRIPTION
     The function allows to create new properties and set their values into a newly created WMI Class.
     Event though it is possible, it is not recommended to create WMI properties in existing WMI classes !
     
     .PARAMETER ClassName
     Specify the name of the class where you would like to create the new properties.
     
     .PARAMETER PropertyName
     The name of the property.
     
     .PARAMETER PropertyValue
     The value of the property.
     
     .EXAMPLE
     New-WMIProperty -ClassName "PowerShellDistrict" -PropertyName "WebSite" -PropertyValue "www.PowerShellDistrict.com"
     
     .NOTES
     Version: 1.0
     Author: Stephane van Gulick
     Creation date:16.07.2014
     Last modification date: 16.07.2014
     
     .LINK
     www.powershellDistrict.com
     
     .LINK
     
    http://social.technet.microsoft.com/profile/st%C3%A9phane%20vg/
     
    #>
     
     
    [CmdletBinding()]
     Param(
     [Parameter(Mandatory=$true)]
     [ValidateScript({
     $_ -ne ""
     })]
     [string]$ClassName,
     
     [Parameter(Mandatory=$false)]
     [string]$NameSpace="Root\cimv2",
     
     [Parameter(Mandatory=$true)][string]$PropertyName,
     [Parameter(Mandatory=$false)][string]$PropertyValue=""
     
      
     )
     begin{
     [wmiclass]$WMI_Class = Get-WmiObject -Class $ClassName -Namespace $NameSpace -list
     }
     Process{
     write-verbose "Attempting to create property $($PropertyName) with value: $($PropertyValue) in class: $($ClassName)"
     $WMI_Class.Properties.add($PropertyName,$PropertyValue)
     Write-Output "Added $($PropertyName)."
     }
     end{
     $WMI_Class.Put() | Out-Null
     [wmiclass]$WMI_Class = Get-WmiObject -Class $ClassName -list
     return $WMI_Class
     }
     
      
      
      
      
     
     
    }
     
    Function Set-WMIPropertyValue {
     
    <#
     .SYNOPSIS
     This function set a WMI property value.
     
     .DESCRIPTION
     The function allows to set a new value in an existing WMI property.
     
     .PARAMETER ClassName
     Specify the name of the class where the property resides.
     
     .PARAMETER PropertyName
     The name of the property.
     
     .PARAMETER PropertyValue
     The value of the property.
     
     .EXAMPLE
     New-WMIProperty -ClassName "PowerShellDistrict" -PropertyName "WebSite" -PropertyValue "www.PowerShellDistrict.com"
     Sets the property "WebSite" to "www.PowerShellDistrict.com"
     .EXAMPLE
     New-WMIProperty -ClassName "PowerShellDistrict" -PropertyName "MainTopic" -PropertyValue "PowerShellDistrict"
     Sets the property "MainTopic" to "PowerShell"
     
     
     .NOTES
     Version: 1.0
     Author: Stephane van Gulick
     Creation date:16.07.2014
     Last modification date: 16.07.2014
     
     .LINK
     www.powershellDistrict.com
     
     .LINK
     
    http://social.technet.microsoft.com/profile/st%C3%A9phane%20vg/
     
    #>
     
     
    [CmdletBinding()]
     Param(
     [Parameter(Mandatory=$true)]
     [ValidateScript({
     $_ -ne ""
     })]
     [string]$ClassName,
     
     [Parameter(Mandatory=$false)]
     [string]$NameSpace="Root\cimv2",
     
     [Parameter(Mandatory=$true)]
     [ValidateScript({
     $_ -ne ""
     })]
     [string]$PropertyName,
     
     [Parameter(Mandatory=$true)]
     [string]$PropertyValue
     
      
     )
     begin{
     write-verbose "Setting new value : $($PropertyValue) on property: $($PropertyName):"
     [wmiclass]$WMI_Class = Get-WmiObject -Class $ClassName -list
      
     
     }
     Process{
     $WMI_Class.SetPropertyValue($PropertyName,$PropertyValue)
      
     }
     End{
     $WMI_Class.Put() | Out-Null
     return Get-WmiObject -Class $ClassName -list
     }
     
     
    }
     
    Function Remove-WMIProperty{
    <#
     .SYNOPSIS
     This function removes a WMI property.
     
     .DESCRIPTION
     The function allows to remove a specefic WMI property from a specefic WMI class.
     /!\Be aware that any wrongly deleted WMI properties could make your system unstable./!\
     
     .PARAMETER ClassName
     Specify the name of the class name.
     
     .PARAMETER PropertyName
     The name of the property.
     
     .EXAMPLE
     Remove-WMIProperty -ClassName "PowerShellDistrict" -PropertyName "MainTopic"
     Removes the WMI property "MainTopic".
     
     .NOTES
     Version: 1.0
     Author: Stephane van Gulick
     Creation date:21.07.2014
     Last modification date: 24.07.2014
     
     .LINK
     www.powershellDistrict.com
     
     .LINK
     
    http://social.technet.microsoft.com/profile/st%C3%A9phane%20vg/
     
    #>
     
     
    [CmdletBinding()]
     Param(
     [Parameter(Mandatory=$true)][string]$ClassName,
     [Parameter(Mandatory=$true)][string]$PropertyName,
     [Parameter(Mandatory=$false)][string]$NameSpace = "Root\Cimv2",
     [Parameter(Mandatory=$false)][string]$Force
     
      
     )
     if ($PSBoundParameters['NameSpace']){
     
     [wmiclass]$WMI_Class = Get-WmiObject -Class $ClassName -Namespace $NameSpace -list
     }
     else{
     write-verbose "Gaterhing data of $($ClassName)"
     [wmiclass]$WMI_Class = Get-WmiObject -Class $ClassName -list
     }
     if (!($force)){
      
     $Answer = Read-Host "Deleting $($PropertyName) can make your system unreliable. Press 'Y' to continue"
     if ($Answer -eq"Y"){
     $WMI_Class.Properties.remove($PropertyName)
     write-ouput "Property $($propertyName) removed."
      
     }else{
     write-ouput "Uknowned answer. Class '$($PropertyName)' has not been deleted."
     }
     }#End force
     elseif ($force){
     $WMI_Class.Properties.remove($PropertyName)
     write-ouput "Property $($propertyName) removed."
     }
     
      
      
     
    }
     
    Function Remove-WMIClass {
     
    <#
     .SYNOPSIS
     This function removes a WMI class from the WMI repository.
     /!\ Removing a wrong WMI class could make your system unreliable. Use wisely and at your own risk /!\
     
     .DESCRIPTION
     The function deletes a WMI class from the WMI repository. Use this function wiseley as this could make your system unstable if wrongly used.
     
     .PARAMETER ClassName
     Specify the name of the class that you would like to delete.
     
     .PARAMETER NameSpace
     Specify the name of the namespace where the WMI class resides (default is Root\cimv2).
     .PARAMETER Force
     Will delete the class without asking for confirmation.
     
     .EXAMPLE
     Remove-WMIClass -ClassName "PowerShellDistrict"
     This will launch an attempt to remove the WMI class PowerShellDistrict from the repository. The user will be asked for confirmation before deleting the class.
     
     .EXAMPLE
     Remove-WMIClass -ClassName "PowerShellDistrict" -force
     This will remove the WMI PowerShellDistrict class from the repository. The user will NOT be asked for confirmation before deleting the class.
     
     .NOTES
     Version: 1.0
     Author: Stephane van Gulick
     Creation date:18.07.2014
     Last modification date: 24.07.2014
     
     .LINK
     www.powershellDistrict.com
     
     .LINK
     
    http://social.technet.microsoft.com/profile/st%C3%A9phane%20vg/
     
    #>
     
     
    [CmdletBinding()]
     Param(
     [parameter(mandatory=$true,valuefrompipeline=$true)]
     [ValidateScript({
     $_ -ne ""
     })]
     [string[]]$ClassName,
     
     [Parameter(Mandatory=$false)]
     [string]$NameSpace = "Root\CimV2",
     
     [Parameter(Mandatory=$false)]
     [Switch]$Force
    )
     
      
     write-verbose "Attempting to delete classes"
     foreach ($Class in $ClassName){
     if(!($Class)){
     write-verbose "Class name is empty. Skipping..."
     }else{
     [wmiclass]$WMI_Class = Get-WmiObject -Namespace $NameSpace -Class $Class -list
     if ($WMI_Class){
      
      
     if (!($force)){
     write-host
     $Answer = Read-Host "Deleting $($Class) can make your system unreliable. Press 'Y' to continue"
     if ($Answer -eq"Y"){
     $WMI_Class.Delete()
     write-output "$($Class) deleted."
      
     }else{
     write-output "Uknowned answer. Class '$($class)' has not been deleted."
     }
     }
     elseif ($force){
     $WMI_Class.Delete()
     write-output "$($Class) deleted."
     }
     }Else{
     write-output "Class $($Class) not present"
     }#End if WMI_CLASS
     }#EndIfclass emtpy
     }#End foreach
      
      
    }
     
    Function Compile-MofFile{
      
     <#
     .SYNOPSIS
     This function will compile a mof file.
     
     .DESCRIPTION
     The function allows to create new WMI Namespaces, classes and properties by compiling a MOF file.
     Important: Using the Compile-MofFile cmdlet, assures that the newly created WMI classes and Namespaces also will be recreated in case of WMI rebuild.
     
     .PARAMETER MofFile
     Specify the complete path to the MOF file.
     
     .EXAMPLE
     Compile-MofFile -MofFile C:\tatoo.mof
     
     .NOTES
     Version: 1.0
     Author: Stéphane van Gulick
     Creation date:18.07.2014
     Last modification date: 18.07.2014
     History : Creation : 18.07.2014 --> SVG
     
     .LINK
     www.powershellDistrict.com
     
     .LINK
     
    http://social.technet.microsoft.com/profile/st%C3%A9phane%20vg/
     
    #>
     
    [CmdletBinding()]
     Param(
     [Parameter(Mandatory=$true)]
     [ValidateScript({
      
     test-path $_
      
     })][string]$MofFile
     
      
     )
      
     begin{
      
     if (test-path "C:\Windows\System32\wbem\mofcomp.exe"){
     $MofComp = get-item "C:\Windows\System32\wbem\mofcomp.exe"
     }
     
     }
     Process{
     Invoke-expression "& $MofComp $MofFile"
     Write-Output "Mof file compilation actions finished."
     }
     End{
      
     }
     
    }
     
    Function Export-MofFile {
      
     <#
     .SYNOPSIS
     This function export a specefic class to a MOF file.
     
     .DESCRIPTION
     The function allows export specefic WMI Namespaces, classes and properties by exporting the data to a MOF file format.
     Use the Generated MOF file in whit the cmdlet "Compile-MofFile" in order to import, or re-import the existing class.
     
     .PARAMETER MofFile
     Specify the complete path to the MOF file.(Must contain ".mof" as extension.
     
     .EXAMPLE
     Export-MofFile -ClassName "PowerShellDistrict" -Path "C:\temp\PowerShellDistrict_Class.mof"
     
     .NOTES
     Version: 1.0
     Author: Stéphane van Gulick
     Creation date:18.07.2014
     Last modification date: 18.07.2014
     History : Creation : 18.07.2014 --> SVG
     
     .LINK
     www.powershellDistrict.com
     
     .LINK
     
    http://social.technet.microsoft.com/profile/st%C3%A9phane%20vg/
     
    #>
     
     [CmdletBinding()]
     Param(
     [parameter(mandatory=$true)]
     [ValidateScript({
     $_.endsWith(".mof")
     })]
     [string]$Path,
     
     
     [parameter(mandatory=$true)]
     [string]$ClassName,
     
     [Parameter(Mandatory=$false)]
     [string]$NameSpace = "Root\CimV2"
      
     )
     
     begin{}
     Process{
     
     if ($PSBoundParameters['ClassName']){
     write-verbose "Checking for Namespace: $($Namespace) and Class $($Classname)"
     
     [wmiclass]$WMI_Info = Get-WmiObject -Namespace $NameSpace -Class $ClassName -list
     
     }
     else{
     [wmi]$WMI_Info = Get-WmiObject -Namespace $NameSpace -list
     
     }
     
     [system.management.textformat]$mof = "mof"
     $MofText = $WMI_Info.GetText($mof)
     Write-Output "Exporting infos to $($path)"
     "#PRAGMA AUTORECOVER" | out-file -FilePath $Path
     $MofText | out-file -FilePath $Path -Append
      
      
     
     }
     End{
     
     return Get-Item $Path
     }
     
    }
     
    Function Get-WMIClass{
     <#
     .SYNOPSIS
     get information about a specefic WMI class.
     
     .DESCRIPTION
     returns the listing of a WMI class.
     
     .PARAMETER ClassName
     Specify the name of the class that needs to be queried.
     
     .PARAMETER NameSpace
     Specify the name of the namespace where the class resides in (default is "Root\cimv2").
     
     .EXAMPLE
     get-wmiclass
     List all the Classes located in the root\cimv2 namespace (default location).
     
     .EXAMPLE
     get-wmiclass -classname win32_bios
     Returns the Win32_Bios class.
     
     .EXAMPLE
     get-wmiclass -classname MyCustomClass
     Returns information from MyCustomClass class located in the default namespace (Root\cimv2).
     
     .EXAMPLE
     Get-WMIClass -NameSpace root\ccm -ClassName *
     List all the Classes located in the root\ccm namespace
     
     .EXAMPLE
     Get-WMIClass -NameSpace root\ccm -ClassName ccm_client
     Returns information from the cm_client class located in the root\ccm namespace.
     
     .NOTES
     Version: 1.0
     Author: Stephane van Gulick
     Creation date:23.07.2014
     Last modification date: 23.07.2014
     
     .LINK
     www.powershellDistrict.com
     
     .LINK
     
    http://social.technet.microsoft.com/profile/st%C3%A9phane%20vg/
     
    #>
    [CmdletBinding()]
     Param(
     [Parameter(Mandatory=$false,valueFromPipeLine=$true)][string]$ClassName,
     [Parameter(Mandatory=$false)][string]$NameSpace = "root\cimv2"
      
     )
     begin{
     write-verbose "Getting WMI class $($Classname)"
     }
     Process{
     if (!($ClassName)){
     $return = Get-WmiObject -Namespace $NameSpace -Class * -list
     }else{
     $return = Get-WmiObject -Namespace $NameSpace -Class $ClassName -list
     }
     }
     end{
     
     return $return
     }
     
    }
    
    