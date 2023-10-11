function Start-DrugGame {
    [CmdletBinding()]
    param(
        [Parameter(
            Position = 0
        )]
        [String] $Name = 'Ben',

        [Parameter(
            Position = 2
        )]
        [ValidateSet(
            15,
            30,
            60,
            90,
            120,
            365
        )]
        [Alias(
            'Length'
        )]
        [Int] $GameLength = 30,

        [Parameter(
            Position = 3
        )]
        [ValidateSet(
            'Basic',
            'Easy',
            'Normal',
            'Hard',
            'Insane'
        )]
        [String] $Difficulty = 'Normal'
    )

    DynamicParam {
        $ParamAttrib  = New-Object System.Management.Automation.ParameterAttribute

        $ParamAttrib.Mandatory  = $true
        $ParamAttrib.Position   = 1

        $ParamAttrib.ParameterSetName = '__AllParameterSets'

        $AttribColl = New-Object System.Collections.ObjectModel.Collection[System.Attribute]

        $AttribColl.Add($ParamAttrib)
        $cities = $global:cityData.Name

        $AttribColl.Add((New-Object System.Management.Automation.ValidateSetAttribute($cities)))

        $RuntimeParam = New-Object System.Management.Automation.RuntimeDefinedParameter('City',  [string], $AttribColl)

        $RuntimeParamDic = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

        $RuntimeParamDic.Add('City',  $RuntimeParam)

        return  $RuntimeParamDic

    }
    
    begin {
        Write-Debug "IN: Start-DrugGame"

        #region Variables

        #Set to true if coming from a child function. Used to conditionally Write-GameInformation
        $global:comingFromChildFunction = $false

        #Time Variables
        $global:day = 1

        #Player Variables
        $global:health = 100
        $global:pocketSpaceTotal = 100
        $global:pocketSpaceConsumed = 0

        #Money/Loan Variables
        $global:bank = 0
        $global:bankInterestRate = 0.03

        $global:cash     = $($global:gameDifficulty | Where-Object 'Difficulty' -eq $Difficulty).StartingCash
        $global:allDebts = 0
        $global:startingLoanFrom = $($global:gameDifficulty | Where-Object 'Difficulty' -eq $Difficulty).StartingDebtFrom

        #City Variables
        $global:cityName = $PSBoundParameters['City']
        $global:cityInformation = $cityData | Where-Object 'Name' -eq $cityName
        
        #Set the current location for the first day randomly
        $global:currentLocation = $global:cityInformation.Locations | Get-Random

        #Get initial random drug prices
        $global:drugTable = foreach ($drug in $global:drugData.Name) {
            Get-RandomDrugPrice -DrugName $drug
        }

        #Define an initial table for holding historical drug prices.
        $global:historicalDrugTable = foreach ($drug in $global:drugTable.Name) {
            @{ 
                $drug = @{
                    #[pscustomobject] @{ 
                    #    Day   = $global:day
                    #    Price = $global:drugTable | Where-Object 'Name' -eq $drug | Select-Object -ExpandProperty 'Price'
                    #}
                }
            }
        }

        #endregion
    }

    process {
        #region Build Loan Data Structure
        
        #At the beginning of the game, you only have a loan from the starting LoanShark,
        # but we still need to represent all of the sharks you can get a loan from, so this 
        # data can be represented when interacting with the loansharks. 

        $global:allLoans = foreach ($ls in $global:loanSharkData) {
            if ($ls.Name -eq $global:startingLoanFrom) {
                $loanParams = @{
                    DebtAmount = $($global:gameDifficulty | Where-Object 'Difficulty' -eq $Difficulty).StartingDebt
                    LoanShark  = $ls.Name
                    DebtPeriod = $($global:loanSharkData  | Where-Object 'Name' -eq $ls.Name).LoanPeriodDays
                    LoanRate   = $($global:loanSharkData  | Where-Object 'Name' -eq $ls.Name).DailyRate
                    OnVacation = $false
                }
            }
            else {
                $loanParams = @{
                    DebtAmount = 0
                    LoanShark  = $ls.Name
                    DebtPeriod = $($global:loanSharkData  | Where-Object 'Name' -eq $ls.Name).LoanPeriodDays
                    LoanRate   = $($global:loanSharkData  | Where-Object 'Name' -eq $ls.Name).DailyRate
                    OnVacation = $true
                }
            }

            New-Loan @loanParams
        }

        #Calculate Initial Debt
        $global:allDebts = Sum-Numbers $($allLoans | Where-Object PlayerHasLoan -eq $true).Amount

        #endregion

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

        #Main Loop
        do {
            $promptResult = Prompt-GameChoices

            Write-Verbose "Prompt Result: $promptResult"
            switch ($promptResult) {
                "Travel" {
                    Travel-City
                }

                "Drugs" {
                    $drugOrder = $null
                    $drugOrder = Prompt-Drug

                    if ($drugOrder) {
                        Transact-Drug -Drug $drugOrder.DrugName -Quantity $drugOrder.Quantity -Action $drugOrder.Action
                    }
                }

                "Shop" {

                }

                "Bank" {
                    $bankOrder = $null
                    $bankOrder = Prompt-Bank

                    if ($bankOrder) {
                        Transact-Bank -Amount $bankOrder.Amount -Action $bankOrder.Action
                    }
                }

                "Loans" {
                    $loanOrder = $null
                    $loanOrder = Prompt-Loan

                    if ($loanOrder) {
                    
                    }
                }

                "Restart" {

                    $gameActionResult = Prompt-GameAction -GameAction $promptResult

                    if ($gameActionResult -eq 0) {
                        #Reset the game
                    }
                }

                "Quit" {
                    $gameActionResult = Prompt-GameAction -GameAction $promptResult

                    if ($gameActionResult -eq 0) {
                        #Quit the game
                        return
                    }
                }
            }

        }
        until ($global:day -gt $GameLength)
    }

    end {

    }
}