function Test-Equals {
<#
    .SYNOPSIS
        Tests for equality across all specified values.
    
    .DESCRIPTION
        Test-Equals consumes an array of values and returns true if all values are equal.
    
    .EXAMPLE
        PS> Test-Equals @(1,1,1,1,1,1,1,1,1,1,1,1,1)

        True

    .EXAMPLE
        PS> Test-Equals @(1,2,1,1,1,1,1,1,1)

        False

    .EXAMPLE
        PS> Test-Equals @("String", "string") -CaseSensitive

        False
#>
    param(
        $InputObject,

        [Switch] $CaseSensitive
    )

    $i = -1
    do {
        if ($CaseSensitive.IsPresent) {
            if ($InputObject[$i] -cne $InputObject[$i+1]) {
                return $false
            }
        }
        else {
            if ($InputObject[$i] -ine $InputObject[$i+1]) {
                return $false
            }
        }
        
        $i++
    }
    until ($i -eq $($InputObject.Count - 1))

    return $true
}