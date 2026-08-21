$OutputEncoding = [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
Add-Type -AssemblyName System.Drawing

function InpaintRect($bmp, [System.Drawing.Rectangle]$r) {
    for ($y = $r.Top; $y -lt $r.Bottom; $y++) {
        for ($x = $r.Left; $x -lt $r.Right; $x++) {
            $p = $bmp.GetPixel($x, $y)
            # Threshold to capture the dark text aliasing we drew
            if ($p.R -lt 200 -and $p.G -lt 200 -and $p.B -lt 200) {
                $up = $y - 1; $foundUp = $false
                while ($up -ge $r.Top) {
                    $c = $bmp.GetPixel($x, $up)
                    if ($c.R -ge 200) { $foundUp = $true; break }
                    $up--
                }
                
                $down = $y + 1; $foundDown = $false
                while ($down -lt $r.Bottom) {
                    $c = $bmp.GetPixel($x, $down)
                    if ($c.R -ge 200) { $foundDown = $true; break }
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

$origPath = "F:\home\philosophy_en.png"
if (-not (Test-Path $origPath)) { Write-Error "Image not found"; exit }

$orig = [System.Drawing.Image]::FromFile($origPath)
$bmp = New-Object System.Drawing.Bitmap($orig.Width, $orig.Height)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.DrawImage($orig, 0, 0, $orig.Width, $orig.Height)
$orig.Dispose()

$whiteBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)

# Erase previous bad text
# Text 1 area (pure white background)
$g.FillRectangle($whiteBrush, 100, 420, 650, 330)
# Text 2 area (pure white background)
$g.FillRectangle($whiteBrush, 1700, 180, 800, 330)
# Text 3 area (overlaps shadow slightly, so we use InpaintRect to perfectly recover shadow pixels)
InpaintRect $bmp (New-Object System.Drawing.Rectangle(1100, 1020, 1150, 250))

$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias

# Set up beautiful typography to match the exact aesthetics of Korean text
$fontFamily = "Arial"
# Size scaled for 4022x2550
$fontDesc = New-Object System.Drawing.Font($fontFamily, 32, [System.Drawing.FontStyle]::Regular)
$fontBanner = New-Object System.Drawing.Font($fontFamily, 34, [System.Drawing.FontStyle]::Regular)

$strongColor = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 30, 30, 30))

$formatRight = New-Object System.Drawing.StringFormat
$formatRight.Alignment = [System.Drawing.StringAlignment]::Far
$formatRight.LineAlignment = [System.Drawing.StringAlignment]::Near

$formatLeft = New-Object System.Drawing.StringFormat
$formatLeft.Alignment = [System.Drawing.StringAlignment]::Near
$formatLeft.LineAlignment = [System.Drawing.StringAlignment]::Near

# Text strings with exact line breaks to shape the paragraph beautifully
$text1 = "It is the basic spirit of Ezekiel Cosmetics Co., Ltd.`nto contribute to the local economy by providing`nsatisfaction to customers and creating jobs through`nstrict quality control in the spirit of creation and innovation."
$text2 = "The community's contribution to growing with customers`nbased on honesty and credit as a transparent ethical`nenterprise is the fundamental spirit of`nEzekiel Cosmetics Co., Ltd."
$text3 = "Ezekiel Cosmetics Co., Ltd. promises to contribute to the`nspirit of management to become a company that learns and serves`ncustomers and develops together in their lives."
$text4 = "Moving forward, Ezekiel Cosmetics Co., Ltd., as a specialized R&D and manufacturing company`nbased on innovative management philosophy, will continue to steadily grow and make rapid progress`nby securing excellent research personnel, developing new technologies,`nand pioneering domestic and overseas markets with leading marketing."

# Carefully measured exact coordinate placements
$rect1 = New-Object System.Drawing.RectangleF(350, 640, 800, 400)
$rect2 = New-Object System.Drawing.RectangleF(2750, 450, 900, 400)
$rect3 = New-Object System.Drawing.RectangleF(1750, 1680, 1600, 200)
$rect4 = New-Object System.Drawing.RectangleF(600, 2100, 2200, 400)

$g.DrawString($text1, $fontDesc, $strongColor, $rect1, $formatRight)
$g.DrawString($text2, $fontDesc, $strongColor, $rect2, $formatLeft)
$g.DrawString($text3, $fontDesc, $strongColor, $rect3, $formatLeft)
$g.DrawString($text4, $fontBanner, $strongColor, $rect4, $formatLeft)

$bmp.Save("F:\home\philosophy_en.png", [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$bmp.Dispose()
$whiteBrush.Dispose()
$fontDesc.Dispose()
$fontBanner.Dispose()
$strongColor.Dispose()

Write-Host "Success: Restored and correctly formatted."
