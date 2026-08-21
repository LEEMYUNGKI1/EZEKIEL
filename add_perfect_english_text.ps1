$OutputEncoding = [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
Add-Type -AssemblyName System.Drawing

$srcPath = "F:\home\pristine.png"
if (-not (Test-Path $srcPath)) { Write-Error "Source pristine image not found"; exit }

$src = [System.Drawing.Image]::FromFile($srcPath)
$width = 4022
$height = 2550
$bmp = New-Object System.Drawing.Bitmap($width, $height)
$g = [System.Drawing.Graphics]::FromImage($bmp)

# Upscale settings
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$g.DrawImage($src, 0, 0, $width, $height)
$src.Dispose()

# Text settings
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias
$fontDesc = New-Object System.Drawing.Font("Arial", 40, [System.Drawing.FontStyle]::Regular)
$fontBanner = New-Object System.Drawing.Font("Arial", 42, [System.Drawing.FontStyle]::Regular)
$textColor = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 34, 34, 34))

$formatRight = New-Object System.Drawing.StringFormat
$formatRight.Alignment = [System.Drawing.StringAlignment]::Far
$formatRight.LineAlignment = [System.Drawing.StringAlignment]::Near

$formatLeft = New-Object System.Drawing.StringFormat
$formatLeft.Alignment = [System.Drawing.StringAlignment]::Near
$formatLeft.LineAlignment = [System.Drawing.StringAlignment]::Near

$text1 = "It is the basic spirit of Ezekiel Cosmetics Co., Ltd.`nto contribute to the local economy by providing`nsatisfaction to customers and creating jobs through`nstrict quality control in the spirit of creation and innovation."
$text2 = "The community's contribution to growing with customers`nbased on honesty and credit as a transparent ethical`nenterprise is the fundamental spirit of`nEzekiel Cosmetics Co., Ltd."
$text3 = "Ezekiel Cosmetics Co., Ltd. promises to contribute to the`nspirit of management to become a company that learns and serves`ncustomers and develops together in their lives."
$text4 = "Moving forward, Ezekiel Cosmetics Co., Ltd., as a specialized R&D and manufacturing company`nbased on innovative management philosophy, will continue to steadily grow and make rapid progress`nby securing excellent research personnel, developing new technologies,`nand pioneering domestic and overseas markets with leading marketing."

$rect1 = New-Object System.Drawing.RectangleF(0, 620, 1100, 600)
$rect2 = New-Object System.Drawing.RectangleF(2750, 420, 950, 600)
$rect3 = New-Object System.Drawing.RectangleF(1750, 1640, 1600, 400)
$rect4 = New-Object System.Drawing.RectangleF(700, 2050, 2200, 500)

$g.DrawString($text1, $fontDesc, $textColor, $rect1, $formatRight)
$g.DrawString($text2, $fontDesc, $textColor, $rect2, $formatLeft)
$g.DrawString($text3, $fontDesc, $textColor, $rect3, $formatLeft)
$g.DrawString($text4, $fontBanner, $textColor, $rect4, $formatLeft)

$bmp.Save("F:\home\philosophy_en.png", [System.Drawing.Imaging.ImageFormat]::Png)

$g.Dispose()
$bmp.Dispose()
$fontDesc.Dispose()
$fontBanner.Dispose()
$textColor.Dispose()
$formatRight.Dispose()
$formatLeft.Dispose()

Write-Host "Success: Restored and cleanly generated 4K image."
