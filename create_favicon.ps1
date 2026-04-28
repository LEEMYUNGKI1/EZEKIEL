Add-Type -AssemblyName System.Drawing

# Use the latest uploaded image path with transparency requirement
$sourcePath = Join-Path $env:USERPROFILE ".gemini\antigravity\brain\2d091c4c-010c-4caf-b088-c4740e000869\media__1777359185817.png"

function Get-CircularImage {
    param($srcImg, $size)
    $dest = New-Object System.Drawing.Bitmap($size, $size)
    $g = [System.Drawing.Graphics]::FromImage($dest)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.Clear([System.Drawing.Color]::Transparent)
    
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $path.AddEllipse(0, 0, $size, $size)
    
    $g.SetClip($path)
    # Draw original image into the circular clip
    $g.DrawImage($srcImg, 0, 0, $size, $size)
    
    $path.Dispose()
    $g.Dispose()
    return $dest
}

if ($sourcePath -and (Test-Path $sourcePath)) {
    Write-Output "Found source image: $sourcePath"
    
    $srcImg = [System.Drawing.Bitmap]::FromFile($sourcePath)
    
    # 32x32 circular
    $dest32 = Get-CircularImage -srcImg $srcImg -size 32
    $dest32.Save("f:\home\favicon-32x32.png", [System.Drawing.Imaging.ImageFormat]::Png)
    
    # 16x16 circular
    $dest16 = Get-CircularImage -srcImg $srcImg -size 16
    $dest16.Save("f:\home\favicon-16x16.png", [System.Drawing.Imaging.ImageFormat]::Png)

    # 48x48 circular
    $dest48 = Get-CircularImage -srcImg $srcImg -size 48
    $dest48.Save("f:\home\favicon-48x48.png", [System.Drawing.Imaging.ImageFormat]::Png)

    # 256x256 circular
    $dest256 = Get-CircularImage -srcImg $srcImg -size 256
    $dest256.Save("f:\home\favicon.png", [System.Drawing.Imaging.ImageFormat]::Png)

    # Dispose source
    $srcImg.Dispose()
    
    # Cleanup
    $dest32.Dispose()
    $dest16.Dispose()
    $dest48.Dispose()
    $dest256.Dispose()
    
    Write-Output "Transparent circular favicons generated successfully."
} else {
    Write-Error "Source image not found: $sourcePath"
}
