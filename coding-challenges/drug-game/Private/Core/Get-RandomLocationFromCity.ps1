function Get-RandomLocationFromCity {
    #Return a random location, given a list of locations, but do not return the same location that the player is currently in.
    [CmdletBinding()]
    param(
        $Locations,

        $CurrentLocation
    )


    do {
        $newLocation = $Locations | Get-Random
    }
    until ($newLocation -ne $CurrentLocation)

    return $newLocation
}