@echo off
title MicroFast - Copiar para Pendrive D:
color 0B
echo.
echo  [MICROFAST] Copiando para D:\Pendrive Tecnico MF...
echo  =====================================================
if not exist "D:\Pendrive Tecnico MF" mkdir "D:\Pendrive Tecnico MF"
xcopy /E /I /Y /Q "%~dp0" "D:\Pendrive Tecnico MF\"
echo.
echo  [OK] Copia concluida em D:\Pendrive Tecnico MF
echo  Abra: D:\Pendrive Tecnico MF\INDEX.hta
echo.
pause
