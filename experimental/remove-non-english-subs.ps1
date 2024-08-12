$subs = Get-ChildItem 'E:\TVShows\Show.S04.1080p.WEBRip.x265\Subs\' -Recurse -Filter "*.srt"

foreach ($s in $subs) {
    if ($s.Name -notmatch "_English.srt") {
        Remove-Item $s.FullName
    }
}