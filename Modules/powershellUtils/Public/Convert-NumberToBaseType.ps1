function Convert-NumberToBaseType {
<#
    .SYNOPSIS
        Convert a provided number into other bases, given a base type.

    .DESCRIPTION
        Convert-NumberToBaseType consumes and number represented in base 2, 8, 10 or 16 and a base type, 
        and converts the provided integer into the remaining bases.

    .EXAMPLE
        PS> Convert-NumberToBaseType -Number 1001 -BaseType 16

        Binary        Octal Decimal Hexadecimal
        ------        ----- ------- -----------
        1000000000001 10001 4097    1001
    
    .EXAMPLE
        PS> Convert-NumberToBaseType -Number deadbeef -BaseType 16

        Binary                           Octal       Decimal    Hexadecimal
        ------                           -----       -------    -----------
        11011110101011011011111011101111 33653337357 3735928559 deadbeef
#>
    param(
        [Alias('Value','Num','Int')]
        $Number,

        [ValidateSet(2, 8, 10, 16)]
        [Alias('Base')]
        [Int] $BaseType
    )

    begin {}

    process {
        switch ($BaseType) {
            2 {
                $bin = $Number
                $dec = [Convert]::ToInt64($Number, 2)
                $oct = [Convert]::ToString($dec,   8)
                $hex = [Convert]::ToString($dec,  16)
            }

            8 {
                $oct = $Number
                $dec = [Convert]::ToInt64($Number, 8)
                $bin = [Convert]::ToString($dec,   2)
                $hex = [Convert]::ToString($dec,  16)
            }

            10 {
                $dec = $Number
                $bin = [Convert]::ToString($dec,   2)
                $oct = [Convert]::ToString($dec,   8)
                $hex = [Convert]::ToString($dec,  16)
            }

            16 {
                $hex = $Number
                $dec = [Convert]::ToInt64($Number, 16)
                $bin = [Convert]::ToString($dec,    2)
                $oct = [Convert]::ToString($dec,    8)
            }
        }

        [pscustomobject] @{
            Binary      = $([String] $bin)
            Octal       = $([String] $oct)
            Decimal     = $([String] $dec)
            Hexadecimal = $([String] $hex)
        }
    }

    end {}
}