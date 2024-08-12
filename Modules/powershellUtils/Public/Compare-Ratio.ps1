function Compare-Ratio {
<#
    .SYNOPSIS
        Given three out of four values of two ratios, solve for the missing value.

    .DESCRIPTION
        Compare-Ratio solves for the missing value when only three of the four values of the ratio are known.

        The missing value can be supplied as any capital or lower case letter.
    .EXAMPLE
        PS> Compare-Ratio -RatioOne 62.4/1000 -RatioTwo  X/730

        62.4 : 1000 = 45.552 : 730

    .EXAMPLE
        PS> Compare-Ratio -RatioOne 62.4/1000 -RatioTwo  X/730 -AsObject

        A    B         C D
        -    -         - -
        62.4 1000 45.552 730

#>
    param(
        [String] $RatioOne = "62.4/1000",

        [String] $RatioTwo = "X/730",

        [Switch] $AsObject
    )

    $A = $RatioOne -split "/" | Select-Object -First 1
    $B = $RatioOne -split "/" | Select-Object -Skip  1 -First 1
    $C = $RatioTwo -split "/" | Select-Object -First 1
    $D = $RatioTwo -split "/" | Select-Object -Skip  1 -First 1

    $returnResults = $true

    switch ($true) {
        ($A -match "[A-Za-z]") {
            $res = [double]$B * ([double]$C/[double]$D)

            $A = $res
        }

        ($B -match "[A-Za-z]") {
            $res = [double]$A * ([double]$D/[double]$C)

            $B = $res
        }

        ($C -match "[A-Za-z]") {
            $res = [double]$D * ([double]$A/[double]$B)

            $C = $Res
        }

        ($D -match "[A-Za-z]") {
            $res = [double]$C * ([double]$B/[double]$A)

            $D = $res
        }

        default {
            $returnResults = $false
        }
    }

    if ($returnResults) {
        if ($AsObject) {
            [pscustomObject] @{
                A = $A
                B = $B
                C = $C
                D = $D
            }
        }
        else {
            "$A : $B = $C : $D"
        }
    }

}