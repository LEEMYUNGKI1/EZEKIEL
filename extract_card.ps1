Add-Type -AssemblyName System.Drawing

$imagePath = "f:\home\card.jpg"
$outLogoPath = "f:\home\logo.png"

$bmp = [System.Drawing.Bitmap]::FromFile($imagePath)
$width = $bmp.Width
$height = $bmp.Height

# Get color from top-left (0,0)
$pixelColor = $bmp.GetPixel(0, 0)
$hexColor = "#{0:X2}{1:X2}{2:X2}" -f $pixelColor.R, $pixelColor.G, $pixelColor.B

# Crop the top 35% where EZEKIEL COSMETIC is
$cropY = 0
$cropHeight = [int]($height * 0.35)
$cropWidth = $width
$cropX = 0

$rect = New-Object System.Drawing.Rectangle($cropX, $cropY, $cropWidth, $cropHeight)
$croppedBmp = $bmp.Clone($rect, $bmp.PixelFormat)

$croppedBmp.Save($outLogoPath, [System.Drawing.Imaging.ImageFormat]::Png)

Write-Output "Image Size: ${width}x${height}"
Write-Output "Background Color: $hexColor"
Write-Output "Cropped Logo saved to $outLogoPath"

$croppedBmp.Dispose()
$bmp.Dispose()
