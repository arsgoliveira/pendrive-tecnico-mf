# ============================================================
# MICROFAST TECNICO - Reset de Senha de Acesso
# Remove hash de credenciais do config\dados.ini
# ============================================================
$ErrorActionPreference = "SilentlyContinue"
$Host.UI.RawUI.WindowTitle = "MicroFast - Reset de Senha"

if ($PSScriptRoot -and $PSScriptRoot -ne "") {
    $base = Split-Path $PSScriptRoot -Parent
} else { $base = "D:\Pendrive Tecnico MF" }

$cfg = "$base\config\dados.ini"

Clear-Host
Write-Host ""
Write-Host "  ========================================" -ForegroundColor Cyan
Write-Host "   MICROFAST - Reset de Senha de Acesso  " -ForegroundColor White
Write-Host "  ========================================" -ForegroundColor Cyan
Write-Host ""

if (-not (Test-Path $cfg)) {
    Write-Host "  [OK] Nenhuma credencial configurada. Abra o INDEX.hta para definir." -ForegroundColor Green
    Read-Host "  Enter para fechar"; exit 0
}

Write-Host "  Isso vai apagar as senhas salvas e pedir nova senha no proximo acesso." -ForegroundColor Yellow
Write-Host ""
$conf = Read-Host "  Confirmar reset? [S/N]"
if ($conf -notmatch "^[Ss]") {
    Write-Host "  Cancelado." -ForegroundColor Gray
    Read-Host "  Enter para fechar"; exit 0
}

try {
    $linhas = Get-Content $cfg -Encoding UTF8
    $novas  = $linhas | Where-Object { $_ -notmatch "^th=|^ch=" }
    $novas | Out-File $cfg -Encoding UTF8
    Write-Host "  [OK] Credenciais removidas com sucesso!" -ForegroundColor Green
    Write-Host "  Abra o INDEX.hta e defina uma nova senha." -ForegroundColor Cyan
} catch {
    Write-Host "  [X] Erro ao acessar $cfg : $_" -ForegroundColor Red
}
Write-Host ""
Read-Host "  Enter para fechar"
