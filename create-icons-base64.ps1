# Create icons using base64 encoded minimal PNG
$base64PNG = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg=="

$sizes = @{
    "mdpi" = 48
    "hdpi" = 72
    "xhdpi" = 96
    "xxhdpi" = 144
    "xxxhdpi" = 192
}

$basePath = "C:\Users\motio\OneDrive\Desktop\Weather\android\app\src\main\res"

foreach ($density in $sizes.Keys) {
    $size = $sizes[$density]
    $dirPath = Join-Path $basePath "mipmap-$density"
    $iconPath = Join-Path $dirPath "ic_launcher.png"
    
    # Create directory
    New-Item -ItemType Directory -Path $dirPath -Force | Out-Null
    
    # Create a simple colored PNG using System.Drawing
    try {
        Add-Type -AssemblyName System.Drawing
        $bitmap = New-Object System.Drawing.Bitmap($size, $size)
        $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
        
        # Blue background
        $graphics.Clear([System.Drawing.Color]::FromArgb(33, 150, 243))
        
        # White circle
        $brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
        $padding = [int]($size * 0.15)
        $graphics.FillEllipse($brush, $padding, $padding, $size - ($padding * 2), $size - ($padding * 2))
        
        $graphics.Dispose()
        $bitmap.Save($iconPath, [System.Drawing.Imaging.ImageFormat]::Png)
        $bitmap.Dispose()
        
        Write-Host "✓ Created $density ($size x $size)"
    } catch {
        Write-Host "✗ Error creating $density : $_" -ForegroundColor Red
        # Fallback: create a minimal 1x1 PNG and let Android scale it
        $bytes = [System.Convert]::FromBase64String($base64PNG)
        [System.IO.File]::WriteAllBytes($iconPath, $bytes)
        Write-Host "  Created minimal fallback icon"
    }
}

Write-Host "`nIcon creation complete!" -ForegroundColor Green
