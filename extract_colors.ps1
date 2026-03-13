Add-Type -AssemblyName System.Drawing

$imagePath = "f:\home\card.jpg"

$bmp = [System.Drawing.Bitmap]::FromFile($imagePath)
$width = $bmp.Width
$height = $bmp.Height

$samples = @(
    @($width * 0.1, $height * 0.1),
    @($width * 0.9, $height * 0.1),
    @($width * 0.1, $height * 0.9),
    @($width * 0.9, $height * 0.9),
    @($width * 0.5, $height * 0.05)
)

foreach ($p in $samples) {
    $x = [int]$p[0]
    $y = [int]$p[1]
    $pixelColor = $bmp.GetPixel($x, $y)
    $hexColor = "#{0:X2}{1:X2}{2:X2}" -f $pixelColor.R, $pixelColor.G, $pixelColor.B
    Write-Output "Sample at ($x, $y): $hexColor"
}

$bmp.Dispose()
