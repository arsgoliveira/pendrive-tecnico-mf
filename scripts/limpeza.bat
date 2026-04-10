@echo off
:: ============================================================
:: MICROFAST TECNICO - Limpeza Automatica do PC
:: ============================================================
title MicroFast - Limpeza do Sistema
color 0B
echo.
echo  [MICROFAST] Iniciando limpeza automatica...
echo  ============================================

:: --- Temp do usuario ---
echo  [1/6] Limpando pasta Temp do usuario...
rd /s /q "%TEMP%" 2>nul
mkdir "%TEMP%" 2>nul
echo  [OK] Temp limpo

:: --- Temp do Windows ---
echo  [2/6] Limpando Windows Temp...
rd /s /q "C:\Windows\Temp" 2>nul
mkdir "C:\Windows\Temp" 2>nul
echo  [OK] Windows\Temp limpo

:: --- Prefetch ---
echo  [3/6] Limpando Prefetch...
rd /s /q "C:\Windows\Prefetch" 2>nul
mkdir "C:\Windows\Prefetch" 2>nul
echo  [OK] Prefetch limpo

:: --- Lixeira ---
echo  [4/6] Esvaziando Lixeira...
PowerShell -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue"
echo  [OK] Lixeira esvaziada

:: --- Cache Windows Update ---
echo  [5/6] Limpando cache do Windows Update...
net stop wuauserv >nul 2>&1
net stop bits >nul 2>&1
rd /s /q "C:\Windows\SoftwareDistribution\Download" 2>nul
mkdir "C:\Windows\SoftwareDistribution\Download" 2>nul
net start wuauserv >nul 2>&1
net start bits >nul 2>&1
echo  [OK] Cache do Windows Update limpo

:: --- DNS Cache ---
echo  [6/6] Limpando cache DNS...
ipconfig /flushdns >nul 2>&1
echo  [OK] Cache DNS limpo

echo.
echo  ============================================
echo  [CONCLUIDO] Limpeza finalizada com sucesso!
echo  ============================================
echo.

:: Calcula espaco liberado aproximado
for /f "tokens=3" %%a in ('dir C:\ /-c ^| find "bytes free"') do set FREE=%%a
echo  Espaco livre atual em C: %FREE% bytes
echo.
timeout /t 5
