# ============================================================
# MICROFAST TECNICO - Diagnostico Completo v3.1
# Formato identico aos relatorios SGS reais
# Inclui: avaliacao de upgrade + relatorio de bateria
# ============================================================
param(
    [string]$ClienteNome = "",
    [string]$Contexto    = "SGS",
    [string]$Observacoes = "-",
    [string]$TecnicoNome = "Antonio Oliveira",
    [string]$OutputPath  = ""
)
$ErrorActionPreference = "SilentlyContinue"
$Host.UI.RawUI.WindowTitle = "MicroFast - Diagnostico v3.1"

# Resolve OutputPath: usa PSScriptRoot se nao informado
if ($OutputPath -eq "" -or $OutputPath -eq $null) {
    if ($PSScriptRoot -and $PSScriptRoot -ne "") {
        $OutputPath = Join-Path (Split-Path $PSScriptRoot -Parent) "relatorios"
    } else {
        $OutputPath = "D:\Pendrive Tecnico MF\relatorios"
    }
}

# Sanitiza inputs
$ClienteNome = $ClienteNome.Trim().Replace('"','').Replace("'",'')
$Observacoes = $Observacoes.Trim().Replace('"','').Replace("'",'')
$TecnicoNome = $TecnicoNome.Trim().Replace('"','').Replace("'",'')
if ($ClienteNome -eq "") { $ClienteNome = $env:COMPUTERNAME }
if ($Observacoes -eq "") { $Observacoes = "-" }

$Data    = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
$DataArq = Get-Date -Format "yyyyMMdd_HHmm"
$NomePC  = $env:COMPUTERNAME
if ($ClienteNome -eq "") { $ClienteNome = $NomePC }
if (!(Test-Path $OutputPath)) { New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null }
$Arquivo = "$OutputPath\diagnostico_${NomePC}_${DataArq}.txt"

function WH($t)   { Write-Host "`n  --- $t ---" -ForegroundColor Cyan }
function WOK($k,$v) { Write-Host "  $($k.PadRight(14)): $v" -ForegroundColor White }
function WGOOD($m){ Write-Host "  [v] $m" -ForegroundColor Green }
function WWARN($m){ Write-Host "  [!] $m" -ForegroundColor Yellow }
function WERR($m) { Write-Host "  [X] $m" -ForegroundColor Red }

Clear-Host
Write-Host ""
Write-Host "  ========================================" -ForegroundColor Cyan
Write-Host "     RELATORIO DE DIAGNOSTICO - $Contexto" -ForegroundColor White
Write-Host "     Tecnico: $TecnicoNome" -ForegroundColor White
Write-Host "     $Data" -ForegroundColor Gray
Write-Host "  ========================================" -ForegroundColor Cyan

$L = New-Object System.Collections.Generic.List[string]
$L.Add("========================================")
$L.Add("   RELATORIO DE DIAGNOSTICO - $Contexto")
$L.Add("   Tecnico: $TecnicoNome")
$L.Add("   Data: $Data")
$L.Add("========================================")

# SO
WH "SISTEMA OPERACIONAL"
$OS   = Get-CimInstance Win32_OperatingSystem
$CS   = Get-CimInstance Win32_ComputerSystem
$BIOS = Get-CimInstance Win32_BIOS
$L.Add(""); $L.Add("--- SISTEMA OPERACIONAL ---")
$L.Add("Nome do PC    : $($OS.CSName)")
$L.Add("SO            : $($OS.Caption)")
$L.Add("Versao        : $($OS.Version)")
$L.Add("Build         : $($OS.BuildNumber)")
$L.Add("Arquitetura   : $($OS.OSArchitecture)")
$L.Add("Ultimo Boot   : $($OS.LastBootUpTime.ToString('dd/MM/yyyy HH:mm:ss'))")
$L.Add("Status Windows: OK")
WOK "Nome do PC"  $OS.CSName
WOK "SO"          $OS.Caption
WOK "Build"       "$($OS.BuildNumber) / $($OS.Version)"
WOK "Arquitetura" $OS.OSArchitecture
WOK "Ultimo Boot" $OS.LastBootUpTime.ToString('dd/MM/yyyy HH:mm:ss')

# Usuario
WH "USUARIO ATUAL"
$L.Add(""); $L.Add("--- USUARIO ATUAL ---")
$L.Add("Usuario       : $($env:USERNAME)")
$L.Add("Dominio       : $($env:USERDOMAIN)")
$L.Add("Perfil        : $($env:USERPROFILE)")
WOK "Usuario" $env:USERNAME
WOK "Dominio" $env:USERDOMAIN
WOK "Perfil"  $env:USERPROFILE

# CPU
WH "PROCESSADOR"
$CPU = Get-CimInstance Win32_Processor
$L.Add(""); $L.Add("--- PROCESSADOR ---")
$L.Add("Modelo        : $($CPU.Name.Trim())")
$L.Add("Nucleos       : $($CPU.NumberOfCores)")
$L.Add("Threads       : $($CPU.NumberOfLogicalProcessors)")
$L.Add("Clock Max     : $($CPU.MaxClockSpeed) MHz")
$L.Add("Arquitetura   : 64 bits")
WOK "Modelo"   $CPU.Name.Trim()
WOK "Nucleos"  "$($CPU.NumberOfCores) / $($CPU.NumberOfLogicalProcessors) threads"
WOK "Clock"    "$($CPU.MaxClockSpeed) MHz"
WOK "Carga"    "$($CPU.LoadPercentage)%"

# RAM
WH "MEMORIA RAM"
$Sticks = Get-CimInstance Win32_PhysicalMemory
$TotalGB= [math]::Round(($Sticks | Measure-Object -Property Capacity -Sum).Sum / 1GB, 0)
$EmUso  = [math]::Round(($OS.TotalVisibleMemorySize - $OS.FreePhysicalMemory) / 1MB, 2)
$Disp   = [math]::Round($OS.FreePhysicalMemory / 1MB, 2)
$L.Add(""); $L.Add("--- MEMORIA RAM ---")
$L.Add("Total         : $TotalGB GB")
$L.Add("Em uso        : $EmUso GB")
$L.Add("Disponivel    : $Disp GB")
WOK "Total"      "$TotalGB GB"
WOK "Em uso"     "$EmUso GB"
WOK "Disponivel" "$Disp GB"
foreach ($s in $Sticks) {
    $gb  = [math]::Round($s.Capacity / 1GB, 0)
    $spd = $s.Speed
    $bnk = $s.BankLabel
    $L.Add("Pente         : $gb GB - $spd MHz - $bnk")
    WOK "Pente" "$gb GB - $spd MHz - $bnk"
}

# Discos
WH "DISCOS"
$Drives  = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3"
$DiskFis = Get-PhysicalDisk
$L.Add(""); $L.Add("--- DISCOS (Unidades Locais) ---")
$SMARTGeral = "OK"
foreach ($d in $Drives) {
    $tot = [math]::Round($d.Size/1GB,1)
    $us  = [math]::Round(($d.Size-$d.FreeSpace)/1GB,1)
    $liv = [math]::Round($d.FreeSpace/1GB,1)
    $pct = if($d.Size -gt 0){ [math]::Round((($d.Size-$d.FreeSpace)/$d.Size)*100,1) } else {0}
    $txt = "Drive $($d.DeviceID)  Total=${tot}GB | Usado=${us}GB | Livre=${liv}GB | $pct% cheio"
    $L.Add($txt)
    Write-Host "  $txt" -ForegroundColor $(if($pct -gt 85){"Red"}elseif($pct -gt 70){"Yellow"}else{"Green"})
}
$L.Add(""); $L.Add("--- SAUDE SMART ---")
foreach ($df in $DiskFis) {
    $sz  = [math]::Round($df.Size/1GB,0)
    $hs  = $df.HealthStatus
    $med = $df.MediaType
    $L.Add("$($df.FriendlyName) | $med | $sz GB | SMART: $hs")
    if ($hs -ne "Healthy") { $SMARTGeral = "ATENCAO" }
    Write-Host "  Disco: $($df.FriendlyName) - SMART: $hs - $med" -ForegroundColor $(if($hs -eq "Healthy"){"Green"}else{"Red"})
}

# Rede
WH "CONFIGURACAO DE REDE"
$Adapters = Get-CimInstance Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled }
$L.Add(""); $L.Add("--- CONFIGURACAO DE REDE ---")
foreach ($a in $Adapters) {
    $ni   = Get-CimInstance Win32_NetworkAdapter | Where-Object { $_.Index -eq $a.Index }
    $nome = if ($ni.NetConnectionID) { $ni.NetConnectionID } else { $a.Description }
    $ip   = ($a.IPAddress | Where-Object { $_ -match '\.' }) -join ", "
    $mask = ($a.IPSubnet | Select-Object -First 1)
    $gw   = ($a.DefaultIPGateway -join ", ")
    $L.Add("")
    $L.Add("Interface     : $nome")
    $L.Add("IP            : $ip / $mask")
    if ($gw) { $L.Add("Gateway       : $gw") }
    WOK "Interface" $nome
    WOK "IP"        "$ip / $mask"
    if ($gw) { WOK "Gateway" $gw }
}
$online = Test-Connection -ComputerName "8.8.8.8" -Count 1 -Quiet -TimeToLive 32
$L.Add("Internet      : $(if($online){'ONLINE'}else{'OFFLINE'})")
WOK "Internet" $(if($online){"ONLINE"}else{"OFFLINE"})

# GPU
WH "PLACA DE VIDEO"
$GPUs = Get-CimInstance Win32_VideoController
$L.Add(""); $L.Add("--- PLACA DE VIDEO ---")
foreach ($g in $GPUs) {
    $vram = if($g.AdapterRAM -and $g.AdapterRAM -gt 0){ "$([math]::Round($g.AdapterRAM/1MB,0)) MB" } else { "Shared/Dinamica" }
    $L.Add("Nome          : $($g.Name)")
    $L.Add("Driver        : $($g.DriverVersion)")
    $L.Add("VRAM          : $vram")
    $L.Add("Resolucao     : $($g.CurrentHorizontalResolution) x $($g.CurrentVerticalResolution)")
    WOK "GPU"      $g.Name
    WOK "Driver"   $g.DriverVersion
    WOK "VRAM"     $vram
    WOK "Resolucao" "$($g.CurrentHorizontalResolution) x $($g.CurrentVerticalResolution)"
}

# Bateria
$Bat = Get-CimInstance Win32_Battery
if ($Bat) {
    WH "BATERIA"
    $carga  = $Bat.EstimatedChargeRemaining
    $bstatus= switch ($Bat.BatteryStatus) {
        1{"Descarregando"}; 2{"AC - Carregando"}; 3{"Totalmente carregada"}
        4{"Baixa"}; 5{"Critica"}; 6{"Carregando"}; default{"Desconhecido"}
    }
    $L.Add(""); $L.Add("--- BATERIA ---")
    $L.Add("Status        : $bstatus")
    $L.Add("Carga         : $carga%")
    $L.Add("Tempo restante: $($Bat.EstimatedRunTime) min")
    WOK "Status" $bstatus
    WOK "Carga"  "$carga%"
    WOK "Tempo"  "$($Bat.EstimatedRunTime) min"
}

# Softwares
WH "SOFTWARES INSTALADOS"
$Progs = @()
$Progs += Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" 2>$null
$Progs += Get-ItemProperty "HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" 2>$null
$Progs += Get-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*" 2>$null
$Progs  = $Progs | Where-Object { $_.DisplayName } | Sort-Object DisplayName |
          Group-Object DisplayName | ForEach-Object { $_.Group | Select-Object -First 1 }
$L.Add(""); $L.Add("--- SOFTWARES INSTALADOS ---")
foreach ($p in $Progs) {
    $L.Add("$($p.DisplayName) | v$($p.DisplayVersion) | $($p.Publisher)")
}
WGOOD "$($Progs.Count) programas listados"

# Windows Update
WH "WINDOWS UPDATE"
$L.Add(""); $L.Add("--- ATUALIZACOES WINDOWS ---")
try {
    $sess = New-Object -ComObject Microsoft.Update.Session
    $srch = $sess.CreateUpdateSearcher()
    $res  = $srch.Search("IsInstalled=0 and Type='Software'")
    $nUpd = $res.Updates.Count
    $L.Add("Pendentes     : $nUpd atualizacao(oes)")
    if ($nUpd -gt 0) { foreach ($u in $res.Updates) { $L.Add("  - $($u.Title)") } }
    WOK "Pendentes" "$nUpd atualizacao(oes)"
} catch {
    $L.Add("Pendentes     : verificacao manual necessaria")
    WWARN "Verificacao via COM falhou - abra o Windows Update manualmente"
}

# ── AVALIACAO DE UPGRADE ─────────────────────────────────
WH "AVALIACAO DE HARDWARE"
$L.Add(""); $L.Add("--- AVALIACAO DE HARDWARE ---")

$score   = 0
$alertas = New-Object System.Collections.Generic.List[string]
$recos   = New-Object System.Collections.Generic.List[string]

# RAM score
if     ($TotalGB -ge 32) { $rRAM = "EXCELENTE ($TotalGB GB)"; $score += 25 }
elseif ($TotalGB -ge 16) { $rRAM = "BOM ($TotalGB GB)";       $score += 20 }
elseif ($TotalGB -ge 8)  { $rRAM = "ADEQUADO ($TotalGB GB)";  $score += 12; $alertas.Add("RAM $TotalGB GB - upgrade para 16 GB recomendado") }
else                     { $rRAM = "INSUFICIENTE ($TotalGB GB)"; $score += 4; $alertas.Add("RAM $TotalGB GB - UPGRADE URGENTE") }

# Disco score
$driveC = $Drives | Where-Object { $_.DeviceID -eq "C:" } | Select-Object -First 1
$totC   = if($driveC){ [math]::Round($driveC.Size/1GB,0) } else {0}
$pctC   = if($driveC -and $driveC.Size -gt 0){ [math]::Round((($driveC.Size-$driveC.FreeSpace)/$driveC.Size)*100,0) } else {0}
$dfisC  = $DiskFis | Select-Object -First 1
$isSSD  = ($dfisC.MediaType -match "SSD|Solid") -or ($dfisC.FriendlyName -match "NVMe|SSD|nvme")

if     ($isSSD -and $totC -ge 500) { $rDisco = "EXCELENTE (SSD $totC GB)"; $score += 25 }
elseif ($isSSD)                    { $rDisco = "BOM (SSD $totC GB)";        $score += 20 }
elseif ($totC -ge 500)             { $rDisco = "ADEQUADO (HDD $totC GB)";   $score += 10; $recos.Add("Migrar para SSD - ganho de desempenho significativo") }
else                               { $rDisco = "LIMITADO ($totC GB)";       $score += 5;  $alertas.Add("Disco C: $totC GB - espaco limitado") }
if ($pctC -gt 85) { $alertas.Add("Disco C: $pctC% ocupado - LIMPEZA URGENTE") }
elseif ($pctC -gt 70) { $recos.Add("Disco C: $pctC% ocupado - executar limpeza preventiva") }

# CPU score
$cpuGen = 0
if ($CPU.Name -match "(\d+)th Gen") { $cpuGen = [int]$Matches[1] }
elseif ($CPU.Name -match "Ryzen.*(\d)\d{3}") { $cpuGen = [int]$Matches[1] + 1 }
$cpuScore = if($cpuGen -ge 12){25} elseif($cpuGen -ge 10){22} elseif($cpuGen -ge 8){18} elseif($cpuGen -ge 6){12} else {8}
$score += $cpuScore
$rCPU = if($cpuGen -ge 12){"EXCELENTE (Gen $cpuGen)"} elseif($cpuGen -ge 10){"BOM (Gen $cpuGen)"} elseif($cpuGen -ge 8){"ADEQUADO (Gen $cpuGen)"} elseif($cpuGen -gt 0){"DEFASADO (Gen $cpuGen)"} else{"VERIFICADO"}
if ($cpuGen -gt 0 -and $cpuGen -lt 8) { $alertas.Add("CPU Gen $cpuGen defasado - considere upgrade") }

if ($SMARTGeral -ne "OK") { $alertas.Add("SMART com alertas - RISCO DE PERDA DE DADOS - BACKUP URGENTE!") }

$nota   = if($score -ge 85){"A"} elseif($score -ge 70){"B"} elseif($score -ge 55){"C"} elseif($score -ge 40){"D"} else{"F"}
$precisa= if($alertas.Count -gt 0){"SIM - UPGRADE RECOMENDADO"} else{"NAO - HARDWARE ADEQUADO"}

$L.Add("RAM           : $rRAM")
$L.Add("Disco         : $rDisco")
$L.Add("CPU           : $rCPU")
$L.Add("SMART Geral   : $SMARTGeral")
$L.Add("Score         : $score/75  (Nota: $nota)")
$L.Add("Precisa Upgrade: $precisa")

Write-Host ""
Write-Host "  Score: $score/75  |  Nota: $nota  |  $precisa" -ForegroundColor $(if($score -ge 70){"Green"}elseif($score -ge 50){"Yellow"}else{"Red"})

if ($alertas.Count -gt 0) {
    $L.Add(""); $L.Add("ALERTAS CRITICOS:")
    foreach ($a in $alertas) { $L.Add("  [!] $a"); WERR $a }
}
if ($recos.Count -gt 0) {
    $L.Add(""); $L.Add("RECOMENDACOES:")
    foreach ($r in $recos) { $L.Add("  [>] $r"); WWARN $r }
}
if ($Observacoes -ne "-" -and $Observacoes -ne "") {
    $L.Add(""); $L.Add("OBSERVACOES DO TECNICO: $Observacoes")
}

$L.Add("")
$L.Add("========================================")
$L.Add("   FIM DO RELATORIO")
$L.Add("========================================")

# Grava
$L | Out-File -FilePath $Arquivo -Encoding UTF8

Write-Host ""
Write-Host "  ========================================" -ForegroundColor Green
Write-Host "  [OK] Relatorio salvo:" -ForegroundColor Green
Write-Host "  $Arquivo" -ForegroundColor Cyan
Write-Host "  ========================================" -ForegroundColor Green
Start-Process notepad.exe $Arquivo

# Bateria opcional
if ($Bat) {
    Write-Host ""
    Write-Host "  Notebook detectado. Gerar relatorio de bateria (.html)? [S/N]" -ForegroundColor Yellow
    $r = Read-Host "  "
    if ($r -match "^[Ss]") {
        $batFile = "$OutputPath\bateria_${NomePC}_${DataArq}.html"
        & powercfg /batteryreport /output "$batFile" | Out-Null
        if (Test-Path $batFile) {
            Write-Host "  [OK] Bateria: $batFile" -ForegroundColor Green
            Start-Process $batFile
        }
    }
}

Write-Host ""
Read-Host "  Pressione Enter para fechar"
