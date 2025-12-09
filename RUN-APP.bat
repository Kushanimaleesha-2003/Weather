@echo off
cls
color 0A
title Weather App - Flutter Build
echo.
echo ============================================================
echo           WEATHER APP - FLUTTER BUILD & RUN
echo ============================================================
echo.
cd /d "%~dp0"

echo [STEP 1] Checking emulator connection...
echo.
adb devices
echo.
echo If you see "emulator-5554" above, emulator is connected.
echo If not, please start your Pixel 7 emulator from Android Studio.
echo.
pause

echo.
echo [STEP 2] Cleaning project...
flutter clean
echo.

echo.
echo [STEP 3] Getting dependencies...
flutter pub get
echo.

echo.
echo [STEP 4] Starting Flutter build and run...
echo This will take 5-10 minutes on first build...
echo You will see build progress below:
echo.
echo ============================================================
echo.

flutter run -d emulator-5554

echo.
echo ============================================================
echo Build process finished!
echo ============================================================
pause
