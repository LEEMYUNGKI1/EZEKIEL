Add-Type -AssemblyName System.Drawing

# Use the specific uploaded image path
$sourcePath = Join-Path $env:USERPROFILE ".gemini\antigravity\brain\2d091c4c-010c-4caf-b088-c4740e000869\media__1777357866114.png"

if ($sourcePath -and (Test-Path $sourcePath)) {
    Write-Output "Found source image: $sourcePath"
    
    $srcImg = [System.Drawing.Bitmap]::FromFile($sourcePath)
    
    # Crop to square first if necessary, or assume it's roughly square (the generated images usually are 1:1)
    
    # 32x32 optimization
    $dest32 = New-Object System.Drawing.Bitmap(32, 32)
    $g32 = [System.Drawing.Graphics]::FromImage($dest32)
    $g32.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g32.DrawImage($srcImg, 0, 0, 32, 32)
    $dest32.Save("f:\home\favicon-32x32.png", [System.Drawing.Imaging.ImageFormat]::Png)
    
    # 16x16 optimization
    $dest16 = New-Object System.Drawing.Bitmap(16, 16)
    $g16 = [System.Drawing.Graphics]::FromImage($dest16)
    $g16.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g16.DrawImage($srcImg, 0, 0, 16, 16)
    $dest16.Save("f:\home\favicon-16x16.png", [System.Drawing.Imaging.ImageFormat]::Png)

    # 48x48 optimization
    $dest48 = New-Object System.Drawing.Bitmap(48, 48)
    $g48 = [System.Drawing.Graphics]::FromImage($dest48)
    $g48.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g48.DrawImage($srcImg, 0, 0, 48, 48)
    $dest48.Save("f:\home\favicon-48x48.png", [System.Drawing.Imaging.ImageFormat]::Png)

    # 256x256
    $dest256 = New-Object System.Drawing.Bitmap(256, 256)
    $g256 = [System.Drawing.Graphics]::FromImage($dest256)
    $g256.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g256.DrawImage($srcImg, 0, 0, 256, 256)

    # Dispose source to unlock file
    $srcImg.Dispose()
    
    # Overwrite original favicon.png with 256x256 as a high-res base or 32x32? High-res is better for general apple-touch-icon etc if needed
    $dest256.Save("f:\home\favicon.png", [System.Drawing.Imaging.ImageFormat]::Png)
    
    # Create an actual .ico file containing multiple sizes
    # We can use ImageMagick if available, or just an icon module. But simply renaming png works in most modern browsers. We've set PNG links in HTML anyway.
    
    # Cleanup
    $g32.Dispose()
    $dest32.Dispose()
    $g16.Dispose()
    $dest16.Dispose()
    $g48.Dispose()
    $dest48.Dispose()
    $g256.Dispose()
    $dest256.Dispose()
    
    Write-Output "Favicon optimized successfully using the NEW uploaded image."
} else {
    Write-Error "Source file new generated image not found."
}
