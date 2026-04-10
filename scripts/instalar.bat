@echo off
:: ============================================================
:: MICROFAST TECNICO - Instalacao Silenciosa via winget
:: Uso: instalar.bat "ID.Pacote" "Nome Amigavel"
:: ============================================================
title MicroFast - Instalacao Silenciosa
color 0B
set PACOTE=%~1
set NOME=%~2
if "%PACOTE%"=="" (
    echo  [ERRO] Nenhum pacote informado.
    echo  Uso: instalar.bat "Google.Chrome" "Google Chrome"
    timeout /t 5
    exit /b 1
)
echo.
echo  [MICROFAST] Instalacao Silenciosa
echo  Pacote : %PACOTE%
echo  Nome   : %NOME%
echo  ============================================
echo.
:: Verifica se winget esta disponivel
where winget >nul 2>&1
if %errorlevel% neq 0 (
    echo  [ERRO] winget nao encontrado!
    echo  Instale o "App Installer" pela Microsoft Store.
    timeout /t 8
    exit /b 1
)
echo  [INFO] Iniciando instalacao via winget...
winget install --id %PACOTE% --silent --accept-source-agreements --accept-package-agreements
if %errorlevel% equ 0 (
    echo.
    echo  [OK] %NOME% instalado com sucesso!
) else (
    echo.
    echo  [AVISO] Verifique se o ID do pacote esta correto.
    echo  Tente: winget search %PACOTE%
)
echo.
timeout /t 5
