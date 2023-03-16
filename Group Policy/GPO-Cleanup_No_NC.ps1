<#
############################################################################# 
#                                                                           # 
#   This Sample Code is provided for the purpose of illustration only       # 
#   and is not intended to be used in a production environment.  THIS       # 
#   SAMPLE CODE AND ANY RELATED INFORMATION ARE PROVIDED "AS IS" WITHOUT    # 
#   WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING BUT NOT    # 
#   LIMITED TO THE IMPLIED WARRANTIES OF MERCHANTABILITY AND/OR FITNESS     # 
#   FOR A PARTICULAR PURPOSE.  We grant You a nonexclusive, royalty-free    # 
#   right to use and modify the Sample Code and to reproduce and distribute # 
#   the object code form of the Sample Code, provided that You agree:       # 
#   (i) to not use Our name, logo, or trademarks to market Your software    # 
#   product in which the Sample Code is embedded; (ii) to include a valid   # 
#   copyright notice on Your software product in which the Sample Code is   # 
#   embedded; and (iii) to indemnify, hold harmless, and defend Us and      # 
#   Our suppliers from and against any claims or lawsuits, including        # 
#   attorneys' fees, that arise or result from the use or distribution      # 
#   of the Sample Code.                                                     #
#                                                                           #
#   This posting is provided "AS IS" with no warranties, and confers        #
#   no rights. Use of included script samples are subject to the terms      #
#   specified at http://www.microsoft.com/info/cpyright.htm.                #
#                                                                           # 
#   Author: Donovan du Val                                                  # 
#   Version 1.0         Date Last modified: 22 January 2018                 # 
#                                                                           # 
############################################################################# 
.Synopsis
The script will disable GPO's which contain no settings and not linked. It will also find the GPO's that do not have read 
access for authenticated users and it will add authenticated users with read access to these policies. NO renaming will be done!

To implement a new naming convention and implement the same changes as this script, make use of the below script:
https://gallery.technet.microsoft.com/GPO-Clean-up-with-a-New-6a451c8a?redir=0
        
.DESCRIPTION
This script will:
1. Find GPO's with no settings and these will be disabled.
2. Find GPO's with user extension enabled with no user settings configured. The user extension will be disabled.
3. Find GPO's with computer extension enabled with no computer settings. The computer extension will be disabled.
4. Find GPO's where authenticated users has no read access. Authenticated users will then be granted read access (MS16-072-KB3163622).
5. Finds unlinked GPO's on both sites and OU's. These will be disabled.

.EXAMPLE
GPO-Cleanup_NO_NC.ps1 -whatif
Outputs the changes that will be made to all the GPO's that match the filters.
.EXAMPLE
GPO-Cleanup_NO_NC.ps1
Outputs no details but implements the changes.
.EXAMPLE
Get-Help GPO-Cleanup_NO_NC.ps1 -full
Outputs help text with examples.
.Link
Using Whatif and confirms in functions: 
https://blogs.technet.microsoft.com/pstips/2018/01/17/passing-down-the-whatif-and-confirm-preferences-to-other-cmdlets-from-an-advanced-function/

Adding help details to functions: 
https://msdn.microsoft.com/en-us/library/dd878343(v=vs.85).aspx
#>
#Requires –Version 4.0
#Requires -Modules ActiveDirectory
#Requires -Modules GroupPolicy
[CmdletBinding(SupportsShouldProcess=$True)]
Param()
Begin
{
    #adding Whatif and confirmation
    $commonParams = @{}
    if($WhatIfPreference.IsPresent) {$commonParams.Add('WhatIf', $true)}
    $GPOlist = Get-GPO -All | Where-Object {($_.Id -notlike "6AC1786C-016F-11D2-945F-00C04fB984F9") -or ($_.id -notlike "31B2F340-016D-11D2-945F-00C04FB984F9")}
}
Process
{
        foreach ($PerGPO in $GPOlist)
        {
        $GPOReport = [xml](Get-GPOReport $PerGPO.DisplayName -ReportType xml)

        $GPO = New-Object PSobject -Property @{
                'DisplayName' = $PerGPO.DisplayName
                'GPOStatus' = $PerGPO.GpoStatus
                'GUID' = $PerGPO.Id
                'sitelinks' = if (Get-ADObject -Filter {(objectClass -eq "site")} -SearchBase (Get-ADRootDSE).ConfigurationNamingContext -Properties gPLink | Where-Object {$_.gplink -match $PerGPO.Id}) {$true} else{$false}
                'WMIFilterFilter' = if ($PerGpo.WmiFilter) {$true} else {$false} 
                'GPOLinks' = if ($GPOReport.gpo.linksto) {$true} else {$false} 
                'UserExtensions' = if ($GPOReport.GPO.User.extensiondata) {$true} else {$false}
                'ComputerExtensions' = if ($GPOReport.GPO.Computer.extensiondata) {$true} else {$false}
                }

        $gponame = $GPO.DisplayName
    
        #adds authenticated users with read access to GPO's where it has been removed. (MS16-072-KB3163622)
        if (!(Get-GPPermission -Name $GPOName -TargetName "Authenticated Users" -TargetType Group -ErrorAction SilentlyContinue))
        {
        write-verbose "No authenticated users exists on $GPOName. It will now be added"

        Set-GPPermissions -Name $GPOName -PermissionLevel GpoRead -TargetName "Authenticated Users" -TargetType Group -PipelineVariable $commonParams | Out-Null
        }

        #disables extensions based on which extensions are configured.
        switch ($gpo)
        {        
            {(($gpo.ComputerExtensions -eq $False) -and ($gpo.UserExtensions -eq $True))} 
            {
                if($WhatIfPreference.IsPresent) { "(Custom) What if: GPO: $gponame will have computer extensions disabled" } 
                else {$PerGPO.GpoStatus = 'ComputerSettingsDisabled'; 
                Write-Verbose "No Computer extensions exist: $GPOName"
                }
            }
            {(($gpo.ComputerExtensions -eq $True) -and ($gpo.UserExtensions -eq $False))} 
            {
                if($WhatIfPreference.IsPresent) { "(Custom) What if: GPO: $gponame will have user extensions disabled" } 
                else {$PerGPO.GpoStatus = 'UserSettingsDisabled'; 
                Write-Verbose "No User extensions exist: $GPOName"
                }
            }
            {(($gpo.ComputerExtensions -eq $True) -and ($gpo.UserExtensions -eq $True))} 
            {
                if($WhatIfPreference.IsPresent) { "(Custom) What if: GPO: $gponame all extensions are enabled" } 
                else { $PerGPO.GpoStatus = 'AllSettingsEnabled'; 
                Write-Verbose "Both User and Computer extensions exist: $GPOName"
                }
            }
            {(($gpo.ComputerExtensions -eq $False) -and ($gpo.UserExtensions -eq $False))} 
            {
                if($WhatIfPreference.IsPresent) { "(Custom) What if: GPO: $gponame will have all extensions disabled" } 
                else {$PerGPO.GpoStatus = 'AllSettingsDisabled'; 
                Write-Verbose "Both settings exist, disabling: $GPOName"
                }
            }
        }

        #disable GPO's with no site links or OU links, then renames
        if ((($GPO.sitelinks -eq $false) -and ($GPO.GPOLinks -eq $false)) -and ($GPO.GpoStatus -ne 'AllSettingsDisabled'))
        {
            if($WhatIfPreference.IsPresent)  
            {
            "(Custom) What if: GPO: $gponame will have all extensions disabled"
            }
            else{
            $PerGPO.GpoStatus = 'AllSettingsDisabled'
            Write-Verbose "$GPOName has been disabled: $GPOName"
            }
        }
    }
}
End
{    
    #Ending the tasks with a quick message
    if($WhatIfPreference.IsPresent) 
    { 
    write-host "No changes made!" -ForegroundColor Green
    }
    else 
    {
    Write-host "Clean up completed." -ForegroundColor Green
    }
}