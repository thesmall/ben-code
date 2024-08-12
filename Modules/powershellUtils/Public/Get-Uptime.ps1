function Get-Uptime {
<#
    .SYNOPSIS
        Returns the uptime of a windows computer.

    .DESCRIPTION
        Get-Uptime returns the uptime, boot date and short/FQDN values of a provided windows computername.

    .EXAMPLE
        PS> Get-Uptime

        ComputerName FullyQualifiedDomainName BootTime           Uptime
        ------------ ------------------------ --------           ------
        BEAST        BEAST                    4/25/2024 18:55:07 01:35:55.7340000

#>
    param(
        [Parameter(
            Position = 0,
            Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [String] $ComputerName = $env:COMPUTERNAME,

        [PSCredential] $Credential = [System.Management.Automation.PSCredential]::Empty
    )

    begin {

    }

    process {
        try { 
            $dnsName  = [System.Net.DNS]::GetHostEntry($ComputerName) 
            $os       = $(Get-WmiObject 'win32_operatingsystem' -ComputerName $ComputerName -ErrorAction 'Stop' -Credential $Credential)
            $bootTime = $os.ConvertToDateTime($os.LastBootUpTime) 
            $uptime   = $os.ConvertToDateTime($os.LocalDateTime) - $bootTime

            [pscustomobject] @{
                ComputerName             = $ComputerName
                FullyQualifiedDomainName = $dnsName.HostName
                BootTime                 = $bootTime
                Uptime                   = $uptime
            }
        }
        catch {
            Write-Output "$ComputerName $($_.Exception.Message)" 
        }
    }

    end {

    }
}