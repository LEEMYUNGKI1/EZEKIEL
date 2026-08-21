$OutputEncoding = [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
Add-Type -AssemblyName System.Drawing

$origPath = (Get-ChildItem -Path "f:\home\*.png" | Where-Object { $_.Length -eq 5665138 }).FullName | Select-Object -First 1
$orig = [System.Drawing.Image]::FromFile($origPath)
$bmp = New-Object System.Drawing.Bitmap($orig.Width, $orig.Height)
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.DrawImage($orig, 0, 0, $orig.Width, $orig.Height)

$pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(100, 255, 0, 0), 3)
$font = New-Object System.Drawing.Font("Arial", 25, [System.Drawing.FontStyle]::Bold)
$brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::Blue)

# Draw vertical lines
for ($x = 200; $x -lt $orig.Width; $x += 200) {
    $g.DrawLine($pen, $x, 0, $x, $orig.Height)
    $g.DrawString($x.ToString(), $font, $brush, $x, 50)
}

# Draw horizontal lines
for ($y = 200; $y -lt $orig.Height; $y += 200) {
    $g.DrawLine($pen, 0, $y, $orig.Width, $y)
    $g.DrawString($y.ToString(), $font, $brush, 50, $y)
}

$bmp.Save("F:\home\philosophy_grid.png", [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$bmp.Dispose()
$orig.Dispose()
$pen.Dispose()
$font.Dispose()
$brush.Dispose()
