<######################################################################
Multi Layered Menu Demonstration

v1.0    9th August 2012:    A script is born
v1.1    15th August 2012:    Cut the Demo Version
v1.2	3rd December 2014:	Corrected level 2 menu checking
v1.3 6th March 2017: Corrected for PowerShell 5

Written By Paul Westlake

All Code provided as is and used at your own risk.
######################################################################>
$xAppName = "MenuDemo"
[BOOLEAN]$global:xExitSession=$false
function LoadMenuSystem(){
	[INT]$xMenu1 = 0
	[INT]$xMenu2 = 0
	[BOOLEAN]$xValidSelection = $false
	while ( $xMenu1 -lt 1 -or $xMenu1 -gt 4 ){
		CLS
		#… Present the Menu Options
		Write-Host "`n`tMulti Layered Menu Demonstration - Admin Processes - Version 1.3`n" -ForegroundColor Magenta
		Write-Host "`t`tPlease select the admin area you require`n" -Fore Cyan
		Write-Host "`t`t`t1. User Tasks" -Fore Cyan
		Write-Host "`t`t`t2. Group Tasks" -Fore Cyan
		Write-Host "`t`t`t3. Shared Mailbox Tasks" -Fore Cyan
		Write-Host "`t`t`t4. Quit and exit`n" -Fore Cyan
		#… Retrieve the response from the user
		[int]$xMenu1 = Read-Host "`t`tEnter Menu Option Number"
		if( $xMenu1 -lt 1 -or $xMenu1 -gt 4 ){
			Write-Host "`tPlease select one of the options available.`n" -Fore Red;start-Sleep -Seconds 1
		}
	}
	Switch ($xMenu1){    #… User has selected a valid entry.. load next menu
		1 {
			while ( $xMenu2 -lt 1 -or $xMenu2 -gt 4 ){
				CLS
				# Present the Menu Options
				Write-Host "`n`tMulti Layered Menu Demonstration - Admin Processes - Version 1.3`n" -Fore Magenta
				Write-Host "`t`tPlease select the User administration task you require`n" -Fore Cyan
				Write-Host "`t`t`t1. Create New User" -Fore Cyan
				Write-Host "`t`t`t2. Delete Existing User" -Fore Cyan
				Write-Host "`t`t`t3. Rename Existing User" -Fore Cyan
				Write-Host "`t`t`t4. Go to Main Menu`n" -Fore Cyan
				[int]$xMenu2 = Read-Host "`t`tEnter Menu Option Number"
				if( $xMenu2 -lt 1 -or $xMenu2 -gt 4 ){
					Write-Host "`tPlease select one of the options available.`n" -Fore Red;start-Sleep -Seconds 1
				}
			}
			Switch ($xMenu2){
				1{ Write-Host "`n`tYou Selected Option 1 - Put your Function or Action Here`n" -Fore Yellow; start-Sleep -Seconds 3 }
				2{ Write-Host "`n`tYou Selected Option 2 - Put your Function or Action Here`n" -Fore Yellow; start-Sleep -Seconds 3 }
				3{ Write-Host "`n`tYou Selected Option 3 - Put your Function or Action Here`n" -Fore Yellow; start-Sleep -Seconds 3 }
				default { Write-Host "`n`tYou Selected Option 4 - Quit the Administration Tasks`n" -Fore Yellow; break}
			}
		}
		2 {
			while ( $xMenu2 -lt 1 -or $xMenu2 -gt 4 ){
				CLS
				# Present the Menu Options
				Write-Host "`n`tMulti Layered Menu Demonstration = Admin Processes - Version 1.3`n" -Fore Magenta
				Write-Host "`t`tPlease select the Group administration task you require`n" -Fore Cyan
				Write-Host "`t`t`t1. Create a New Mail Group" -Fore Cyan
				Write-Host "`t`t`t2. Add Member to an existing Mail Group" -Fore Cyan
				Write-Host "`t`t`t3. Remove Member from an existing Mail Group" -Fore Cyan
				Write-Host "`t`t`t4. Go to Main Menu`n" -Fore Cyan
				[int]$xMenu2 = Read-Host "`t`tEnter Menu Option Number"
			}
			if( $xMenu2 -lt 1 -or $xMenu2 -gt 4 ){
				Write-Host "`tPlease select one of the options available.`n" -Fore Red;start-Sleep -Seconds 1
			}
			Switch ($xMenu2){
				1{ Write-Host "`n`tYou Selected Option 1 - Put your Function or Action Here`n" -Fore Yellow;start-Sleep -Seconds 3 }
				2{ Write-Host "`n`tYou Selected Option 2 - Put your Function or Action Here`n" -Fore Yellow;start-Sleep -Seconds 3 }
				3{ Write-Host "`n`tYou Selected Option 3 - Put your Function or Action Here`n" -Fore Yellow;start-Sleep -Seconds 3 }
				default { Write-Host "`n`tYou Selected Option 4 - Go to Main Menu`n" -Fore Yellow; break }
			}
		}
		3 {
			while ( $xMenu2 -lt 1 -or $xMenu2 -gt 4 ){
				CLS
				# Present the Menu Options
				Write-Host "`n`tMulti Layered Menu Demonstration - Admin Processes - Version 1.1`n" -Fore Magenta
				Write-Host "`t`tPlease select the Shared Mailbox administration task you require`n" -Fore Cyan
				Write-Host "`t`t`t1. Create a New Shared Mailbox" -Fore Cyan
				Write-Host "`t`t`t2. Delete a Shared Mailbox" -Fore Cyan
				Write-Host "`t`t`t3. Add Editor to an existing Mailbox" -Fore Cyan
				Write-Host "`t`t`t4. Go to Main Menu`n" -Fore Cyan
				[int]$xMenu2 = Read-Host "`t`tEnter Menu Option Number"
				if( $xMenu2 -lt 1 -or $xMenu2 -gt 4 ){
					Write-Host "`tPlease select one of the options available.`n" -Fore Red;start-Sleep -Seconds 1
				}
			}
			Switch ( $xMenu2 ){
				1{ Write-Host "`n`tYou Selected Option 1 - Put your Function or Action Here`n" -Fore Yellow;start-Sleep -Seconds 3 }
				2{ Write-Host "`n`tYou Selected Option 2 - Put your Function or Action Here`n" -Fore Yellow;start-Sleep -Seconds 3 }
				3{ Write-Host "`n`tYou Selected Option 3 - Put your Function or Action Here`n" -Fore Yellow;start-Sleep -Seconds 3 }
				default { Write-Host "`n`tYou Selected Option 4 - Go to Main Menu`n" -Fore Yellow; break }
			}
		}
		default { $global:xExitSession=$true;break }
	}
}
LoadMenuSystem
If ($xExitSession){
	exit-pssession #… User quit & Exit
}else{
	.\MenuDemo.ps1 #… Loop the function
}