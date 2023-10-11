# Ref URL https://sdmsoftware.com/powershell/finding-empty-group-policy-objects/

import-module grouppolicy
$gpos = get-gpo -All
foreach ($item in $gpos) {
    if ($item.Computer.DSVersion -eq 0 -and $item.User.DSVersion -eq 0) {
        write-host $item.DisplayName is empty
    }
}