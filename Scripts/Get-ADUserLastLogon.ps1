function Get-ADUserLastLogon {
    [CmdletBinding()]
    
    param(
        [Parameter(
            ValueFromPipeline = $true
        )]
        $Identity
    )

    begin {
        $dcs = Get-ADDomain | Select-Object -ExpandProperty 'ReplicaDirectoryServers'
    }

    process {
        $lastLogons = foreach ($dc in $dcs) {
            $result = Get-ADUser $Identity -Server $dc -Properties 'LastLogon' | 
                Select-Object 'SAMAccountName', 'LastLogon'

            [PSCustomObject] @{
                SAMAccountName   = $Identity
                LastLogon        = $result.LastLogon
                DomainController = $dc
            }
        }

        $lastLogonsConverted = $lastLogons | ForEach-Object { 
            [PSCustomObject] @{
                Identity         = $Identity
                LastLogon        = [DateTime]::FromFileTime($_.LastLogon)
                DomainController = $_.DomainController
            }
        }

        Write-Output $($lastLogonsConverted | Sort-Object 'LastLogon' -Descending | Select-Object -First 1)
    }

    end {

    }
}