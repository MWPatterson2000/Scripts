$gpos = get-gpo -All
foreach ($item in $gpos)
{
      [xml]$report = Get-GPOReport -Name $gpo -ReportType Xml
      if ($item.Computer.DSVersion -eq 0 -and $item.User.DSVersion -eq 0)
     {
    #rename the gpo
    $gpo.DisplayName = "_Disabled" + $gpo.DisplayName
    $gpo.GpoStatus = "AllSettingsDisabled"
      }
}