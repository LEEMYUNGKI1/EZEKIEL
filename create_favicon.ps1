Add-Type -AssemblyName System.Drawing

# Use the latest rounded square image
$sourcePath = Join-Path $env:USERPROFILE ".gemini\antigravity\brain\2d091c4c-010c-4caf-b088-c4740e000869\media__1777360545338.png"

function Get-MaximizedRoundedImage {
    param($srcImg, $size, $radius)
    
    # 1. Find bounding box of the icon (non-white pixels)
    $left = $srcImg.Width; $top = $srcImg.Height; $right = 0; $bottom = 0
    $found = $false
    
    # Sample pixels to find boundaries
    for ($y = 0; $y -lt $srcImg.Height; $y += 2) {
        for ($x = 0; $x -lt $srcImg.Width; $x += 2) {
            $p = $srcImg.GetPixel($x, $y)
            if ($p.R -lt 253 -or $p.G -lt 253 -or $p.B -lt 253) {
                if ($x -lt $left) { $left = $x }
                if ($x -gt $right) { $right = $x }
                if ($y -lt $top) { $top = $y }
                if ($y -gt $bottom) { $bottom = $y }
                $found = $true
            }
        }
    }
    
    if (-not $found) { 
        $left = 0; $top = 0; $right = $srcImg.Width - 1; $bottom = $srcImg.Height - 1 
    }
    
    $cropW = $right - $left + 1
    $cropH = $bottom - $top + 1
    
    # 2. Create the destination bitmap
    $dest = New-Object System.Drawing.Bitmap($size, $size)
    $g = [System.Drawing.Graphics]::FromImage($dest)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.Clear([System.Drawing.Color]::Transparent)
    
    # 3. Apply rounded mask (slightly inside to ensure no white edges)
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $diameter = $radius * 2
    $path.AddArc(0, 0, $diameter, $diameter, 180, 90)
    $path.AddArc($size - $diameter, 0, $diameter, $diameter, 270, 90)
    $path.AddArc($size - $diameter, $size - $diameter, $diameter, $diameter, 0, 90)
    $path.AddArc(0, $size - $diameter, $diameter, $diameter, 90, 90)
    $path.CloseFigure()
    $g.SetClip($path)
    
    # 4. Draw the CROPPED icon area to fill the size
    $srcRect = New-Object System.Drawing.Rectangle($left, $top, $cropW, $cropH)
    $destRect = New-Object System.Drawing.Rectangle(0, 0, $size, $size)
    $g.DrawImage($srcImg, $destRect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)
    
    $path.Dispose()
    $g.Dispose()
    return $dest
}

if ($sourcePath -and (Test-Path $sourcePath)) {
    Write-Output "Maximizing and rounded corner processing: $sourcePath"
    $srcImg = [System.Drawing.Bitmap]::FromFile($sourcePath)
    
    # Radius is adjusted for maximized fit (approx 18% of size)
    
    $dest32 = Get-MaximizedRoundedImage -srcImg $srcImg -size 32 -radius 6
    $dest32.Save("f:\home\favicon-32x32.png", [System.Drawing.Imaging.ImageFormat]::Png)
    
    $dest16 = Get-MaximizedRoundedImage -srcImg $srcImg -size 16 -radius 3
    $dest16.Save("f:\home\favicon-16x16.png", [System.Drawing.Imaging.ImageFormat]::Png)

    $dest48 = Get-MaximizedRoundedImage -srcImg $srcImg -size 48 -radius 9
    $dest48.Save("f:\home\favicon-48x48.png", [System.Drawing.Imaging.ImageFormat]::Png)

    $dest256 = Get-MaximizedRoundedImage -srcImg $srcImg -size 256 -radius 45
    $dest256.Save("f:\home\favicon.png", [System.Drawing.Imaging.ImageFormat]::Png)

    $srcImg.Dispose()
    $dest32.Dispose()
    $dest16.Dispose()
    $dest48.Dispose()
    $dest256.Dispose()
    
    Write-Output "Maximized rounded favicons generated successfully."
} else {
    Write-Error "Source image not found: $sourcePath"
}
