@echo off
cd /d "C:\Users\motio\OneDrive\Desktop\Weather"
echo Starting Flutter build and run...
echo Time: %date% %time% > flutter-build.log
flutter run -d emulator-5554 >> flutter-build.log 2>&1
echo Build completed with exit code: %ERRORLEVEL% >> flutter-build.log
