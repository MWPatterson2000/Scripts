# https://github.com/HarriJaakkonen/Scripts/blob/main/Get-MyPublicIPV6.ps1

# Get public IPV6 from IP Info and paste to clipboard

$result = (Invoke-RestMethod https://ident.me)+"/32"  | Set-Clipboard

# Add forms assembly

Add-Type -AssemblyName System.Windows.Forms
$global:balmsg = New-Object System.Windows.Forms.NotifyIcon

# Get process

$path = (Get-Process -id $pid).Path

# Variables for the balloon tip

$balmsg.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($path)
$balmsg.BalloonTipIcon = [System.Windows.Forms.ToolTipIcon]::Warning
$balmsg.BalloonTipText = 'Your Public IPv6 copied to clipboard'
$balmsg.BalloonTipTitle = "Attention $Env:USERNAME"
$balmsg.Visible = $true
$balmsg.ShowBalloonTip(50000)