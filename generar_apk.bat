@echo off
echo ========================================
echo   Generando APK de UTB Assists
echo ========================================
echo.
cd /d "%~dp0\src\frontend"

echo Paso 1: Limpiando proyecto...
call flutter clean

echo.
echo Paso 2: Obteniendo dependencias...
call flutter pub get

echo.
echo Paso 3: Generando APK de produccion (Release)...
echo Esto puede tardar varios minutos...
call flutter build apk --release

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ========================================
    echo   APK Generado Exitosamente!
    echo ========================================
    echo.
    echo Ubicacion del APK:
    echo %CD%\build\app\outputs\flutter-apk\app-release.apk
    echo.
    echo Nombre de la aplicacion: UTB Assists
    echo Version: 1.0.0+1
    echo.
    echo Puedes instalar este APK en cualquier dispositivo Android
    echo.
) else (
    echo.
    echo ========================================
    echo   ERROR al generar el APK
    echo ========================================
    echo.
    echo Por favor revisa los errores anteriores.
    echo.
)

pause
