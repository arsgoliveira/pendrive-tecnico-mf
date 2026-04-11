# ============================================================
# MICROFAST TECNICO - Baixar Ferramentas Portables v3.0
# Baixa versoes PORTATEIS que rodam direto do pendrive
# Execute uma vez para popular a pasta tools\
# ============================================================
param([string]$ToolsDir = "")

$ErrorActionPreference = "SilentlyContinue"
# Resolve ToolsDir — PSScriptRoot pode ser vazio via ShellExecute
if ($ToolsDir -eq "") {
    if ($PSScriptRoot -and $PSScriptRoot -ne "") {
        $ToolsDir = Join-Path (Split-Path $PSScriptRoot -Parent) "tools"
    } else {
        $ToolsDir = "D:\Pendrive Tecnico MF\tools"
    }
}
$Host.UI.RawUI.WindowTitle = "MicroFast - Baixar Ferramentas Portaveis"
$ProgressPreference = "SilentlyContinue"

function WH($t)  { Write-Host "`n  --- $t ---" -ForegroundColor Cyan }
function OK($m)  { Write-Host "  [OK] $m" -ForegroundColor Green }
function WARN($m){ Write-Host "  [!]  $m" -ForegroundColor Yellow }
function ERR($m) { Write-Host "  [X]  $m" -ForegroundColor Red }
function INF($m) { Write-Host "  [i]  $m" -ForegroundColor White }

Clear-Host
Write-Host ""
Write-Host "  +=============================================+" -ForegroundColor Cyan
Write-Host "  |   MICROFAST - Downloader de Ferramentas     |" -ForegroundColor Cyan
Write-Host "  |   Baixa portables para a pasta tools\       |" -ForegroundColor Cyan
Write-Host "  |   Tudo roda direto do pendrive!             |" -ForegroundColor Cyan
Write-Host "  +=============================================+" -ForegroundColor Cyan
Write-Host ""

if (!(Test-Path $ToolsDir)) { New-Item -ItemType Directory -Path $ToolsDir -Force | Out-Null }

$online = Test-Connection -ComputerName "8.8.8.8" -Count 1 -Quiet
if (!$online) {
    ERR "Sem conexao com a internet! Conecte e tente novamente."
    Read-Host "Enter para fechar"
    exit 1
}
OK "Internet disponivel"

function Download-File($nome, $url, $destino) {
    $dir = Split-Path $destino
    if (!(Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    if (Test-Path $destino) {
        WARN "$nome ja existe - pulando"
        return $true
    }
    Write-Host "  Baixando $nome..." -ForegroundColor Yellow
    Write-Host "  URL: $url" -ForegroundColor DarkGray
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $wc = New-Object System.Net.WebClient
        $wc.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
        $wc.DownloadFile($url, $destino)
        if (Test-Path $destino) {
            $sz = [math]::Round((Get-Item $destino).Length/1KB,0)
            if ($sz -lt 10) {
                ERR "$nome - arquivo muito pequeno ($sz KB), possivel erro de download"
                Remove-Item $destino -Force
                return $false
            }
            OK "$nome baixado ($sz KB)"
            return $true
        }
    } catch {
        ERR "Falha ao baixar $nome : $_"
        return $false
    }
    return $false
}

function Download-AndExtract($nome, $url, $destDir, $checkFile) {
    if (!(Test-Path $destDir)) { New-Item -ItemType Directory -Path $destDir -Force | Out-Null }
    $checkPath = "$destDir\$checkFile"
    if (Test-Path $checkPath) {
        WARN "$nome ja existe - pulando"
        return $true
    }
    Write-Host "  Baixando $nome (zip)..." -ForegroundColor Yellow
    Write-Host "  URL: $url" -ForegroundColor DarkGray
    $tmpZip = "$env:TEMP\mf_$($nome -replace '[^a-zA-Z0-9]','_').zip"
    try {
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $wc = New-Object System.Net.WebClient
        $wc.Headers.Add("User-Agent","Mozilla/5.0 (Windows NT 10.0; Win64; x64)")
        $wc.DownloadFile($url, $tmpZip)
        if (Test-Path $tmpZip) {
            $sz = [math]::Round((Get-Item $tmpZip).Length/1KB,0)
            if ($sz -lt 10) {
                ERR "$nome - zip muito pequeno ($sz KB), possivel erro"
                Remove-Item $tmpZip -Force
                return $false
            }
            Expand-Archive -Path $tmpZip -DestinationPath $destDir -Force
            Remove-Item $tmpZip -Force
            if (Test-Path $checkPath) {
                OK "$nome extraido com sucesso"
                return $true
            }
            $found = Get-ChildItem -Path $destDir -Recurse -Filter $checkFile | Select-Object -First 1
            if ($found) {
                if ($found.DirectoryName -ne $destDir) {
                    Get-ChildItem -Path $found.DirectoryName -Recurse | Move-Item -Destination $destDir -Force
                }
                OK "$nome extraido com sucesso"
                return $true
            }
            WARN "$nome extraido mas $checkFile nao encontrado na estrutura"
            INF "Verifique manualmente: $destDir"
            return $false
        }
    } catch {
        ERR "Falha ao baixar/extrair $nome : $_"
        if (Test-Path $tmpZip) { Remove-Item $tmpZip -Force }
        return $false
    }
    return $false
}

Write-Host ""
Write-Host "  Selecione o que baixar:" -ForegroundColor White
Write-Host "  [1]  Todas as ferramentas (recomendado)" -ForegroundColor White
Write-Host "  [2]  Apenas diagnostico (CrystalDisk, HWiNFO, CPU-Z, GPU-Z)" -ForegroundColor White
Write-Host "  [3]  Apenas utilitarios (Rufus, Autoruns, ProcExp, PuTTY)" -ForegroundColor White
Write-Host "  [4]  Apenas seguranca (AdwCleaner, RKill)" -ForegroundColor White
Write-Host ""
$op = Read-Host "  Escolha (Enter = todas)"
if ($op -eq "") { $op = "1" }

$totalOk = 0
$totalFail = 0

# === FERRAMENTAS DE DIAGNOSTICO ===
function Baixar-Diagnostico {
    WH "FERRAMENTAS DE DIAGNOSTICO (Portaveis)"

    # Sysinternals Autoruns (ZIP portable - URL estavel da Microsoft)
    if (Download-AndExtract "Autoruns (Sysinternals)" `
        "https://download.sysinternals.com/files/Autoruns.zip" `
        "$ToolsDir\Autoruns" "Autoruns64.exe") { $script:totalOk++ } else { $script:totalFail++ }

    # Sysinternals Process Explorer (ZIP portable)
    if (Download-AndExtract "Process Explorer (Sysinternals)" `
        "https://download.sysinternals.com/files/ProcessExplorer.zip" `
        "$ToolsDir\ProcessExplorer" "procexp64.exe") { $script:totalOk++ } else { $script:totalFail++ }

    # Sysinternals TCPView (ZIP portable)
    if (Download-AndExtract "TCPView (Sysinternals)" `
        "https://download.sysinternals.com/files/TCPView.zip" `
        "$ToolsDir\TCPView" "Tcpview64.exe") { $script:totalOk++ } else { $script:totalFail++ }

    # HWiNFO64 Portable
    INF "HWiNFO64 - tentando baixar versao portable..."
    $hwDest = "$ToolsDir\HWiNFO64"
    if (!(Test-Path $hwDest)) { New-Item -ItemType Directory -Path $hwDest -Force | Out-Null }
    if (Test-Path "$hwDest\HWiNFO64.exe") {
        WARN "HWiNFO64 ja existe - pulando"
        $script:totalOk++
    } else {
        $hwOk = $false
        $hwUrls = @(
            "https://www.hwinfo.com/files/hwi_portable.zip",
            "https://www.hwinfo.com/files/hwi_846.zip"
        )
        foreach ($hwUrl in $hwUrls) {
            if (Download-AndExtract "HWiNFO64 Portable" $hwUrl $hwDest "HWiNFO64.exe") {
                $hwOk = $true; break
            }
            $found = Get-ChildItem -Path $hwDest -Recurse -Filter "HWiNFO64.EXE" | Select-Object -First 1
            if ($found) {
                if ($found.DirectoryName -ne $hwDest) {
                    Get-ChildItem -Path $found.DirectoryName | Move-Item -Destination $hwDest -Force
                }
                OK "HWiNFO64 encontrado e reorganizado"
                $hwOk = $true; break
            }
        }
        if ($hwOk) { $script:totalOk++ }
        else {
            WARN "HWiNFO64 - baixe manualmente de https://www.hwinfo.com/download/"
            WARN "Escolha 'Portable' e extraia em $hwDest"
            $script:totalFail++
        }
    }

    # CPU-Z Portable (ZIP)
    $cpuzDest = "$ToolsDir\CPU-Z"
    if (!(Test-Path $cpuzDest)) { New-Item -ItemType Directory -Path $cpuzDest -Force | Out-Null }
    if (Test-Path "$cpuzDest\cpuz_x64.exe") {
        WARN "CPU-Z ja existe - pulando"
        $script:totalOk++
    } else {
        $cpuzOk = $false
        $cpuzUrls = @(
            "https://download.cpuid.com/cpu-z/cpu-z_2.12-en.zip",
            "https://download.cpuid.com/cpu-z/cpu-z_2.11-en.zip",
            "https://download.cpuid.com/cpu-z/cpu-z_2.10-en.zip"
        )
        foreach ($cpuzUrl in $cpuzUrls) {
            if (Download-AndExtract "CPU-Z Portable" $cpuzUrl $cpuzDest "cpuz_x64.exe") {
                $cpuzOk = $true; break
            }
        }
        if ($cpuzOk) { $script:totalOk++ }
        else {
            WARN "CPU-Z - baixe manualmente de https://www.cpuid.com/softwares/cpu-z.html"
            WARN "Escolha ZIP (English) e extraia em $cpuzDest"
            $script:totalFail++
        }
    }

    # GPU-Z (EXE standalone portable)
    if (Download-File "GPU-Z" `
        "https://us1-dl.techpowerup.com/files/GPU-Z.2.61.0.exe" `
        "$ToolsDir\GPU-Z\GPU-Z.exe") { $script:totalOk++ }
    else {
        WARN "GPU-Z - baixe manualmente de https://www.techpowerup.com/gpuz/"
        $script:totalFail++
    }

    # CrystalDiskInfo Portable
    $cdiDest = "$ToolsDir\CrystalDiskInfo"
    if (!(Test-Path $cdiDest)) { New-Item -ItemType Directory -Path $cdiDest -Force | Out-Null }
    if (Test-Path "$cdiDest\DiskInfo64.exe") {
        WARN "CrystalDiskInfo ja existe - pulando"
        $script:totalOk++
    } else {
        if (Download-AndExtract "CrystalDiskInfo Portable" `
            "https://jaist.dl.sourceforge.net/project/crystaldiskinfo/9.4.4/CrystalDiskInfo9_4_4.zip" `
            $cdiDest "DiskInfo64.exe") { $script:totalOk++ }
        else {
            WARN "CrystalDiskInfo - baixe manualmente de https://crystalmark.info/en/software/crystaldiskinfo/"
            WARN "Escolha 'Zip' e extraia em $cdiDest"
            $script:totalFail++
        }
    }

    # CrystalDiskMark Portable
    $cdmDest = "$ToolsDir\CrystalDiskMark"
    if (!(Test-Path $cdmDest)) { New-Item -ItemType Directory -Path $cdmDest -Force | Out-Null }
    if (Test-Path "$cdmDest\DiskMark64.exe") {
        WARN "CrystalDiskMark ja existe - pulando"
        $script:totalOk++
    } else {
        if (Download-AndExtract "CrystalDiskMark Portable" `
            "https://jaist.dl.sourceforge.net/project/crystaldiskmark/8.0.5/CrystalDiskMark8_0_5.zip" `
            $cdmDest "DiskMark64.exe") { $script:totalOk++ }
        else {
            WARN "CrystalDiskMark - baixe manualmente de https://crystalmark.info/en/software/crystaldiskmark/"
            $script:totalFail++
        }
    }
}

# === FERRAMENTAS UTILITARIAS ===
function Baixar-Utilitarios {
    WH "UTILITARIOS (Portaveis)"

    # Rufus (EXE standalone portable)
    if (Download-File "Rufus Portable" `
        "https://github.com/pbatard/rufus/releases/download/v4.6/rufus-4.6p.exe" `
        "$ToolsDir\Rufus\rufus.exe") { $script:totalOk++ }
    else {
        if (Download-File "Rufus Portable (v4.5)" `
            "https://github.com/pbatard/rufus/releases/download/v4.5/rufus-4.5p.exe" `
            "$ToolsDir\Rufus\rufus.exe") { $script:totalOk++ }
        else {
            WARN "Rufus - baixe manualmente de https://rufus.ie (versao portable)"
            $script:totalFail++
        }
    }

    # PuTTY (EXE standalone portable)
    if (Download-File "PuTTY Portable" `
        "https://the.earth.li/~sgtatham/putty/latest/w64/putty.exe" `
        "$ToolsDir\PuTTY\putty.exe") { $script:totalOk++ }
    else { $script:totalFail++ }

    # TreeSize Free Portable
    INF "TreeSize Free - requer instalacao via winget"
    $wgAvail = Get-Command winget -ErrorAction SilentlyContinue
    if ($wgAvail) {
        Write-Host "  Instalando TreeSize Free via winget..." -ForegroundColor Yellow
        $r = & winget install --id "JAMSoftware.TreeSize.Free" --silent --accept-source-agreements --accept-package-agreements 2>&1
        if ($LASTEXITCODE -eq 0) { OK "TreeSize Free instalado via winget"; $script:totalOk++ }
        else { WARN "TreeSize Free - winget falhou (pode ja estar instalado)"; $script:totalOk++ }
    } else {
        WARN "winget nao disponivel - TreeSize nao instalado"
        $script:totalFail++
    }
}

# === FERRAMENTAS DE SEGURANCA ===
function Baixar-Seguranca {
    WH "SEGURANCA (Portaveis - rodam sem instalar)"

    # AdwCleaner (EXE standalone - sempre portable)
    if (Download-File "AdwCleaner" `
        "https://adwcleaner.malwarebytes.com/adwcleaner?channel=release" `
        "$ToolsDir\AdwCleaner\AdwCleaner.exe") { $script:totalOk++ }
    else { $script:totalFail++ }

    # RKill (EXE standalone portable)
    if (Download-File "RKill" `
        "https://download.bleepingcomputer.com/grinler/rkill.exe" `
        "$ToolsDir\RKill\rkill.exe") { $script:totalOk++ }
    else { $script:totalFail++ }

    # Malwarebytes (requer instalacao)
    INF "Malwarebytes requer instalacao (nao e portable)"
    $wgAvail = Get-Command winget -ErrorAction SilentlyContinue
    if ($wgAvail) {
        Write-Host "  Instalando Malwarebytes via winget..." -ForegroundColor Yellow
        $r = & winget install --id "Malwarebytes.Malwarebytes" --silent --accept-source-agreements --accept-package-agreements 2>&1
        if ($LASTEXITCODE -eq 0) { OK "Malwarebytes instalado via winget"; $script:totalOk++ }
        else { WARN "Malwarebytes - winget falhou (pode ja estar instalado)"; $script:totalOk++ }
    } else {
        WARN "winget nao disponivel para Malwarebytes"
        $script:totalFail++
    }
}

# === REDE E ACESSO REMOTO ===
function Baixar-Rede {
    WH "REDE E ACESSO REMOTO"

    if (Test-Path "$ToolsDir\PuTTY\putty.exe") {
        WARN "PuTTY ja existe - pulando"
        $script:totalOk++
    }

    # RustDesk (portable EXE)
    if (Download-File "RustDesk" `
        "https://github.com/rustdesk/rustdesk/releases/download/1.3.7/rustdesk-1.3.7-x86_64.exe" `
        "$ToolsDir\RustDesk\rustdesk.exe") { $script:totalOk++ }
    else {
        INF "RustDesk - instalando via winget..."
        $wg = Get-Command winget -ErrorAction SilentlyContinue
        if ($wg) {
            & winget install --id "RustDesk.RustDesk" --silent --accept-source-agreements --accept-package-agreements 2>&1 | Out-Null
            if ($LASTEXITCODE -eq 0) { OK "RustDesk instalado via winget"; $script:totalOk++ }
            else { WARN "RustDesk - baixe de https://rustdesk.com"; $script:totalFail++ }
        } else { $script:totalFail++ }
    }

    # AnyDesk (portable EXE)
    if (Download-File "AnyDesk" `
        "https://download.anydesk.com/AnyDesk.exe" `
        "$ToolsDir\AnyDesk\AnyDesk.exe") { $script:totalOk++ }
    else { $script:totalFail++ }

    # Advanced IP Scanner
    INF "Advanced IP Scanner - instalando via winget..."
    $wg = Get-Command winget -ErrorAction SilentlyContinue
    if ($wg) {
        & winget install --id "Famatech.AdvancedIPScanner" --silent --accept-source-agreements --accept-package-agreements 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) { OK "Advanced IP Scanner instalado"; $script:totalOk++ }
        else { WARN "Advanced IP Scanner - pode ja estar instalado"; $script:totalOk++ }
    }

    # Wireshark (requer instalacao)
    INF "Wireshark requer instalacao"
    if ($wg) {
        & winget install --id "WiresharkFoundation.Wireshark" --silent --accept-source-agreements --accept-package-agreements 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) { OK "Wireshark instalado via winget"; $script:totalOk++ }
        else { WARN "Wireshark - pode ja estar instalado"; $script:totalOk++ }
    }
}

# === STRESS TEST ===
function Baixar-StressTest {
    WH "STRESS TEST"

    # Prime95 (portable ZIP)
    $p95Dest = "$ToolsDir\Prime95"
    if (!(Test-Path $p95Dest)) { New-Item -ItemType Directory -Path $p95Dest -Force | Out-Null }
    if (Test-Path "$p95Dest\prime95.exe") {
        WARN "Prime95 ja existe - pulando"
        $script:totalOk++
    } else {
        if (Download-AndExtract "Prime95" `
            "https://www.mersenne.org/download/software/v30/30.19/p95v3019b13.win64.zip" `
            $p95Dest "prime95.exe") { $script:totalOk++ }
        else {
            WARN "Prime95 - baixe de https://www.mersenne.org/download/"
            $script:totalFail++
        }
    }

    # FurMark (via winget)
    INF "FurMark - instalando via winget..."
    $wg = Get-Command winget -ErrorAction SilentlyContinue
    if ($wg) {
        & winget install --id "Geeks3D.FurMark" --silent --accept-source-agreements --accept-package-agreements 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) { OK "FurMark instalado via winget"; $script:totalOk++ }
        else { WARN "FurMark - pode ja estar instalado"; $script:totalOk++ }
    }
}

# Executa conforme opcao
switch ($op) {
    "2" { Baixar-Diagnostico }
    "3" { Baixar-Utilitarios }
    "4" { Baixar-Seguranca }
    default {
        Baixar-Diagnostico
        Baixar-Utilitarios
        Baixar-Seguranca
        Baixar-Rede
        Baixar-StressTest
    }
}

Write-Host ""
Write-Host "  ========================================" -ForegroundColor Green
Write-Host "  Download concluido!" -ForegroundColor Green
Write-Host "  Sucesso: $totalOk  |  Falhas: $totalFail" -ForegroundColor $(if($totalFail -eq 0){"Green"}else{"Yellow"})
Write-Host "  Pasta tools: $ToolsDir" -ForegroundColor Cyan
Write-Host ""

$total = (Get-ChildItem $ToolsDir -Recurse -File -ErrorAction SilentlyContinue | Measure-Object).Count
OK "$total arquivos na pasta tools\"

if ($totalFail -gt 0) {
    Write-Host ""
    WARN "Algumas ferramentas falharam no download automatico."
    WARN "URLs podem ter mudado. Baixe manualmente pelos sites indicados."
}

Write-Host "  ========================================" -ForegroundColor Green
Write-Host ""
Read-Host "  Pressione Enter para fechar"
