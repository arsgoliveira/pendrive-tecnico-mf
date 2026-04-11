@echo off
title MicroFast - Copiar para Pendrive D:
color 0B
echo.
echo  =====================================================
echo   MICROFAST TECNICO - Copiar para D:\Pendrive Tecnico MF
echo  =====================================================
echo.

set DEST=D:\Pendrive Tecnico MF
set SRC=%~dp0

echo  Origem : %SRC%
echo  Destino: %DEST%
echo.

if not exist "%DEST%" (
    echo  Criando pasta destino...
    mkdir "%DEST%"
)

echo  Copiando arquivos...
xcopy /E /I /Y /Q "%SRC%." "%DEST%\"

echo.
echo  =====================================================
echo  [OK] Copia concluida!
echo  Abra: %DEST%\INDEX.hta
echo  =====================================================
echo.
pause
