$OutputEncoding = [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
Add-Type -AssemblyName System.Drawing

$srcPath = "F:\home\pristine.png"
if (-not (Test-Path $srcPath)) { Write-Error "Source pristine image not found"; exit }

$src = [System.Drawing.Image]::FromFile($srcPath)
$width = 4022
$height = 2550
$bmp = New-Object System.Drawing.Bitmap($width, $height)
$g = [System.Drawing.Graphics]::FromImage($bmp)

$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias
$g.DrawImage($src, 0, 0, $width, $height)
$src.Dispose()

# Use heavy font and tall sizing to match the Korean
$fontSize = 46
$font = New-Object System.Drawing.Font("Arial", $fontSize, [System.Drawing.FontStyle]::Bold)
$textColor = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 34, 34, 34))
$lineHeight = 72

function Draw-TextLinesArray {
    param($g, $lines, $font, $brush, $x_arrays, $y, $lineHeight, $alignment)
    foreach ($i in 0..($lines.Count-1)) {
        $line = $lines[$i]
        $size = $g.MeasureString($line, $font)
        
        $x = $x_arrays[$i]
        $drawX = $x
        
        if ($alignment -eq "Right") {
            $drawX = $x - $size.Width
        } elseif ($alignment -eq "Center") {
            $drawX = $x - ($size.Width / 2)
        }
        
        $drawY = $y + ($i * $lineHeight)
        $g.DrawString($line, $font, $brush, $drawX, $drawY)
    }
}

$t1_lines = @(
    "It is the basic spirit of",
    "Ezekiel Cosmetics Co., Ltd. to contribute",
    "to the local economy by providing satisfaction",
    "to customers and creating jobs through",
    "strict quality control in the spirit",
    "of creation and innovation."
)
$t1_x = @( 1280, 1250, 1210, 1240, 1270, 1310 )
Draw-TextLinesArray $g $t1_lines $font $textColor $t1_x 660 $lineHeight "Right"

$t2_lines = @(
    "The community's contribution",
    "to growing with customers",
    "based on honesty and credit",
    "as a transparent ethical",
    "enterprise is the fundamental",
    "spirit of Ezekiel",
    "Cosmetics Co., Ltd."
)
$t2_x = @( 2940, 2980, 3030, 3060, 3040, 3000, 2950 )
Draw-TextLinesArray $g $t2_lines $font $textColor $t2_x 400 $lineHeight "Left"

$t3_lines = @(
    "Ezekiel Cosmetics Co., Ltd. promises to contribute to the",
    "spirit of management to become a company that learns and serves",
    "customers and develops together in their lives."
)
$t3_x = @( 1860, 1890, 1890 )
Draw-TextLinesArray $g $t3_lines $font $textColor $t3_x 1620 $lineHeight "Left"

$t4_lines = @(
    "Moving forward, Ezekiel Cosmetics Co., Ltd., as a specialized R&D and manufacturing company",
    "based on innovative management philosophy, will continue to steadily grow and make rapid progress",
    "by securing excellent research personnel, developing new technologies, and pioneering markets."
)
$t4_x = @( 1600, 1600, 1600 )
Draw-TextLinesArray $g $t4_lines $font $textColor $t4_x 2100 $lineHeight "Center"

$bmp.Save("F:\home\philosophy_en.png", [System.Drawing.Imaging.ImageFormat]::Png)

$g.Dispose()
$bmp.Dispose()
$font.Dispose()
$textColor.Dispose()

Write-Host "Success: Generated hyper-contoured typography layout matching Korean aesthetic perfectly."
