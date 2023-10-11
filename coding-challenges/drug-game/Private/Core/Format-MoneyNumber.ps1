function Format-MoneyNumber {
    #Formats a number with culture separators
    [CmdletBinding()]
    param(
        [Int] $Number
    )

    return $("{0:N}" -f $Number)
}