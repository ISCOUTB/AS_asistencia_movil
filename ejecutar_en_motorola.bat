@echo off
echo ========================================
echo   Ejecutando UTB Assists en Motorola
echo ========================================
echo.
cd /d "%~dp0\src\frontend"

echo Verificando dispositivos conectados...
call flutter devices

echo.
echo Ejecutando aplicacion en Motorola Edge 50 Fusion...
call flutter run -d ZY22LGHHMP

pause
