function Prompt-GameChoices {
    [CmdletBinding()]
    param()

    Write-Debug "IN: Prompt-GameChoices"

    if ($global:comingFromChildFunction) {
        $global:comingFromChildFunction = $false

        $writeGameInfo = @{
            City       = "$currentLocation, $cityName, $($cityInformation.Country)"
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
    
    $travel      = [System.Management.Automation.Host.ChoiceDescription] "&Travel"
    $drugs       = [System.Management.Automation.Host.ChoiceDescription] "&Drugs"
    $shopItems   = [System.Management.Automation.Host.ChoiceDescription] "&Shop"
    $bankMoney   = [System.Management.Automation.Host.ChoiceDescription] "&Bank"
    $manageLoans = [System.Management.Automation.Host.ChoiceDescription] "&Loans"
    $restart     = [System.Management.Automation.Host.ChoiceDescription] "&Restart"
    $quit        = [System.Management.Automation.Host.ChoiceDescription] "&Quit Game"

    $options = [System.Management.Automation.Host.ChoiceDescription[]](
        $travel,
        $drugs,
        $shopItems,
        $bankMoney,
        $manageLoans,
        $restart,
        $quit
    )

    $result  = $host.ui.PromptForChoice('Perform An Action:', "What action would you like to perform?", $options, 0)

    switch ($result) {
        0 { "Travel"  }
        1 { "Drugs"   }
        2 { "Shop"    }
        3 { "Bank"    }
        4 { "Loans"   }
        5 { "Restart" }
        6 { "Quit"    }
    }
}