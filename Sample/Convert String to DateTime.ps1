$timeinfo = '10/9/2017 11:03:12 AM'
$template = 'M/d/yyyy h:mm:ss tt'
[DateTime]::ParseExact($timeinfo, $template, [System.Globalization.CultureInfo]::InvariantCulture)

$timeinfo = '4/11/2020 3:05:08 PM'
$template = 'M/d/yyyy h:mm:ss tt'
[DateTime]::ParseExact($timeinfo, $template, [System.Globalization.CultureInfo]::InvariantCulture)
