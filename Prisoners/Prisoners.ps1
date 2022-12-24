<#
This code is modeled off of a potential stategey to the riddle proposed in the Veritasium Youtube video titled: 'The Riddle That Seems Impossible Even If You Know The Answer'
Link: https://www.youtube.com/watch?v=iSNsgj1OCLA


The premise of the riddle is: 

* There are 100 prisoners. Each prisoner is numbered.
* There is a room; inside the room are boxes, one for each of the 100 prisoners.
* Inside each box is a random number, 1 through 100.
* Each prisoner will:
    1. Enter the room.
    2. Open up to half of the boxes looking for their own number.
    3. Leaves the room either after they have found the box containing their number or have opened 50 boxes.
    4. Not communicate with other prisoners both during and after they have left the room.
* If ALL 100 prisoners can find their number before any each of them open 50 boxes, all of the prisoners are released from prison.
* If ANY of the 100 prisoners fail to find their number, all 100 are executed.
* The prisoners CAN stategize a method to finding their own number within 50 boxes, before any of them have enter the room.


As described in the video, there is a method for achieving a roughly 30% success rate of the prisoners being released.
This is done by having each prisoner enter the room and open their OWN box, as denoted by their prisoner number.

For example:
Prisoner 1  opens box 1
Prisoner 12 opens box 12
Prisoner 99 opens box 99


and then each prisoner should follow the chain:

Box 1  contains the number 4  --> Open box 4
Box 4  contains the number 15 --> Open box 15
Box 15 contains the number 93 --> Open box 93
Box 93 contains the number 13 --> Open box 13
Box 13 contains the number 1  --> The prisoner found their number.

until they either find their own number (as demonstrated above) or they open half of the boxes.


The below code implements this strategy.
The "main" function returns the results of N number of prisoners opening and following boxes until they find their own. 
It prints out if the group of N prisoners were released or not.
#>


function New-BoxAssignment {
<#
    .SYNOPSIS
        Return an object consisting of a specified number of boxes, each of which has a prisoner's number "inside" it.

    .DESCRIPTION
        This function consumers a value, the number of prisoners that will be in the "experiment" and 
        returns an object consisting of the specified number of boxes, and each number that is contained within the box. 

    .EXAMPLE
        PS> New-BoxAssignment -NumberOfPrisoners 20

        BoxNumber PrisonerNumber
        --------- --------------
                1             10
                2             20
                3             18
                4              7
                5             11
                6             19
                7              3
                8              9
                9             13
               10             16
               11              2
               12             15
               13             14
               14              6
               15              4
               16              8
               17              1
               18              5
               19             12
               20             17

        Box 1  contains prisoner number 10
        Box 2  contains prisoner number 20
        Box 11 contains prisoner number 2
        
        Etc.
#>
    [CmdletBinding()]
    param(
        #Specifies a number of Prisoners to calculate the strategy for. There must be an even number of prisoners.
        [ValidateScript({($_ % 2) -eq 0})]
        [Int] $NumberOfPrisoners = 100
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
<#
    .SYNOPSIS
        Return an array of numbers that are a "loop" that a specified prisoner takes trying to find their own box.

    .DESCRIPTION
        Given a BoxAssignment object and a prisoner (the prisoner's number), 
        return an array consisting of the path that prisoner takes trying to find the box containing their own number

    .EXAMPLE
        PS> $BoxAssignment = New-BoxAssignment -NumberOfPrisoners 20

        PS> Get-BoxLoop -BoxAssignment $boxass -Prisoner 3

        1
        4
        5
        20
        6
        12
        3


        Prisoner 3 opens box 3 and finds the number 1
        Prisoner 3 opens box 1 and finds the number 4
        Prisoner 3 opens box 4 and finds the number 5
        ...
        Prisoner 3 opens box 6 and finds the number 12
        Prisoner 3 opens box 12 and finds the number 3

        The prisoner has a "loop" of 7. There are 20 prisoners. The prisoner found their number before opening more than half of the boxes.
#>
    [CmdletBinding()]
    param(
        #Specifies a BoxAssignment object.
        $BoxAssignment,

        #Specifies an individual prisoner, by their number.
        [Int] $Prisoner
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
<#
    .SYNOPSIS
        Process the strategy given a number of prisoners.

    .DESCRIPTION
        1. Create a new BoxAssignment based on the number of prisoners specified.
        2. Generate the Box Loop for each prisoner. 
        3. Build the results and output each prisoner's loop, whether the prisoners were executed or released and some statistics.

    .EXAMPLE
        PS> main -NumberOfPrisoners 20

        Prisoner LoopLength LoopData
        -------- ---------- --------
               1          6 8, 14, 15, 16, 17, 1
               2          9 7, 20, 9, 12, 19, 13, 4, 6, 2
               3          4 11, 10, 5, 3
               4          9 6, 2, 7, 20, 9, 12, 19, 13, 4
               5          4 3, 11, 10, 5
               6          9 2, 7, 20, 9, 12, 19, 13, 4, 6
               7          9 20, 9, 12, 19, 13, 4, 6, 2, 7
               8          6 14, 15, 16, 17, 1, 8
               9          9 12, 19, 13, 4, 6, 2, 7, 20, 9
              10          4 5, 3, 11, 10
              11          4 10, 5, 3, 11
              12          9 19, 13, 4, 6, 2, 7, 20, 9, 12
              13          9 4, 6, 2, 7, 20, 9, 12, 19, 13
              14          6 15, 16, 17, 1, 8, 14
              15          6 16, 17, 1, 8, 14, 15
              16          6 17, 1, 8, 14, 15, 16
              17          6 1, 8, 14, 15, 16, 17
              18          1 18
              19          9 13, 4, 6, 2, 7, 20, 9, 12, 19
              20          9 9, 12, 19, 13, 4, 6, 2, 7, 20

        The Prisoners escaped.
        Number of Loops: 4
        Shortest Loop: 1
        Longest Loop: 9
#>
    [CmdletBinding()]
    param(
        #Specifies a number of Prisoners to calculate the strategy for. There must be an even number of prisoners.
        [ValidateScript({($_ % 2) -eq 0})]
        [Int] $NumberOfPrisoners = 100
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

    $longestLoop = $res | Sort-Object 'LoopLength' | Select-Object -Last 1 -ExpandProperty 'LoopLength'

    #Write the results.
    $res

    $numberofLoops = $res | 
        Select-Object -ExpandProperty 'LoopLength' | 
        Sort-object -Unique | 
        Measure-Object | 
        Select-object -ExpandProperty 'Count'

    $shortestLoop  = $res | 
        Sort-Object LoopLength | 
        Select-Object -First 1 -ExpandProperty 'LoopLength'

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