<#
.Synopsis
    Copies all claim rules from one RPT to another
.DESCRIPTION
    Copies all claim rules from one RPT to another
.EXAMPLE
    Copy-ADFSClaimRules -SourceRelyingPartyTrustName "Office 365" -DestinationRelyingPartyTrustName "Token testing website - Marius"
#>
function Copy-ADFSClaimRules {
    [CmdletBinding()]
    Param (
        # Param1 help description
        [Parameter(Mandatory=$true,
            ValueFromPipeline=$false,
            Position=0)]
        [string] $SourceRelyingPartyTrustName,

        [Parameter(Mandatory=$true,
            ValueFromPipeline=$false,
            Position=0)]
        [string] $DestinationRelyingPartyTrustName
    )

    Begin {
    }
    Process {
        $SourceRPT = Get-AdfsRelyingPartyTrust -Name $SourceRelyingPartyTrustName
        $DestinationRPT = Get-AdfsRelyingPartyTrust -Name $DestinationRelyingPartyTrustName

        if(!$SourceRPT) {
            Write-Error "Could not find $SourceRelyingPartyTrustName"
            return;
        } elseif(!$DestinationRPT) {
            Write-Error "Could not find $DestinationRelyingPartyTrustName"
            return;
        }

        Set-AdfsRelyingPartyTrust -TargetRelyingParty $DestinationRPT -IssuanceTransformRules $SourceRPT.IssuanceTransformRules -IssuanceAuthorizationRules $SourceRPT.IssuanceAuthorizationRules -DelegationAuthorizationRules $SourceRpT.DelegationAuthorizationRules
    }
    End {
    }
}