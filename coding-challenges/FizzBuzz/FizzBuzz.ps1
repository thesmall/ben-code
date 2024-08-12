function FizzBuzz {
    [CmdletBinding()]
    param(
        [Parameter(
            ValueFromPipeline = $true
        )]
        [Int] $Number
    )

    process {
        if ( (($Number % 3) -eq 0)  -and (($Number % 5) -eq 0) ) {
            $result = "FizzBuzz"
        }
        elseif (($Number % 3) -eq 0) {
            $result = "Fizz"
        }
        elseif (($Number % 5) -eq 0) {
            $result = "Buzz"
        }
        else {
            $result = "N/A"
        }

        [pscustomobject] @{
            Number = $Number
            Result = $result
        }
    }
}