# ============================================================
# MICROFAST TECNICO - Deteccao de Hardware e Busca de Drivers
# ============================================================

param([string]$Acao = "detectar")  # detectar | atualizar | display | audio | rede | chipset

$ErrorActionPreference = "SilentlyContinue"
Write-Host ""
Write-Host "  [MICROFAST] Modulo de Drivers" -ForegroundColor Cyan
Write-Host "  ================================" -ForegroundColor Cyan

function Detect-Hardware {
    Write-Host ""
    Write-Host "  Detectando hardware instalado..." -ForegroundColor Yellow
    Write-Host ""

    # Modelo do computador
    $CS = Get-CimInstance Win32_ComputerSystem
    $BIOS = Get-CimInstance Win32_BIOS
    Write-Host "  [MODELO] $($CS.Manufacturer) $($CS.Model)" -ForegroundColor Green
    Write-Host "  [SERIAL] $($BIOS.SerialNumber)" -ForegroundColor Gray

    # CPU
    $CPU = Get-CimInstance Win32_Processor
    Write-Host "  [CPU   ] $($CPU.Name.Trim())" -ForegroundColor Green

    # GPU
    $GPUs = Get-CimInstance Win32_VideoController
    foreach ($g in $GPUs) {
        Write-Host "  [GPU   ] $($g.Name) | Driver: $($g.DriverVersion)" -ForegroundColor Green
    }

    # Audio
    $Audio = Get-CimInstance Win32_SoundDevice
    foreach ($a in $Audio) {
        Write-Host "  [AUDIO ] $($a.Name)" -ForegroundColor Green
    }

    # Rede
    $Net = Get-CimInstance Win32_NetworkAdapter | Where-Object { $_.PhysicalAdapter -eq $true }
    foreach ($n in $Net) {
        Write-Host "  [REDE  ] $($n.Name)" -ForegroundColor Green
    }

    # Discos fisicos
    $Discos = Get-PhysicalDisk
    foreach ($d in $Discos) {
        Write-Host "  [DISCO ] $($d.FriendlyName) | $($d.MediaType) | $([math]::Round($d.Size/1GB,0)) GB" -ForegroundColor Green
    }

    Write-Host ""
    Write-Host "  Fabricante detectado: $($CS.Manufacturer)" -ForegroundColor Cyan

    # Sugere URL do fabricante para drivers
    $fab = $CS.Manufacturer.ToLower()
    if ($fab -match "dell") {
        Write-Host "  URL de drivers: https://www.dell.com/support/home" -ForegroundColor Cyan
        Start-Process "https://www.dell.com/support/home"
    } elseif ($fab -match "lenovo") {
        Write-Host "  URL de drivers: https://support.lenovo.com" -ForegroundColor Cyan
        Start-Process "https://support.lenovo.com"
    } elseif ($fab -match "hp|hewlett") {
        Write-Host "  URL de drivers: https://support.hp.com" -ForegroundColor Cyan
        Start-Process "https://support.hp.com"
    } elseif ($fab -match "asus") {
        Write-Host "  URL de drivers: https://www.asus.com/support" -ForegroundColor Cyan
        Start-Process "https://www.asus.com/support"
    } elseif ($fab -match "acer") {
        Write-Host "  URL de drivers: https://www.acer.com/drivers" -ForegroundColor Cyan
        Start-Process "https://www.acer.com/drivers"
    } elseif ($fab -match "samsung") {
        Write-Host "  URL de drivers: https://www.samsung.com/semiconductor/minisite/ssd/download/tools/" -ForegroundColor Cyan
    } else {
        Write-Host "  Fabricante: $($CS.Manufacturer) — busque drivers no site oficial" -ForegroundColor Yellow
    }
}

function Update-AllDrivers {
    Write-Host ""
    Write-Host "  Atualizando todos os drivers via Windows Update..." -ForegroundColor Yellow
    $result = Start-Process "pnputil.exe" -ArgumentList "/scan-devices" -Wait -PassThru
    Write-Host "  [OK] Varredura de dispositivos concluida" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Iniciando Windows Update para drivers..." -ForegroundColor Yellow
    Start-Process "ms-settings:windowsupdate"
    Write-Host "  [INFO] Windows Update aberto — clique em 'Verificar atualizacoes'" -ForegroundColor Cyan
}

function Update-DisplayDriver {
    Write-Host ""
    $GPU = Get-CimInstance Win32_VideoController
    foreach ($g in $GPU) {
        Write-Host "  GPU detectada: $($g.Name)" -ForegroundColor Green
        if ($g.Name -match "NVIDIA") {
            Write-Host "  Abrindo site NVIDIA GeForce..." -ForegroundColor Cyan
            Start-Process "https://www.nvidia.com/pt-br/geforce/drivers/"
        } elseif ($g.Name -match "AMD|Radeon") {
            Write-Host "  Abrindo AMD Adrenalin Software..." -ForegroundColor Cyan
            Start-Process "https://www.amd.com/pt/support"
        } elseif ($g.Name -match "Intel") {
            Write-Host "  Abrindo Intel Driver & Support Assistant..." -ForegroundColor Cyan
            Start-Process "https://www.intel.com.br/content/www/br/pt/support/intel-driver-support-assistant.html"
        }
    }
}

function Update-AudioDriver {
    Write-Host ""
    Write-Host "  Buscando driver de audio atual..." -ForegroundColor Yellow
    $Audio = Get-CimInstance Win32_SoundDevice
    foreach ($a in $Audio) {
        Write-Host "  Dispositivo: $($a.Name)" -ForegroundColor Green
    }
    Write-Host "  Instalando via winget..." -ForegroundColor Yellow
    winget install --id "Realtek.RealtekAudioDriver" --silent --accept-source-agreements 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  [OK] Driver Realtek instalado via winget" -ForegroundColor Green
    } else {
        Write-Host "  [INFO] Tentando via Windows Update..." -ForegroundColor Yellow
        pnputil /scan-devices | Out-Null
        Start-Process "ms-settings:windowsupdate"
    }
}

function Update-NetworkDriver {
    Write-Host ""
    $Net = Get-CimInstance Win32_NetworkAdapter | Where-Object { $_.PhysicalAdapter -eq $true }
    foreach ($n in $Net) {
        Write-Host "  Adaptador: $($n.Name)" -ForegroundColor Green
        if ($n.Name -match "Intel") {
            Start-Process "https://www.intel.com/content/www/us/en/download/18293/intel-network-adapter-driver-for-windows-10.html"
        } elseif ($n.Name -match "Realtek") {
            Start-Process "https://www.realtek.com/en/component/zoo/category/network-interface-controllers-10-100-1000m-gigabit-ethernet-pci-express-software"
        } elseif ($n.Name -match "Qualcomm|Atheros") {
            Start-Process "https://www.qualcomm.com/support"
        }
    }
    pnputil /scan-devices | Out-Null
    Write-Host "  [OK] Varredura de drivers de rede concluida" -ForegroundColor Green
}

# Executa a acao solicitada
switch ($Acao) {
    "detectar"  { Detect-Hardware }
    "atualizar" { Update-AllDrivers }
    "display"   { Update-DisplayDriver }
    "audio"     { Update-AudioDriver }
    "rede"      { Update-NetworkDriver }
    default     { Detect-Hardware }
}

Write-Host ""
Write-Host "  [MICROFAST] Modulo de drivers concluido." -ForegroundColor Cyan
Write-Host ""
Read-Host "  Pressione Enter para fechar"
