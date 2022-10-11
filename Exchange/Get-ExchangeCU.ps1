function Get-ExchangeCU() {
    Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" | `
     Where-Object DisplayName -Match "Microsoft Exchange Server \d{4}" | `
     Select-Object -ExpandProperty DisplayName
}
Get-ExchangeCU