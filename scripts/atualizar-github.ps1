# ============================================================
# MICROFAST TECNICO - Atualizacao via GitHub
# ============================================================

param(
    [string]$Repo   = "arsgoliveira/pendrive-tecnico-mf",
    [string]$Branch = "main",
    [string]$Token  = "",
    [string]$Acao   = "verificar"   # verificar | atualizar
)

$ErrorActionPreference = "SilentlyContinue"
$PendriveRaiz = Split-Path -Parent $PSScriptRoot
$VersoesFile  = "$PendriveRaiz\config\versao.txt"

Write-Host ""
Write-Host "  [MICROFAST] Sincronizacao com GitHub" -ForegroundColor Cyan
Write-Host "  Repo  : $Repo" -ForegroundColor Gray
Write-Host "  Branch: $Branch" -ForegroundColor Gray
Write-Host ""

# Carrega versao local
$VersaoLocal = if (Test-Path $VersoesFile) { Get-Content $VersoesFile -Raw } else { "0.0.0" }
$VersaoLocal = $VersaoLocal.Trim()
Write-Host "  Versao local: $VersaoLocal" -ForegroundColor Yellow

# Monta headers
$Headers = @{ "User-Agent" = "MicroFast-Pendrive" }
if ($Token -ne "") { $Headers["Authorization"] = "token $Token" }

# Busca versao remota
try {
    $ApiUrl = "https://api.github.com/repos/$Repo/contents/config/versao.txt?ref=$Branch"
    $Response = Invoke-RestMethod -Uri $ApiUrl -Headers $Headers
    $VersaoRemota = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($Response.content)).Trim()
    Write-Host "  Versao remota: $VersaoRemota" -ForegroundColor Cyan
} catch {
    Write-Host "  [ERRO] Nao foi possivel acessar o repositorio GitHub." -ForegroundColor Red
    Write-Host "  Verifique a URL do repositorio e a conexao com a internet." -ForegroundColor Yellow
    Read-Host "  Pressione Enter para fechar"
    exit 1
}

if ($Acao -eq "verificar") {
    if ($VersaoRemota -ne $VersaoLocal) {
        Write-Host ""
        Write-Host "  [!] Atualizacao disponivel: $VersaoLocal -> $VersaoRemota" -ForegroundColor Yellow
        Write-Host "  Execute com -Acao atualizar para aplicar." -ForegroundColor Cyan
    } else {
        Write-Host ""
        Write-Host "  [OK] Pendrive ja esta na versao mais recente." -ForegroundColor Green
    }
    Read-Host "  Pressione Enter para fechar"
    exit 0
}

# ── ATUALIZAR ────────────────────────────────────────────────
if ($VersaoRemota -eq $VersaoLocal) {
    Write-Host ""
    Write-Host "  [OK] Ja esta atualizado. Nada para fazer." -ForegroundColor Green
    Read-Host "  Pressione Enter para fechar"
    exit 0
}

Write-Host ""
Write-Host "  Baixando atualizacao..." -ForegroundColor Yellow

# Lista arquivos no repositorio
$TreeUrl = "https://api.github.com/repos/$Repo/git/trees/${Branch}?recursive=1"
try {
    $Tree = Invoke-RestMethod -Uri $TreeUrl -Headers $Headers
} catch {
    Write-Host "  [ERRO] Falha ao listar arquivos do repositorio." -ForegroundColor Red
    Read-Host "  Pressione Enter para fechar"
    exit 1
}

$pastas = @("scripts", "config")
$arquivos = $Tree.tree | Where-Object { $_.type -eq "blob" -and ($pastas | Where-Object { $_.path -match "^$_/" }) }

$baixados = 0
foreach ($arquivo in $Tree.tree | Where-Object { $_.type -eq "blob" }) {
    $path = $arquivo.path
    # Baixa apenas scripts e config (nao tools — muito pesado)
    if ($path -match "^(scripts|config)/") {
        $destino = "$PendriveRaiz\$($path -replace '/', '\')"
        $dir = Split-Path $destino
        if (!(Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
        $rawUrl = "https://raw.githubusercontent.com/$Repo/$Branch/$path"
        try {
            Invoke-WebRequest -Uri $rawUrl -Headers $Headers -OutFile $destino
            Write-Host "  [OK] $path" -ForegroundColor Green
            $baixados++
        } catch {
            Write-Host "  [AVISO] Falha: $path" -ForegroundColor Yellow
        }
    }
}

# Atualiza versao local
$VersaoRemota | Out-File -FilePath $VersoesFile -Encoding UTF8 -NoNewline

Write-Host ""
Write-Host "  ============================================" -ForegroundColor Green
Write-Host "  Atualizado para v$VersaoRemota ($baixados arquivos)" -ForegroundColor Green
Write-Host "  ============================================" -ForegroundColor Green
Write-Host ""
Read-Host "  Pressione Enter para fechar"
