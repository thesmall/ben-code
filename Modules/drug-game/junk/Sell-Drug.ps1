function Sell-Drug {
    [CmdletBinding()]
    param(
        [String] $Drug,

        [Int] $Quantity,

        $DrugTable = $global:drugTable
    )
    #The following things happen when selling drugs:
    <#
        1. Available cash increases.
        2. Pocket space gets freed up.
    #>

    Write-Verbose "IN: Sell-Drug"

    $canSell = $true

    #Calculate cost of drug
    $DrugObj = $DrugTable | Where-Object 'Name' -eq $Drug
    $drugPrice = $DrugObj.Price

    $costOfDrug = $drugPrice * $Quantity


    #Run through the checks to sell Drugs

    #Does the player have a non-zero quantity of drug to sell?
    if ($DrugObj.$Quantity -eq 0) {
        $canSell = $false
        $doesntHaveUnitsOfDrug = $true
    }

    #Is the drug available to sell on the drug market? {{NOT IMPLEMENTED}}


    
    

    

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