function New-Loan {
    [CmdletBinding()]
    param(
        [Int] $DebtAmount,

        [String] $LoanShark,

        [Int] $DebtPeriod,

        [Double] $LoanRate,

        [Bool] $OnVacation
    )

    $hasLoan = if ($DebtAmount -gt 0) { $true } else { $false }
    
    if ($OnVacation) {
        $DebtAmount = 0
        $DebtPeriod = 0 
    }

    return [pscustomobject] @{
        Amount              = $DebtAmount
        LoanShark           = $LoanShark
        LoanDueIn           = $DebtPeriod
        LoanRate            = $LoanRate
        PlayerHasLoan       = $hasLoan
        LoanSharkOnVacation = $OnVacation
    }
}