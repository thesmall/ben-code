<#
A PowerShell-based implementation of Dawkins' "Weasel Program", as detailed by Wikipedia:
https://en.wikipedia.org/wiki/Weasel_program

Example:

Start-WeaselProgram `
    -InputString "ASDLFKJ ASDFASDF DFD  DDFFDL" `
    -OutputString "METHINKS IT IS LIKE A WEASEL" `
    -ReproductionsCount 100 `
    -MutationRatePercent 5

Round String                       CorrectMutations
----- ------                       ----------------
    0 ASDLFKJSASTFASDF DFD  DDFFDL                5
    1 MJDLFKJSASTFWSDF DFDE DDFFDL                6
    2 MJDLFKJSASTFWSDF KFDE DDFFDL                7
    3 MJDHFNJSARTFWSDF KFDE DDFFDL                9
    4 MJDHPNJSARTFWSDF KFDE DDFFYL                9
    5 MJDHPNJSARTFWSDF KFDA DDFFYL               10
    6 MJDHPNJS RTYWSDF KFDA DDFFYL               11
    7 MJDHPNJS RTFWSUF KRDA WDFFYL               12
    8 MJDHPNJS RTFWS F KRDA WDFFYL               13
    9 MJDHWNKS RTFWS F KRDA WDFFYL               14
   10 MJDHWNKS RTFWS F KRDA WDFSYL               15
   11 MJDHWNKS RTFIS F KRDA WDFSNL               16
   12 MJDHWNKS RTFIS F KRDA WDFSNL               16
   13 MJDHWNKS HTFIS F KRDA WBFSNL               16
   14 MPDHWNKS HTFIS F KRDA WBFSNL               16
   15 MPDHWNKS HTFIS F KEDA WBFSNL               17
   16 MEDHWNKS HTFIS F KEOA WDFSNL               18
   17 MEDHINKS HTFIS F KEOA WDFSNL               19
   18 MEDHINKS HTFIS F KEOA WDFSEL               20
   19 MEDHINKS HTFIS F KEOA WDFSEL               20
   20 MEDHINKS HTFIS F KEOA WDFSEL               20
   21 MEDHINKS HTFIS FIKEOA WDFSEL               21
   22 MEDHINKS HTFIS FIKEOA WDFSEL               21
   23 MEDHINKS HTFIS FIKEEA WDFSEL               21
   24 METHINKS HTFIS FIKEEA WDFSEL               22
   25 METHINKS HTFIS FIKEEA WDFSEL               22
   26 METHINKS HTFIS FIKEEA WDFSEL               22
   27 METHINKS HTFIS LIKEEA WDFSEL               23
   28 METHINKS HTFIS LIKEEA WDFSEL               23
   29 METHINKS HTFIS LIKEEA WDFSEL               23
   30 METHINKS HTFIS LIKEEA WDFSEL               23
   31 METHINKS HTFIS LIKEEA WDFSEL               23
   32 METHINKS HTFIS LIKEEA WD SEL               23
   33 METHINKS HTFIS LIKEEA WE SEL               24
   34 METHINKS HT IS LIKEEA WE SEL               25
   35 METHINKS HT IS LIKEEA WE SEL               25
   36 METHINKS HT IS LIKEEA WE SEL               25
   37 METHINKS HT IS LIKEEA WE SEL               25
   38 METHINKS HT IS LIKEEA WE SEL               25
   39 METHINKS HT IS LIKE A WE SEL               26
   40 METHINKS HT IS LIKE A WE SEL               26
   41 METHINKS UT IS LIKE A WE SEL               26
   42 METHINKS UT IS LIKE A WE SEL               26
   43 METHINKS UT IS LIKE A WE SEL               26
   44 METHINKS UT IS LIKE A WE SEL               26
   45 METHINKS UT IS LIKE A WE SEL               26
   46 METHINKS IT IS LIKE A WE SEL               27
   47 METHINKS IT IS LIKE A WE SEL               27
   48 METHINKS IT IS LIKE A WE SEL               27
   49 METHINKS IT IS LIKE A WE SEL               27
   50 METHINKS IT IS LIKE A WE SEL               27
   51 METHINKS IT IS LIKE A WE SEL               27
   52 METHINKS IT IS LIKE A WE SEL               27
   53 METHINKS IT IS LIKE A WE SEL               27
   54 METHINKS IT IS LIKE A WE SEL               27
   55 METHINKS IT IS LIKE A WE SEL               27
   56 METHINKS IT IS LIKE A WE SEL               27
   57 METHINKS IT IS LIKE A WEASEL               28
#>

function Start-WeaselProgram {
    param(
        #Specifies the input string. The input string should be the same length as the output string.
        [String] $InputString =  "ASDLFKJ ASDFASDF DFD  DDFFDL",

        #Specifies the output string. The output string should be the same length as the input string.
        [String] $OutputString = "METHINKS IT IS LIKE A WEASEL",

        #Specifies the number of reproductions per round, as an integer.
        [Int] $ReproductionsCount = 100,

        #Specifies the mutation rate percentage, as an integer.
        [Int] $MutationsRatePercent = 5
    )

    begin {

        $CHARACTER_SET = @(
            "A","B","C","D","E","F","G","H","I",
            "J","K","L","M","N","O","P","Q","R",
            "S","T","U","V","W","X","Y","Z"," "
        )

        $round = 0

        if ($InputString.Length -ne $OutputString.Length) {
            Write-Error -Message "The specified InputString needs to be the same length as the OutputString."
            
            #returning in the begin block still results in the process block running, so set a variable return = true, 
            #to return the function at the beginning of the process block.
            $return = $true
        }

        $InputString  = $InputString.ToUpper()
        $OutputString = $OutputString.ToUpper()
    }

    process {
        if ($return) {
            return
        }

        do {
           [Array] $reproductionArrayInput   = @()
           [Array] $reproductionArrayHolding = @()
           [Array] $reproductionArrayOutput  = @()

            #region Create $ReproductionsCount copies of the $InputString

            do {
                [Array] $reproductionArrayInput += $InputString
            }
            until (($reproductionArrayInput | Measure-Object | Select-Object -ExpandProperty 'Count') -eq $ReproductionsCount)

            #endregion

            #region Reproduction Loop

            #Loop over each spawn in the reproduction array, with a $MutationRatePercent chance to mutate a given letter in the spawn.

            foreach ($spawn in $reproductionArrayInput) {

                $mutatedSpawn = ""
                foreach ($character in $spawn.GetEnumerator()) {
                    $randomInt = Get-Random -Minimum 1 -Maximum 100

                    if ($randomInt -le $MutationsRatePercent) {
                        $mutatedSpawn += $CHARACTER_SET | Get-Random
                    }
                    else {
                        $mutatedSpawn += $character
                    }
                }

                [Array] $reproductionArrayHolding += $mutatedSpawn
            }

            #endregion

            #region Determine Correct Mutations Loop

            #Loop over each spawn and count the number of correct mutations.
            #A mutation is correct if the character is both equal to its OutputString counterpart, and in the correct position.

            foreach ($newSpawn in $reproductionArrayHolding) {
                $correctMutations = 0

                for ($i=0; $i -lt $newSpawn.Length; $i++) {
                    if ($newSpawn[$i] -eq $OutputString[$i]) {
                        $correctMutations++
                    }
                }

                $reproductionArrayOutput += [pscustomobject][ordered] @{
                    Round            = $round
                    String           = $newSpawn
                    CorrectMutations = $correctMutations
                }
            }

            #endregion

            #region Final Selection

            #Sort all of the reproductions and select the one with the highest number of correct mutations.
            #Output the winning spawn of the round and reuse it at the beginning of the outermost loop.

            $winningSpawn = $reproductionArrayOutput |
                Sort-Object CorrectMutations |
                    Select-Object -Last 1

            #Print out the winning spawn.
            Write-Output $winningSpawn

            $InputString = $winningSpawn.String

            $round++

            #endregion
        }
        until ($InputString -eq $OutputString)
    }

    end {

    }

}