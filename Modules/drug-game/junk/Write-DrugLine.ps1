function Write-DrugLine {
    param($Drug)

    $fgColorChange = switch ($Drug.Change) {
        "^" { "Green" }
        "v" { "Red"   }
    }

    if ($Drug.Change) {
        Write-Host -Object $drug.Change -ForegroundColor $fgColorChange -NoNewLine
    }
    else {
        Write-Host -Object "   " -NoNewLine
    }
    Write-Host -Object "  " -NoNewLine
    Write-Host -Object "$($drug.Name)         $($drug.Quantity)          $($drug.Price)"
}