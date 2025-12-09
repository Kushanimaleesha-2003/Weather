# Create simple launcher icons
Add-Type -AssemblyName System.Drawing

$densities = @{
    "mdpi" = 48
    "hdpi" = 72
    "xhdpi" = 96
    "xxhdpi" = 144
    "xxxhdpi" = 192
}

foreach ($density in $densities.Keys) {
    $size = $densities[$density]
    $path = "C:\Users\motio\OneDrive\Desktop\Weather\android\app\src\main\res\mipmap-$density\ic_launcher.png"
    
    $bitmap = New-Object System.Drawing.Bitmap($size, $size)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    
    # Blue background
    $graphics.Clear([System.Drawing.Color]::FromArgb(33, 150, 243))
    
    # White circle (sun icon representation)
    $brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    $padding = [int]($size * 0.15)
    $graphics.FillEllipse($brush, $padding, $padding, $size - ($padding * 2), $size - ($padding * 2))
    
    $graphics.Dispose()
    $bitmap.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $bitmap.Dispose()
    
    Write-Host "Created icon for $density ($size x $size)"
}

Write-Host "All icons created successfully!"
