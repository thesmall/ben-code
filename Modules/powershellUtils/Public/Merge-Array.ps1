function Merge-Array {
<#
.Synopsis
    Merge two arrays into a single array, whose elements alternate.

.DESCRIPTION
    This function consumes two arrays of any length, and returns a single array whose elements alternate between the two arrays.

.EXAMPLE
    PS> Merge-Array -ArrayOne (1,2,3) -ArrayTwo (4,5,6)
    
    1
    4
    2
    5
    3
    6

.EXAMPLE
    PS> Merge-Array @("10.0.0.100", "10.0.0.101", "10.1.0.100", "10.1.0.101") @("10.100.0.100", "10.100.0.101", "10.101.0.100")

    10.0.0.100
    10.100.0.100
    10.0.0.101
    10.100.0.101
    10.1.0.100
    10.101.0.100
    10.1.0.101
#>
    param(
        $ArrayOne,

        $ArrayTwo
    )

    $counter = 0
    
    $combinedArray = do {
        @($ArrayOne[$counter], $ArrayTwo[$counter])
        $counter++
    }
    until (($counter -gt $ArrayOne.Length) -and ( $counter -gt $ArrayTwo.Length))

    return $combinedArray
}

New-Alias -Name 'Interpolate-Array' -Value 'Merge-Array'