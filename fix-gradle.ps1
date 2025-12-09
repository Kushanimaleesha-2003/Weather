# Fix Gradle Lock Issue Script
Write-Host "=== Fixing Gradle Lock Issue ===" -ForegroundColor Cyan

# Step 1: Kill all Java/Gradle processes
Write-Host "`n[1/5] Killing Java/Gradle processes..." -ForegroundColor Yellow
Get-Process | Where-Object {$_.ProcessName -match "java|gradle|dart"} | Stop-Process -Force -ErrorAction SilentlyContinue
taskkill /F /IM java.exe /T 2>$null
taskkill /F /IM javaw.exe /T 2>$null
Start-Sleep -Seconds 3

# Step 2: Remove Gradle cache
Write-Host "[2/5] Removing Gradle cache..." -ForegroundColor Yellow
Remove-Item -Path "$env:USERPROFILE\.gradle\wrapper\dists" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "$env:USERPROFILE\.gradle\caches" -Recurse -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 2

# Step 3: Remove lock files
Write-Host "[3/5] Removing lock files..." -ForegroundColor Yellow
Get-ChildItem -Path "$env:USERPROFILE\.gradle" -Recurse -Filter "*.lock" -ErrorAction SilentlyContinue | Remove-Item -Force

# Step 4: Clean Flutter
Write-Host "[4/5] Cleaning Flutter project..." -ForegroundColor Yellow
Set-Location "C:\Users\motio\OneDrive\Desktop\Weather"
flutter clean

# Step 5: Try running
Write-Host "[5/5] Ready to run! Now execute: flutter run -d emulator-5554" -ForegroundColor Green
Write-Host "`n=== Fix Complete ===" -ForegroundColor Cyan
