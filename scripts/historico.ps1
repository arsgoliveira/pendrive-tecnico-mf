# ============================================================
# MICROFAST TECNICO - Historico de Atendimentos v4.0
# Registra e exibe historico de acoes do pendrive
# ============================================================
param(
    [string]$Acao      = "listar",   # listar | registrar | exportar
    [string]$TipoAcao  = "",
    [string]$Cliente   = "",
    [string]$Resultado = "",
    [string]$Tecnico   = "Antonio Oliveira"
)
$ErrorActionPreference = "SilentlyContinue"

if ($PSScriptRoot -and $PSScriptRoot -ne "") {
    $base = Split-Path $PSScriptRoot -Parent
} else { $base = "D:\Pendrive Tecnico MF" }

$csvFile = "$base\relatorios\historico.csv"
$Host.UI.RawUI.WindowTitle = "MicroFast - Historico de Atendimentos"

# Garante que o CSV existe com header
if (-not (Test-Path $csvFile)) {
    "Data,Hora,Acao,Cliente,PC,Resultado,Tecnico" | Out-File $csvFile -Encoding UTF8
}

function Registrar($tipo, $cliente, $resultado) {
    $data    = Get-Date -Format "dd/MM/yyyy"
    $hora    = Get-Date -Format "HH:mm:ss"
    $pc      = $env:COMPUTERNAME
    $linha   = "`"$data`",`"$hora`",`"$tipo`",`"$cliente`",`"$pc`",`"$resultado`",`"$Tecnico`""
    Add-Content -Path $csvFile -Value $linha -Encoding UTF8
}

switch ($Acao) {
    "registrar" {
        Registrar $TipoAcao $Cliente $Resultado
        exit 0
    }
    "exportar" {
        $dest = "$base\relatorios\historico_$(Get-Date -Format 'yyyyMMdd').csv"
        Copy-Item $csvFile $dest -Force
        Start-Process explorer.exe "/select,`"$dest`""
        exit 0
    }
    default {
        Clear-Host
        Write-Host ""
        Write-Host "  ╔══════════════════════════════════════════╗" -ForegroundColor Cyan
        Write-Host "  ║   MICROFAST - Historico de Atendimentos  ║" -ForegroundColor Cyan
        Write-Host "  ╚══════════════════════════════════════════╝" -ForegroundColor Cyan
        Write-Host ""

        if (-not (Test-Path $csvFile)) {
            Write-Host "  Nenhum atendimento registrado ainda." -ForegroundColor Gray
            Read-Host "  Enter para fechar"; exit 0
        }

        $registros = Import-Csv $csvFile -Encoding UTF8 -ErrorAction SilentlyContinue
        if (-not $registros -or $registros.Count -eq 0) {
            Write-Host "  Nenhum registro encontrado." -ForegroundColor Gray
            Read-Host "  Enter para fechar"; exit 0
        }

        Write-Host "  Total de registros: $($registros.Count)" -ForegroundColor White
        Write-Host ""
        Write-Host "  Data       Hora      Acao                Cliente/PC          Resultado" -ForegroundColor Cyan
        Write-Host "  " + ("-" * 85) -ForegroundColor DarkGray

        $registros | Select-Object -Last 50 | ForEach-Object {
            $cor = switch -Wildcard ($_.Resultado) {
                "*OK*"      { "Green"  }
                "*ERRO*"    { "Red"    }
                "*AVISO*"   { "Yellow" }
                default     { "White"  }
            }
            $linha = "  $($_.Data.PadRight(11))$($_.Hora.PadRight(10))$($_.Acao.PadRight(22))$("$($_.Cliente) / $($_.PC)".PadRight(22))$($_.Resultado)"
            Write-Host $linha -ForegroundColor $cor
        }

        Write-Host ""
        Write-Host "  [E] Exportar CSV  [L] Limpar historico  [Enter] Fechar" -ForegroundColor Gray
        $op = Read-Host "  "
        if ($op -eq "E" -or $op -eq "e") {
            $dest = "$base\relatorios\historico_$(Get-Date -Format 'yyyyMMdd').csv"
            Copy-Item $csvFile $dest -Force
            Write-Host "  [OK] Exportado: $dest" -ForegroundColor Green
            Start-Process notepad.exe $dest
        } elseif ($op -eq "L" -or $op -eq "l") {
            $conf = Read-Host "  Confirmar limpeza do historico? [S/N]"
            if ($conf -match "^[Ss]") {
                "Data,Hora,Acao,Cliente,PC,Resultado,Tecnico" | Out-File $csvFile -Encoding UTF8
                Write-Host "  [OK] Historico limpo." -ForegroundColor Green
            }
        }
        Read-Host "  Enter para fechar"
    }
}
