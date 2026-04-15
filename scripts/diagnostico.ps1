# ============================================================
# MICROFAST TECNICO - Diagnostico Completo v3.2
# Formato identico aos relatorios SGS reais
# Inclui: avaliacao de upgrade + relatorio de bateria
# ============================================================
param(
    [string]$ParamFile   = "",
    [string]$ClienteNome = "",
    [string]$Contexto    = "SGS",
    [string]$Observacoes = "-",
    [string]$TecnicoNome = "Antonio Oliveira",
    [string]$OutputPath  = ""
)
$ErrorActionPreference = "SilentlyContinue"
$Host.UI.RawUI.WindowTitle = "MicroFast - Diagnostico v3.2"

# ── Lê parâmetros do arquivo INI se fornecido ────────────
if ($ParamFile -ne "" -and (Test-Path $ParamFile)) {
    $lines = Get-Content $ParamFile -Encoding UTF8 -ErrorAction SilentlyContinue
    foreach ($line in $lines) {
        if ($line -match '^ClienteNome=(.*)$') { $ClienteNome = $Matches[1].Trim() }
        if ($line -match '^Contexto=(.*)$')    { $Contexto    = $Matches[1].Trim() }
        if ($line -match '^Observacoes=(.*)$') { $Observacoes = $Matches[1].Trim() }
        if ($line -match '^TecnicoNome=(.*)$') { $TecnicoNome = $Matches[1].Trim() }
        if ($line -match '^OutputPath=(.*)$')  { $OutputPath  = $Matches[1].Trim() }
    }
    # Remove arquivo temporário após leitura
    Remove-Item $ParamFile -Force -ErrorAction SilentlyContinue
}

# ── Limpa aspas residuais que possam ter chegado ────────
$ClienteNome = $ClienteNome.Trim(" '`"")
$Contexto    = $Contexto.Trim(" '`"")
$Observacoes = $Observacoes.Trim(" '`"")
$TecnicoNome = $TecnicoNome.Trim(" '`"")
$OutputPath  = $OutputPath.Trim(" '`"")

# ── Resolve OutputPath se ainda vazio ────────────────────
if ($OutputPath -eq "") {
    if ($PSScriptRoot -and $PSScriptRoot -ne "") {
        $OutputPath = Join-Path (Split-Path $PSScriptRoot -Parent) "relatorios"
    } else {
        $OutputPath = "D:\Pendrive Tecnico MF\relatorios"
    }
}

# Defaults
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

# ── Grava .TXT ───────────────────────────────────────────
$L | Out-File -FilePath $Arquivo -Encoding UTF8

# ── Gera relatório HTML visual ───────────────────────────
$htmlFile = "$OutputPath\relatorio_${NomePC}_${DataArq}.html"
$notaCor  = switch ($nota) {
    "A" { "#00c853" } "B" { "#64dd17" } "C" { "#ffab00" }
    "D" { "#ff6d00" } default { "#ff1744" }
}
$scoreBar = [math]::Round($score / 75 * 100, 0)
$ramPct   = [math]::Round(($EmUso / ([math]::Max($TotalGB, 1))) * 100, 0)
$discoPct = $pctC

$html = @"
<!DOCTYPE html>
<html lang="pt-BR">
<head><meta charset="UTF-8">
<title>Relatório — $ClienteNome — $Data</title>
<style>
*{margin:0;padding:0;box-sizing:border-box;}
body{background:#0d1117;color:#e0f0ff;font-family:'Segoe UI',Arial,sans-serif;padding:2rem;}
.header{display:flex;align-items:center;justify-content:space-between;border-bottom:2px solid #00e5ff;padding-bottom:1.5rem;margin-bottom:2rem;}
.brand{font-size:28px;font-weight:700;color:#00e5ff;letter-spacing:2px;}
.brand span{color:#fff;}
.meta{text-align:right;font-size:13px;color:#8ab4d4;}
.meta strong{color:#e0f0ff;display:block;font-size:16px;}
.score-box{background:#111820;border:2px solid $notaCor;border-radius:16px;padding:1.5rem 2rem;display:flex;align-items:center;gap:2rem;margin-bottom:2rem;}
.score-nota{font-size:80px;font-weight:700;color:$notaCor;line-height:1;}
.score-info h2{font-size:20px;color:#e0f0ff;margin-bottom:.5rem;}
.score-info p{font-size:14px;color:#8ab4d4;margin-bottom:.75rem;}
.progress{background:#1e3048;border-radius:20px;height:12px;overflow:hidden;}
.progress-fill{height:100%;border-radius:20px;background:$notaCor;width:${scoreBar}%;}
.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(300px,1fr));gap:1rem;margin-bottom:2rem;}
.card{background:#111820;border:1px solid #1e3048;border-radius:10px;padding:1.25rem;}
.card h3{font-size:12px;text-transform:uppercase;letter-spacing:1px;color:#4a7a9b;margin-bottom:1rem;}
.row{display:flex;justify-content:space-between;padding:5px 0;border-bottom:1px solid #1e3048;font-size:13px;}
.row:last-child{border:none;}
.row .lbl{color:#8ab4d4;}
.row .val{color:#e0f0ff;font-weight:500;text-align:right;}
.bar-row{margin:6px 0;}
.bar-lbl{display:flex;justify-content:space-between;font-size:12px;color:#8ab4d4;margin-bottom:3px;}
.bar{background:#1e3048;border-radius:4px;height:8px;overflow:hidden;}
.bar-fill{height:100%;border-radius:4px;}
.bar-fill.ram{background:#00e5ff;width:${ramPct}%;}
.bar-fill.disk{background:$(if($discoPct -gt 85){'#ff1744'}elseif($discoPct -gt 70){'#ffab00'}else{'#00c853'});width:${discoPct}%;}
.alertas{margin-bottom:2rem;}
.alerta{display:flex;align-items:flex-start;gap:.75rem;background:rgba(255,23,68,.08);border:1px solid rgba(255,23,68,.25);border-radius:8px;padding:.875rem;margin-bottom:.5rem;font-size:13px;color:#ff6b6b;}
.alerta.warn{background:rgba(255,171,0,.08);border-color:rgba(255,171,0,.25);color:#ffab00;}
.alerta.ok{background:rgba(0,200,83,.08);border-color:rgba(0,200,83,.25);color:#00c853;}
.footer{text-align:center;font-size:12px;color:#4a7a9b;border-top:1px solid #1e3048;padding-top:1.5rem;margin-top:1rem;}
</style></head>
<body>
<div class="header">
  <div><div class="brand">MICRO<span>FAST</span></div><div style="font-size:12px;color:#4a7a9b;letter-spacing:2px">RELATÓRIO TÉCNICO</div></div>
  <div class="meta"><strong>$ClienteNome</strong>$Data · $Contexto · Téc: $TecnicoNome</div>
</div>

<div class="score-box">
  <div class="score-nota">$nota</div>
  <div class="score-info">
    <h2>Score: $score / 75 — $precisa</h2>
    <p>RAM: $rRAM &nbsp;|&nbsp; Disco: $rDisco &nbsp;|&nbsp; CPU: $rCPU</p>
    <div class="progress"><div class="progress-fill"></div></div>
  </div>
</div>

<div class="grid">
  <div class="card">
    <h3>Sistema Operacional</h3>
    <div class="row"><span class="lbl">PC</span><span class="val">$NomePC</span></div>
    <div class="row"><span class="lbl">SO</span><span class="val">$($OS.Caption)</span></div>
    <div class="row"><span class="lbl">Build</span><span class="val">$($OS.BuildNumber)</span></div>
    <div class="row"><span class="lbl">Último boot</span><span class="val">$($OS.LastBootUpTime.ToString('dd/MM HH:mm'))</span></div>
    <div class="row"><span class="lbl">Usuário</span><span class="val">$($env:USERNAME)</span></div>
  </div>
  <div class="card">
    <h3>Processador</h3>
    <div class="row"><span class="lbl">Modelo</span><span class="val" style="max-width:200px;word-break:break-word">$($CPU.Name.Trim())</span></div>
    <div class="row"><span class="lbl">Núcleos</span><span class="val">$($CPU.NumberOfCores) / $($CPU.NumberOfLogicalProcessors) threads</span></div>
    <div class="row"><span class="lbl">Clock</span><span class="val">$($CPU.MaxClockSpeed) MHz</span></div>
    <div class="row"><span class="lbl">Avaliação</span><span class="val" style="color:$notaCor">$rCPU</span></div>
  </div>
  <div class="card">
    <h3>Memória RAM</h3>
    <div class="bar-row"><div class="bar-lbl"><span>Uso atual</span><span>${ramPct}%</span></div><div class="bar"><div class="bar-fill ram"></div></div></div>
    <div class="row"><span class="lbl">Total</span><span class="val">$TotalGB GB</span></div>
    <div class="row"><span class="lbl">Em uso</span><span class="val">$EmUso GB</span></div>
    <div class="row"><span class="lbl">Disponível</span><span class="val">$Disp GB</span></div>
    <div class="row"><span class="lbl">Avaliação</span><span class="val" style="color:$notaCor">$rRAM</span></div>
  </div>
  <div class="card">
    <h3>Disco — Drive C:</h3>
    <div class="bar-row"><div class="bar-lbl"><span>Uso do disco</span><span>${discoPct}%</span></div><div class="bar"><div class="bar-fill disk"></div></div></div>
    <div class="row"><span class="lbl">Total</span><span class="val">$totC GB</span></div>
    <div class="row"><span class="lbl">SMART</span><span class="val" style="color:$(if($SMARTGeral -eq 'OK'){'#00c853'}else{'#ff1744'})">$SMARTGeral</span></div>
    <div class="row"><span class="lbl">Tipo</span><span class="val">$(if($isSSD){'SSD ✓'}else{'HDD'})</span></div>
    <div class="row"><span class="lbl">Avaliação</span><span class="val" style="color:$notaCor">$rDisco</span></div>
  </div>
</div>

<div class="alertas">
"@

if ($alertas.Count -gt 0) {
    foreach ($a in $alertas) {
        $html += "  <div class='alerta'>⚠ $a</div>`n"
    }
} elseif ($recos.Count -gt 0) {
    foreach ($r in $recos) {
        $html += "  <div class='alerta warn'>› $r</div>`n"
    }
} else {
    $html += "  <div class='alerta ok'>✓ Hardware adequado — sem alertas críticos detectados.</div>`n"
}

if ($Observacoes -ne "-" -and $Observacoes -ne "") {
    $html += "  <div class='alerta warn' style='color:#8ab4d4'>📝 Observações: $Observacoes</div>`n"
}

$html += @"
</div>
<div class="footer">MicroFast Informática · Tel. (013) 97826-4067 · Técnico: $TecnicoNome · $Data</div>
</body></html>
"@

$html | Out-File -FilePath $htmlFile -Encoding UTF8

Write-Host ""
Write-Host "  ========================================" -ForegroundColor Green
Write-Host "  [OK] Relatório TXT : $Arquivo" -ForegroundColor Green
Write-Host "  [OK] Relatório HTML: $htmlFile" -ForegroundColor Cyan
Write-Host "  ========================================" -ForegroundColor Green

# Notificação sonora
[console]::beep(1000, 200)
[console]::beep(1200, 200)

# Abre os dois relatórios
Start-Process notepad.exe -ArgumentList "`"$Arquivo`""
Start-Sleep -Milliseconds 500
Start-Process $htmlFile

# Registra no histórico
$histScript = Join-Path (if($PSScriptRoot){"$PSScriptRoot"}else{"D:\Pendrive Tecnico MF\scripts"}) "historico.ps1"
if (Test-Path $histScript) {
    & $histScript -Acao registrar -TipoAcao "Diagnóstico" -Cliente $ClienteNome -Resultado "Nota $nota | Score $score/75 | $precisa" -Tecnico $TecnicoNome
}

# Bateria opcional
if ($Bat) {
    Write-Host ""
    Write-Host "  Notebook detectado. Gerar relatorio de bateria (.html)? [S/N]" -ForegroundColor Yellow
    $r = Read-Host "  "
    if ($r -match "^[Ss]") {
        $batFile = "$OutputPath\bateria_${NomePC}_${DataArq}.html"
        # powercfg precisa rodar do System32 para carregar energy.dll corretamente
        $powercfgExe = "$env:SystemRoot\System32\powercfg.exe"
        if (Test-Path $powercfgExe) {
            $proc = Start-Process -FilePath $powercfgExe `
                -ArgumentList "/batteryreport /output `"$batFile`"" `
                -Wait -PassThru -WindowStyle Hidden `
                -WorkingDirectory "$env:SystemRoot\System32"
            Start-Sleep -Seconds 2
        } else {
            # fallback
            & powercfg.exe /batteryreport /output "$batFile" 2>$null
            Start-Sleep -Seconds 2
        }
        if (Test-Path $batFile) {
            Write-Host "  [OK] Bateria: $batFile" -ForegroundColor Green
            Start-Process $batFile
        } else {
            Write-Host "  [!] Relatorio de bateria nao gerado (energy.dll indisponivel neste sistema)" -ForegroundColor Yellow
            Write-Host "  Tente: powercfg /batteryreport no CMD como Admin" -ForegroundColor Gray
        }
    }
}

Write-Host ""
Read-Host "  Pressione Enter para fechar"
