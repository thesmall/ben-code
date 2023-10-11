function ConvertTo-Mkv {
<#
    .SYNOPSIS
        Convert an .mp4 H265 encoded file into .mkv format.

    .DESCRIPTION
        A very specific function for converting a .mp4 H265 encoded file into the .mkv format.

        This function will technically attempt to convert any video into MKV format.

    .EXAMPLE
        PS> ConvertTo-Mkv -FilePath "C:\Example\Path\Example.Movie.2016.1080p.BluRay.x265\Example.Movie.2016.1080p.BluRay.x265.mp4"

        'C:\Example\Path\Example.Movie.2016.1080p.BluRay.x265\Example.Movie.2016.1080p.BluRay.x265.mp4': Using the demultiplexer for the format 'QuickTime/MP4'.
        'C:\Example\Path\Example.Movie.2016.1080p.BluRay.x265\Example.Movie.2016.1080p.BluRay.x265.mp4' track 0: Using the output module for the format 'HEVC/H.265'.
        'C:\Example\Path\Example.Movie.2016.1080p.BluRay.x265\Example.Movie.2016.1080p.BluRay.x265.mp4' track 1: Using the output module for the format 'AAC'.
        The file 'C:\Example\Path\Example.Movie.2016.1080p.BluRay.x265\Example.Movie.2016.1080p.BluRay.x265.mkv' has been opened for writing.
        The cue entries (the index) are being written...
        Multiplexing took 1 minute 22 seconds.

#>
    param(
        [Parameter(
            ValueFromPipeline = $true
        )]
        [String] $FilePath,

        [String] $MkvMergePath = "C:\working\tools\mkvtoolnix\mkvmerge.exe",

        [Switch] $DeleteSourceOnCompletion
    )

    begin {

    }

    process {
        $item       = Get-Item $FilePath
        $inputFile  = $item.FullName
        $outputFile = $item.Fullname.Replace(".mp4",".mkv")

        . $MkvMergePath --ui-language en --priority lower --output "$outputFile" --language 0:und --language 1:en "$inputFile" --track-order 0:0,0:1

        if ($DeleteSourceOnCompletion) {
            Remove-Item $inputFile -Confirm:$false -Force
        }
    }

    end {

    }
}