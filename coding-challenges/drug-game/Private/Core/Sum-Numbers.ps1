function Sum-Numbers {
    #Sums N numbers together.
    [CmdletBinding()]
    param(
        [Int[]] $Numbers
    )


    [Int] $sum = 0
    foreach ($n in $Numbers) {
        $sum += $n
    }

    return $sum
}