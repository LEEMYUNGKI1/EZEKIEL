$OutputEncoding = [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
Add-Type -AssemblyName System.Drawing

$jsonContent = Get-Content -Path "f:\home\translations.json" -Raw -Encoding UTF8
$data = $jsonContent | ConvertFrom-Json

function InpaintRect($bmp, [System.Drawing.Rectangle]$r) {
    for ($y = $r.Top; $y -lt $r.Bottom; $y++) {
        for ($x = $r.Left; $x -lt $r.Right; $x++) {
            $p = $bmp.GetPixel($x, $y)
            # Use 205 threshold to aggressively capture text aliasing!
            if ($p.R -lt 205 -and $p.G -lt 205 -and $p.B -lt 205) {
                $up = $y - 1; $foundUp = $false
                while ($up -ge $r.Top) {
                    $c = $bmp.GetPixel($x, $up)
                    if ($c.R -ge 205) { $foundUp = $true; break }
                    $up--
                }
                
                $down = $y + 1; $foundDown = $false
                while ($down -lt $r.Bottom) {
                    $c = $bmp.GetPixel($x, $down)
                    if ($c.R -ge 205) { $foundDown = $true; break }
                    $down++
                }
                
                $color = [System.Drawing.Color]::White
                if (-not $foundUp -and -not $foundDown) { $color = [System.Drawing.Color]::White }
                elseif (-not $foundUp) { $color = $bmp.GetPixel($x, $down) }
                elseif (-not $foundDown) { $color = $bmp.GetPixel($x, $up) }
                else {
                    $c1 = $bmp.GetPixel($x, $up)
                    $c2 = $bmp.GetPixel($x, $down)
                    $wUp = $down - $y
                    $wDown = $y - $up
                    $tot = $wUp + $wDown
                    $color = [System.Drawing.Color]::FromArgb(
                        [int](($c1.R * $wUp + $c2.R * $wDown) / $tot),
                        [int](($c1.G * $wUp + $c2.G * $wDown) / $tot),
                        [int](($c1.B * $wUp + $c2.B * $wDown) / $tot)
                    )
                }
                $bmp.SetPixel($x, $y, $color)
            }
        }
    }
}

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
    
    # Fully expanded inpainting areas hitting exactly up to the 1, 2, 3 graphic bubbles
    InpaintRect $bmp (New-Object System.Drawing.Rectangle(130, 440, 600, 300))  # Left
    InpaintRect $bmp (New-Object System.Drawing.Rectangle(1730, 200, 750, 300)) # Right
    InpaintRect $bmp (New-Object System.Drawing.Rectangle(1120, 1050, 1100, 150)) # Bottom
    InpaintRect $bmp (New-Object System.Drawing.Rectangle(300, 1370, 1500, 160)) # Banner

    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias
    
    if ($Lang -eq "ENG") {
        $fontTitle = New-Object System.Drawing.Font("Arial", 25, [System.Drawing.FontStyle]::Bold)
        $fontDesc = New-Object System.Drawing.Font("Arial", 18, [System.Drawing.FontStyle]::Regular)
    } else {
        $fontTitle = New-Object System.Drawing.Font("Microsoft YaHei", 25, [System.Drawing.FontStyle]::Bold)
        $fontDesc = New-Object System.Drawing.Font("Microsoft YaHei", 18, [System.Drawing.FontStyle]::Regular)
    }
    
    $textColor = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::Black)
    $strongColor = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 30, 30, 30))

    $formatLeft = New-Object System.Drawing.StringFormat
    $formatLeft.Alignment = [System.Drawing.StringAlignment]::Far
    $formatLeft.LineAlignment = [System.Drawing.StringAlignment]::Near
    
    $formatRight = New-Object System.Drawing.StringFormat
    $formatRight.Alignment = [System.Drawing.StringAlignment]::Near
    $formatRight.LineAlignment = [System.Drawing.StringAlignment]::Near
    
    $formatCenter = New-Object System.Drawing.StringFormat
    $formatCenter.Alignment = [System.Drawing.StringAlignment]::Center
    $formatCenter.LineAlignment = [System.Drawing.StringAlignment]::Center

    # Drawing text securely inside the perfectly cleaned inpainted rectangles
    $r1_t   = New-Object System.Drawing.RectangleF(130, 440, 600, 50)
    $r1_d   = New-Object System.Drawing.RectangleF(130, 490, 600, 250)
    $g.DrawString($T1_Title, $fontTitle, $textColor, $r1_t, $formatLeft)
    $g.DrawString($T1_Desc, $fontDesc, $strongColor, $r1_d, $formatLeft)

    $r2_t   = New-Object System.Drawing.RectangleF(1730, 200, 750, 50)
    $r2_d   = New-Object System.Drawing.RectangleF(1730, 250, 750, 250)
    $g.DrawString($T2_Title, $fontTitle, $textColor, $r2_t, $formatRight)
    $g.DrawString($T2_Desc, $fontDesc, $strongColor, $r2_d, $formatRight)

    $r3_t   = New-Object System.Drawing.RectangleF(1120, 1040, 1100, 50)
    $r3_d   = New-Object System.Drawing.RectangleF(1120, 1090, 1100, 150)
    $g.DrawString($T3_Title, $fontTitle, $textColor, $r3_t, $formatRight)
    $g.DrawString($T3_Desc, $fontDesc, $strongColor, $r3_d, $formatRight)

    $r4_d = New-Object System.Drawing.RectangleF(300, 1380, 1500, 150)
    $g.DrawString($T4_Desc, $fontDesc, $textColor, $r4_d, $formatCenter)

    $bmp.Save($OutputFile, [System.Drawing.Imaging.ImageFormat]::Png)
    $g.Dispose()
    $bmp.Dispose()
    $fontTitle.Dispose()
    $fontDesc.Dispose()
    $textColor.Dispose()
    $strongColor.Dispose()
    
    Write-Host "Created $OutputFile"
}

Write-Host "Inpainting and Creating ENG image..."
Create-TranslatedImage "ENG" "f:\home\philosophy_en.png" $data.ENG.t1_title $data.ENG.t1_desc $data.ENG.t2_title $data.ENG.t2_desc $data.ENG.t3_title $data.ENG.t3_desc $data.ENG.t4_desc

Write-Host "Inpainting and Creating CHN image..."
Create-TranslatedImage "CHN" "f:\home\philosophy_cn.png" $data.CHN.t1_title $data.CHN.t1_desc $data.CHN.t2_title $data.CHN.t2_desc $data.CHN.t3_title $data.CHN.t3_desc $data.CHN.t4_desc

Write-Host "Done generating images."
