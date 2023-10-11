function Rename-Subtitle {
<#
    .SYNOPSIS
        Renames subtitle files so that they can be correctly understood by Plex. 

    .DESCRIPTION
        Rename-Subtitle iterates over files matching a specific extension and attempts to rename the files while matching the subtitle files with their expected... capabilities.

        Specifically, when presented with one-to-three corresponding subtitle files for a given video file, they are often in an assumed order of "Standard", "SDH" and "Forced".
        
        With this assumed order, the function iterates over the files and renames them according to the video file they are associated with, while preserving the language and subtitle type in the file name.

    .EXAMPLE
        PS> Get-ChildItem E:\ExamplePath\TVShow.S01.1080p\ -Directory | Foreach-Object { Rename-Subtitle -Path $_.FullName -Verbose }

#>
    [CmdletBinding()]
    [OutputType()]
    param(
        $Path,

        $SubtitleExtension = "*.srt"
    )

    begin {

    }

    process {
        $episodes = Get-ChildItem -Path $Path -Directory
        
        foreach ($epi in $episodes) {
            Write-Verbose "Processing Episode: $($epi.Name)" -Verbose

            $subs = Get-ChildItem -Path $epi.FullName -Filter $SubtitleExtension -Recurse -File | 
                Sort-Object Name

            # Subtitle File BaseName
            $baseName = Split-Path $epi.FullName -Leaf

            for ($i=0; $i -lt $subs.Count; $i++) {
                Write-Verbose "Processing Subtitle: $($subs[$i].Name)" -Verbose

                switch ($i) {
                    0 { $subType = "Standard" }
                    1 { $subType = "SDH"      }
                    2 { $subType = "Forced"   }
                }
            
                #Determine Sub Language
                $subLang = switch ($true) {
                    ($subs[$i].Name -match "English")    { "en"; break }
                    ($subs[$i].Name -match "Arabic")     { "ar"; break }
                    ($subs[$i].Name -match "Chinese")    { "zh"; break }
                    ($subs[$i].Name -match "Czch")       { "cs"; break }
                    ($subs[$i].Name -match "Danish")     { "da"; break }
                    ($subs[$i].Name -match "Dutch")      { "nl"; break }
                    ($subs[$i].Name -match "Spanish")    { "es"; break }
                    ($subs[$i].Name -match "Finnish")    { "fi"; break }
                    ($subs[$i].Name -match "Greek")      { "el"; break }
                    ($subs[$i].Name -match "Hewbrew")    { "he"; break }
                    ($subs[$i].Name -match "Hungarian")  { "hu"; break }
                    ($subs[$i].Name -match "Indonesian") { "id"; break }
                    ($subs[$i].Name -match "Italian")    { "it"; break }
                    ($subs[$i].Name -match "Japanese")   { "ja"; break }
                    ($subs[$i].Name -match "Korean")     { "ko"; break }
                    ($subs[$i].Name -match "Polish")     { "pl"; break }
                    ($subs[$i].Name -match "Portuguese") { "pt"; break }
                    ($subs[$i].Name -match "Romanian")   { "ro"; break }
                    ($subs[$i].Name -match "Russian")    { "ru"; break }
                    ($subs[$i].Name -match "Swedish")    { "sv"; break }
                    ($subs[$i].Name -match "Thai")       { "th"; break }
                    ($subs[$i].Name -match "Turkish")    { "tr"; break }
                    ($subs[$i].Name -match "Vietnamese") { "vi"; break }
                    default { continue }
                }

                #Construct subtitle filename
                $fileName = switch ($subType) {
                    "Standard" { "$baseName.$subLang$($subs[$i].Extension)"        }
                    "SDH"      { "$baseName.$subLang.sdh$($subs[$i].Extension)"    }
                    "Forced"   { "$baseName.$subLang.forced$($subs[$i].Extension)" }
                }
                
                Rename-Item -Path $subs[$i].FullName -NewName $fileName
            }
        }
    }

    end {

    }
}