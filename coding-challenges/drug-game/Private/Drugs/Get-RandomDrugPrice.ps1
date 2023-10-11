function Get-RandomDrugPrice {
    [CmdletBinding()]
    param(
        [String] $DrugName,

        #The cost of the drug of the previous day.
        $PreviousPrice,

        #The quantity @ purchase cost string of the previous day.
        $PreviousQuantity,
        
        #The quantity of drug held from the previous day, if applicable.
        $PreviousQuantityRaw,

        #The purchase price of the drug from the previous day, if applicable.
        $PreviousPurchasePrice
    )

    #TODO: Force a Spike/Crash of a specific Drug
        #Cases:
        <#
            1. The old lady tells you about an upcoming spike/crash for a specific drug.
                * Low % chance she provides the wrong drug name.
            2. You were arrested and overhear the police talking about an upcoming spike/crash for a specific drug.
        #>

    # Fluctuation Cases:
    <#
        1. Normal Case: Drug is on the market and using regular lower/upper bounds. 
        2. Spike Case: Drug is on the market and is using spike lower/upper bounds.
        3. Crash Case: Drug is on the market and is using crash lower/upper bounds.
        4. Inactive Case: drug is not on the market.
        5. No Change Case: Drug is on the market and has not changed price from the previous day.
    #>

    begin {
        $cases = @(
            'Normal'
            'Crash'
            'Spike'
            'NotOnMarket'
            'NoChange'
        )
    }

    process {
        
        $drugInfo = $global:drugData | Where-Object 'Name' -eq $DrugName

        #region Determine Fluctuation Case
        $chanceNormal      = (1 - ($drugInfo.ChanceCrash + $drugInfo.ChanceSpike + $drugInfo.ChanceNotOnMarket + $drugInfo.ChanceNoChange)) * 100
        $chanceCrash       = ($drugInfo.ChanceCrash       * 100)
        $chanceSpike       = ($drugInfo.ChanceSpike       * 100)
        $chanceNotOnMarket = ($drugInfo.ChanceNotOnMarket * 100)
        $chanceNoChange    = ($drugInfo.ChanceNoChange    * 100)

        $basePercentage = $chanceNormal

        $probabilities = foreach ($case in $cases) {
            $pct = Get-variable | 
                where-Object Name -eq "chance$case" | 
                    Select-Object -ExpandProperty 'Value'

            if ($case -eq 'Normal') {
                [pscustomobject] @{
                    Case            = $case
                    Percentage      = $pct
                    LowerBoundRange = 1
                    UpperBoundRange = $pct
                    Range           = @(1..$pct)
                }
            }
            elseif ($pct -eq 0) {
                [pscustomobject] @{
                    Case            = $case
                    Percentage      = $pct
                    LowerBoundRange = 0
                    UpperBoundRange = 0
                    Range           = @()
                } 
            }
            else {
                [pscustomobject] @{
                    Case            = $case
                    Percentage      = $pct
                    LowerBoundRange = $basePercentage + 1
                    UpperBoundRange = $pct + $basePercentage
                    Range           = @($($basePercentage + 1)..$($pct + $basePercentage))
                }
                $basePercentage += $pct
            }
        }
        
        #endregion

        #region Process probability & determine case for drug.
        $drugCase = Get-Random -Minimum 1 -Maximum 100

        foreach ($pCase in $probabilities) {
            if ($drugCase -in $pCase.Range) {
                $chosenCase = $pCase.Case
                break
            }
        }

        switch ($chosenCase) {
            'Normal' {
                $lowerBound = $drugInfo.LowerBound 
                $upperBound = $drugInfo.UpperBound
            }

            'Crash' {
                $lowerBound = $drugInfo.CrashLowerBound 
                $upperBound = $drugInfo.CrashUpperBound 
            }

            'Spike' {
                $lowerBound = $drugInfo.SpikeLowerBound 
                $upperBound = $drugInfo.SpikeUpperBound
            }

            #NotOnMarket has no case.
            #NoChange has no case.
        }

        #endregion

        #region build Drug object 

        if ($chosenCase -eq "NotOnMarket") {
            $drugPrice = 'N/A'
        }
        elseif ($chosenCase -eq "NoChange") {
            $drugPrice = $PreviousPrice
        }
        else {
            $drugPrice = Get-Random `
                -Minimum $lowerBound `
                -Maximum $upperBound
        }

        Write-Verbose "[$DrugName] Previous Price: $PreviousPrice"
        Write-Verbose "[$DrugName] Drug Price: $drugPrice"

        switch ($true) {
            (($PreviousPrice -eq '') -or ($null -eq $PreviousPrice) -or ($PreviousPrice -eq "N/A") -or ($drugPrice -eq "N/A")) {
                [String] $change = ''
                break
            }
            ($drugPrice -eq $PreviousPrice) {
                [String] $change = [char]8212
                break
            }
            ($drugPrice -gt $PreviousPrice) {
                [String] $change = [char]8593 # UTF8 Arrow Up
                break
            }
            ($drugPrice -lt $PreviousPrice) {
                [String] $change = [char]8595 # UTF8 Arrow Down
                break
            }
        }

        return [pscustomobject] @{
            Chg           = $change
            Name          = $DrugName
            Quantity      = $PreviousQuantity
            QuantityRaw   = $PreviousQuantityRaw
            PurchasePrice = $PreviousPurchasePrice
            Price         = $drugPrice
        }

        #endregion
    }

    end {

    }
}



