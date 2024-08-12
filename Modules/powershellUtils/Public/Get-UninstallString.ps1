function Get-UninstallString {
    <#
        .SYNOPSIS
            Get uninstall strings for a specified computer.
    
        .DESCRIPTION
            Query a specified computer's registry for uninstall strings.
    
            If no ComputerName is specified, the command queries the current computer.
    
            This command does not perform any filtering or sanitization of captured information, 
            and so it may process registry entries that do not have much information in them.
    
        .EXAMPLE
    
    
        .EXAMPLE
    #>
        [CmdletBinding()]
        param(
            #Specifies the name of a computer to query uninstall strings for. If the parameter is not specified, query the current computer.
            $ComputerName
        )
    
        begin {
            $uninstallLocations = @(
                'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\'
                'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\'
            )
        }
    
        process {
            if ($env:COMPUTERNAME -match $ComputerName) {
                $results = foreach ($location in $uninstallLocations) {
                    $records = Get-ChildItem $location | Get-ItemProperty
    
                    foreach ($r in $records) {
                        [PSCustomObject] @{
                            RegistryKey     = $r.PSChildName
                            DisplayName     = $r.DisplayName
                            DisplayVersion  = $r.DisplayVersion
                            UninstallString = $r.UninstallString
                            Architecture    = $( if ($location -match "WOW6432Node") { "x86" } else { "x64" } ) 
                        }
                    }
                }
    
                $results
            }
            else {
                Invoke-Command -ComputerName $ComputerName -ScriptBlock {
                    $results = foreach ($location in $using:uninstallLocations) {
                        $records = Get-ChildItem $location | Get-ItemProperty
    
                        foreach ($r in $records) {
                            [PSCustomObject] @{
                                RegistryKey     = $r.PSChildName
                                DisplayName     = $r.DisplayName
                                DisplayVersion  = $r.DisplayVersion
                                UninstallString = $r.UninstallString
                                Architecture    = $( if ($location -match "WOW6432Node") { "x86" } else { "x64" } ) 
                            }
                        }
                    }
    
                    $results
                }
            }
            
        }
    
        end {
    
        }
    }