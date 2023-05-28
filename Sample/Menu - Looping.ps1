do {
  [int]$userMenuChoice = 0
  while ( $userMenuChoice -lt 1 -or $userMenuChoice -gt 4) {
    Write-Host "1. Menu Option 1"
    Write-Host "2. Menu Option 2"
    Write-Host "3. Menu Option 3"
    Write-Host "4. Quit and Exit"

    [int]$userMenuChoice = Read-Host "Please choose an option"

    switch ($userMenuChoice) {
      1{firstFunction}
      2{Write-Host "You chose option 2"}
      3{Write-Host "You chose option 3"}
      default {Write-Host "Nothing selected"}
    }
  }
} while ( $userMenuChoice -ne 4 )