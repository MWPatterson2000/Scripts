$services = Get-Service
$menu = @{}
for ($i=1;$i -le $services.count; $i++) 
{ Write-Host "$i. $($services[$i-1].name),$($services[$i-1].status)" 
$menu.Add($i,($services[$i-1].name))}

[int]$ans = Read-Host 'Enter selection'
$selection = $menu.Item($ans) ; Get-Service $selection