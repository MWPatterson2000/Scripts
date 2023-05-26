# ==============================================================================================
# 
# 
# NAME: Get-DirectorySize.ps1 
# 
# AUTHOR: Ragnar Harper , Crayon as
# DATE  : 08.04.2009
# 
#		http://blog.crayon.no/blogs/ragnar
# COMMENT: Takes a directory as input, walks recursive through all directories 
#           calculates and displays size for each folder. 
# 			Size displayed in Megabytes.
# ==============================================================================================

function Get-DirectoryInfo($path)
{
	$size=Get-ChildItem $path | Where-Object {$_.PsIsContainer -ne $true} | Measure-Object -Sum Length
	$sizeinmb=$size.sum / 1mb
	$DirectorySize.Add($path.Replace("Microsoft.PowerShell.Core\FileSystem::",""),$sizeinmb)
	foreach($d in (Get-ChildItem $path | Where-Object {$_.PsIsContainer -eq $true}))
	{
		Get-DirectoryInfo($d.PsPath)
	}	
}
$StartDir = $args[0]
$DirectorySize=@{}
Get-DirectoryInfo($StartDir)
$DirectorySize.GetEnumerator() | Sort-Object -property Value

