$OutputEncoding = [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
Add-Type -AssemblyName System.Drawing

$origPath = "F:\home\philosophy_en.png"
if (-not (Test-Path $origPath)) {
    Write-Error "Could not find $origPath"
    exit
}

$orig = [System.Drawing.Image]::FromFile($origPath)
$bmp = New-Object System.Drawing.Bitmap($orig.Width, $orig.Height)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.DrawImage($orig, 0, 0, $orig.Width, $orig.Height)
$orig.Dispose()

$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias

# Setup fonts and colors
$fontTitle = New-Object System.Drawing.Font("Arial", 25, [System.Drawing.FontStyle]::Bold)
$fontDesc = New-Object System.Drawing.Font("Arial", 18, [System.Drawing.FontStyle]::Regular)
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

# Texts
$T1_Title = "1.Creation and Innovation"
$T1_Desc = "It is the basic spirit of Ezekiel Cosmetics Co., Ltd. to contribute to the local economy by providing satisfaction to customers and creating jobs through strict quality control in the spirit of creation and innovation."

$T2_Title = "2.Honesty and Credibility"
$T2_Desc = "The community's contribution to growing with customers based on honesty and credit as a transparent ethical enterprise is the fundamental spirit of Ezekiel Cosmetics Co., Ltd."

$T3_Title = "3.Proper management"
$T3_Desc = "Ezekiel Cosmetics Co., Ltd. promises to contribute to the spirit of management to become a company that learns and serves customers and develops together in their lives."

# R1 (Position 1)
$r1_t   = New-Object System.Drawing.RectangleF(130, 440, 600, 50)
$r1_d   = New-Object System.Drawing.RectangleF(130, 490, 600, 250)
$g.DrawString($T1_Title, $fontTitle, $textColor, $r1_t, $formatLeft)
$g.DrawString($T1_Desc, $fontDesc, $strongColor, $r1_d, $formatLeft)

# R2 (Position 2)
$r2_t   = New-Object System.Drawing.RectangleF(1730, 200, 750, 50)
$r2_d   = New-Object System.Drawing.RectangleF(1730, 250, 750, 250)
$g.DrawString($T2_Title, $fontTitle, $textColor, $r2_t, $formatRight)
$g.DrawString($T2_Desc, $fontDesc, $strongColor, $r2_d, $formatRight)

# R3 (Position 3)
$r3_t   = New-Object System.Drawing.RectangleF(1120, 1040, 1100, 50)
$r3_d   = New-Object System.Drawing.RectangleF(1120, 1090, 1100, 150)
$g.DrawString($T3_Title, $fontTitle, $textColor, $r3_t, $formatRight)
$g.DrawString($T3_Desc, $fontDesc, $strongColor, $r3_d, $formatRight)

$bmp.Save("F:\home\philosophy_en.png", [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$bmp.Dispose()
$fontTitle.Dispose()
$fontDesc.Dispose()
$textColor.Dispose()
$strongColor.Dispose()

Write-Host "Image successfully created at F:\home\philosophy_en.png"
