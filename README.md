# MicroFast Técnico v3.0.1
**Pendrive de Manutenção Profissional — MicroFast Informática**
Tel. (013) 97826-4067

## Como usar
1. Copie TODA esta pasta para `D:\Pendrive Tecnico MF\`
2. Dê dois cliques em **INDEX.hta**
3. No primeiro acesso, defina sua senha (mínimo 6 caracteres)

## Estrutura
```
D:\Pendrive Tecnico MF\
├── INDEX.hta                  ← ABRIR ESTE
├── COPIAR-PARA-D.bat          ← Copia tudo para D:
├── README.md
│
├── scripts\
│   ├── diagnostico.ps1        ← Diagnóstico completo + Score A-F
│   ├── limpeza.bat            ← Limpeza temp, prefetch, lixeira
│   ├── rede.ps1               ← Ferramentas de rede (ping, dns, speed)
│   ├── drivers.ps1            ← Detecção e atualização de drivers
│   ├── instalar.bat           ← Instalação silenciosa via winget
│   ├── windows-update.ps1     ← Windows Update via PSWindowsUpdate
│   ├── atualizar-github.ps1   ← Sync com GitHub
│   ├── runas-admin.bat        ← Abre ferramentas como Admin
│   ├── abrir-ferramenta.ps1   ← Launcher de portables
│   └── baixar-ferramentas.ps1 ← Baixa todos os portables (1ª vez)
│
├── tools\                     ← Coloque os portables aqui
│   ├── CrystalDiskInfo\DiskInfo64.exe
│   ├── CrystalDiskMark\DiskMark64.exe
│   ├── HWiNFO64\HWiNFO64.exe
│   ├── CPU-Z\cpuz_x64.exe
│   ├── GPU-Z\GPU-Z.exe
│   ├── Rufus\rufus.exe
│   ├── RustDesk\rustdesk.exe
│   └── ...
│
├── relatorios\                ← Relatórios gerados automaticamente
│
└── config\
    ├── versao.txt             ← Versão atual (3.0.1)
    └── dados.ini              ← Credenciais (hash) — criado no 1º uso

```

## Repositório GitHub
`arsgoliveira/pendrive-tecnico-mf`

Para atualizar: Painel → Atualizar → Baixar e Aplicar

## Changelog
### v3.0.1
- Corrigido: INDEX.hta estava truncado (fechamento faltando)
- Corrigido: Detecção IS_HTA agora usa ActiveXObject (100% confiável)
- Corrigido: Inputs sanitizados antes de passar ao PowerShell
- Corrigido: Logout agora limpa campo de senha SGS e reseta status
- Adicionado: Verificador automático de versão no GitHub (background)

### v3.0.0
- Painel híbrido HTA + Browser
- 11 módulos: Diagnóstico, Limpeza, Relatórios, Rede, Drivers, Programas, Win Update, Ferramentas, Guias, Admin/SGS, Atualizar
- Diagnóstico com Score A–F e avaliação de upgrade
- Storage: config\dados.ini (HTA) ou localStorage (browser)
