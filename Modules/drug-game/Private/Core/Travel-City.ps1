function Travel-City {
    [CmdletBinding()]
    param()
    #The following things MUST happen when traveling to another city:
    <#
        * Day increments.
        * Drug prices change.
        * City changes.
        * Debt increases (if the player has any debt).
        * Time until a loan is due decreases.
        * Generate Bank Interest (if the player has money in the bank).
    #>

    #The following things CAN happen when traveling to another city:
    <#
        * Drop some quantity of drugs.
        * Get mugged for some quantity of cach on hand (and take random damage).
        * If damaged, potentially get an infection.
        * If infected, take damage.
        * Buy additional pocket space (prompt?).
        * Old Lady Rant (sometimes useful).
        * Get Chased by police.
        * A loanshark may return from "vacation".
        * Get beaten up by the loanshark if the debt is due (past grace period).
    #>

    Write-Debug "IN: Travel-City"

    #Increment Day
    $global:day++

    #Get random drug prices
    $global:drugTable = foreach ($drug in $global:drugTable) {
        $randomDrugPriceParam = @{
            DrugName              = $drug.Name
            PreviousPrice         = $drug.Price
            PreviousQuantity      = $drug.Quantity
            PreviousQuantityRaw   = $drug.QuantityRaw
            PreviousPurchasePrice = $drug.PurchasePrice
        }

        Get-RandomDrugPrice @randomDrugPriceParam
    }

    #Change City
    $global:currentLocation = Get-RandomLocationFromCity `
        -Locations $global:cityInformation.Locations `
        -CurrentLocation $global:currentLocation

    #Increase Debt
    foreach ($loan in $global:allLoans) {
        Update-Loan -Loan $loan
    }
    $global:allDebts = Sum-Numbers -Numbers $($allLoans | Where-Object 'PlayerHasLoan' -eq $true).Amount

    #Generate Bank Interest
    if ($global:bank -gt 0) {
        $global:bank = $global:bank * $(1 + $global:bankInterestRate)
    }

    #Write Game Information
    $writeGameInfo = @{
        City       = "$global:currentLocation, $global:cityName, $($global:cityInformation.Country)"
        Difficulty = $Difficulty
        Cash       = $global:cash
        Bank       = $global:bank
        Debt       = $global:allDebts
        Health     = $global:health
        Day        = $global:day
        TotalDays  = $GameLength
        Drugs      = $global:drugTable
    }
    
    Write-GameInformation @writeGameInfo
}