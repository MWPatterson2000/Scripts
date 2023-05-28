#Hide PowerShell Console
$Script:showWindowAsync = Add-Type -MemberDefinition @"
[DllImport("user32.dll")]
public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);
"@ -Name "Win32ShowWindowAsync" -Namespace Win32Functions -PassThru
Function Show-Powershell()
{
$null = $showWindowAsync::ShowWindowAsync((Get-Process -Id $pid).MainWindowHandle, 10)
}
Function Hide-Powershell()
{
$null = $showWindowAsync::ShowWindowAsync((Get-Process -Id $pid).MainWindowHandle, 2)
}

Hide-PowerShell