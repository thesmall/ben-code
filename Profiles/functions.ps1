function Format-DiskSize {
    [cmdletbinding()]
    param (
        [Long] $Value
    )
    if ($Value -ge 1TB)     {[string]::Format("{0:0.00} TB", $Value / 1TB)}
    elseif ($Value -ge 1GB) {[string]::Format("{0:0.00} GB", $Value / 1GB)}
    elseif ($Value -ge 1MB) {[string]::Format("{0:0.00} MB", $Value / 1MB)}
    elseif ($Value -ge 1KB) {[string]::Format("{0:0.00} KB", $Value / 1KB)}
    elseif ($Value -gt 0)   {[string]::Format("{0:0.00} Bytes", $Value)}
    else {""}
}

function Tail-LogFile {
    param(
        [String] $Path
    )

    if (Test-Path $Path) {
        Get-Content -Path $Path -Tail 1 -Wait
    }
    else {
        Write-Error "Unable to Get-Content from $Path. Does it exist?" -Category 'InvalidArgument'
    }
}

function Search-PSTranscript {
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
                    File = $t
                    Matches = @($matchingContent)
                }
            }
        }
    }

    end {

    }
}

#Can cd to the previous directory by typing 'cd -'
Remove-Item Alias:cd -ErrorAction 'SilentlyContinue'
function cd {
    if ($args[0] -eq '-') {
        $pwd = $oldpwd
    }
    else {
        $pwd = $args[0]
    }

    $tmp = Get-Location

    if ($pwd) {
        Set-Location $pwd
    }

    Set-Variable -Name 'oldpwd' -Value $tmp -Scope 'Global'
}