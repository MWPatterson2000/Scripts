#Install-Module -Name QRCodeGenerator -RequiredVersion 2.4.1

$SSID = 'MyWlan'
$WiFipassword = 'password'
$FilePath = "$home\desktop\wifi.png"
New-QRCodeWifiAccess -SSID $SSID -Password $WiFipassword -Width 10 -OutPath $FilePath