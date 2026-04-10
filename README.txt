+==============================================================+
|         MICROFAST TECNICO v3.0 - ESTRUTURA DO PENDRIVE       |
|         Tel. (013) 97826-4067                                |
+==============================================================+

COMO USAR
---------
1. Copie TODA esta pasta para o pendrive (raiz: D:\)
2. De dois cliques em INDEX.hta para abrir o painel
3. No primeiro acesso, defina sua senha (min. 6 caracteres)
4. Para baixar ferramentas portaveis: Dashboard > Baixar Ferramentas

ESTRUTURA
---------
D:\
|-- INDEX.hta                  <- ABRIR ESTE (painel principal)
|-- README.txt                 <- Este arquivo
|
|-- scripts\
|   |-- diagnostico.ps1        <- Diagnostico completo + relatorio
|   |-- limpeza.bat            <- Limpeza real (temp, prefetch, lixeira)
|   |-- rede.ps1               <- Ferramentas de rede completas
|   |-- drivers.ps1            <- Deteccao de hardware + drivers
|   |-- instalar.bat           <- Instalacao silenciosa via winget
|   |-- windows-update.ps1     <- Windows Update via PSWindowsUpdate
|   |-- abrir-ferramenta.ps1   <- Launcher de portables
|   |-- baixar-ferramentas.ps1 <- Downloader automatico de portables
|   |-- atualizar-github.ps1   <- Sync com repositorio GitHub
|   `-- runas-admin.bat        <- Abre ferramentas como Admin
|
|-- tools\                     <- FERRAMENTAS PORTAVEIS (rodam do pendrive)
|   |-- CrystalDiskInfo\DiskInfo64.exe
|   |-- CrystalDiskMark\DiskMark64.exe
|   |-- HWiNFO64\HWiNFO64.exe
|   |-- CPU-Z\cpuz_x64.exe
|   |-- GPU-Z\GPU-Z.exe
|   |-- Speccy\Speccy64.exe
|   |-- Rufus\rufus.exe
|   |-- Autoruns\Autoruns64.exe
|   |-- ProcessExplorer\procexp64.exe
|   |-- TCPView\Tcpview64.exe
|   |-- AdwCleaner\AdwCleaner.exe
|   |-- RKill\rkill.exe
|   `-- PuTTY\putty.exe
|
|-- relatorios\                <- Relatorios gerados automaticamente
|
`-- config\
    |-- versao.txt             <- Versao atual (para sync GitHub)
    `-- logo.ico               <- Icone opcional (coloque aqui)

FERRAMENTAS PORTAVEIS
---------------------
Todas rodam DIRETO do pendrive sem instalacao:

  Diagnostico:
    - CrystalDiskInfo    Saude SMART de HDD/SSD
    - CrystalDiskMark    Benchmark de velocidade do disco
    - HWiNFO64           Monitor completo de hardware e temperatura
    - CPU-Z              Detalhes de CPU, RAM e placa-mae
    - GPU-Z              Info completa de placa de video
    - Speccy             Resumo visual do hardware

  Utilitarios:
    - Rufus              Cria pendrives bootaveis
    - PuTTY              SSH / Telnet / Serial

  Seguranca:
    - AdwCleaner         Remove adware e PUPs (standalone)
    - RKill              Mata processos de malware

  Sysinternals (Microsoft):
    - Autoruns            Gerencia inicializacao
    - Process Explorer    Task Manager avancado
    - TCPView             Monitor de conexoes TCP/UDP

REPOSITORIO GITHUB
------------------
URL: github.com/arsgoliveira/pendrive-tecnico-mf
Configure em: Painel > Atualizar Pendrive
O botao "Baixar e Aplicar" atualiza automaticamente os scripts.

SEGURANCA
---------
- Senhas armazenadas com hash no localStorage do HTA
- Nunca salvas em texto puro
- Autenticacao SGS separada para operacoes corporativas

REQUISITOS DO SISTEMA
---------------------
- Windows 10/11
- PowerShell 5.1+ (ja incluso no Windows)
- winget (App Installer - Microsoft Store) para instalacoes
- Execucao de HTA habilitada (padrao no Windows)

MicroFast Informatica - Tel. (013) 97826-4067
