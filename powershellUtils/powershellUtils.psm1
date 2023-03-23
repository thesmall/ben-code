# Get public and private function definition files.
$public  = @(Get-ChildItem -Path $PSScriptRoot\Public\*.ps1  -ErrorAction 'SilentlyContinue')
$private = @(Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction 'SilentlyContinue')

# Dot source the files
foreach ($file in @($public + $private)) {
    try {
        . $file.fullname
    }
    catch {
        Write-Error -Message "Failed to import function $($file.fullname): $_"
    }
}

# Export Public functions
Export-ModuleMember `
    -Function $Public.BaseName `
    -Alias @(
        'psh'
        'pshistory'
        'rsm'
        'Search-PSTranscript'
    )