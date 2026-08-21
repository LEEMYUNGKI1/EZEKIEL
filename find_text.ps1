Add-Type -AssemblyName System.Drawing
$origPath = (Get-ChildItem -Path "f:\home\*.png" | Where-Object { $_.Length -eq 5665138 }).FullName | Select-Object -First 1

$img = [System.Drawing.Image]::FromFile($origPath)
$bmp = New-Object System.Drawing.Bitmap($img)
$img.Dispose()

$width = $bmp.Width
$height = $bmp.Height

Write-Host "Scanning $width x $height..."

$chunkSize = 25
$xChunks = [Math]::Ceiling($width / $chunkSize)
$yChunks = [Math]::Ceiling($height / $chunkSize)

$darkChunks = @()

for ($y = 0; $y -lt $yChunks; $y++) {
    for ($x = 0; $x -lt $xChunks; $x++) {
        $startX = $x * $chunkSize
        $startY = $y * $chunkSize
        
        $hasDark = $false
        for ($py = $startY; $py -lt ($startY + $chunkSize) -and $py -lt $height; $py += 5) {
            for ($px = $startX; $px -lt ($startX + $chunkSize) -and $px -lt $width; $px += 5) {
                # Read pixel color
                $color = $bmp.GetPixel($px, $py)
                # Black text check
                if ($color.R -lt 120 -and $color.G -lt 120 -and $color.B -lt 120) {
                    $hasDark = $true
                    break
                }
            }
            if ($hasDark) { break }
        }
        
        if ($hasDark) {
            $darkChunks += [pscustomobject]@{X=$x; Y=$y}
        }
    }
}

$t1_chunks = @() # Left side
$t2_chunks = @() # Right side top
$t3_chunks = @() # Bottom center
$t4_chunks = @() # Banner text

foreach ($c in $darkChunks) {
    $realX = $c.X * $chunkSize
    $realY = $c.Y * $chunkSize
    
    if ($realY -lt 150) { continue } # skip top logo

    if ($realX -lt 1100 -and $realY -lt 1000) {
        $t1_chunks += $c
    }
    elseif ($realX -ge 1100 -and $realY -lt 1000) {
        $t2_chunks += $c
    }
    elseif ($realY -ge 1000 -and $realY -lt 1300) {
        $t3_chunks += $c
    }
    elseif ($realY -ge 1300) {
        $t4_chunks += $c
    }
}

function GetBounds($chunks) {
    if ($chunks.Count -eq 0) { return "None" }
    $minX = ($chunks | Measure-Object -Property X -Minimum).Minimum * $chunkSize
    $maxX = (($chunks | Measure-Object -Property X -Maximum).Maximum + 1) * $chunkSize
    $minY = ($chunks | Measure-Object -Property Y -Minimum).Minimum * $chunkSize
    $maxY = (($chunks | Measure-Object -Property Y -Maximum).Maximum + 1) * $chunkSize
    return "$minX, $minY, $($maxX - $minX), $($maxY - $minY)"
}

Write-Host "Left Text (T1) Bounds: $(GetBounds $t1_chunks)"
Write-Host "Right Text (T2) Bounds: $(GetBounds $t2_chunks)"
Write-Host "Bottom Text (T3) Bounds: $(GetBounds $t3_chunks)"
Write-Host "Banner Text (T4) Bounds: $(GetBounds $t4_chunks)"

$bmp.Dispose()
