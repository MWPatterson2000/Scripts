function Test-AllDomainController {
    $dcs=(Get-ADDomainController -Filter *).Name
    foreach ($items in $dcs) {
    Test-Connection $items -Count 1}
    }


Test-AllDomainController
