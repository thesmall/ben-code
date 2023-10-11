function Update-Loan {
    [CmdletBinding()]
    param(
        $Loan
    )

    if ($Loan.PlayerHasLoan) {
         #Increase the debt by multiplying the Amount * (1 + LoanRate)
         $Loan.Amount = $Loan.Amount * $(1 + $Loan.LoanRate)

         #Decrease the loan amount of days the loan is due in
         $Loan.LoanDueIn--
 
         if ($LoanDueIn -le -4) {
             #### INFLICT DAMAGE FUNCTION ####
             $global:health = $global:health - (Get-Random -Minimum 15 -Maximum 30)
         }
    }
}