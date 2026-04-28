Add-Type -AssemblyName System.Drawing

# Use the latest rounded square image
$sourcePath = Join-Path $env:USERPROFILE ".gemini\antigravity\brain\2d091c4c-010c-4caf-b088-c4740e000869\media__1777360545338.png"

function Get-RoundedImage {
    param($srcImg, $size, $radius)
    $dest = New-Object System.Drawing.Bitmap($size, $size)
    $g = [System.Drawing.Graphics]::FromImage($dest)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.Clear([System.Drawing.Color]::Transparent)
    
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $diameter = $radius * 2
    
    # Rounded rectangle path
    $path.AddArc(0, 0, $diameter, $diameter, 180, 90)
    $path.AddArc($size - $diameter, 0, $diameter, $diameter, 270, 90)
    $path.AddArc($size - $diameter, $size - $diameter, $diameter, $diameter, 0, 90)
    $path.AddArc(0, $size - $diameter, $diameter, $diameter, 90, 90)
    $path.CloseFigure()
    
    $g.SetClip($path)
    $g.DrawImage($srcImg, 0, 0, $size, $size)
    
    $path.Dispose()
    $g.Dispose()
    return $dest
}

if ($sourcePath -and (Test-Path $sourcePath)) {
    Write-Output "Processing rounded image: $sourcePath"
    $srcImg = [System.Drawing.Bitmap]::FromFile($sourcePath)
    
    # Radius relative to size (roughly 15-20% is common for app icons)
    
    # 32x32
    $dest32 = Get-RoundedImage -srcImg $srcImg -size 32 -radius 6
    $dest32.Save("f:\home\favicon-32x32.png", [System.Drawing.Imaging.ImageFormat]::Png)
    
    # 16x16
    $dest16 = Get-RoundedImage -srcImg $srcImg -size 16 -radius 3
    $dest16.Save("f:\home\favicon-16x16.png", [System.Drawing.Imaging.ImageFormat]::Png)

    # 48x48
    $dest48 = Get-RoundedImage -srcImg $srcImg -size 48 -radius 9
    $dest48.Save("f:\home\favicon-48x48.png", [System.Drawing.Imaging.ImageFormat]::Png)

    # 256x256
    $dest256 = Get-RoundedImage -srcImg $srcImg -size 256 -radius 45
    $dest256.Save("f:\home\favicon.png", [System.Drawing.Imaging.ImageFormat]::Png)

    $srcImg.Dispose()
    $dest32.Dispose()
    $dest16.Dispose()
    $dest48.Dispose()
    $dest256.Dispose()
    
    Write-Output "Rounded corner favicons generated successfully."
} else {
    Write-Error "Source image not found: $sourcePath"
}
