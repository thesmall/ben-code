# Calulate all Leap Years between X an Y
# Context: Written for use in the Password Game: https://neal.fun/password-game/
$x = 1900
$y = 4000

$leapYears = $x..$y | ForEach-Object { 
    if ((($_ % 4) -eq 0) -and (($_ % 100) -ne 0)) {
        $_
    }
}

#Find a Leap Year whose digits add up to 25.
foreach ($y in $leapYears) {
    [int[]] $splitY = $y -split ""

    $res = $splitY | Measure-Object -Sum

    if ($res.Sum -eq 25) {
        return $y
    }
}