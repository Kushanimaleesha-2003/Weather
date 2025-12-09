# Final icon creation script with full error handling
$ErrorActionPreference = "Continue"
$basePath = "C:\Users\motio\OneDrive\Desktop\Weather\android\app\src\main\res"

Write-Host "Creating launcher icons..." -ForegroundColor Cyan

$densities = @{
    "mdpi" = 48
    "hdpi" = 72
    "xhdpi" = 96
    "xxhdpi" = 144
    "xxxhdpi" = 192
}

try {
    Add-Type -AssemblyName System.Drawing
    Write-Host "System.Drawing loaded successfully" -ForegroundColor Green
} catch {
    Write-Host "ERROR: Cannot load System.Drawing - $_" -ForegroundColor Red
    exit 1
}

foreach ($density in $densities.Keys) {
    $size = $densities[$density]
    $dirPath = Join-Path $basePath "mipmap-$density"
    $iconPath = Join-Path $dirPath "ic_launcher.png"
    
    try {
        # Create directory
        if (-not (Test-Path $dirPath)) {
            New-Item -ItemType Directory -Path $dirPath -Force | Out-Null
            Write-Host "Created directory: $dirPath" -ForegroundColor Yellow
        }
        
        # Create bitmap
        $bitmap = New-Object System.Drawing.Bitmap($size, $size)
        $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
        
        # Blue background (Material Blue 500)
        $graphics.Clear([System.Drawing.Color]::FromArgb(33, 150, 243))
        
        # White circle (sun/weather icon)
        $brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
        $padding = [int]($size * 0.15)
        $graphics.FillEllipse($brush, $padding, $padding, $size - ($padding * 2), $size - ($padding * 2))
        
        # Cleanup
        $graphics.Dispose()
        $bitmap.Save($iconPath, [System.Drawing.Imaging.ImageFormat]::Png)
        $bitmap.Dispose()
        
        if (Test-Path $iconPath) {
            $fileInfo = Get-Item $iconPath
            Write-Host "✓ Created $density ($size x $size) - $($fileInfo.Length) bytes" -ForegroundColor Green
        } else {
            Write-Host "✗ Failed to create $density" -ForegroundColor Red
        }
    } catch {
        Write-Host "✗ Error creating $density : $_" -ForegroundColor Red
    }
}

Write-Host "`nVerifying icons..." -ForegroundColor Cyan
$created = Get-ChildItem "$basePath\mipmap-*" -Recurse -Filter "ic_launcher.png" -ErrorAction SilentlyContinue
if ($created) {
    Write-Host "Successfully created $($created.Count) icon files:" -ForegroundColor Green
    $created | ForEach-Object { Write-Host "  - $($_.FullName)" -ForegroundColor Gray }
} else {
    Write-Host "WARNING: No icons found after creation!" -ForegroundColor Yellow
}
