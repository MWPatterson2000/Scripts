# https://4sysops.com/archives/find-orphaned-active-directory-gpos-in-the-sysvol-share-with-powershell/

function Get-OrphanedGPO {
    
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$ForestName
    )
    try {
        ## Find all domains in the forest
        $domains = Get-AdForest -Identity $ForestName | Select-Object -ExpandProperty Domains
        $gpoGuids = @()
        $sysvolGuids = @()
        foreach ($domain in $Domains) {
            $gpoGuids += Get-GPO -All -Domain $domain | Select-Object @{ n='GUID'; e = {$_.Id.ToString()}} | Select-Object -ExpandProperty GUID
            foreach ($guid in $gpoGuids) {
                $polPath = "\\$domain\SYSVOL\$domain\Policies"
                $polFolders = Get-ChildItem $polPath -Exclude 'PolicyDefinitions' | Select-Object -ExpandProperty name
                foreach ($folder in $polFolders) {
                    $sysvolGuids += $folder -replace '{|}'
                }
            }
        }
        Compare-Object -ReferenceObject $sysvolGuids -DifferenceObject $gpoGuids | Select-Object -ExpandProperty InputObject
    } catch {
        $PSCmdlet.ThrowTerminatingError($_)
    }
}
