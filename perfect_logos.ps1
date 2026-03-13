Add-Type -AssemblyName System.Drawing

$img = [System.Drawing.Bitmap]::FromFile("f:\home\card.jpg")
$bgR = 102; $bgG = 46; $bgB = 64

$startY = 10
$endY = 250
$startX = 20
$endX = $img.Width - 20

$width = $endX - $startX
$height = $endY - $startY

$logoBlack = New-Object System.Drawing.Bitmap($width, $height)
$logoWhite = New-Object System.Drawing.Bitmap($width, $height)

for ($y = 0; $y -lt $height; $y++) {
    for ($x = 0; $x -lt $width; $x++) {
        $p = $img.GetPixel($x + $startX, $y + $startY)
        
        $dist = [Math]::Abs($p.R - $bgR) + [Math]::Abs($p.G - $bgG) + [Math]::Abs($p.B - $bgB)
        $alpha = [int]($dist / 553.0 * 255.0 * 3.0) 
        if ($alpha -gt 255) { $alpha = 255 }
        if ($dist -lt 50) { $alpha = 0 } # Remove JPEG artifacts
        
        $cBlack = [System.Drawing.Color]::FromArgb($alpha, 0, 0, 0)
        $cWhite = [System.Drawing.Color]::FromArgb($alpha, 255, 255, 255)
        
        $logoBlack.SetPixel($x, $y, $cBlack)
        $logoWhite.SetPixel($x, $y, $cWhite)
    }
}

$logoBlack.Save("f:\home\logo-black.png", [System.Drawing.Imaging.ImageFormat]::Png)
$logoWhite.Save("f:\home\logo-white.png", [System.Drawing.Imaging.ImageFormat]::Png)

$img.Dispose()
$logoBlack.Dispose()
$logoWhite.Dispose()
Write-Output "Perfect transparent logos generated successfully."
