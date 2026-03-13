$apiKey = $env:GEMINI_API_KEY
if (-not $apiKey) {
    Write-Host "No API Key found"
    exit 1
}

$imagePath = "f:\home\부서.jpg"
$imageBytes = [System.IO.File]::ReadAllBytes($imagePath)
$base64Image = [System.Convert]::ToBase64String($imageBytes)

$body = @{
    contents = @(
        @{
            parts = @(
                @{
                    text = "Please transcribe the organization chart in this image. Emphasize the hierarchy of departments (e.g., Board of Directors, CEO, and various teams). Do not include names and titles, just the department names and their hierarchical relationships. Format as a markdown list."
                },
                @{
                    inline_data = @{
                        mime_type = "image/jpeg"
                        data = $base64Image
                    }
                }
            )
        }
    )
} | ConvertTo-Json -Depth 10

$url = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-pro:generateContent?key=$apiKey"
$headers = @{ "Content-Type" = "application/json" }

try {
    $response = Invoke-RestMethod -Uri $url -Method Post -Body $body -Headers $headers
    Write-Host $response.candidates[0].content.parts[0].text
} catch {
    Write-Host "Error details: $($_.Exception.Message)"
    if ($_.ErrorDetails) {
        Write-Host "Response body: $($_.ErrorDetails.Message)"
    }
}
