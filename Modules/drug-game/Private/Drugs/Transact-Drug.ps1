function Transact-Drug {
    [CmdletBinding()]
    param(
        [String] $Drug,

        [Int] $Quantity,

        $Action,

        $DrugTable = $global:drugTable,

        [Int] $AvailableCash = $global:cash
    )

    Write-Debug "IN: Transact-Drug"

    #Calculate cost of drug
    $DrugObj = $DrugTable | Where-Object 'Name' -eq $Drug
    $drugPrice = $DrugObj.Price

    $costOfDrug = $drugPrice * $Quantity

    switch ($Action) {
        #The following things happen when buying drugs:
        <#
            1. Available cash decreases.
            2. Pocket space gets consumed.
            3. Increment quantity of drug in display.
                1. Increment the Raw quantity of drugs.
                2. Calculate the purchase price of drugs (which could include a previous purchase price).
        #>
        "Buy" {
            #Subtract cost of drugs from cash
            $global:cash = $AvailableCash - $costOfDrug
            
            #Add the quantity of drugs to the current amount of pocket space consumed 
            $global:pocketSpaceConsumed = $global:pocketSpaceConsumed + $Quantity

            #Update Quantity Values in DrugTable
            $previousQuantity = $($global:drugTable | Where-Object Name -eq $Drug).QuantityRaw
            $($global:drugTable | Where-Object Name -eq $Drug).QuantityRaw += $Quantity


            #Calculate the Purchase Price, potentially based on the previous purchase price.
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
        }

        #The following things happen when selling drugs:
        <#
            1. Available cash increases.
            2. Pocket space gets freed up.
            3. Decrement quantity of drug in display.
                1. Decrement the Raw quantity of drugs.
        #>
        "Sell" {
            #Add cost of drugs to cash
            $global:cash = $AvailableCash + $costOfDrug
            
            #Add the quantity of drugs to the current amount of pocket space consumed 
            $global:pocketSpaceConsumed = $global:pocketSpaceConsumed - $Quantity

            #Update Quantity Values in DrugTable
            $previousQuantity = $($global:drugTable | Where-Object Name -eq $Drug).QuantityRaw
            $($global:drugTable | Where-Object Name -eq $Drug).QuantityRaw -= $Quantity

            $QuantityString = "$($($global:drugTable | Where-Object Name -eq $Drug).QuantityRaw) @ $($($global:drugTable | Where-Object Name -eq $Drug).PurchasePrice)"
            $($global:drugTable | Where-Object Name -eq $Drug).Quantity = $QuantityStrin
        }
    }
}