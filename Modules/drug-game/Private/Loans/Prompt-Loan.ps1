function Prompt-Loan {
    [CmdletBinding()]
    param()

    Write-Debug "IN: Prompt-Loan"

    #Whenever we exit this function, we're always coming from a "child function" respective to the main loop, always display game information.
    $global:comingFromChildFunction = $true

    #region Represent the Loan Sharks and their statuses
    <#
        LoanShark's Name
        Daily Rate
        DueDate
        Status (How Much You Owe; Is the loanshark's service available?)
        Detailed breakdown of how much you owe.
    #>

    foreach ($loan in $global:allLoans) {

    }


}