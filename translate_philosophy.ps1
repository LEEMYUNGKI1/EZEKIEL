$OutputEncoding = [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
Add-Type -AssemblyName System.Drawing

$jsonContent = Get-Content -Path "f:\home\translations.json" -Raw -Encoding UTF8
$data = $jsonContent | ConvertFrom-Json

function Create-TranslatedImage {
    param(
        [string]$Lang,
        [string]$OutputFile,
        [string]$T1_Title, [string]$T1_Desc,
        [string]$T2_Title, [string]$T2_Desc,
        [string]$T3_Title, [string]$T3_Desc,
        [string]$T4_Desc
    )
    
    $origPath = (Get-ChildItem -Path "f:\home\*.png" | Where-Object { $_.Length -eq 5665138 }).FullName | Select-Object -First 1
    
    $orig = [System.Drawing.Image]::FromFile($origPath)
    $bmp = New-Object System.Drawing.Bitmap($orig.Width, $orig.Height)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.DrawImage($orig, 0, 0, $orig.Width, $orig.Height)
    $orig.Dispose()
    
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias
    
    $whiteBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    
    # Very tight erase boxes to preserve bubbles and arrows
    # 1. Left Text "창조와 혁신의 정신으로..." is horizontally aligned, W~550px
    $g.FillRectangle($whiteBrush, 280, 480, 570, 250)
    # 2. Right Text "정직과 신용을 바탕으로..."
    $g.FillRectangle($whiteBrush, 1750, 230, 680, 250)
    # 3. Bottom Text "(주)에스겔코스메틱은..."
    $g.FillRectangle($whiteBrush, 1120, 1070, 1100, 130)
    
    # 4. Banner Text
    $bannerColor = $bmp.GetPixel(400, 1450)
    $bannerBrush = New-Object System.Drawing.SolidBrush($bannerColor)
    $g.FillRectangle($bannerBrush, 325, 1370, 1500, 150)

    $fontFamily = "Malgun Gothic"
    if ($Lang -eq "ENG") { $fontFamily = "Arial" }
    
    # Much more reasonable font sizes for tight areas
    $titleFont = New-Object System.Drawing.Font($fontFamily, 36, [System.Drawing.FontStyle]::Bold)
    $descFont = New-Object System.Drawing.Font($fontFamily, 26, [System.Drawing.FontStyle]::Regular)
    $textColor = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::Black)
    $strongColor = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 60, 60, 60))

    $formatLeft = New-Object System.Drawing.StringFormat
    $formatLeft.Alignment = [System.Drawing.StringAlignment]::Far
    $formatLeft.LineAlignment = [System.Drawing.StringAlignment]::Near
    
    $formatRight = New-Object System.Drawing.StringFormat
    $formatRight.Alignment = [System.Drawing.StringAlignment]::Near
    $formatRight.LineAlignment = [System.Drawing.StringAlignment]::Near

    # Draw T1 (Left side, right aligned) perfectly inside wiped region
    $r1_t   = New-Object System.Drawing.RectangleF(280, 480, 570, 70)
    $r1_d   = New-Object System.Drawing.RectangleF(280, 550, 570, 180)
    $g.DrawString($T1_Title, $titleFont, $textColor, $r1_t, $formatLeft)
    $g.DrawString($T1_Desc, $descFont, $strongColor, $r1_d, $formatLeft)

    # Draw T2 (Right side, left aligned)
    $r2_t   = New-Object System.Drawing.RectangleF(1750, 230, 680, 70)
    $r2_d   = New-Object System.Drawing.RectangleF(1750, 300, 680, 180)
    $g.DrawString($T2_Title, $titleFont, $textColor, $r2_t, $formatRight)
    $g.DrawString($T2_Desc, $descFont, $strongColor, $r2_d, $formatRight)

    # Draw T3 (Bottom) -> single line Title and Desc beside each other? No, stack them
    $r3_t   = New-Object System.Drawing.RectangleF(1120, 1060, 1100, 60)
    $r3_d   = New-Object System.Drawing.RectangleF(1120, 1120, 1100, 80)
    $g.DrawString($T3_Title, $titleFont, $textColor, $r3_t, $formatRight)
    $g.DrawString($T3_Desc, $descFont, $strongColor, $r3_d, $formatRight)

    # Draw T4 (Banner) -> single line or wrapped
    $r4_d = New-Object System.Drawing.RectangleF(325, 1370, 1500, 150)
    $g.DrawString($T4_Desc, $descFont, $textColor, $r4_d, $formatRight)

    $bmp.Save($OutputFile, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
    $whiteBrush.Dispose()
    $bannerBrush.Dispose()
    
    Write-Host "Created $OutputFile"
}

Write-Host "Creating ENG image..."
Create-TranslatedImage "ENG" "f:\home\philosophy_en.png" $data.ENG.t1_title $data.ENG.t1_desc $data.ENG.t2_title $data.ENG.t2_desc $data.ENG.t3_title $data.ENG.t3_desc $data.ENG.t4_desc

Write-Host "Creating CHN image..."
Create-TranslatedImage "CHN" "f:\home\philosophy_cn.png" $data.CHN.t1_title $data.CHN.t1_desc $data.CHN.t2_title $data.CHN.t2_desc $data.CHN.t3_title $data.CHN.t3_desc $data.CHN.t4_desc

Write-Host "Done generating images."
