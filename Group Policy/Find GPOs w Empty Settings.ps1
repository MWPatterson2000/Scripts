Get-GPO -all | %{
$count = $null
$name = $_.displayname
$gpo = Get-GPOReport -Name $name -ReportType html
$count = ([string]$gpo | find  "No settings defined.").count
if($count -eq 2) {
[array]$list += $name
}
} 