function Import-GameData {
    [CmdletBinding()]
    param(
        [String] $Path
    )

    return $(Get-Content -Path $Path | ConvertFrom-Json)
}