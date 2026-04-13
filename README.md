<div align="center">

```
███╗   ███╗██╗ ██████╗██████╗  ██████╗ ███████╗ █████╗ ███████╗████████╗
████╗ ████║██║██╔════╝██╔══██╗██╔═══██╗██╔════╝██╔══██╗██╔════╝╚══██╔══╝
██╔████╔██║██║██║     ██████╔╝██║   ██║█████╗  ███████║███████╗   ██║
██║╚██╔╝██║██║██║     ██╔══██╗██║   ██║██╔══╝  ██╔══██║╚════██║   ██║
██║ ╚═╝ ██║██║╚██████╗██║  ██║╚██████╔╝██║     ██║  ██║███████║   ██║
╚═╝     ╚═╝╚═╝ ╚═════╝╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝  ╚═╝╚══════╝   ╚═╝
                    T É C N I C O  —  P E N D R I V E
```

**Painel de Manutenção Profissional para Técnicos de Informática**

[![Version](https://img.shields.io/badge/versão-3.0.3-00e5ff?style=for-the-badge&logo=github)](https://github.com/arsgoliveira/pendrive-tecnico-mf/releases)
[![Platform](https://img.shields.io/badge/plataforma-Windows%2010%2F11-0097a7?style=for-the-badge&logo=windows)](https://github.com/arsgoliveira/pendrive-tecnico-mf)
[![Engine](https://img.shields.io/badge/engine-HTA%20%2B%20PowerShell-00bcd4?style=for-the-badge&logo=powershell)](https://github.com/arsgoliveira/pendrive-tecnico-mf)
[![Author](https://img.shields.io/badge/autor-Antonio%20Oliveira-0097a7?style=for-the-badge)](https://github.com/arsgoliveira)

<br/>

> **Pendrive Técnico MF** é um sistema completo de manutenção que roda diretamente do pendrive —
> sem instalação, sem dependências, 100% offline quando necessário.
> Diagnóstico real via WMI, limpeza automática, gestão de drivers, ferramentas de rede e muito mais.

<br/>

---

</div>

## 📋 Índice

- [Visão Geral](#-visão-geral)
- [Funcionalidades](#-funcionalidades)
- [Estrutura do Projeto](#-estrutura-do-projeto)
- [Instalação no Pendrive](#-instalação-no-pendrive)
- [Módulos do Painel](#-módulos-do-painel)
- [Scripts PowerShell](#-scripts-powershell)
- [Ferramentas Portables](#-ferramentas-portables)
- [Autenticação e Segurança](#-autenticação-e-segurança)
- [Atualização via GitHub](#-atualização-via-github)
- [Changelog](#-changelog)
- [Autor](#-autor)

---

## 🎯 Visão Geral

O **MicroFast Técnico** é um painel de manutenção profissional desenvolvido em **HTA (HTML Application)** — tecnologia nativa do Windows que combina interface web com acesso completo ao sistema operacional via `Shell.Application`, `WScript.Shell` e `FileSystemObject`.

**Modo de operação dual:**

| Modo | Como abrir | Capacidade |
|------|-----------|-----------|
| 🖥️ **HTA** — pendrive local | `INDEX.hta` duplo clique | Executa scripts reais, acessa sistema, gera relatórios |
| 🌐 **Browser** — online | Qualquer navegador moderno | Interface completa em modo demonstração |

A detecção de ambiente é automática via `new ActiveXObject()` — o sistema se adapta sem configuração adicional.

---

## ⚡ Funcionalidades

<table>
<tr>
<td width="50%">

### 🔍 Diagnóstico Completo
- Coleta de hardware real via **WMI** (CPU, RAM, Disco, GPU)
- Status **SMART** nativo de discos físicos
- Interfaces de rede, IP, gateway, ping externo
- Lista completa de programas instalados (registro)
- Verificação de **Windows Update** pendentes via COM
- Relatório de bateria via **powercfg** (notebooks)
- **Score A–F** com avaliação de upgrade automática
- Saída em `.TXT` formato SGS

### 🧹 Limpeza Automática
- `%TEMP%` e `C:\Windows\Temp`
- `C:\Windows\Prefetch`
- Lixeira (todos os usuários)
- Cache do **Windows Update** (SoftwareDistribution)
- Cache **DNS** (ipconfig /flushdns)
- Cache de navegadores (Chrome, Edge, Firefox)
- Event Logs antigos do sistema

### 📡 Ferramentas de Rede (9 funções)
- Ping avançado: min / max / média / perda%
- Traceroute completo hop a hop
- Diagnóstico DNS com teste de latência
- Varredura de portas TCP
- Teste de velocidade via download de referência
- Monitoramento de conexões ativas (netstat)
- Informações completas das interfaces (ipconfig /all)
- Tabela ARP + rotas
- Renovação de IP via DHCP (release/renew)

</td>
<td width="50%">

### 🖥️ Gestão de Drivers
- Identificação de fabricante via **WMI** automaticamente
- Abertura do site correto (Dell, Lenovo, HP, Asus, Acer)
- Driver de vídeo: NVIDIA / AMD / Intel
- Driver de áudio Realtek via winget ou pnputil
- Driver de rede/Wi-Fi: Intel / Realtek / Qualcomm
- `pnputil /scan-devices` para dispositivos com `!`

### 📦 Gestão de Programas
- Instalação **silenciosa** via `winget`
- Pacotes rápidos pré-configurados
- Requer autenticação SGS para instalar

### 🪟 Windows Update
- Verificação via **PSWindowsUpdate** (instalado automaticamente)
- Instalar tudo / só segurança / só Defender
- Atualização de definições do Windows Defender

### 🔐 Admin / SGS Corporativo
- Autenticação separada para ambiente **Hidromares by SGS**
- Execução de CMD, PowerShell, RegEdit e gpedit como Admin
- Credenciais armazenadas como **hash** em `config\dados.ini`

### 🔄 Atualização via GitHub
- Repositório: `arsgoliveira/pendrive-tecnico-mf`
- Verificação de versão em **background** ao login
- Sync seletivo: apenas `scripts\` e `config\` (sem tools)
- Token opcional para repositórios privados

</td>
</tr>
</table>

---

## 📁 Estrutura do Projeto

```
pendrive-tecnico-mf/
│
├── 📄 INDEX.hta                       ← Painel principal — abrir este
├── 📄 COPIAR-PARA-D.bat               ← Copia tudo para D:\Pendrive Tecnico MF\
├── 📄 SETUP-DEFENDER.bat              ← Configura exclusão do Windows Defender (1ª vez)
├── 📄 README.md
├── 📄 .gitignore
│
├── 📂 scripts/
│   ├── 🔍 diagnostico.ps1             ← Diagnóstico completo v3.2 + Score A–F
│   ├── 🧹 limpeza.bat                 ← Limpeza automática do sistema
│   ├── 📡 rede.ps1                    ← 9 ferramentas de rede interativas
│   ├── 🖥️  drivers.ps1                ← Detecção e atualização de drivers
│   ├── 📦 instalar.bat                ← Instalação silenciosa via winget
│   ├── 🪟 windows-update.ps1          ← Windows Update via PSWindowsUpdate
│   ├── 🔄 atualizar-github.ps1        ← Sincronização com repositório GitHub
│   ├── 🔐 runas-admin.bat             ← Executor de ferramentas como Admin
│   ├── 🛡️  setup-exclusao.ps1          ← Configura exclusão no Windows Defender
│   ├── 🛠️  abrir-ferramenta.ps1        ← Launcher de portables da pasta tools\
│   └── ⬇️  baixar-ferramentas.ps1      ← Downloader de portables (1ª vez)
│
├── 📂 tools/                          ← Portables — não versionados (.gitignore)
│   ├── CrystalDiskInfo\DiskInfo64.exe
│   ├── CrystalDiskMark\DiskMark64.exe
│   ├── HWiNFO64\HWiNFO64.exe
│   ├── CPU-Z\cpuz_x64.exe
│   ├── GPU-Z\GPU-Z.exe
│   ├── Rufus\rufus.exe
│   ├── RustDesk\rustdesk.exe
│   └── ...
│
├── 📂 relatorios/                     ← Gerados localmente — não versionados
│   ├── diagnostico_HOSTNAME_YYYYMMDD_HHmm.txt
│   └── bateria_HOSTNAME_YYYYMMDD_HHmm.html
│
└── 📂 config/
    ├── versao.txt                     ← Versão atual (controle de atualização)
    └── dados.ini                      ← Hash de credenciais — não versionado
```

> `tools/`, `relatorios/` e `config/dados.ini` estão no `.gitignore` — nunca sobem ao repositório.

---

## 🚀 Instalação no Pendrive

### Via script automático
```batch
REM Execute como Administrador com o pendrive em D:
COPIAR-PARA-D.bat
```

### Via git clone
```powershell
git clone https://github.com/arsgoliveira/pendrive-tecnico-mf.git "D:\Pendrive Tecnico MF"
cd "D:\Pendrive Tecnico MF"
.\INDEX.hta
```

### Requisitos do sistema
| Requisito | Mínimo |
|-----------|--------|
| Windows | 10 / 11 (x64) |
| PowerShell | 5.1+ (nativo no Windows) |
| winget | App Installer — Microsoft Store |
| Espaço livre | ~500 MB com todas as ferramentas |
| Permissão | Administrador para execução de scripts |

---

## 🧩 Módulos do Painel

```
⚡  Dashboard      Visão geral, acesso rápido, terminal de log em tempo real
🔍  Diagnóstico    Coleta WMI completa + Score A–F + relatório .TXT
🧹  Limpeza        Limpeza automática com múltiplas categorias
📋  Relatórios     Visualizador integrado de relatórios gerados
────────────────────────────────────────────────────────
📡  Rede           9 ferramentas: ping, traceroute, DNS, ports, velocidade
🖥️   Drivers        Detecção de fabricante + sites oficiais automáticos
📦  Programas      Instalação silenciosa winget + pacotes rápidos
🪟  Win Update     PSWindowsUpdate: verificar / instalar / segurança / defender
🛠️   Ferramentas    Launcher de portables com fallback para winget
────────────────────────────────────────────────────────
📖  Guias          Passo a passo detalhado para cada módulo
🔐  Admin / SGS    Autenticação corporativa + execução com privilégios
🔄  Atualizar      Sync com GitHub — verificação automática de versão
⚙️   Configurações  Identidade do técnico + gerenciamento de senhas
```

---

## 📜 Scripts PowerShell

### `diagnostico.ps1` — v3.2

Parâmetros (aceita via arquivo `.ini` para evitar problemas de escaping):

```powershell
# Método recomendado — via arquivo de parâmetros (gerado pelo HTA)
.\diagnostico.ps1 -ParamFile "D:\Pendrive Tecnico MF\config\diag_params.ini"

# Método direto — linha de comando
.\diagnostico.ps1 -ClienteNome "João Silva" `
                  -Contexto    "SGS" `
                  -Observacoes "PC lento" `
                  -TecnicoNome "Antonio Oliveira" `
                  -OutputPath  "D:\Pendrive Tecnico MF\relatorios"
```

**Tabela de Score de Upgrade:**

| Nota | Score | Situação | Recomendação |
|------|-------|----------|-------------|
| **A** | 70–75 | Hardware excelente | Nenhuma ação necessária |
| **B** | 55–69 | Bom desempenho | Melhorias opcionais |
| **C** | 40–54 | Adequado para uso básico | Upgrade recomendado em breve |
| **D** | 25–39 | Hardware defasado | Upgrade necessário |
| **F** | 0–24 | Crítico | Upgrade urgente |

Os pontos são distribuídos em 3 categorias: **RAM** (25 pts), **Disco SSD/HDD** (25 pts), **Geração do CPU** (25 pts).

---

### `rede.ps1` — Modos de execução

```powershell
.\rede.ps1              # Abre menu interativo
.\rede.ps1 -Acao 1      # Ping avançado (solicita destino)
.\rede.ps1 -Acao 3      # Diagnóstico DNS completo
.\rede.ps1 -Acao 5      # Teste de velocidade
.\rede.ps1 -Acao 8      # Teste de conectividade completo
.\rede.ps1 -Acao 9      # Renovar IP via DHCP
```

---

### `atualizar-github.ps1`

```powershell
# Verifica se há nova versão disponível
.\atualizar-github.ps1 -Acao verificar -Repo "arsgoliveira/pendrive-tecnico-mf"

# Baixa e aplica atualização
.\atualizar-github.ps1 -Acao atualizar

# Com token para repositório privado
.\atualizar-github.ps1 -Acao atualizar -Token "ghp_xxxx"
```

---

## 🛠️ Ferramentas Portables

Populadas via **Painel → Ferramentas → Baixar Todas** (requer internet):

| Categoria | Ferramenta | Uso |
|-----------|-----------|-----|
| **Diagnóstico** | CrystalDiskInfo | Saúde SMART de HDD/SSD |
| **Diagnóstico** | CrystalDiskMark | Benchmark de velocidade de disco |
| **Diagnóstico** | HWiNFO64 | Monitor de hardware e temperaturas em tempo real |
| **Diagnóstico** | CPU-Z | Info detalhada de CPU, RAM e placa-mãe |
| **Diagnóstico** | GPU-Z | Info completa de placa de vídeo |
| **Utilitário** | Rufus | Criação de pendrives bootáveis |
| **Utilitário** | RustDesk | Acesso remoto sem cadastro |
| **Utilitário** | AnyDesk | Acesso remoto corporativo SGS |
| **Utilitário** | Autoruns | Gerenciamento de programas na inicialização |
| **Segurança** | AdwCleaner | Remoção de adware e PUPs |
| **Segurança** | RKill | Interrupção de processos maliciosos ativos |
| **Rede** | TCPView | Conexões de rede ativas em tempo real |
| **Rede** | PuTTY | Cliente SSH / Telnet / Serial |
| **Stress** | Prime95 | Stress test de CPU e RAM |
| **Stress** | FurMark | Stress test e benchmark de GPU |

---

## 🔐 Autenticação e Segurança

O painel possui dois níveis de acesso independentes:

```
┌─────────────────────────────────┬──────────────────────────────────┐
│  🔧  MODO TÉCNICO               │  🏢  MODO SGS CORPORATIVO         │
│─────────────────────────────────│──────────────────────────────────│
│  Acesso geral ao painel         │  antonio.oliveira.adm@sgs.com    │
│  Todas as ferramentas livres    │  Instalar / desinstalar           │
│  Diagnóstico, limpeza, rede     │  Executar como Admin             │
│                                 │  Operações corporativas SGS       │
└─────────────────────────────────┴──────────────────────────────────┘
```

**Armazenamento de credenciais:**
- Senhas armazenadas como **hash djb2** no arquivo `config\dados.ini`
- Nunca armazenadas em texto puro
- `dados.ini` está no `.gitignore` — não é versionado
- Em modo Browser: `localStorage` com prefixo `mf_`

**Reset de acesso:**
```
Exclua ou edite config\dados.ini removendo as linhas th= e ch=
O painel solicitará nova senha no próximo acesso
```

---

## 🔄 Atualização via GitHub

O painel verifica automaticamente se há nova versão ao fazer login (quando há conexão disponível).

**Via painel:**
```
Painel → Atualizar → Verificar Atualizações → Baixar e Aplicar
```

**Via PowerShell direto:**
```powershell
cd "D:\Pendrive Tecnico MF\scripts"
.\atualizar-github.ps1 -Acao atualizar
```

**Escopo da atualização:**

| Atualizado | Não atualizado |
|-----------|---------------|
| `scripts\*.ps1` | `tools\` (portables locais) |
| `scripts\*.bat` | `relatorios\` (dados de clientes) |
| `config\versao.txt` | `config\dados.ini` (credenciais) |
| `INDEX.hta` | |

---

## 📋 Changelog

### `v3.0.3` — Abril 2026
> *Setup automático de exclusão no Windows Defender*

- ✅ **Add:** `SETUP-DEFENDER.bat` — configura exclusão do Windows Defender com um clique, resolve falso positivo de "script mal-intencionado" nos scripts do pendrive
- ✅ **Add:** `scripts\setup-exclusao.ps1` — script PowerShell que adiciona o diretório do pendrive às exclusões do Defender via `Add-MpPreference`
- 🟡 **Info:** Execute `SETUP-DEFENDER.bat` como Administrador **uma vez** ao instalar o pendrive em uma nova máquina

### `v3.0.2` — Abril 2026
> *Correções críticas de execução de scripts*

- 🔴 **Fix:** Parâmetros do diagnóstico agora passados via arquivo `diag_params.ini` — elimina todos os problemas de escaping no `ShellExecute`
- 🔴 **Fix:** Bloco de Notas rejeitava o relatório com "nome inválido" — `Start-Process notepad` corrigido com `-ArgumentList`
- 🔴 **Fix:** Segunda execução do diagnóstico fechava imediatamente — aspas simples no `ShellExecute` quebravam o argumento
- 🟡 **Fix:** `energy.dll` não carregada no `powercfg /batteryreport` — agora executa com `WorkingDirectory = System32`
- 🟡 **Fix:** `$PSScriptRoot` vazio em todos os scripts quando chamados via `ShellExecute` — fallback adicionado em todos os `.ps1`

### `v3.0.1` — Abril 2026
> *Estabilidade, segurança e detecção de ambiente*

- 🔴 **Fix:** `INDEX.hta` estava truncado — fechamento `</script></body></html>` ausente
- 🔴 **Fix:** Detecção `IS_HTA` migrada para `new ActiveXObject()` — 100% confiável, independente de URL ou caminho
- 🟡 **Fix:** Inputs sanitizados antes de passar ao PowerShell — previne quebra de comando com caracteres especiais
- 🟡 **Fix:** Logout agora limpa campo de senha SGS, reseta badge e variável `APP.sgs`
- ✅ **Add:** Verificador automático de versão no GitHub em background ao fazer login

### `v3.0.0` — Abril 2026
> *Release inicial*

- ✅ Painel híbrido **HTA + Browser** com detecção automática de ambiente
- ✅ **11 módulos** completos com terminal de log em tempo real
- ✅ Diagnóstico com **Score A–F** e avaliação de upgrade automática
- ✅ Storage abstrato: `dados.ini` no HTA / `localStorage` no browser
- ✅ Autenticação dual: Técnico + SGS Corporativo com hash de senha
- ✅ Sync automático com GitHub via `atualizar-github.ps1`
- ✅ **8 guias** passo a passo integrados ao painel

---

## 👤 Autor

<table>
<tr>
<td align="center" width="140">
  <br/>
  <strong>Antonio Oliveira</strong><br/>
  <sub>Técnico de Informática</sub><br/><br/>
  <sub>📍 Santos — SP</sub><br/>
  <sub>📞 (013) 97826-4067</sub><br/><br/>
</td>
<td>

**MicroFast Informática**
Manutenção, suporte técnico e atendimento a domicílio — Santos/SP

**Hidromares by SGS**
Técnico de TI Externo · Domínio `AMR`
`antonio.oliveira.adm@sgs.com`

</td>
</tr>
</table>

---

<div align="center">

**MicroFast Técnico** — desenvolvido para uso profissional em campo

`arsgoliveira/pendrive-tecnico-mf` &nbsp;·&nbsp; `v3.0.3` &nbsp;·&nbsp; `HTA + PowerShell + Windows`

</div>
