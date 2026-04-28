Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName System.Drawing.Drawing2D

# Use the REFINED image with true transparency
$sourcePath = Join-Path $env:USERPROFILE ".gemini\antigravity\brain\2d091c4c-010c-4caf-b088-c4740e000869\refined_skincare_favicon_icon_1777359982518.png"

function Get-ResizedIcon {
    param($srcImg, $size)
    $resized = New-Object System.Drawing.Bitmap($size, $size)
    $g = [System.Drawing.Graphics]::FromImage($resized)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.Clear([System.Drawing.Color]::Transparent)
    $g.DrawImage($srcImg, 0, 0, $size, $size)
    $g.Dispose()
    return $resized
}

if ($sourcePath -and (Test-Path $sourcePath)) {
    Write-Output "Processing refined image: $sourcePath"
    $srcImg = [System.Drawing.Bitmap]::FromFile($sourcePath)
    
    # Save with -refined suffix for comparison
    $dest32 = Get-ResizedIcon -srcImg $srcImg -size 32
    $dest32.Save("f:\home\favicon-refined-32x32.png", [System.Drawing.Imaging.ImageFormat]::Png)
    
    $dest16 = Get-ResizedIcon -srcImg $srcImg -size 16
    $dest16.Save("f:\home\favicon-refined-16x16.png", [System.Drawing.Imaging.ImageFormat]::Png)

    $dest48 = Get-ResizedIcon -srcImg $srcImg -size 48
    $dest48.Save("f:\home\favicon-refined-48x48.png", [System.Drawing.Imaging.ImageFormat]::Png)

    $dest256 = Get-ResizedIcon -srcImg $srcImg -size 256
    $dest256.Save("f:\home\favicon-refined.png", [System.Drawing.Imaging.ImageFormat]::Png)

    $srcImg.Dispose()
    $dest32.Dispose()
    $dest16.Dispose()
    $dest48.Dispose()
    $dest256.Dispose()
    
    Write-Output "Refined favicons generated successfully."
} else {
    Write-Error "Source image not found: $sourcePath"
}
