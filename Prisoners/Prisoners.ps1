function New-BoxAssignment {
    [CmdletBinding()]
    param(
        $NumberOfPrisoners = 100
    )

    [System.Collections.ArrayList] $prisonersArray = 1..$NumberOfPrisoners

    $res = 1..$NumberOfPrisoners | ForEach-Object { 
        $prisoner = $(Get-Random -InputObject $prisonersArray)

        [pscustomobject] @{
            BoxNumber = $_
            PrisonerNumber = $prisoner
        }

        $prisonersArray.Remove($prisoner)
    }

    return $res
}

function Get-BoxLoop {
    [CmdletBinding()]
    param(
        $BoxAssignment,

        $Prisoner
    )

    [System.Collections.ArrayList] $loopArray = @()
    $originalNumber = $Prisoner

    do {
        $nextNumber = $BoxAssignment | Where-Object BoxNumber -eq $Prisoner | Select-Object -ExpandProperty PrisonerNumber
        $loopArray.Add($nextNumber) | Out-Null
        $Prisoner = $nextNumber
    }
    until ($Prisoner -eq $originalNumber)

    return $loopArray
}

function Main {
    [CmdletBinding()]
    param(
        $NumberOfPrisoners = 100
    )

    $global:mainBoxAssignment = New-BoxAssignment -NumberOfPrisoners $NumberOfPrisoners

    $res = foreach ($p in 1..$NumberOfPrisoners) {
        $loopData = Get-BoxLoop -BoxAssignment $mainBoxAssignment -Prisoner $p

        [pscustomobject] @{
            Prisoner   = $p
            LoopLength = $loopData.Count
            LoopData   = "$($loopData -join ", ")" 
        }
    }

    $longestLoop = $res | Sort-Object LoopLength | Select-Object -Last 1 -ExpandProperty LoopLength

    $res

    $numberofLoops = $res | Select-Object -ExpandProperty LoopLength | Sort-object -Unique | Measure-Object | Select-object -ExpandProperty Count 
    $shortestLoop  = $res | Sort-Object LoopLength | Select-Object -First 1 -ExpandProperty LoopLength

    ""
    if ($longestLoop -gt ($NumberOfPrisoners/2)) {
        "The Prisoners were Executed."
    }

    else {
        "The Prisoners escaped."
    }
    "Number of Loops: $numberOfLoops"
    "Shortest Loop: $shortestLoop"
    "Longest Loop: $longestLoop"
}