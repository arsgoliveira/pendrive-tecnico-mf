# ============================================================
# MICROFAST TECNICO - Windows Update via PSWindowsUpdate
# ============================================================

param([string]$Acao = "verificar")  # verificar | instalar | seguranca | defender

$ErrorActionPreference = "SilentlyContinue"
Write-Host ""
Write-Host "  [MICROFAST] Modulo Windows Update" -ForegroundColor Cyan
Write-Host "  ====================================" -ForegroundColor Cyan

# Instala modulo PSWindowsUpdate se nao existir
function Ensure-PSWindowsUpdate {
    if (!(Get-Module -ListAvailable -Name PSWindowsUpdate)) {
        Write-Host "  Instalando modulo PSWindowsUpdate..." -ForegroundColor Yellow
        Install-PackageProvider -Name NuGet -Force -Scope CurrentUser | Out-Null
        Install-Module PSWindowsUpdate -Force -Scope CurrentUser -AllowClobber | Out-Null
        Write-Host "  [OK] PSWindowsUpdate instalado" -ForegroundColor Green
    }
    Import-Module PSWindowsUpdate
}

switch ($Acao) {
    "verificar" {
        Write-Host ""
        Write-Host "  Verificando atualizacoes disponiveis..." -ForegroundColor Yellow
        Ensure-PSWindowsUpdate
        $updates = Get-WindowsUpdate -ErrorAction SilentlyContinue
        if ($updates.Count -eq 0) {
            Write-Host "  [OK] Nenhuma atualizacao pendente!" -ForegroundColor Green
        } else {
            Write-Host "  $($updates.Count) atualizacao(oes) encontrada(s):" -ForegroundColor Yellow
            foreach ($u in $updates) {
                Write-Host "    • $($u.Title)" -ForegroundColor White
            }
        }
    }
    "instalar" {
        Write-Host ""
        Write-Host "  Instalando todas as atualizacoes..." -ForegroundColor Yellow
        Ensure-PSWindowsUpdate
        Install-WindowsUpdate -AcceptAll -AutoReboot -Confirm:$false
        Write-Host "  [OK] Atualizacoes instaladas. O sistema pode reiniciar." -ForegroundColor Green
    }
    "seguranca" {
        Write-Host ""
        Write-Host "  Instalando apenas patches de seguranca..." -ForegroundColor Yellow
        Ensure-PSWindowsUpdate
        Install-WindowsUpdate -Category "Security Updates" -AcceptAll -Confirm:$false
        Write-Host "  [OK] Patches de seguranca instalados." -ForegroundColor Green
    }
    "defender" {
        Write-Host ""
        Write-Host "  Atualizando definicoes do Windows Defender..." -ForegroundColor Yellow
        & "C:\Program Files\Windows Defender\MpCmdRun.exe" -SignatureUpdate
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  [OK] Windows Defender atualizado com sucesso!" -ForegroundColor Green
        } else {
            Write-Host "  [AVISO] Tentando via Update-MpSignature..." -ForegroundColor Yellow
            Update-MpSignature
            Write-Host "  [OK] Definicoes atualizadas." -ForegroundColor Green
        }
    }
}

Write-Host ""
Write-Host "  [MICROFAST] Modulo Windows Update concluido." -ForegroundColor Cyan
Write-Host ""
Read-Host "  Pressione Enter para fechar"
