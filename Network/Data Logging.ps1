##################################################### 

# Configuration Section 
$ziplocation = "D:\Logs"                #location you want the zip files 
$interval = 15                    #seconds between checks 

# Setup Section 
$computer = gc env:computername    #computer name variable 
if ($interval -le 60) { $interval = 60 }    #set minimum interval to 1 minute 
$counter = 0 

# Functions 
function New-Zip { 
    param([string]$zipfilename) 
    set-content $zipfilename ("PK" + [char]5 + [char]6 + ("$([char]0)" * 18)) 
    (dir $zipfilename).IsReadOnly = $false 
} 

function Add-Zip { 
    param([string]$zipfilename) 

    if (-not (test-path($zipfilename))) { 
        set-content $zipfilename ("PK" + [char]5 + [char]6 + ("$([char]0)" * 18)) 
        (dir $zipfilename).IsReadOnly = $false     
    } 
    
    $shellApplication = new-object -com shell.application 
    $zipPackage = $shellApplication.NameSpace($zipfilename) 
    
    foreach ($file in $input) {  
        $zipPackage.CopyHere($file.FullName) 
        Start-sleep -milliseconds 500 
    } 
} 

# Program Start 
Clear-Host 

# Create zip file if it doesn't exist already 
if (Test-Path ("$ziplocation\$computer netstat archive.zip")) {} else { new-zip "$ziplocation\$computer netstat archive.zip" } 

# Loop until you cancel 
do { 
    # Set dynamic time variables 
    $now = get-date 
    $year = $now.Year 
    $month = $now.Month 
    $day = $now.Day 
    $hour = $now.Hour 
    $minute = $now.Minute 
    if ($minute -le 9) { $minute = "0$minute" } 
    
    # Create and archive port usage information 
    netstat -ano > "$ziplocation\netstat $computer $year-$month-$day $hour$minute IPs.txt" 
    dir $ziplocation"\*.txt" | add-zip "$ziplocation\$computer netstat archive.zip" 
    del $ziplocation"\netstat*.txt" 
    
    netstat -a > "$ziplocation\netstat $computer $year-$month-$day $hour$minute Named.txt" 
    dir $ziplocation"\*.txt" | add-zip "$ziplocation\$computer netstat archive.zip" 
    del $ziplocation"\netstat*.txt" 
    
    $now = $now.AddSeconds($interval) 
    $counter = $counter + 1 
    Write-Host "_________________________________________________________" -ForegroundColor Green 
    Write-Host "Data sets collected : $counter" 
    Write-Host "Next run            : $now" 
    Write-Host "`nPausing $interval seconds... Press CTRL-C to stop the script" -ForegroundColor Blue 
    Start-Sleep -s $interval 
} until (1 -eq 0)
