function Prompt-Drug {
    [CmdletBinding()]
    param()
    <#
        BUG: Can buy more drugs than pocket space???
        FEATURE: For selling, need to calculate profit/loss based on QuantityRaw/Purchase Price.
    #>
    Write-Debug "IN: Prompt-Drug"

    #Whenever we exit this function, we're always coming from a "child function" respective to the main loop, always display game information.
    $global:comingFromChildFunction = $true

    #Track the maximum units of drug that can be purchased.
    $allowedToBuyQuantityCap = $global:pocketSpaceTotal - $global:pocketSpaceConsumed

    #region Prompt for Drug

    do {
        $drugName = Read-Host -Prompt "What drug would you like to buy/sell?"

        if ($drugName -in $global:drugTable.Name) {
            Write-Host ""
            break
        }
        else {
            Write-Host "Stop getting high on your own supply. $DrugName isn't a drug." -ForegroundColor 'Red' -BackgroundColor 'Black'
        }
    }
    while ($true)

    #endregion

    #Identify the current quantity of drug available (to sell).
    $currentDrugQuantity = $($global:drugTable | Where-Object 'Name' -eq $drugName).QuantityRaw

    #Identity the current drug price.
    $drugPrice = $($global:drugTable | Where-Object 'Name' -eq $drugName).Price

    #return of the player attempts to buy or sell a drug not on the market.
    if ($drugPrice -eq "N/A") {
        Write-Host "You can't buy or sell $drugName. It's not on the market!" -ForegroundColor 'Red' -BackgroundColor 'Black'
        return
    }

    #region Prompt for action to take on drug

    $buyDrug  = [System.Management.Automation.Host.ChoiceDescription] "&Buy Drug"
    $sellDrug = [System.Management.Automation.Host.ChoiceDescription] "&Sell Drug"
    $cancel   = [System.Management.Automation.Host.ChoiceDescription] "&Cancel"

    $options = [System.Management.Automation.Host.ChoiceDescription[]]($buyDrug)

    #Only add the Sell option if there is quantity of drug to sell.
    $changeSellToCancel = $true
    if ($currentDrugQuantity -gt 0) { $options += $sellDrug; $changeSellToCancel = $false }
    $options += $cancel
    
    $result  = $host.ui.PromptForChoice(
        'Perform An Action:', 
        'What action would you like to perform?', 
        $options, 
        0
    )

    $action = switch ($result) {
        0 { "Buy" }
        1 { if ($changeSellToCancel) { "Cancel" } else { "Sell" } }
        2 { "Cancel" }
    }

    #endregion

    #return if player does not have enough cash to buy any units of drug.
    if (($action -eq "Buy") -and ($drugPrice -gt $global:cash)) {
        Write-Host "You do not enough cash to buy any $drugName." -ForegroundColor 'Red' -BackgroundColor 'Black'
        $global:comingFromChildFunction = $true
        return
    }

    #return if the player doesn't have any pocket space free.
    if (($global:pocketSpaceConsumed -eq $global:pocketSpaceTotal) -and ($action -eq "Buy")) {
        Write-Host "You do not have any pocket space available to buy drugs!" -ForegroundColor 'Red' -BackgroundColor 'Black'
        return
    }

    #Prompt for quantity (conditional prompt based on buying vs selling)
    switch ($action) {
        "Buy" {
            #region Calculate Max Amount that can be bought

            #Loop over $i unti:
            # 1. The cost of $i * $drugPrice > Cash on Hand
            # OR
            # 2. $i - 1 = the max amount you're technically able to buy.

                #if ($currentDrugQuantity) {
                #    $i = ($currentDrugQuantity - 1)
                #}
                #else {
                #    $i = 0    
                #}

            $i = 0
            do {
                $i++
                $drugCost = $i * $drugPrice
                Write-Verbose "[$i] DrugCost: $i * $drugPrice = $drugCost"
            }
            until (($drugCost -gt $global:cash) -or (($i - 1) -eq $allowedToBuyQuantityCap))
            
            #$i is one unit of drugs greater than we can buy, so subtract 1
            $allowedToBuyQuantity = $i - 1

            #endregion

            $maxAllowed = [System.Management.Automation.Host.ChoiceDescription] "&Max ($allowedToBuyQuantity)"
            $custom     = [System.Management.Automation.Host.ChoiceDescription] "&Custom"
            $abort      = [System.Management.Automation.Host.ChoiceDescription] "&Abort"

            $buyOptions = [System.Management.Automation.Host.ChoiceDescription[]](
                $maxAllowed,
                $custom,
                $abort
            )

            $buyOptionsResult  = $host.ui.PromptForChoice(
                'Perform An Action:', 
                "You can buy up to $allowedToBuyQuantity units of $drugName. Total cost for the max is `$$($drugPrice * $allowedToBuyQuantity).", 
                $buyOptions, 
                0
            )

            switch ($buyOptionsResult) {
                #Max Amount
                0 {
                    $quantity = $allowedToBuyQuantity
                }
                #Custom Amount
                1 {
                    do {
                        $customAmount = Read-Host "Custom Amount"
                
                        if ($customAmount -in (1..$allowedToBuyQuantity)) {
                            break
                        }
                        else {
                            #Constraints:
                            #1. Can't buy a zero amount of drugs.
                            #2. Can't buy more units of drugs than you have money to spend
                            #3. Can't buy more unit than you have available pocket space.
                            if ($customAmount -eq 0) {
                                Write-Host "You can't buy a zero amount of drugs!" -ForegroundColor 'Red' -BackgroundColor 'Black'
                            }
                            elseif ($customAmount -gt $allowedToBuyQuantity) {
                                Write-Host "You can't buy more than $allowedToBuyQuantity units of $drugName!" -ForegroundColor 'Red' -BackgroundColor 'Black'
                            }
                            else {
                                Write-Host "You can't hold more than $allowedToBuyQuantityCap units of $drugName" -ForegroundColor 'Red' -BackgroundColor 'Black'
                            }
                        }
                    }
                    while ($true)

                    $quantity = $customAmount
                    
                }

                #Abort
                2 { return }
            }            
        }

        "Sell" {
            $max    = [System.Management.Automation.Host.ChoiceDescription] "&Max ($currentDrugQuantity)"
            $custom = [System.Management.Automation.Host.ChoiceDescription] "&Custom"
            $abort  = [System.Management.Automation.Host.ChoiceDescription] "&Abort"

            $sellOptions = [System.Management.Automation.Host.ChoiceDescription[]](
                $max,
                $custom,
                $abort
            )

            $sellOptionsresult = $host.ui.PromptForChoice(
                'Perform An Action:', 
                "You have $currentDrugQuantity units of $drugName. You can sell them for `$$($drugPrice * $currentDrugQuantity).",
                $sellOptions, 
                0
            )

            switch ($sellOptionsResult) {
                #Max Amount
                0 {
                    $quantity = $currentDrugQuantity
                }
                #Custom Amount
                1 {
                    do {
                        $customAmount = Read-Host "Custom Amount"
                
                        if ($customAmount -in (1..$currentDrugQuantity)) {
                            break
                        }
                        else {
                            #Constraints:
                            #1. Can't sell a zero amount of drugs.
                            #2. Can't sell more units of drugs than you have on you
                            if ($customAmount -eq 0) {
                                Write-Host "You can't sell a zero amount of drugs!" -ForegroundColor 'Red' -BackgroundColor 'Black'
                            }
                            else {
                                Write-Host "You can't sell more units of $drugName than you have on you ($currentDrugQuantity)!" -ForegroundColor 'Red' -BackgroundColor 'Black'
                            }
                        }
                    }
                    while ($true)

                    $quantity = $customAmount
                    
                }

                #Abort
                2 { return }
            }
        }

        "Cancel" {
            Write-Host "The transaction to buy or sell $drugName has been canceled." -ForegroundColor 'Green' -BackgroundColor 'Black'
        }

        #Cancel (Do Nothing)
    }

    if (($action -eq "Buy") -or ($action -eq "Sell")) {
        return [PSCustomObject] @{
            DrugName = $drugName
            Action   = $action
            Quantity = $quantity
        }
    }
}