<#
Name: Installed Script Check.ps1

Allows the User to Check for PowerShell Script Changes on the Client

Michael Patterson
scripts@mwpatterson.com

Revision History
    2024-04-07 - Initial Release

#>

[CmdletBinding()]
[Alias()]
[OutputType([int])]
Param(
    # Parameter help description
    #[Parameter(AttributeValues)]
    #[ParameterType]
    #$ParameterName
)

Begin {
    # Variables
    #$path = "C:\PowerShell\Installed" # Path to store report and JSON files for comparison
    $path = 'D:\PowerShell\Installed' # Path to store report and JSON files for comparison

    # Start Function(s)
    # Clear Varables
    function Get-UserVariable ($Name = '*') {
        [CmdletBinding()]
        #param ()
        # these variables may exist in certain environments (like ISE, or after use of foreach)
        $special = 'ps', 'psise', 'psunsupportedconsoleapplications', 'foreach', 'profile'

        $ps = [PowerShell]::Create()
        $null = $ps.AddScript('$null=$host;Get-Variable') 
        $reserved = $ps.Invoke() | 
        Select-Object -ExpandProperty Name
        $ps.Runspace.Close()
        $ps.Dispose()
        Get-Variable -Scope Global | 
        Where-Object Name -like $Name |
        Where-Object { $reserved -notcontains $_.Name } |
        Where-Object { $special -notcontains $_.Name } |
        Where-Object Name 
    }

    # Check for Differences Between Currrent & Previous Scripts
    function Get-Differences {
        [CmdletBinding()]
        param ()
        # Get the Files
        #$dir = "C:\PowerShell\Installed\*- Scripts.json"
        $dir = "$path\*- Scripts.json"
        #Write-Host $dir
        $latest = @(Get-ChildItem -Path $dir | Sort-Object LastWriteTime -Descending | Select-Object -First 2)
        $count = @($latest).Count
        #Write-Host "File Count:" $count
        #Write-Host "Current:" $latest.FullName[0] # Current Settings
        #Write-Host "Previous:" $latest.FullName[1] # Previous Settings

        If ($count -eq 2) {
            # Read the files in
            $scriptsCurrent = Get-Content -Raw -Path $latest.FullName[0] | ConvertFrom-Json # Current Settings
            $scriptsPrevious = Get-Content -Raw -Path $latest.FullName[1] | ConvertFrom-Json # Previous Settings

            $countC = @($scriptsCurrent).Count
            $countC = $countC - 1
            $countP = @($scriptsPrevious).Count
            $countP = $countP - 1
            for ($numC = 0 ; $numC -le $countC ; $numC++) {
                #$temp = ($checkValuesA[$numC])
                If (($scriptsPrevious).Name -contains ($scriptsCurrent[$numC]).Name) {
                    #Write-Host "Current:"($scriptsCurrent[$numC]).Name (($scriptsCurrent[$numC]).Version).Major (($scriptsCurrent[$numC]).Version).Minor (($scriptsCurrent[$numC]).Version).Build (($scriptsCurrent[$numC]).Version).Revision
                    #Write-Host "Current:"$scriptsCurrent[$numC]
                    #Write-Host "Previous:"($scriptsPrevious).Name
                    for ($numP = 0 ; $numP -le $countP ; $numP++) {
                        If (($scriptsPrevious[$numP]).Name -contains ($scriptsCurrent[$numC]).Name) {
                            #Write-Host "Previous:"($scriptsPrevious[$numP]).Name (($scriptsPrevious[$numP]).Version).Major (($scriptsPrevious[$numP]).Version).Minor (($scriptsPrevious[$numP]).Version).Build (($scriptsPrevious[$numP]).Version).Revision
                            #Write-Host "Previous:"$scriptsPrevious[$numP]
                            #$tempM = "Updated," + ($scriptsCurrent[$numC]).Name + "," + (($scriptsCurrent[$numC]).Version).Major + "." + (($scriptsCurrent[$numC]).Version).Minor + "." + (($scriptsCurrent[$numC]).Version).Build + "." + (($scriptsCurrent[$numC]).Version).Revision
                            #$tempM = 'Updated,' + ($scriptsCurrent[$numC]).Name + ',' + ($scriptsCurrent[$numC]).Version
                            $tempM = 'Updated,' + ($scriptsCurrent[$numC]).Name + ',' + (($scriptsCurrent[$numC]).Version).Major + '.' + (($scriptsCurrent[$numC]).Version).Minor + '.' + (($scriptsCurrent[$numC]).Version).Build + '.' + (($scriptsCurrent[$numC]).Version).Revision
                            <#
                        If ((($scriptsPrevious[$numP]).Version).Major -eq (($scriptsCurrent[$numC]).Version).Major) {
                            If ((($scriptsPrevious[$numP]).Version).Minor -eq (($scriptsCurrent[$numC]).Version).Minor) {
                                If ((($scriptsPrevious[$numP]).Version).Build -eq (($scriptsCurrent[$numC]).Version).Build) {
                                    If ((($scriptsPrevious[$numP]).Version).Revision -eq (($scriptsCurrent[$numC]).Version).Revision) {}
                                    else {
                                        Write-Host "`tUpdated PowerShell Script:" ($scriptsCurrent[$numC]).Name -ForegroundColor Yellow
                                        #$tempM = "Updated," + ($scriptsCurrent[$numC]).Name + "," + (($scriptsCurrent[$numC]).Version).Major + "." + (($scriptsCurrent[$numC]).Version).Minor + "." + (($scriptsCurrent[$numC]).Version).Build + "." + (($scriptsCurrent[$numC]).Version).Revision
                                        $tempM | Out-File $outputCsv -Append
                                    }
                                }
                                else {
                                    Write-Host "`tUpdated PowerShell Script:" ($scriptsCurrent[$numC]).Name -ForegroundColor Yellow
                                    #$tempM = "Updated," + ($scriptsCurrent[$numC]).Name + "," + (($scriptsCurrent[$numC]).Version).Major + "." + (($scriptsCurrent[$numC]).Version).Minor + "." + (($scriptsCurrent[$numC]).Version).Build + "." + (($scriptsCurrent[$numC]).Version).Revision
                                    $tempM | Out-File $outputCsv -Append
                                }
                            }
                            else {
                                Write-Host "`tUpdated PowerShell Script:" ($scriptsCurrent[$numC]).Name -ForegroundColor Yellow
                                #$tempM = "Updated," + ($scriptsCurrent[$numC]).Name + "," + (($scriptsCurrent[$numC]).Version).Major + "." + (($scriptsCurrent[$numC]).Version).Minor + "." + (($scriptsCurrent[$numC]).Version).Build + "." + (($scriptsCurrent[$numC]).Version).Revision
                                $tempM | Out-File $outputCsv -Append
                            }
                        }
                        #>
                            If (($scriptsPrevious[$numP]).Version -eq ($scriptsCurrent[$numC]).Version) {
                                #Write-Host "Same"
                            }
                            else {
                                #Write-Host "Current:"$scriptsCurrent[$numC]
                                #Write-Host "Previous:"$scriptsPrevious[$numP]
                                #Write-Host "`tUpdated PowerShell Script:" ($scriptsCurrent[$numC]).Name ($scriptsCurrent[$numC]).Version -ForegroundColor Yellow
                                Write-Host "`tUpdated Script:" ($scriptsCurrent[$numC]).Name ($scriptsCurrent[$numC]).Version -ForegroundColor Yellow
                                $tempM = 'Updated,' + ($scriptsCurrent[$numC]).Name + ',' + (($scriptsCurrent[$numC]).Version).Major + '.' + (($scriptsCurrent[$numC]).Version).Minor + '.' + (($scriptsCurrent[$numC]).Version).Build + '.' + (($scriptsCurrent[$numC]).Version).Revision
                                $tempM | Out-File $outputCsv -Append
                            }
                        }
                    }
                }
                else {
                    #Write-Host "`tNew PowerShell Script:" ($scriptsCurrent[$numC]).Name ($scriptsCurrent[$numC]).Version -ForegroundColor Yellow
                    Write-Host "`tNew Script:" ($scriptsCurrent[$numC]).Name ($scriptsCurrent[$numC]).Version -ForegroundColor Yellow
                    $tempM = 'New,' + ($scriptsCurrent[$numC]).Name + ',' + (($scriptsCurrent[$numC]).Version).Major + '.' + (($scriptsCurrent[$numC]).Version).Minor + '.' + (($scriptsCurrent[$numC]).Version).Build + '.' + (($scriptsCurrent[$numC]).Version).Revision
                    $tempM | Out-File $outputCsv -Append
                }
            }
            for ($numP = 0 ; $numP -le $countP ; $numP++) {
                If (($scriptsCurrent).Name -NotContains ($scriptsPrevious[$numP]).Name) {
                    #Write-Host "`tRemoved PowerShell Script:" ($scriptsCurrent[$numP]).Name -ForegroundColor Yellow
                    Write-Host "`tRemoved Script:" ($scriptsCurrent[$numP]).Name -ForegroundColor Yellow
                    $tempM = 'Removed,' + ($scriptsPrevious[$numP]).Name + ',' + (($scriptsPrevious[$numP]).Version).Major + '.' + (($scriptsPrevious[$numP]).Version).Minor + '.' + (($scriptsCurrent[$numP]).Version).Build + '.' + (($scriptsCurrent[$numP]).Version).Revision
                    $tempM | Out-File $outputCsv -Append
                }
            }
        }
    }

    # End Function(s)

}

Process {
    # Get Currnet PowerShell Scripts Installed
    $Script:ScriptReportJ = "$path\$(Get-Date -Format yyyy-MM-dd-HH-mm) - Scripts.json"
    $Script:ScriptReportC = "$path\$(Get-Date -Format yyyy-MM-dd-HH-mm) - Scripts.csv"
    $Script:ScriptReportS = "$path\$(Get-Date -Format yyyy-MM-dd-HH-mm) - Scripts Names.csv"
    $Script:objTemp = New-Object System.Object
    #Get-InstalledScript | Select-Object Name,Repository,Version | Format-Table -AutoSize
    $tempAR = Get-InstalledScript | Sort-Object Name
    @($tempAR) | Export-Csv -path $Script:ScriptReportC -NoTypeInformation -Encoding UTF8
    #@($tempAR) | Select-Object Version,Name,Repository | ConvertTo-Json | Out-File $Script:ScriptReportJ -Append
    @($tempAR) | Select-Object Name, Repository, Version | ConvertTo-Json | Out-File $Script:ScriptReportJ -Append
    @($tempAR) | Select-Object Name, Repository, Version | Export-Csv -path $Script:ScriptReportS -NoTypeInformation -Encoding UTF8

    # Write Changes to File
    $outputCsv = "$path\$(Get-Date -Format yyyy-MM-dd-HH-mm) - Update Script.csv"

    # Compare Currrent & Previous Scripts Installed
    Get-Differences

}

End {
    # Clear Variables
    Write-Host "`nScript Cleanup"
    Get-UserVariable | Remove-Variable -ErrorAction SilentlyContinue

    # Memory Cleanup
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()

    # End
    #Exit
    return
}
