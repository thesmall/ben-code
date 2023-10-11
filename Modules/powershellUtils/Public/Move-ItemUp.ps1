function Move-ItemUp {
<#
    .SYNOPSIS
        Moves items in a specified path, matching an extension, up one directory level.
    
    .DESCRIPTION
        Move-ItemUp moves files in a specified directory, matching a specified extension up one directory level.

    .EXAMPLE
        PS> Move-ItemUp -Path E:\ExamplePath\TVShow.S01.1080p\Subs\

        This function does not produce any output.

#>
    [CmdletBinding()]
    [OutputType()]
    param(
        [String] $Path,

        [String] $ExtensionFilter
    )

    begin {

    }

    process {
        $items = Get-ChildItem $Path -Recurse -File -Filter $ExtensionFilter

        foreach ($item in $items) {
            $newPath = $item.FullName | Split-Path -Parent | Split-Path -Parent

            Move-item $item.FullName -Destination $newPath
        }
    }

    end {

    }
}