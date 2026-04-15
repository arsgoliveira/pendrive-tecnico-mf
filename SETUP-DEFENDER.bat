@echo off
:: ============================================================
:: MICROFAST TECNICO - Executar como Administrador
:: Resolve: antivirus bloqueando scripts do pendrive
:: ============================================================
title MicroFast - Setup Exclusao Defender
color 0B
echo.
echo  Configurando exclusao do Windows Defender...
echo  Isso resolve o erro: "script mal-intencionado bloqueado"
echo.
PowerShell -Command "Start-Process powershell.exe -ArgumentList '-NoProfile -ExecutionPolicy RemoteSigned -File ""%~dp0scripts\setup-exclusao.ps1""' -Verb RunAs -Wait"
echo.
echo  Pronto! Feche e reabra o INDEX.hta
pause
