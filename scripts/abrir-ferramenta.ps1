# ============================================================
# MICROFAST TECNICO - Launcher de Ferramentas Portables
# Abre da pasta tools\ ou baixa via winget se nao encontrado
# ============================================================

param([string]$Ferramenta = "")

$ErrorActionPreference = "SilentlyContinue"
# Resolve raiz do pendrive — PSScriptRoot pode ser vazio se chamado via ShellExecute
if ($PSScriptRoot -and $PSScriptRoot -ne "") {
    $PendriveRaiz = Split-Path -Parent $PSScriptRoot
} else {
    $PendriveRaiz = "D:\Pendrive Tecnico MF"
}
$ToolsDir = "$PendriveRaiz\tools"

# Mapa: nome -> { arquivo no pendrive | winget ID | URL download }
$FerramentasMap = @{
    # --- Diagnostico de Hardware ---
    "crystaldiskinfo" = @{ arquivo="CrystalDiskInfo\DiskInfo64.exe";  winget="CrystalDewWorld.CrystalDiskInfo"; url="https://crystalmark.info/en/software/crystaldiskinfo/" }
    "crystaldiskmark" = @{ arquivo="CrystalDiskMark\DiskMark64.exe";  winget="CrystalDewWorld.CrystalDiskMark"; url="https://crystalmark.info/en/software/crystaldiskmark/" }
    "hwinfo"          = @{ arquivo="HWiNFO64\HWiNFO64.exe";           winget="REALiX.HWiNFO";                  url="https://www.hwinfo.com/download/" }
    "cpuz"            = @{ arquivo="CPU-Z\cpuz_x64.exe";              winget="CPUID.CPU-Z";                     url="https://www.cpuid.com/softwares/cpu-z.html" }
    "gpuz"            = @{ arquivo="GPU-Z\GPU-Z.exe";                 winget="TechPowerUp.GPU-Z";               url="https://www.techpowerup.com/gpuz/" }
    "speccy"          = @{ arquivo="Speccy\Speccy64.exe";              winget="Piriform.Speccy";                 url="https://www.ccleaner.com/speccy/download/portable" }
    # --- Rede e Acesso Remoto ---
    "putty"           = @{ arquivo="PuTTY\putty.exe";                  winget="PuTTY.PuTTY";                     url="https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html" }
    "rustdesk"        = @{ arquivo="RustDesk\rustdesk.exe";            winget="RustDesk.RustDesk";               url="https://rustdesk.com" }
    "anydesk"         = @{ arquivo="AnyDesk\AnyDesk.exe";              winget="AnyDeskSoftwareGmbH.AnyDesk";     url="https://anydesk.com/pt/downloads" }
    "ipscanner"       = @{ arquivo="IPScanner\Advanced_IP_Scanner.exe";winget="Famatech.AdvancedIPScanner";      url="https://www.advanced-ip-scanner.com" }
    "wireshark"       = @{ arquivo="";                                 winget="WiresharkFoundation.Wireshark";   url="https://www.wireshark.org/download.html" }
    "tcpview"         = @{ arquivo="TCPView\Tcpview64.exe";            winget="Microsoft.Sysinternals.TCPView";  url="" }
    # --- Seguranca ---
    "malwarebytes"    = @{ arquivo="";                                 winget="Malwarebytes.Malwarebytes";       url="https://www.malwarebytes.com" }
    "adwcleaner"      = @{ arquivo="AdwCleaner\AdwCleaner.exe";        winget="";                                url="https://www.malwarebytes.com/adwcleaner" }
    "rkill"           = @{ arquivo="RKill\rkill.exe";                  winget="";                                url="https://www.bleepingcomputer.com/download/rkill/" }
    "autoruns"        = @{ arquivo="Autoruns\Autoruns64.exe";          winget="Microsoft.Sysinternals.Autoruns"; url="https://learn.microsoft.com/en-us/sysinternals/downloads/autoruns" }
    # --- Utilitarios ---
    "rufus"           = @{ arquivo="Rufus\rufus.exe";                  winget="Rufus.Rufus";                     url="https://rufus.ie" }
    "procexp"         = @{ arquivo="ProcessExplorer\procexp64.exe";    winget="Microsoft.Sysinternals.ProcessExplorer"; url="" }
    "treesize"        = @{ arquivo="TreeSize\TreeSizeFree.exe";        winget="JAMSoftware.TreeSize.Free";       url="https://www.jam-software.com/treesize_free" }
    "windirstat"      = @{ arquivo="WinDirStat\windirstat.exe";        winget="WinDirStat.WinDirStat";           url="https://windirstat.net" }
    # --- Stress Test ---
    "prime95"         = @{ arquivo="Prime95\prime95.exe";              winget="";                                url="https://www.mersenne.org/download/" }
    "furmark"         = @{ arquivo="FurMark\FurMark.exe";              winget="Geeks3D.FurMark";                 url="https://www.geeks3d.com/furmark/" }
}

Write-Host ""
Write-Host "  [MICROFAST] Launcher de Ferramentas" -ForegroundColor Cyan

if ($Ferramenta -eq "" -or !$FerramentasMap.ContainsKey($Ferramenta.ToLower())) {
    Write-Host "  Ferramentas disponiveis:" -ForegroundColor Yellow
    foreach ($k in $FerramentasMap.Keys | Sort-Object) {
        $exe = "$ToolsDir\$($FerramentasMap[$k].arquivo)"
        $status = if ($FerramentasMap[$k].arquivo -ne "" -and (Test-Path $exe)) { "[NO PENDRIVE]" } else { "[winget/download]" }
        Write-Host "    $k $status" -ForegroundColor $(if($status -match "PENDRIVE"){"Green"}else{"Yellow"})
    }
    Write-Host ""
    Read-Host "  Pressione Enter para fechar"
    exit 0
}

$key = $Ferramenta.ToLower()
$cfg = $FerramentasMap[$key]

# 1. Tenta abrir do pendrive
if ($cfg.arquivo -ne "") {
    $exePath = "$ToolsDir\$($cfg.arquivo)"
    if (Test-Path $exePath) {
        Write-Host "  [OK] Abrindo $Ferramenta do pendrive..." -ForegroundColor Green
        Write-Host "  Path: $exePath" -ForegroundColor Gray
        Start-Process $exePath
        exit 0
    }
}

# 2. Tenta instalar via winget
if ($cfg.winget -ne "") {
    Write-Host "  Nao encontrado no pendrive. Instalando via winget..." -ForegroundColor Yellow
    Write-Host "  Pacote: $($cfg.winget)" -ForegroundColor Gray
    $result = Start-Process "winget" -ArgumentList "install --id $($cfg.winget) --silent --accept-source-agreements --accept-package-agreements" -Wait -PassThru
    if ($result.ExitCode -eq 0) {
        Write-Host "  [OK] Instalado com sucesso via winget!" -ForegroundColor Green
    } else {
        Write-Host "  [AVISO] winget falhou. Abrindo pagina de download..." -ForegroundColor Yellow
        if ($cfg.url -ne "") { Start-Process $cfg.url }
    }
} elseif ($cfg.url -ne "") {
    Write-Host "  Abrindo pagina de download..." -ForegroundColor Yellow
    Start-Process $cfg.url
}

Write-Host ""
Read-Host "  Pressione Enter para fechar"
