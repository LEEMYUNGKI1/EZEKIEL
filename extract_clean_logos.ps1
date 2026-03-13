Add-Type -AssemblyName System.Drawing

$img = [System.Drawing.Bitmap]::FromFile("f:\home\card.jpg")
# The exact background color from the card we extracted earlier was #4A1040, which is (74, 16, 64)
# We need to make this color fully transparent.

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
        
        # Calculate how close the pixel is to WHITE (the text color in the original image)
        # The text is white (255,255,255), the background is purple (74,16,64)
        
        # A simple way to extract the text: text pixels have high RGB values.
        # Let's use the Green channel as a brightness indicator since it's 16 in BG and 255 in Text
        $brightness = $p.G 
        
        # Normalize alpha based on green channel (16 to 255) -> (0 to 255)
        $alpha = [int](($brightness - 16) / (255.0 - 16.0) * 255.0)
        
        # Clamp alpha
        if ($alpha -lt 0) { $alpha = 0 }
        if ($alpha -gt 255) { $alpha = 255 }

        # For logoLight, we want Purple text (#4A1040) on transparent background
        $cLight = [System.Drawing.Color]::FromArgb($alpha, 74, 16, 64)
        $logoLight.SetPixel($x, $y, $cLight)

        # For logoDark, we want White text on transparent background
        $cDark = [System.Drawing.Color]::FromArgb($alpha, 255, 255, 255)
        $logoDark.SetPixel($x, $y, $cDark)
    }
}

$logoLight.Save("f:\home\logo-light.png", [System.Drawing.Imaging.ImageFormat]::Png)
$logoDark.Save("f:\home\logo-dark.png", [System.Drawing.Imaging.ImageFormat]::Png)

$img.Dispose()
$logoLight.Dispose()
$logoDark.Dispose()
Write-Output "Perfect transparent logos generated successfully."
