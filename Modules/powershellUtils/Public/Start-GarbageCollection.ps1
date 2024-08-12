function Start-GarbageCollection {
<#
    .SYNOPSIS
        Starts the garbage collection process in the current session.

    .DESCRIPTION
        Start-GarbageCollection is a wrapper function that starts the .Net garbage collection process for the current PowerShell session.

        The garbage collection process attempts reclaim unused memory.

    .EXAMPLE
        PS> Start-GarbageCollection

        This function does not produce any output.
#>
    [CmdletBinding()]
    param()

    [System.GC]::Collect()
}