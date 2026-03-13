Add-Type -AssemblyName System.Drawing

$imagePath = "f:\home\card.jpg"

$bmp = [System.Drawing.Bitmap]::FromFile($imagePath)
$width = $bmp.Width
$height = $bmp.Height

# Get color from center (width/2, height/2)
$pixelColor = $bmp.GetPixel($width/2, $height/2 + 50)
$hexColor = "#{0:X2}{1:X2}{2:X2}" -f $pixelColor.R, $pixelColor.G, $pixelColor.B

Write-Output "Center Background Color: $hexColor"

$bmp.Dispose()
