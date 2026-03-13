Add-Type -AssemblyName System.Drawing

$img = [System.Drawing.Bitmap]::FromFile("f:\home\card.jpg")
$bgR = 74; $bgG = 16; $bgB = 64

# Bounds (Expanded to not cut off "C O S M E T I C")
$startY = 10
$endY = 250
$startX = 20
$endX = $img.Width - 20

$width = $endX - $startX
$height = $endY - $startY

$logoLight = New-Object System.Drawing.Bitmap($width, $height)
$logoDark  = New-Object System.Drawing.Bitmap($width, $height)

for ($y = 0; $y -lt $height; $y++) {
    for ($x = 0; $x -lt $width; $x++) {
        $p = $img.GetPixel($x + $startX, $y + $startY)
        
        $diffR = $p.R - $bgR; if ($diffR -lt 0) { $diffR = 0 }
        $diffG = $p.G - $bgG; if ($diffG -lt 0) { $diffG = 0 }
        $diffB = $p.B - $bgB; if ($diffB -lt 0) { $diffB = 0 }
        
        $diff = [Math]::Max($diffR, [Math]::Max($diffG, $diffB))
        $t = $diff / 130.0  # boost brightness for solid text
        if ($t -gt 1.0) { $t = 1.0 }
        $alpha = [int]($t * 255)

        # Light logo: text is #4A1040
        $cLight = [System.Drawing.Color]::FromArgb($alpha, 74, 16, 64)
        $logoLight.SetPixel($x, $y, $cLight)

        # Dark logo: text is White
        $cDark = [System.Drawing.Color]::FromArgb($alpha, 255, 255, 255)
        $logoDark.SetPixel($x, $y, $cDark)
    }
}

$logoLight.Save("f:\home\logo-light.png", [System.Drawing.Imaging.ImageFormat]::Png)
$logoDark.Save("f:\home\logo-dark.png", [System.Drawing.Imaging.ImageFormat]::Png)

$img.Dispose()
$logoLight.Dispose()
$logoDark.Dispose()
Write-Output "Transparent logos generated successfully."
