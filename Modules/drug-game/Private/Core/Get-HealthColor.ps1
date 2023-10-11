function Get-HealthColor {
    #returns a color depending on how "healthy" the player is, given their health (represented as an int between 0 and 100).
    [CmdletBinding()]
    param(
       [Int] $Health
    )

    switch ($true) {
        ($Health -gt 80) {
            return 'Green'
        }
        ($Health -gt 30) {
            return 'Yellow'
        }
        ($Health -gt 0) {
            return 'Red'
        }
    }
}