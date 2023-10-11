function Write-GameInformation {
    [CmdletBinding()]
    param(
        [String] $City,

        [String] $Difficulty,

        [Int] $Cash,

        [Int] $Bank,

        [Int] $Debt,

        [Int] $Health,

        [Int] $Day,

        [Int] $TotalDays,

        $Drugs
    )

    begin {
        Write-Debug "IN: Write-GameInformation"

        $formattedCash = Format-MoneyNumber -Number $cash
        $formattedBank = Format-MoneyNumber -Number $bank
        $formattedDebt = Format-MoneyNumber -Number $debt
        $separator = '------------------------------------------------------'
        $cityBanner = @"
$separator
City: $City
Day: $Day / $TotalDays
Difficulty: $Difficulty
$separator
"@
    }

    process {
        Write-Host $cityBanner

        Write-Host -Object "Cash: " -NoNewLine 
        Write-Host -ForegroundColor 'Green' -Object "`$$formattedCash"

        Write-Host -Object "Bank: " -NoNewLine 
        Write-Host -ForegroundColor 'Green' -Object "`$$formattedBank"

        Write-Host -Object "Debt: " -NoNewLine 
        Write-Host -ForegroundColor 'Red'   -Object "`$$formattedDebt"

        Write-Host -Object "Health: " -NoNewLine 
        Write-Host -ForegroundColor $(Get-HealthColor -Health $Health) -Object "$Health%"

        Write-Host -Object "Pocket Space: $pocketSpaceConsumed / $pocketSpaceTotal"
        Write-Host $separator
        
        # Make this colorized
        Write-Host -Object $($Drugs | Select-Object 'Chg','Name','Quantity','Price' | Format-Table -AutoSize | Out-String)
    }

    end {

    }
}