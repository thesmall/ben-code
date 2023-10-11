<#
    .SYNOPSIS
        Search PowerShell Transcript for a specified text pattern, given a specified folder.

    .DESCRIPTION
        Search-PowerShellTranscript searched files in a specified folder for a specified text pattern. 

    .EXAMPLE
        PS> Search-PowerShellTranscript -Path C:\working\pstranscripts\ -Pattern "psreadline" | Format-List 

        File    : C:\working\pstranscripts\USER_COMP_Console_2022.12.24.txt
        Matches : {    + CategoryInfo          : InvalidOperation: (PSReadline:String) [Write-Error], WriteErrorException,     + CategoryInfo          : InvalidOperation: (PSReadline:String) [Write-Error], WriteErrorException, + Get-Module   
                psreadline |Update-Module -Force, + Get-Module psreadline |Update-Module -Force…}

        File    : C:\working\pstranscripts\USER_COMP_Console_2023.01.24.txt
        Matches : {    + CategoryInfo          : ObjectNotFound: (Get-PSReadLineKeyHandlerfunction:String) [], CommandNotFoundException,     + CategoryInfo          : ObjectNotFound: (Get-PSReadLineKeyHandlerfunction:String) [], 
                CommandNotFoundException,     + CategoryInfo          : ObjectNotFound: (Get-PSReadLineOptionfunction:String) [], CommandNotFoundException,     + CategoryInfo          : ObjectNotFound:
                (Get-PSReadLineOptionfunction:String) [], CommandNotFoundException…}

        File    : C:\working\pstranscripts\USER_COMP_Console_2018.07.27.txt
        Matches : {    powershellUtils | PSReadline}] [[-Passthru]]  [<CommonParameters>],     powershellUtils | PSReadline}] [[-Passthru]]  [<CommonParameters>],     powershellUtils | PSReadline}] [[-Passthru]]  [<CommonParameters>],     
                powershellUtils | PSReadline}] [[-Passthru]]  [<CommonParameters>]…}

        File    : C:\working\pstranscripts\USER_COMP_Console_2018.07.30.txt
        Matches : {"JargonFilesMOTD,Microsoft.PowerShell.Host,Microsoft.PowerShell.Management,Microsoft.PowerShell.Utility,posh-git,powershellUtils,PSReadline", 
                "Microsoft.PowerShell.Host,Microsoft.PowerShell.Management,Microsoft.PowerShell.Utility,posh-git,powershellUtils,PSReadline" specified by the, TerminatingError(Reset-Module): "Cannot validate argument on parameter 'Name'.   
                The argument "cj" does not belong to the set "JargonFilesMOTD,Microsoft.PowerShell.Host,Microsoft.PowerShell.Management,Microsoft.PowerShell.Utility,posh-git,powershellUtils,PSReadline" specified by the ValidateSet
                attribute. Supply an argument that is in the set and then try the command again.", TerminatingError(Reset-Module): "Cannot validate argument on parameter 'Name'. The argument "JargonFilesMOTD" does not belong to the set     
                "Microsoft.PowerShell.Host,Microsoft.PowerShell.Management,Microsoft.PowerShell.Utility,posh-git,powershellUtils,PSReadline" specified by the ValidateSet attribute. Supply an argument that is in the set and then try the     
                command again."}
#>
function Search-PowerShellTranscript {
    [CmdletBinding()]
    param(
        [String] $Path,

        [String] $Pattern
    )

    begin {

    }

    process {
        $transcriptFiles = Get-ChildItem $Path

        foreach ($t in $transcriptFiles) {
            $matchingContent = Get-Content $t.FullName | 
                Select-String -SimpleMatch $Pattern | 
                    Sort-Object

            if ($matchingContent) {
                [pscustomobject] @{
                    File    = $t
                    Matches = @($matchingContent)
                }
            }
        }
    }

    end {

    }
}

New-Alias -Name 'Search-PSTranscript' -Value 'Search-PowerShellTranscript' -ErrorAction 'SilentlyContinue'