$allUsers = @()
$allusers = Get-ADUser -Filter *
$count = 0
foreach ($User in $allusers)
{
    $count++
    #Write-Host $count
    If ($count -eq 200) {
        Write-Host "30 Second Pause"
        Start-Sleep -Seconds 30
        $count = 0
    }
        
}