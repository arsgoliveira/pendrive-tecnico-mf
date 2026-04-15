# ============================================================
# MICROFAST TECNICO - Configurar Exclusão do Windows Defender
# Execute UMA VEZ como Administrador ao instalar o pendrive
# Resolve: "script tem conteúdo mal-intencionado"
# ============================================================

$ErrorActionPreference = "SilentlyContinue"
$Host.UI.RawUI.WindowTitle = "MicroFast - Configurar Exclusao Defender"

function OK($m)   { Write-Host "  [OK] $m" -ForegroundColor Green }
function WARN($m) { Write-Host "  [!]  $m" -ForegroundColor Yellow }
function ERR($m)  { Write-Host "  [X]  $m" -ForegroundColor Red }
function INF($m)  { Write-Host "  [i]  $m" -ForegroundColor Cyan }

Clear-Host
Write-Host ""
Write-Host "  ========================================================" -ForegroundColor Cyan
Write-Host "   MICROFAST - Configurar Exclusao Windows Defender        " -ForegroundColor White
Write-Host "   Resolve falso positivo nos scripts do pendrive           " -ForegroundColor Gray
Write-Host "  ========================================================" -ForegroundColor Cyan
Write-Host ""

# Verifica se está rodando como Admin
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    ERR "Execute este script como ADMINISTRADOR!"
    ERR "Clique direito no arquivo → Executar como administrador"
    Read-Host "`n  Enter para fechar"
    exit 1
}

# Detecta pasta do pendrive
$base = $PSScriptRoot
if ($base -and $base -ne "") {
    $pasta = Split-Path $base -Parent
} else {
    $pasta = "D:\Pendrive Tecnico MF"
}

INF "Pasta do pendrive: $pasta"
Write-Host ""

# ── 1. Adiciona exclusão de pasta no Defender ───────────
Write-Host "  [1/4] Adicionando exclusao de pasta..." -ForegroundColor Yellow
try {
    Add-MpPreference -ExclusionPath $pasta -ErrorAction Stop
    OK "Pasta excluida: $pasta"
} catch {
    ERR "Falha ao excluir pasta: $_"
}

# ── 2. Adiciona exclusão para processo powershell.exe ───
Write-Host "  [2/4] Configurando politica de execucao de scripts..." -ForegroundColor Yellow
try {
    # Configura ExecutionPolicy para o usuário atual (não precisa de Bypass)
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force -ErrorAction Stop
    OK "ExecutionPolicy: RemoteSigned (CurrentUser)"
} catch {
    WARN "Nao foi possivel alterar ExecutionPolicy: $_"
    # Tenta LocalMachine
    try {
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope LocalMachine -Force
        OK "ExecutionPolicy: RemoteSigned (LocalMachine)"
    } catch {}
}

# ── 3. Desbloqueia todos os scripts PS1 do pendrive ─────
Write-Host "  [3/4] Desbloqueando scripts do pendrive..." -ForegroundColor Yellow
$scriptsDir = Join-Path $pasta "scripts"
if (Test-Path $scriptsDir) {
    $scripts = Get-ChildItem $scriptsDir -Filter "*.ps1" -Recurse
    foreach ($s in $scripts) {
        try {
            Unblock-File -Path $s.FullName -ErrorAction SilentlyContinue
            OK "Desbloqueado: $($s.Name)"
        } catch {}
    }
    # Desbloqueia o HTA também
    $hta = Join-Path $pasta "INDEX.hta"
    if (Test-Path $hta) {
        Unblock-File -Path $hta -ErrorAction SilentlyContinue
        OK "Desbloqueado: INDEX.hta"
    }
} else {
    WARN "Pasta scripts nao encontrada: $scriptsDir"
}

# ── 4. Verifica Defender ativo ──────────────────────────
Write-Host "  [4/4] Verificando status do Windows Defender..." -ForegroundColor Yellow
try {
    $mpStatus = Get-MpComputerStatus -ErrorAction Stop
    if ($mpStatus.AMServiceEnabled) {
        OK "Windows Defender ativo — exclusoes aplicadas"
    }
    $exclusoes = (Get-MpPreference).ExclusionPath
    if ($exclusoes -contains $pasta) {
        OK "Exclusao confirmada na lista do Defender"
    }
} catch {
    WARN "Nao foi possivel verificar status do Defender"
}

# ── Resultado ────────────────────────────────────────────
Write-Host ""
Write-Host "  ========================================================" -ForegroundColor Green
Write-Host "  Configuracao concluida!" -ForegroundColor Green
Write-Host ""
Write-Host "  Proximos passos:" -ForegroundColor White
Write-Host "  1. Feche e reabra o INDEX.hta" -ForegroundColor Gray
Write-Host "  2. Execute o Diagnostico normalmente" -ForegroundColor Gray
Write-Host ""
Write-Host "  Se o problema persistir:" -ForegroundColor White
Write-Host "  Windows Security → Virus & threat protection" -ForegroundColor Gray
Write-Host "  → Manage settings → Exclusions → Add exclusion" -ForegroundColor Gray
Write-Host "  → Folder → $pasta" -ForegroundColor Cyan
Write-Host "  ========================================================" -ForegroundColor Green
Write-Host ""
Read-Host "  Enter para fechar"
