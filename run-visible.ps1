# Visible Flutter Run Script
$ErrorActionPreference = "Continue"
$LogFile = "C:\Users\motio\OneDrive\Desktop\Weather\flutter-run.log"

function Write-Log {
    param($Message)
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] $Message"
    Write-Host $logMessage
    Add-Content -Path $LogFile -Value $logMessage
}

Write-Log "========================================="
Write-Log "Starting Flutter Build and Run"
Write-Log "========================================="

Set-Location "C:\Users\motio\OneDrive\Desktop\Weather"

Write-Log "Checking Flutter devices..."
$devices = flutter devices 2>&1
Write-Log $devices

Write-Log "Starting flutter run..."
Write-Log "This may take 5-10 minutes on first build..."
Write-Log ""

# Run Flutter and capture all output
flutter run -d emulator-5554 2>&1 | ForEach-Object {
    Write-Log $_
    Write-Host $_
}

Write-Log "========================================="
Write-Log "Build completed"
Write-Log "========================================="
