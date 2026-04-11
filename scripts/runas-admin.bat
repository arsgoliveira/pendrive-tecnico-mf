@echo off
:: ============================================================
:: MICROFAST TECNICO - Executar como Administrador
:: Uso: runas-admin.bat [cmd|powershell|regedit|gpedit]
:: ============================================================
set FERRAMENTA=%~1
if "%FERRAMENTA%"=="" set FERRAMENTA=cmd

if /i "%FERRAMENTA%"=="cmd" (
    PowerShell -Command "Start-Process cmd.exe -Verb RunAs"
) else if /i "%FERRAMENTA%"=="powershell" (
    PowerShell -Command "Start-Process powershell.exe -Verb RunAs"
) else if /i "%FERRAMENTA%"=="regedit" (
    PowerShell -Command "Start-Process regedit.exe -Verb RunAs"
) else if /i "%FERRAMENTA%"=="gpedit" (
    PowerShell -Command "Start-Process gpedit.msc -Verb RunAs"
) else if /i "%FERRAMENTA%"=="taskmgr" (
    PowerShell -Command "Start-Process taskmgr.exe -Verb RunAs"
) else (
    echo [ERRO] Ferramenta desconhecida: %FERRAMENTA%
    timeout /t 3
)
