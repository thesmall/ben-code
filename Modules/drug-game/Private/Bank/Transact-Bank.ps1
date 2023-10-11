function Transact-Bank {
    [CmdletBinding()]
    param(
        [Int] $Amount,

        [String] $Action
    )

    Write-Debug "IN: Transact-Bank"

    switch ($Action) {
        "Deposit" {
            $global:cash = $global:cash - $Amount
            $global:bank = $global:bank + $Amount
        }

        "Withdraw" {
            $global:cash = $global:cash + $Amount
            $global:bank = $global:bank - $Amount
        }
    }
}