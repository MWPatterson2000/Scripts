<#
    Allows the User to Check for PowerShell Module Changes on the Client
#>

# Variables
#$path = "C:\PowerShell\Installed" # Path to store report and JSON files for comparison
$path = "D:\PowerShell\Installed" # Path to store report and JSON files for comparison

# Function
# Check for Differences Between Currrent & Previous Modules
function Get-Differences
{
    # Get the Files
    #$dir = "C:\PowerShell\Installed\*- Modules.json"
    $dir = "$path\*- Modules.json"
    #Write-Host $dir
    $latest = @(Get-ChildItem -Path $dir | Sort-Object LastWriteTime -Descending | Select-Object -First 2)
    $count = @($latest).Count
    #Write-Host "File Count:" $count
    #Write-Host "Current:" $latest.FullName[0] # Current Settings
    #Write-Host "Previous:" $latest.FullName[1] # Previous Settings

    If ($count -eq 2) {
        # Read the files in
        $modulesCurrent = Get-Content -Raw -Path $latest.FullName[0] | ConvertFrom-Json # Current Settings
        $modulesPrevious = Get-Content -Raw -Path $latest.FullName[1] | ConvertFrom-Json # Previous Settings

        $countC = @($modulesCurrent).Count
        $countC = $countC - 1
        $countP = @($modulesPrevious).Count
        $countP = $countP - 1
        for ($numC = 0 ; $numC -le $countC ; $numC++) {
            #$temp = ($checkValuesA[$numC])
            If (($modulesPrevious).Name -contains ($modulesCurrent[$numC]).Name) {
                #Write-Host "Current:"($modulesCurrent[$numC]).Name (($modulesCurrent[$numC]).Version).Major (($modulesCurrent[$numC]).Version).Minor (($modulesCurrent[$numC]).Version).Build (($modulesCurrent[$numC]).Version).Revision
                #Write-Host "Current:"$modulesCurrent[$numC]
                #Write-Host "Previous:"($modulesPrevious).Name
                for ($numP = 0 ; $numP -le $countP ; $numP++) {
                    If (($modulesPrevious[$numP]).Name -contains ($modulesCurrent[$numC]).Name) {
                        #Write-Host "Previous:"($modulesPrevious[$numP]).Name (($modulesPrevious[$numP]).Version).Major (($modulesPrevious[$numP]).Version).Minor (($modulesPrevious[$numP]).Version).Build (($modulesPrevious[$numP]).Version).Revision
                        #Write-Host "Previous:"$modulesPrevious[$numP]
                        #$tempM = "Updated," + ($modulesCurrent[$numC]).Name + "," + (($modulesCurrent[$numC]).Version).Major + "." + (($modulesCurrent[$numC]).Version).Minor + "." + (($modulesCurrent[$numC]).Version).Build + "." + (($modulesCurrent[$numC]).Version).Revision
                        $tempM = "Updated," + ($modulesCurrent[$numC]).Name + "," + ($modulesCurrent[$numC]).Version
                        <#
                        If ((($modulesPrevious[$numP]).Version).Major -eq (($modulesCurrent[$numC]).Version).Major) {
                            If ((($modulesPrevious[$numP]).Version).Minor -eq (($modulesCurrent[$numC]).Version).Minor) {
                                If ((($modulesPrevious[$numP]).Version).Build -eq (($modulesCurrent[$numC]).Version).Build) {
                                    If ((($modulesPrevious[$numP]).Version).Revision -eq (($modulesCurrent[$numC]).Version).Revision) {}
                                    else {
                                        Write-Host "`tUpdated PowerShell Module:" ($modulesCurrent[$numC]).Name -ForegroundColor Yellow
                                        #$tempM = "Updated," + ($modulesCurrent[$numC]).Name + "," + (($modulesCurrent[$numC]).Version).Major + "." + (($modulesCurrent[$numC]).Version).Minor + "." + (($modulesCurrent[$numC]).Version).Build + "." + (($modulesCurrent[$numC]).Version).Revision
                                        $tempM | Out-File $outputCsv -Append
                                    }
                                }
                                else {
                                    Write-Host "`tUpdated PowerShell Module:" ($modulesCurrent[$numC]).Name -ForegroundColor Yellow
                                    #$tempM = "Updated," + ($modulesCurrent[$numC]).Name + "," + (($modulesCurrent[$numC]).Version).Major + "." + (($modulesCurrent[$numC]).Version).Minor + "." + (($modulesCurrent[$numC]).Version).Build + "." + (($modulesCurrent[$numC]).Version).Revision
                                    $tempM | Out-File $outputCsv -Append
                                }
                            }
                            else {
                                Write-Host "`tUpdated PowerShell Module:" ($modulesCurrent[$numC]).Name -ForegroundColor Yellow
                                #$tempM = "Updated," + ($modulesCurrent[$numC]).Name + "," + (($modulesCurrent[$numC]).Version).Major + "." + (($modulesCurrent[$numC]).Version).Minor + "." + (($modulesCurrent[$numC]).Version).Build + "." + (($modulesCurrent[$numC]).Version).Revision
                                $tempM | Out-File $outputCsv -Append
                            }
                        }
                        #>
                        If (($modulesPrevious[$numP]).Version -eq ($modulesCurrent[$numC]).Version) {
                            #Write-Host "Same"
                        }
                        else {
                            #Write-Host "Current:"$modulesCurrent[$numC]
                            #Write-Host "Previous:"$modulesPrevious[$numP]
                            Write-Host "`tUpdated PowerShell Module:" ($modulesCurrent[$numC]).Name -ForegroundColor Yellow
                            #$tempM = "Updated," + ($modulesCurrent[$numC]).Name + "," + (($modulesCurrent[$numC]).Version).Major + "." + (($modulesCurrent[$numC]).Version).Minor + "." + (($modulesCurrent[$numC]).Version).Build + "." + (($modulesCurrent[$numC]).Version).Revision
                            $tempM | Out-File $outputCsv -Append
                        }
                    }
                }
            }
            else {
                Write-Host "`tNew PowerShell Module:" ($modulesCurrent[$numC]).Name -ForegroundColor Yellow
                $tempM = "New," + ($modulesCurrent[$numC]).Name + "," + (($modulesCurrent[$numC]).Version).Major + "." + (($modulesCurrent[$numC]).Version).Minor + "." + (($modulesCurrent[$numC]).Version).Build + "." + (($modulesCurrent[$numC]).Version).Revision
                $tempM | Out-File $outputCsv -Append
            }
        }
        for ($numP = 0 ; $numP -le $countP ; $numP++) {
            If (($modulesCurrent).Name -NotContains ($modulesPrevious[$numP]).Name) {
                Write-Host "`tRemoved PowerShell Module:" ($modulesCurrent[$numP]).Name -ForegroundColor Yellow
                $tempM = "Removed," + ($modulesPrevious[$numP]).Name + "," + (($modulesPrevious[$numP]).Version).Major + "." + (($modulesPrevious[$numP]).Version).Minor + "." + (($modulesCurrent[$numP]).Version).Build + "." + (($modulesCurrent[$numP]).Version).Revision
                $tempM | Out-File $outputCsv -Append
            }
        }
    }
}

# Get Currnet PowerShell Modules Installed
#$Script:ModuleReportJ = "C:\PowerShell\Installed\$(Get-Date -Format yyyy-MM-dd-HH-mm) - Modules.json"
#$Script:ModuleReportC = "C:\PowerShell\Installed\$(Get-Date -Format yyyy-MM-dd-HH-mm) - Modules.csv"
$Script:ModuleReportJ = "$path\$(Get-Date -Format yyyy-MM-dd-HH-mm) - Modules.json"
$Script:ModuleReportC = "$path\$(Get-Date -Format yyyy-MM-dd-HH-mm) - Modules.csv"
$Script:ModuleReportS = "$path\$(Get-Date -Format yyyy-MM-dd-HH-mm) - Modules Names.csv"
$Script:objTemp = New-Object System.Object
#Get-InstalledModule | Select-Object Name,Repository,Version | Format-Table -AutoSize
$tempAR = Get-InstalledModule | Sort-Object Name
@($tempAR) | Export-Csv -path $Script:ModuleReportC -NoTypeInformation -Encoding UTF8
#@($tempAR) | Select-Object Version,Name,Repository | ConvertTo-Json | Out-File $Script:ModuleReportJ -Append
@($tempAR) | Select-Object Name,Repository,Version | ConvertTo-Json | Out-File $Script:ModuleReportJ -Append
@($tempAR) | Select-Object Name,Repository,Version | Export-Csv -path $Script:ModuleReportS -NoTypeInformation -Encoding UTF8

# Write Changes to File
$outputCsv = "$path\$(Get-Date -Format yyyy-MM-dd-HH-mm) - Update Modules.csv"

# Compare Currrent & Previous Modules Installed
Get-Differences

