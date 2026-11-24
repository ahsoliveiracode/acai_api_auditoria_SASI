# Pacote Completo de Auditoria de Sistemas (7 Integrantes · Prof. Eduardo Pelli)

**Sistema Auditado:** Açaí do Vale (`acai_api/delivery-main` — preservado sem nenhuma modificação)  
**Entrega Classroom & Apresentação (≤ 15 min):** **25/11/2026** (`GRUPO_X.pdf` com no máximo **20 páginas**)

## Alocação Atual da Equipe
- **Pessoa 1 (Confirmado):** Augusto Henrique — Líder, Planejamento, Certificado de Controle Interno e Redução de Custos
- **Pessoa 2 (Confirmada):** Ana Júlia Silveira — Ambiente Físico (`PC09`), Micros/Contingência (`PC10`) e Backup (`PC11`)
- **Pessoa 3 (Em aberto):** `[Rafael Gomes / José Inácio / Alisson]` — BD, Teleprocessamento e Redes (`PC01`, `PC05`, `PC12`)
- **Pessoa 4 (Confirmada):** Helen Gonçalves — Sistema em Operação e *Test Deck* (`PC02`, `PC03`, `PC06`)
- **Pessoa 5 (Em aberto):** `[Rafael Gomes / José Inácio / Alisson]` — Relatórios, Telas e Funções (`PC04`, `PC07`, `PC08`)
- **Pessoa 6 (Confirmada):** Maria Eduarda Silveira (Duda) — Questionários, Entrevista/Ata e Pastas de Documentação
- **Pessoa 7 (Em aberto):** `[Rafael Gomes / José Inácio / Alisson]` — Relatório de Fraquezas, PDF ≤ 20 págs e Slides ≤ 15 min

## Estrutura de Pastas e Arquivos

```text
auditoria/
├── 00_PLANO_MESTRE_FASE1.md                                        # Planejamento nos 6 passos, DFDs, Grau de Risco (1-5) e Equipe
├── README.md                                                       # Índice geral do grupo
├── disparo/
│   ├── 01_OFICIO_SOLICITACAO_ACESSO_E_DOCS.md                      # Pedido de URL, credenciais, docs e agenda (P1 Augusto + P6 Duda)
│   ├── 02_QUESTIONARIO_CONTROLES_INTERNOS.md                       # Questionário unificado nos 9 passos (coord. P6 Duda)
│   ├── 03_CHECKLIST_VISITA_IN_LOCO.md                              # Formulário de Visita in loco nos 5 passos (P2 Ana Júlia)
│   └── 04_ATA_ENTREVISTA_AMBIENTE_COMPUTACIONAL.md                 # Roteiro e Ata de Entrevista nos 7 passos (P6 Duda)
├── equipe/
│   ├── PESSOA_1_AUGUSTO_LIDER_E_PARECER.md                         # Augusto (P1) — Confirmado
│   ├── PESSOA_2_ANA_JULIA_FISICO_E_INFRA.md                        # Ana Júlia (P2) — Confirmada
│   ├── PESSOA_3_BANCO_DADOS_E_REDES.md                             # Pessoa 3 — [A definir]
│   ├── PESSOA_4_HELEN_OPERACAO_E_TEST_DECK.md                      # Helen (P4) — Confirmada
│   ├── PESSOA_5_TELAS_RELATORIOS_E_FUNCOES.md                      # Pessoa 5 — [A definir]
│   ├── PESSOA_6_MARIA_EDUARDA_ENTREVISTAS_E_PASTAS_DOCS.md         # Maria Eduarda / Duda (P6) — Confirmada
│   └── PESSOA_7_RELATORIO_PDF_E_SLIDES.md                          # Pessoa 7 — [A definir]
├── scripts/
│   └── test-deck.sh                                                # Automação estática (--static) e Test Deck 5 situações (--live)
└── evidencias/
    └── evidencia_estatica_inicial.md                               # Evidência automatizada atualizada
```

## Comandos Rápidos do *Test Deck* (Pessoa 4 — Helen / Equipe Técnica)

```bash
# 1. Gerar/atualizar evidência estática imediata:
./auditoria/scripts/test-deck.sh --static

# 2. Executar as 5 situações obrigatórias do Test Deck contra a URL ativa:
./auditoria/scripts/test-deck.sh --live http://localhost:3000
```
