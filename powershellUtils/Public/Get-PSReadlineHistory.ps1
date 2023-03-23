<#
    .SYNOPSIS
        Returns the contents of the PSReadLine History for the current user.

    .DESCRIPTION
        Get-PSReadLineHistory returns the contents of the current user's HistorySavePath.

    .EXAMPLE
        PS> Get-PSReadLineHistory

        ...
        git push
        sfc /scannow
        ii C:\Windows\Logs\CBS\CBS.log
        cls
        Get-Module psreadline
        Get-Module psreadline |Update-Module -Force
        Find-Module psreadline
        Find-Module psreadline |Install-Module -Scope AllUsers
        Remove-Module psreadline
        Get-Module -ListAvailable
        Get-Module
        Get-Module posh-git
        Find-Module posh-git
        Find-Module posh-git | Update-Module
        Uninstall-Module posh-git
        Uninstall-Module posh-git -Force
        Get-Module posh-git
        ...
#>
function Get-PSReadLineHistory {
    [CmdletBinding()]
    param()

    Get-PSReadLineOption | 
        Select-Object -ExpandProperty 'HistorySavePath' | 
            Get-Item | Get-Content
}

New-Alias -Name 'psh'       -Value "Get-PSReadlineHistory" -ErrorAction 'SilentlyContinue'
New-Alias -Name 'pshistory' -Value "Get-PSReadlineHistory" -ErrorAction 'SilentlyContinue'