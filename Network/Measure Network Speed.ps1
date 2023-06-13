# Source URL: https://sid-500.com/2023/06/13/measure-link-speed-bandwith-with-powershell/

# Measure Link Speed

$File = 'https://patrick6649.files.wordpress.com/2022/08/lektion18.mp4'
$Location = Join-Path -Path $Home -ChildPath "Downloads\lektion18.mp4"

$time = Measure-Command {
    Start-BitsTransfer -Source $File -Destination $Location
} | Select-Object -ExpandProperty TotalSeconds

$Speed = (0.889 / $time) * 8

Write-Output "Network Speed: $([math]::Round($Speed,2)) Mbit/sec"