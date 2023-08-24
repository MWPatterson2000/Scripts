# https://sid-500.com/2023/08/22/powershell-search-and-delete-empty-folders/
# Folder empty, then remove them

$path = 'C:\Data'

Get-ChildItem $path -Recurse -Directory | ForEach-Object {
    If ((Get-ChildItem $_.FullName) -eq $null) {
        Remove-Item -Path $_.FullName -Confirm:$false -Verbose
    }
}
