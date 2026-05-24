@echo off
title NexaMa Flutter
cd /d "%~dp0"

echo === NexaMa - Lancement Flutter ===
echo Backend attendu sur http://localhost:3000 (laissez l autre terminal ouvert)
echo.

flutter pub get
if errorlevel 1 exit /b 1

echo.
echo Appareils disponibles :
flutter devices
echo.

REM Windows desktop (recommande sur PC)
flutter run -d windows
if errorlevel 1 (
  echo.
  echo Si Windows echoue, essayez : flutter run -d chrome
  pause
)
