function Prompt-SellDrug {
    [CmdletBinding()]
    param()

    #Prompt for Drug
    do {
        $drugName = Read-Host -Prompt "Drug"

        if ($drugName -in $global:drugTable.Name) {
            break
        }
        else {
            Write-Warning "Are you on drugs? $DrugName isn't a drug."
        }
    }
    while ($true)

    #Prompt for Quantity
    $drugQuantity = Read-Host -Prompt "Quantity"

    return [PSCustomObject]@{
        DrugName = $drugName
        Quantity = $drugQuantity
    }
}