# Get public and private function definition files.
$publicFunctions  = @(Get-ChildItem -Path $PSScriptRoot\Public\*.ps1  -Recurse -ErrorAction 'SilentlyContinue')
$privateFunctions = @(Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -Recurse -ErrorAction 'SilentlyContinue')
$dataPaths        = @(Get-ChildItem -Path $PSScriptRoot\data\*.json   -Recurse -ErrorAction 'SilentlyContinue')

# Dot source the files
foreach ($file in @($publicFunctions + $privateFunctions)) {
    try {
        . $file.fullname
    }
    catch {
        Write-Error -Message "Failed to import function $($file.fullname): $_"
    }
}

#region Global Variables

$global:cityData       = Import-GameData $($dataPaths | Where-Object { $_.Name -like "*cities*"           })
$global:drugData       = Import-GameData $($dataPaths | Where-Object { $_.Name -like "*drugs*"            })
$global:loanSharkData  = Import-GameData $($dataPaths | Where-Object { $_.Name -like "*loansharks*"       })
$global:gameDifficulty = Import-GameData $($dataPaths | Where-Object { $_.Name -like "*gamedifficulties*" })

#endregion

# Export Public functions
Export-ModuleMember `
    -Function $publicFunctions.Basename