# ============================================================
# MICROFAST TECNICO - Ferramentas de Rede
# ping, traceroute, DNS, varredura de portas, velocidade
# ============================================================
param([string]$Acao = "menu", [string]$Alvo = "")
$ErrorActionPreference = "SilentlyContinue"
$Host.UI.RawUI.WindowTitle = "MicroFast - Ferramentas de Rede"

function WH($t) { Write-Host "`n  ─── $t ───" -ForegroundColor Cyan }
function OK($m) { Write-Host "  [OK] $m" -ForegroundColor Green }
function ERR($m){ Write-Host "  [X]  $m" -ForegroundColor Red }
function INF($m){ Write-Host "  [i]  $m" -ForegroundColor White }
function Linha  { Write-Host "  " + ("─"*55) -ForegroundColor DarkGray }

Clear-Host
Write-Host ""
Write-Host "  ╔═══════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "  ║   MICROFAST - Ferramentas de Rede         ║" -ForegroundColor Cyan
Write-Host "  ╚═══════════════════════════════════════════╝" -ForegroundColor Cyan

function Menu-Rede {
    Write-Host ""
    Write-Host "  [1]  Ping avancado (com estatisticas)" -ForegroundColor White
    Write-Host "  [2]  Traceroute (rota ate o destino)" -ForegroundColor White
    Write-Host "  [3]  Diagnostico DNS" -ForegroundColor White
    Write-Host "  [4]  Informacoes da interface de rede" -ForegroundColor White
    Write-Host "  [5]  Teste de velocidade de internet" -ForegroundColor White
    Write-Host "  [6]  Varredura de portas" -ForegroundColor White
    Write-Host "  [7]  Monitorar rede em tempo real (netstat)" -ForegroundColor White
    Write-Host "  [8]  Teste de conectividade completo" -ForegroundColor White
    Write-Host "  [9]  Liberar e renovar IP (release/renew)" -ForegroundColor White
    Write-Host "  [0]  Sair" -ForegroundColor DarkGray
    Write-Host ""
    $op = Read-Host "  Escolha"
    return $op
}

function Ping-Avancado {
    Write-Host ""
    $dest = Read-Host "  Destino (ex: 8.8.8.8 ou google.com)"
    if ($dest -eq "") { $dest = "8.8.8.8" }
    WH "PING AVANCADO: $dest"
    $results = @()
    $ok = 0; $fail = 0; $times = @()
    Write-Host ""
    for ($i = 1; $i -le 10; $i++) {
        $p = Test-Connection -ComputerName $dest -Count 1 -TimeToLive 64
        if ($p) {
            $ms = $p.ResponseTime
            $times += $ms
            $ok++
            $col = if($ms -gt 100){"Yellow"}elseif($ms -gt 200){"Red"}else{"Green"}
            Write-Host "  Resposta de $dest  : $ms ms" -ForegroundColor $col
        } else {
            $fail++
            Write-Host "  Timeout #$i" -ForegroundColor Red
        }
        Start-Sleep -Milliseconds 300
    }
    Write-Host ""
    $perda  = [math]::Round($fail/10*100,0)
    $minT   = if($times.Count -gt 0){ ($times | Measure-Object -Minimum).Minimum } else {"N/A"}
    $maxT   = if($times.Count -gt 0){ ($times | Measure-Object -Maximum).Maximum } else {"N/A"}
    $avgT   = if($times.Count -gt 0){ [math]::Round(($times | Measure-Object -Average).Average,1) } else {"N/A"}
    Write-Host "  Enviados: 10  |  OK: $ok  |  Falhas: $fail  |  Perda: $perda%" -ForegroundColor White
    Write-Host "  Min: ${minT}ms  |  Max: ${maxT}ms  |  Media: ${avgT}ms" -ForegroundColor White
    if ($perda -eq 0) { OK "Conectividade perfeita com $dest" }
    elseif ($perda -le 20) { Write-Host "  [!] Perda leve ($perda%) - pode haver instabilidade" -ForegroundColor Yellow }
    else { ERR "Alta perda de pacotes ($perda%) - problema de rede detectado" }
}

function Traceroute-Rede {
    Write-Host ""
    $dest = Read-Host "  Destino (ex: google.com)"
    if ($dest -eq "") { $dest = "google.com" }
    WH "TRACEROUTE: $dest"
    Write-Host "  Rastreando rota ate $dest (max 30 saltos)..." -ForegroundColor Gray
    Write-Host ""
    tracert -d -w 1000 $dest
}

function DNS-Diagnostico {
    WH "DIAGNOSTICO DNS"
    $servidores = @("8.8.8.8","8.8.4.4","1.1.1.1","208.67.222.222")
    $hosts = @("google.com","microsoft.com","github.com")
    Write-Host ""
    Write-Host "  Configuracao DNS atual:" -ForegroundColor Yellow
    $adapts = Get-CimInstance Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled }
    foreach ($a in $adapts) {
        if ($a.DNSServerSearchOrder) {
            $ni = Get-CimInstance Win32_NetworkAdapter | Where-Object { $_.Index -eq $a.Index }
            $nome = if ($ni.NetConnectionID) { $ni.NetConnectionID } else { $a.Description }
            Write-Host "  $($nome): $($a.DNSServerSearchOrder -join ' | ')" -ForegroundColor White
        }
    }
    Write-Host ""
    Write-Host "  Testando resolucao DNS:" -ForegroundColor Yellow
    foreach ($h in $hosts) {
        try {
            $res = [System.Net.Dns]::GetHostAddresses($h)
            OK "$h -> $($res[0].IPAddressToString)"
        } catch {
            ERR "Falha ao resolver $h"
        }
    }
    Write-Host ""
    Write-Host "  Testando latencia dos servidores DNS:" -ForegroundColor Yellow
    foreach ($dns in $servidores) {
        $p = Test-Connection -ComputerName $dns -Count 2 -Quiet
        if ($p) {
            $ms = (Test-Connection -ComputerName $dns -Count 2).ResponseTime | Measure-Object -Average
            OK "$dns - ${ms.Average}ms"
        } else {
            ERR "$dns - inacessivel"
        }
    }
    Write-Host ""
    Write-Host "  Limpando cache DNS..." -ForegroundColor Gray
    ipconfig /flushdns | Out-Null
    OK "Cache DNS limpo com sucesso"
}

function Info-Interface {
    WH "INTERFACES DE REDE"
    ipconfig /all
    Write-Host ""
    Write-Host "  Tabela ARP (vizinhos na rede):" -ForegroundColor Yellow
    arp -a
    Write-Host ""
    Write-Host "  Tabela de rotas:" -ForegroundColor Yellow
    route print | Select-String -Pattern "^\s+\d+\.\d+"
}

function Teste-Velocidade {
    WH "TESTE DE VELOCIDADE"
    Write-Host ""
    Write-Host "  Metodo 1: Download de arquivo de referencia..." -ForegroundColor Yellow
    $testUrl = "http://speedtest.tele2.net/10MB.zip"
    $tmpFile = "$env:TEMP\mf_speedtest.tmp"
    try {
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        $wc = New-Object System.Net.WebClient
        $wc.DownloadFile($testUrl, $tmpFile)
        $sw.Stop()
        $sz  = (Get-Item $tmpFile).Length / 1MB
        $sec = $sw.Elapsed.TotalSeconds
        $mbps= [math]::Round($sz / $sec * 8, 2)
        Remove-Item $tmpFile -Force
        OK "Download: $mbps Mbps  ($([math]::Round($sz,1)) MB em $([math]::Round($sec,1))s)"
        if ($mbps -lt 5) { Write-Host "  [!] Conexao lenta" -ForegroundColor Red }
        elseif ($mbps -lt 20) { Write-Host "  [i] Conexao adequada" -ForegroundColor Yellow }
        else { Write-Host "  [v] Conexao boa" -ForegroundColor Green }
    } catch {
        Write-Host "  Metodo 1 falhou. Abrindo Speedtest no navegador..." -ForegroundColor Yellow
        Start-Process "https://www.speedtest.net"
        INF "Use o Speedtest.net para medir velocidade completa"
    }
    Write-Host ""
    Write-Host "  Latencia para servidores principais:" -ForegroundColor Yellow
    foreach ($srv in @("8.8.8.8","1.1.1.1","208.67.222.222")) {
        $p = Test-Connection -ComputerName $srv -Count 3 -ErrorAction SilentlyContinue
        if ($p) {
            $avg = [math]::Round(($p.ResponseTime | Measure-Object -Average).Average, 1)
            Write-Host "  $srv : ${avg}ms" -ForegroundColor $(if($avg -lt 20){"Green"}elseif($avg -lt 80){"Yellow"}else{"Red"})
        }
    }
}

function Scan-Portas {
    Write-Host ""
    $alvo = Read-Host "  Host/IP para varrer (ex: 192.168.0.1)"
    if ($alvo -eq "") { $alvo = "192.168.0.1" }
    Write-Host ""
    Write-Host "  Portas comuns a verificar:" -ForegroundColor Gray
    Write-Host "  [1] Portas comuns (21,22,23,25,80,443,3389,8080)" -ForegroundColor White
    Write-Host "  [2] Range personalizado" -ForegroundColor White
    $op = Read-Host "  Escolha"
    $portas = @()
    if ($op -eq "2") {
        $ini = [int](Read-Host "  Porta inicial")
        $fim = [int](Read-Host "  Porta final")
        $portas = $ini..$fim
    } else {
        $portas = @(21,22,23,25,53,80,110,135,139,143,443,445,1433,3306,3389,5900,8080,8443)
    }
    WH "SCAN DE PORTAS: $alvo"
    $abertas = 0
    foreach ($p in $portas) {
        $tcp = New-Object System.Net.Sockets.TcpClient
        $conn = $tcp.BeginConnect($alvo, $p, $null, $null)
        $wait = $conn.AsyncWaitHandle.WaitOne(500, $false)
        if ($wait -and !$tcp.Client.Connected -eq $false) {
            try { $tcp.EndConnect($conn); Write-Host "  Porta $p : ABERTA" -ForegroundColor Green; $abertas++ } catch {}
        }
        $tcp.Close()
    }
    Write-Host ""
    Write-Host "  Portas abertas: $abertas de $($portas.Count) verificadas" -ForegroundColor White
}

function Monitorar-Rede {
    WH "CONEXOES ATIVAS (netstat)"
    Write-Host "  Atualizando a cada 5 segundos. Ctrl+C para sair." -ForegroundColor Gray
    Write-Host ""
    netstat -an -b | Select-String -Pattern "ESTABLISHED|LISTEN" | Select-Object -First 40
    Write-Host ""
    Write-Host "  Conexoes por estado:" -ForegroundColor Yellow
    netstat -an | Group-Object { ($_ -split '\s+')[3] } | Sort-Object Count -Descending | Select-Object -First 8 | Format-Table Count, Name -AutoSize
}

function Diagnostico-Completo {
    WH "TESTE DE CONECTIVIDADE COMPLETO"
    $hosts = @(
        @{Host="8.8.8.8";     Nome="Google DNS"},
        @{Host="1.1.1.1";     Nome="Cloudflare DNS"},
        @{Host="192.168.0.1"; Nome="Gateway local"},
        @{Host="google.com";  Nome="Google (DNS+HTTP)"},
        @{Host="microsoft.com";Nome="Microsoft"}
    )
    Write-Host ""
    foreach ($h in $hosts) {
        $ok = Test-Connection -ComputerName $h.Host -Count 1 -Quiet -TimeToLive 64
        if ($ok) {
            $ms = (Test-Connection -ComputerName $h.Host -Count 1 -TimeToLive 64).ResponseTime
            OK "$($h.Nome.PadRight(22)) $($h.Host.PadRight(18)) ${ms}ms"
        } else {
            ERR "$($h.Nome.PadRight(22)) $($h.Host.PadRight(18)) FALHOU"
        }
    }
    Write-Host ""
    # Verifica adaptadores
    Write-Host "  Adaptadores ativos:" -ForegroundColor Yellow
    Get-CimInstance Win32_NetworkAdapterConfiguration | Where-Object { $_.IPEnabled } | ForEach-Object {
        $ni = Get-CimInstance Win32_NetworkAdapter | Where-Object { $_.Index -eq $_.Index }
        $ip = ($_.IPAddress | Where-Object { $_ -match '\.' }) -join ", "
        Write-Host "  $($_.Description.Substring(0,[Math]::Min(40,$_.Description.Length)))" -ForegroundColor White
        Write-Host "  IP: $ip | GW: $($_.DefaultIPGateway -join '')" -ForegroundColor Gray
        Write-Host ""
    }
}

function Liberar-IP {
    WH "LIBERAR E RENOVAR IP"
    Write-Host "  Liberando endereco IP..." -ForegroundColor Yellow
    ipconfig /release
    Start-Sleep -Seconds 2
    Write-Host "  Renovando endereco IP..." -ForegroundColor Yellow
    ipconfig /renew
    Write-Host ""
    OK "IP renovado com sucesso"
    ipconfig | Select-String -Pattern "IPv4|Gateway|DNS"
}

# Menu principal
do {
    $opcao = Menu-Rede
    switch ($opcao) {
        "1" { Ping-Avancado }
        "2" { Traceroute-Rede }
        "3" { DNS-Diagnostico }
        "4" { Info-Interface }
        "5" { Teste-Velocidade }
        "6" { Scan-Portas }
        "7" { Monitorar-Rede }
        "8" { Diagnostico-Completo }
        "9" { Liberar-IP }
        "0" { Write-Host "  Saindo..." -ForegroundColor Gray; exit }
        default { Write-Host "  Opcao invalida" -ForegroundColor Red }
    }
    Write-Host ""
    Read-Host "  Enter para voltar ao menu"
    Clear-Host
    Write-Host ""
    Write-Host "  ╔═══════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "  ║   MICROFAST - Ferramentas de Rede         ║" -ForegroundColor Cyan
    Write-Host "  ╚═══════════════════════════════════════════╝" -ForegroundColor Cyan
} while ($true)
