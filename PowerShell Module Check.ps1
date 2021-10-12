<#
    Allows the user to check to PowerShell Module Changes on the Client
#>

# Function
# Check for Differences Between Currrent & Previous Modules
function Get-Differences
{
    # Get the Files
    $dir = "C:\PowerShell\Installed\*- Modules.json"
    #Write-Host $dir
    $latest = @(Get-ChildItem -Path $dir | Sort-Object LastWriteTime -Descending | Select-Object -First 2)
    $count = @($latest).Count
    #Write-Host "File Count:" $count
    #Write-Host "Current:" $latest.FullName[0] # Current Settings
    #Write-Host "Previous:" $latest.FullName[1] # Previous Settings
    #Pause

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
                for ($numP = 0 ; $numP -le $countP ; $numP++) {
                    If (($modulesPrevious[$numP]).Name -contains ($modulesCurrent[$numC]).Name) {
                        If ((($modulesPrevious[$numP]).Version).Major -eq (($modulesCurrent[$numC]).Version).Major) {
                            If ((($modulesPrevious[$numP]).Version).Minor -eq (($modulesCurrent[$numC]).Version).Minor) {
                                If ((($modulesPrevious[$numP]).Version).Build -eq (($modulesCurrent[$numC]).Version).Build) {
                                    If ((($modulesPrevious[$numP]).Version).Revision -eq (($modulesCurrent[$numC]).Version).Revision) {}
                                    else {Write-Host "`tUpdated PowerShell Module:" ($modulesCurrent[$numC]).Name -ForegroundColor Yellow}
                                }
                                else {Write-Host "`tUpdated PowerShell Module:" ($modulesCurrent[$numC]).Name -ForegroundColor Yellow}
                            }
                            else {Write-Host "`tUpdated PowerShell Module:" ($modulesCurrent[$numC]).Name -ForegroundColor Yellow}
                        }
                        else {Write-Host "`tUpdated PowerShell Module:" ($modulesCurrent[$numC]).Name -ForegroundColor Yellow}
                    }
                }
            }
            else {Write-Host "`tNew PowerShell Module:" ($modulesCurrent[$numC]).Name -ForegroundColor Yellow}
        }
    }
}

# Get Currnet PowerShell Modules Installed
$Script:ModuleReportJ = "C:\PowerShell\Installed\$(Get-Date -Format yyyy-MM-dd-HH-mm) - Modules.json"
$Script:ModuleReportC = "C:\PowerShell\Installed\$(Get-Date -Format yyyy-MM-dd-HH-mm) - Modules.csv"
$Script:objTemp = New-Object System.Object
$tempAR = Get-InstalledModule
@($tempAR) | Select-Object Version,Name,Repository | ConvertTo-Json | Out-File $Script:ModuleReportJ -Append
@($tempAR) | Export-Csv -path $Script:ModuleReportC -NoTypeInformation -Encoding UTF8

# Compare Currrent & Previous Modules Installed
Get-Differences

