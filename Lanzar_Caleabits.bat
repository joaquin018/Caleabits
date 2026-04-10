@echo off
setlocal enabledelayedexpansion

:: =============================================================================
:: Caleabits Launcher
:: =============================================================================

title [Caleabits] - Iniciando Aplicacion...
color 0B

echo.
echo  =========================================
echo       CALEABITS - FLUTTER LAUNCHER
echo  =========================================
echo.

:: Cambiar al directorio del script
cd /d "%~dp0"

:: Verificar si Flutter esta en el PATH
where flutter >nul 2>1
if %errorlevel% neq 0 (
    echo [ERROR] No se encontro 'flutter' en el PATH.
    echo Por favor, instala Flutter y asegurate de que este en las variables de entorno.
    pause
    exit /b 1
)

:: Sincronizar dependencias
echo [1/2] Sincronizando dependencias...
call flutter pub get

:: Ejecutar en modo Windows
echo [2/2] Lanzando aplicacion en Windows...
echo.
call flutter run -d windows

if %errorlevel% neq 0 (
    echo.
    echo [!] Hubo un problema al ejecutar la aplicacion.
    echo     Intentando limpiar cache y reintentar...
    echo.
    call flutter clean
    call flutter pub get
    call flutter run -d windows
)

echo.
echo [INFO] Aplicacion finalizada.
pause
