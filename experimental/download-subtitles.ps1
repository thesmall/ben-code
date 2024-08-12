# This code doesn't work well. Open Subtitles throttles IPs that download too fast.

$res = Invoke-WebRequest 'https://www.opensubtitles.org/en/ssearch/sublanguageid-all/idmovie-3834'


$csv = Import-Csv C:\working\pstemp\x-files-episodes.csv -Delimiter ";"

$subLinks = $($res.links | Where-Object innertext -match "\d*x" | Where-Object href -like "*download*" | Select-Object -ExpandProperty href) -replace "-all","-eng"

$episodeCounter = 1
$seasonTracker = 1

for ($i=0;$i -lt $csv.count; $i++) {

    if ($seasonTracker -ne $csv[$i].Season) {
        $seasonTracker++
        $episodeCounter = 1
    }

    $epi = @{
        EpisodeName = $csv[$i].Title
        Season      = $csv[$i].Season
        EpisodeNumber = $("{0:d2}" -f $episodeCounter)
        DownloadURL = "https://www.opensubtitles.org$($sublinks[$i])"
    }

    $epi += @{ FullEpisodeName = "X-Files.1993.S$($epi.Season)E$($epi.EpisodeNumber).$($epi.EpisodeName.Replace(" ","."))"}

    $episodeCounter++

    Write-Verbose "Episode URL $($epi.DownloadUrl)" -Verbose
    #$epi
    Invoke-WebRequest $epi.DownloadUrl -OutFile "C:\working\pstemp\x-files\$([pscustomobject]$epi.FullEpisodeName).zip"
    Start-sleep 0.5
}