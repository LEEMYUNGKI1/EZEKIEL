Add-Type -AssemblyName System.Drawing

$img = [System.Drawing.Bitmap]::FromFile("f:\home\card.jpg")

# Extraction bounds
$startY = 10; $endY = 250
$startX = 20; $endX = $img.Width - 20
$width = $endX - $startX
$height = $endY - $startY

$logoBlack = New-Object System.Drawing.Bitmap($width, $height)
$logoWhite = New-Object System.Drawing.Bitmap($width, $height)

for ($y = 0; $y -lt $height; $y++) {
    for ($x = 0; $x -lt $width; $x++) {
        $p = $img.GetPixel($x + $startX, $y + $startY)
        
        # Calculate mask based on difference from background color (#662E40 -> 102, 46, 64)
        # White text is #FFFFFF (255, 255, 255)
        # We'll use the distance from the background color to determine alpha.
        $bgR = 102; $bgG = 46; $bgB = 64
        $dist = [Math]::Sqrt([Math]::Pow($p.R - $bgR, 2) + [Math]::Pow($p.G - $bgG, 2) + [Math]::Pow($p.B - $bgB, 2))
        
        # Normalize dist: max distance is from purple to white (~230)
        $threshold = 80
        $maxDist = 150
        
        $alpha = 0
        if ($dist -gt $threshold) {
            $alpha = [int](($dist - $threshold) / ($maxDist - $threshold) * 255)
            if ($alpha -gt 255) { $alpha = 255 }
        }
        
        # Smooth alpha for better edges
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
Write-Output "Logos generated: logo-black.png, logo-white.png"
