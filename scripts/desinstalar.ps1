# ============================================================
# MICROFAST TECNICO - Desinstalador de Programas v4.0
# Lista programas instalados e remove via winget ou msiexec
# ============================================================
param(
    [string]$NomePrograma = "",
    [string]$Acao = "listar"   # listar | remover
)
$ErrorActionPreference = "SilentlyContinue"
$Host.UI.RawUI.WindowTitle = "MicroFast - Desinstalador"

function OK($m)   { Write-Host "  [OK] $m" -ForegroundColor Green }
function ERR($m)  { Write-Host "  [X]  $m" -ForegroundColor Red }
function WARN($m) { Write-Host "  [!]  $m" -ForegroundColor Yellow }
function INF($m)  { Write-Host "  [i]  $m" -ForegroundColor Cyan }

Clear-Host
Write-Host ""
Write-Host "  ╔══════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║   MICROFAST - Desinstalador de Programas ║" -ForegroundColor Cyan
Write-Host "  ╚══════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Coleta programas instalados
INF "Coletando lista de programas instalados..."
$progs = @()
$progs += Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" 2>$null
$progs += Get-ItemProperty "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" 2>$null
$progs += Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" 2>$null
$progs = $progs | Where-Object {
    $_.DisplayName -and
    $_.DisplayName -ne "" -and
    $_.UninstallString -ne "" -and
    $_.SystemComponent -ne 1 -and
    $_.DisplayName -notmatch "^Microsoft Visual C\+\+|^Microsoft Visual Studio|Redistributable"
} | Sort-Object DisplayName | Group-Object DisplayName | ForEach-Object { $_.Group | Select-Object -First 1 }

if ($Acao -eq "listar") {
    Write-Host "  $($progs.Count) programas encontrados:" -ForegroundColor White
    Write-Host ""
    $i = 1
    foreach ($p in $progs) {
        $ver = if ($p.DisplayVersion) { "v$($p.DisplayVersion)" } else { "" }
        Write-Host "  [$i]".PadRight(6) -NoNewline -ForegroundColor Cyan
        Write-Host " $($p.DisplayName)".PadRight(50) -NoNewline -ForegroundColor White
        Write-Host " $ver" -ForegroundColor Gray
        $i++
    }
    Write-Host ""
    Write-Host "  Digite o numero do programa para desinstalar (0 = sair):" -ForegroundColor Yellow
    $escolha = Read-Host "  "
    if ($escolha -eq "0" -or $escolha -eq "") { exit 0 }
    $idx = [int]$escolha - 1
    if ($idx -lt 0 -or $idx -ge $progs.Count) {
        ERR "Numero invalido"; Read-Host "  Enter"; exit 1
    }
    $prog = $progs[$idx]
} else {
    $prog = $progs | Where-Object { $_.DisplayName -like "*$NomePrograma*" } | Select-Object -First 1
    if (-not $prog) { ERR "Programa nao encontrado: $NomePrograma"; Read-Host "  Enter"; exit 1 }
}

Write-Host ""
Write-Host "  Programa selecionado: $($prog.DisplayName)" -ForegroundColor Yellow
Write-Host "  Versao: $($prog.DisplayVersion)" -ForegroundColor Gray
Write-Host ""
$conf = Read-Host "  Confirmar desinstalacao? [S/N]"
if ($conf -notmatch "^[Ss]") { Write-Host "  Cancelado." -ForegroundColor Gray; Read-Host "  Enter"; exit 0 }

Write-Host ""
INF "Desinstalando $($prog.DisplayName)..."

# Tenta primeiro via winget
$wingetOk = $false
$wg = Get-Command winget -ErrorAction SilentlyContinue
if ($wg) {
    Write-Host "  Tentando via winget..." -ForegroundColor Gray
    $result = & winget uninstall --name "$($prog.DisplayName)" --silent --accept-source-agreements 2>&1
    if ($LASTEXITCODE -eq 0) { $wingetOk = $true; OK "Removido via winget!" }
}

# Fallback: usa UninstallString do registro
if (-not $wingetOk) {
    Write-Host "  Usando UninstallString do registro..." -ForegroundColor Gray
    $unStr = $prog.UninstallString
    if ($unStr -match "msiexec") {
        $guid = if ($prog.PSChildName -match "\{.*\}") { $prog.PSChildName } else { "" }
        if ($guid) {
            $r = Start-Process msiexec.exe -ArgumentList "/x $guid /qn /norestart" -Wait -PassThru
            if ($r.ExitCode -eq 0) { OK "Removido via msiexec!" }
            else { WARN "msiexec retornou: $($r.ExitCode)" }
        }
    } else {
        # EXE uninstaller com flags silenciosas comuns
        $exeArgs = "/S /silent /uninstall /quiet /VERYSILENT /norestart"
        $exe = $unStr -replace '"','' -split ' ' | Select-Object -First 1
        if (Test-Path $exe) {
            $r = Start-Process $exe -ArgumentList "/S /silent /quiet /VERYSILENT /norestart" -Wait -PassThru
            if ($r.ExitCode -eq 0) { OK "Removido com sucesso!" }
            else { WARN "Instalador retornou codigo $($r.ExitCode) - verifique se foi removido" }
        } else {
            WARN "Executavel de desinstalacao nao encontrado. Tente manualmente."
            Write-Host "  Comando original: $unStr" -ForegroundColor Gray
        }
    }
}

Write-Host ""
Write-Host "  ========================================" -ForegroundColor Green
Read-Host "  Pressione Enter para fechar"
