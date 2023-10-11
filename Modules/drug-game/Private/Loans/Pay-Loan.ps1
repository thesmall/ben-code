function Pay-Loan {
    [CmdletBinding()]
    param(
        $Loan
    )


    #HOW THE FUCK DO YOU CALCULATE THE PREPAYMENT PENALTY

    # Penalty = CurrentlyOwed *(InterestRate - 1 ) * ((InterestRate ^DaysLeft) - 1 ) * 1.9985


    <#
        Day    Debt    Prepayment Penalty    Total  Days Left  Penalty Rate
        ---    ----    ------------------    -----  ---------  ------------
        Day 1  5500 +  5021               =  10521  10         ~.9129
        Day 2  6325 +  4774               =  11099  09         ~.7548
        Day 3  7273 +  4489               =  11762  08         ~.6172
        Day 4  8363 +  4162               =  12525  07         ~.49772
    #>

    #BASE NUMBER?? * DAYS LEFT * DEBT = 

    #The following things happen when you pay off a loan:
    <#
        1. Debt from the loan is eliminated.
        2. LoanPaidOff is set to TRUE.
    #>
    #Constraints:
    <#
        1. If paying early, apply a prepayment penalty.
        2. Can only pay off the FULL loan. No partial payments.
        3.
    #>

    if ($Loan.LoanDueIn -gt 0) {
        
    }

    

}