@echo off
title Build SmartMoney APK
echo ===================================================
echo       SmartMoney Flutter APK Builder
echo ===================================================
echo.
echo Checking for Flutter...
where flutter >nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Flutter SDK is not detected in your PATH.
    echo Please ensure Flutter SDK is installed and added to PATH,
    echo OR use GitHub Actions to build the APK in the cloud automatically.
    echo.
    pause
    exit /b 1
)

echo Flutter detected!
echo 1. Fetching Flutter packages...
call flutter pub get
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Failed to fetch packages.
    pause
    exit /b 1
)

echo.
echo 2. Building Release APK...
call flutter build apk --release
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] APK build failed. Check error log above.
    pause
    exit /b 1
)

echo.
echo ===================================================
echo [SUCCESS] APK built successfully!
echo Location: build\app\outputs\flutter-apk\app-release.apk
echo ===================================================
echo.
explorer build\app\outputs\flutter-apk
pause
