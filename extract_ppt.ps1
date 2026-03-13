$pptPath = "f:\home\ezekiel.ppt"
$outDir = "f:\home\ppt_extract"
if (-Not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir }

try {
    $Application = New-Object -ComObject PowerPoint.Application
    # 0 = msoFalse, 1 = msoTrue, 2 = msoCTrue
    $Presentation = $Application.Presentations.Open($pptPath, 1, 0, 0)
    
    $slidesText = ""
    $imageCount = 1

    foreach ($Slide in $Presentation.Slides) {
        $slidesText += "Slide $($Slide.SlideIndex):`r`n"
        foreach ($Shape in $Slide.Shapes) {
            if ($Shape.HasTextFrame) {
                if ($Shape.TextFrame.HasText) {
                    $slidesText += $Shape.TextFrame.TextRange.Text + "`r`n"
                }
            }
            # msoPicture (13) or msoLinkedPicture (11)
            # Sometimes images are inside groups or other shapes, but let's just check type 13
            if ($Shape.Type -eq 13 -or $Shape.Type -eq 11) {
                $imgPath = Join-Path $outDir "slide_$($Slide.SlideIndex)_img_$imageCount.png"
                $Shape.Export($imgPath, 2) # ppShapeFormatPNG (2)
                $imageCount++
            }
        }
        $slidesText += "`r`n"
    }

    $slidesText | Out-File (Join-Path $outDir "content.txt") -Encoding utf8
    Write-Output "Extraction successful"
} catch {
    Write-Error "Failed to extract PPT: $_"
} finally {
    if ($Presentation) {
        $Presentation.Close()
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($Presentation) | Out-Null
    }
    if ($Application) {
        $Application.Quit()
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($Application) | Out-Null
    }
}
