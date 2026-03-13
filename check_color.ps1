Add-Type -AssemblyName System.Drawing

$img = [System.Drawing.Bitmap]::FromFile("f:\home\card.jpg")
$width = $img.Width

# Let's sample a few pixels from the top part, avoiding the very edges (which might be dark)
$samples = @(
    $img.GetPixel(50, 50),
    $img.GetPixel(100, 50),
    $img.GetPixel($width / 2, 50),
    $img.GetPixel($width - 50, 50)
)

foreach ($p in $samples) {
    $hex = "#{0:X2}{1:X2}{2:X2}" -f $p.R, $p.G, $p.B
    Write-Output "Sample: $hex (R:$($p.R), G:$($p.G), B:$($p.B))"
}

$img.Dispose()
