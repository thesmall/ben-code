function Buy-Drug {
    [CmdletBinding()]
    param(
        [String] $Drug,

        [Int] $Quantity,

        $DrugTable = $global:drugTable,

        [Int] $AvailableCash = $global:cash
    )
    #The following things happen when purchasing drugs:
    <#
        1. Available cash decreases.
        2. Pocket space gets consumed.
        3. Increment quantity of drug in display
    #>

    Write-Verbose "IN: Buy-Drug"

    $canPurchase = $true

    #Calculate cost of drug
    $DrugObj = $DrugTable | Where-Object 'Name' -eq $Drug
    $drugPrice = $DrugObj.Price

    $costOfDrug = $drugPrice * $Quantity


    #Run through the checks to purchase Drugs

    #Is the player trying to purchase more units of drugs than they are able to hold in their pockets?
    <#
    if ($Quantity -gt $global:pocketSpaceTotal) {
        $canPurchase = $false
        $notEnoughPocketSpace = $true
    }
    
    #Does the player have enough money to purchase the quantity of drugs they are attempting to purchase?
    if ($costOfDrug -gt $AvailableCash) {
        $canPurchase = $false
        $notEnoughMoney = $true
    }

    #Is the player trying to purchase units of drug, that when combined with how many units they currently 
    #hold, exceeds the total number of units they can hold in their pockets?
    if (($Quantity + $global:pocketSpaceConsumed) -gt $global:pocketSpaceTotal) {
        $canPurchase = $false
        $notEnoughPocketSpace = $true
    }
    #>
    #if ($canPurchase) {
        Write-Verbose "Can purchase: $Drug | $Quantity @ $drugPrice"
        #Subtract cost of drugs from cash
        $global:cash = $AvailableCash - $costOfDrug
        
        #Add the quantity of drugs to the current amount of pocket space consumed 
        $global:pocketSpaceConsumed = $global:pocketSpaceConsumed + $Quantity

        #Update Quantity Values in DrugTable
        $previousQuantity = $($global:drugTable | Where-Object Name -eq $Drug).QuantityRaw
        $($global:drugTable | Where-Object Name -eq $Drug).QuantityRaw += $Quantity

        #Algorithm:
        # ROUND( ((CurrentPrice * Quantity) + (PreviousPrice * PreviousQuantity) / (Quantity + PreviousQuantity) )

        $previousDrugPrice = $($global:drugTable | Where-Object Name -eq $Drug).PurchasePrice

        if ($($global:drugTable | Where-Object Name -eq $Drug).PurchasePrice) {
            $($global:drugTable | Where-Object Name -eq $Drug).PurchasePrice = 
                [Math]::Round( (($drugPrice * $Quantity) + ($previousDrugPrice * $previousQuantity)) / ($Quantity + $previousQuantity) )
        }
        else {
            $($global:drugTable | Where-Object Name -eq $Drug).PurchasePrice = $drugPrice
        }

        $QuantityString = "$($($global:drugTable | Where-Object Name -eq $Drug).QuantityRaw) @ $($($global:drugTable | Where-Object Name -eq $Drug).PurchasePrice)"
        $($global:drugTable | Where-Object Name -eq $Drug).Quantity = $QuantityString
    #}
    <#
    else {
        Write-Verbose "Cannot purchase: $Drug | $Quantity @ $drugPrice"
        
        switch ($true) {
            $notEnoughPocketSpace {
                Write-Host "You do not have enough pocket space to purchase $Quantity unit(s) of $Drug." -ForegroundColor 'Red' -BackgroundColor "Black"
                break
            }
            $notEnoughMoney {
                Write-Host "You do not have enough cash to purchase $Quantity unit(s) of $Drug." -ForegroundColor 'Red' -BackgroundColor "Black"
                break
            }
        }
    }
    #>

    $writeGameInfo = @{
        City       = "$global:currentLocation, $global:cityName, $($global:cityInformation.Country)"
        Difficulty = $global:Difficulty
        Cash       = $global:cash
        Bank       = $global:bank
        Debt       = $global:debt
        Health     = $global:health
        Day        = $global:day
        TotalDays  = $GameLength
        Drugs      = $global:drugTable
    }
    
    Write-GameInformation @writeGameInfo
}