# Run Flutter App Script
Set-Location "C:\Users\motio\OneDrive\Desktop\Weather"
Write-Host "Starting Flutter build and run..." -ForegroundColor Cyan
Write-Host "This may take several minutes on first build..." -ForegroundColor Yellow

flutter run -d emulator-5554
