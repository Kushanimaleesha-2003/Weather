@echo off
title Flutter Build - Weather App
echo ========================================
echo Starting Flutter Build and Run
echo ========================================
echo.
cd /d "%~dp0"
echo Current directory: %CD%
echo.
echo Checking emulator connection...
where adb >nul 2>&1 && adb devices || echo ADB not in PATH - Flutter will detect devices automatically
echo.
echo Starting Flutter run...
echo This will take several minutes on first build...
echo.
flutter run -d emulator-5554
echo.
echo ========================================
echo Build process completed
echo ========================================
pause
