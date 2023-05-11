# https://github.com/HarriJaakkonen/Scripts/blob/main/Get-InfoFromPublicIP.ps1

# Enter public IP and get city as JSON from ip-api.com

$ip = read-host "Enter the public ip"

$result = (Invoke-WebRequest http://ip-api.com/json/$ip | ConvertFrom-Json).city

# Add forms assembly

Add-Type -AssemblyName System.Windows.Forms
$global:balmsg = New-Object System.Windows.Forms.NotifyIcon

# Get process

$path = (Get-Process -id $pid).Path

# Variables for the balloon tip

$balmsg.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
$balmsg.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Warning
$balmsg.BalloonTipText = $result
$balmsg.BalloonTipTitle = "The IP is located in:"
$balmsg.Visible = $true
$balmsg.ShowBalloonTip(100000)