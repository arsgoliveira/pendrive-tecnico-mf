# MicroFast Tecnico v3.0

**Pendrive de Manutencao Profissional para Windows**

Kit completo de ferramentas para tecnicos de informatica. Roda direto do pendrive via interface HTA (HTML Application) com painel moderno e escuro.

## Como Usar

1. Copie toda a pasta para o pendrive (recomendado: `D:\`)
2. Abra `INDEX.hta` com duplo clique
3. No primeiro acesso, defina sua senha (minimo 6 caracteres)
4. Clique em **Baixar Ferramentas** para popular a pasta `tools\` com portaveis

## Funcionalidades

| Modulo | Descricao |
|--------|-----------|
| **Diagnostico** | Relatorio completo: SO, CPU, RAM, discos SMART, GPU, rede, bateria + Score A-F |
| **Limpeza** | Temp, Prefetch, Lixeira, cache WU, DNS |
| **Rede** | Ping, traceroute, DNS, port scan, velocidade, netstat |
| **Drivers** | Detecta fabricante e abre site correto (Dell, Lenovo, HP, etc.) |
| **Programas** | Instalacao silenciosa via winget |
| **Win Update** | Verificar/instalar via PSWindowsUpdate |
| **Ferramentas** | 13+ portaveis que rodam do pendrive sem instalacao |
| **Admin** | CMD/PS/RegEdit/GPEdit como administrador |
| **Atualizar** | Sync automatico com este repositorio GitHub |

## Ferramentas Portaveis (tools/)

Todas rodam **direto do pendrive** sem instalacao:

- **CrystalDiskInfo** - Saude SMART de HDD/SSD
- **CrystalDiskMark** - Benchmark de velocidade do disco
- **HWiNFO64** - Monitor completo de hardware e temperatura
- **CPU-Z** - Detalhes de CPU, RAM e placa-mae
- **GPU-Z** - Info completa de placa de video
- **Speccy** - Resumo visual do hardware
- **Rufus** - Cria pendrives bootaveis
- **PuTTY** - SSH / Telnet / Serial
- **AdwCleaner** - Remove adware e PUPs
- **RKill** - Mata processos de malware
- **Autoruns** - Gerencia inicializacao (Sysinternals)
- **Process Explorer** - Task Manager avancado (Sysinternals)
- **TCPView** - Monitor de conexoes TCP/UDP (Sysinternals)

## Estrutura

```
INDEX.hta                  <- Painel principal (abrir este)
README.md                  <- Este arquivo
scripts/
  diagnostico.ps1          <- Diagnostico completo + relatorio
  limpeza.bat              <- Limpeza automatica do sistema
  rede.ps1                 <- Ferramentas de rede
  drivers.ps1              <- Deteccao de hardware e drivers
  instalar.bat             <- Instalacao via winget
  windows-update.ps1       <- Windows Update
  abrir-ferramenta.ps1     <- Launcher de portaveis
  baixar-ferramentas.ps1   <- Download automatico de tools
  atualizar-github.ps1     <- Sync com GitHub
  runas-admin.bat          <- Ferramentas como admin
tools/                     <- Ferramentas portaveis (EXEs)
relatorios/                <- Relatorios gerados
config/
  versao.txt               <- Versao atual (para sync)
```

## Requisitos

- Windows 10/11
- PowerShell 5.1+
- winget (App Installer) para instalacoes
- Internet para download de ferramentas e sync

## Autor

**MicroFast Informatica** - Antonio Oliveira
Tel. (013) 97826-4067
