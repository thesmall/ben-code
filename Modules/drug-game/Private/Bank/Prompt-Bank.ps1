function Prompt-Bank {
    [CmdletBinding()]
    param()

    Write-Debug "IN: Prompt-Bank"

    #Whenever we exit this function, we're always coming from a "child function" respective to the main loop, always display game information.
    $global:comingFromChildFunction = $true

    #region Prompt for action to take on money

    $deposit  = [System.Management.Automation.Host.ChoiceDescription] "&Deposit Money"
    $withdraw = [System.Management.Automation.Host.ChoiceDescription] "&Withdraw Money"
    $cancel   = [System.Management.Automation.Host.ChoiceDescription] "&Cancel"

    $options = [System.Management.Automation.Host.ChoiceDescription[]]($deposit, $withdraw, $cancel)

    
    $result  = $host.ui.PromptForChoice(
        'Perform An Action:', 
        'What action would you like to perform?', 
        $options, 
        0
    )

    $action = switch ($result) {
        0 { "Deposit"  }
        1 { "Withdraw" }
        2 { "Cancel"   }
    }

    #endregion

    switch ($action) {
        "Deposit" {
            $maxAllowed = [System.Management.Automation.Host.ChoiceDescription] "&Max ($global:cash)"
            $custom     = [System.Management.Automation.Host.ChoiceDescription] "&Custom"
            $abort      = [System.Management.Automation.Host.ChoiceDescription] "&Abort"

            $depositOptions = [System.Management.Automation.Host.ChoiceDescription[]](
                $maxAllowed,
                $custom,
                $abort
            )

            if ($global:cash -eq 0) {
                Write-Host "You have no cash on hand to deposit into the bank!" -ForegroundColor 'Red' -BackgroundColor 'Black'
                return
            }

            $depositOptionsResult  = $host.ui.PromptForChoice(
                'Perform an Action:', 
                "You can deposit up to `$$global:cash into the bank.", 
                $depositOptions, 
                0
            )

            switch ($depositOptionsResult) {
                #Max Amount
                0 {
                    $quantity = $global:cash
                }
                #Custom Amount
                1 {
                    do {
                        $customAmount = Read-Host "Custom Amount"
                
                        if (($customAmount -gt 1) -and ($customAmount -le $global:cash)) {
                            break
                        }
                        else {
                            #Constraints:
                            #1. Can't deposit a zero amount of money.
                            #2. Can't deposit more money than you have on hand.
                            if ($customAmount -eq 0) {
                                Write-Host "You can't deposit `$0 into the bank!" -ForegroundColor 'Red' -BackgroundColor 'Black'
                            }
                            else {
                                Write-Host "You can't deposit more money than you have on you into the bank!" -ForegroundColor 'Red' -BackgroundColor 'Black'
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

        "Withdraw" {
            $max    = [System.Management.Automation.Host.ChoiceDescription] "&Max ($global:bank)"
            $custom = [System.Management.Automation.Host.ChoiceDescription] "&Custom"
            $abort  = [System.Management.Automation.Host.ChoiceDescription] "&Abort"

            $withdrawOptions = [System.Management.Automation.Host.ChoiceDescription[]](
                $max,
                $custom,
                $abort
            )

            if ($global:bank -eq 0) {
                Write-Host "You have no cash in the bank to withdraw!" -ForegroundColor 'Red' -BackgroundColor 'Black'
                return
            }

            $withdrawOptionsresult = $host.ui.PromptForChoice(
                'Perform An Action:', 
                "You can withdraw up to $global:bank from the bank.",
                $withdrawOptions, 
                0
            )

            switch ($withdrawOptionsResult) {
                #Max Amount
                0 {
                    $quantity = $global:bank
                }
                #Custom Amount
                1 {
                    do {
                        $customAmount = Read-Host "Custom Amount"
                
                        if (($customAmount -gt 1) -and ($customAmount -le $global:bank)) {
                            break
                        }
                        else {
                            #Constraints:
                            #1. Can't withdraw a zero amount of money.
                            #2. Can't withdraw more money than you have in the bank
                            if ($customAmount -eq 0) {
                                Write-Host "You can't withdraw `$0 from the bank!" -ForegroundColor 'Red' -BackgroundColor 'Black'
                            }
                            else {
                                Write-Host "You can't withdraw more money than you have from the bank!" -ForegroundColor 'Red' -BackgroundColor 'Black'
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
            Write-Host "The transaction to deposit or withdraw money from the bank has been canceled." -ForegroundColor 'Green' -BackgroundColor 'Black'
        }
    }

    if (($action -eq "Deposit") -or ($action -eq "Withdraw")) {
        return [PSCustomObject] @{
            Amount = $quantity
            Action = $action
        }
    }
}