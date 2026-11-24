# Caderno da Pessoa 7 — `[A definir: Rafael Gomes / José Inácio / Alisson]` (Relatório Final PDF ≤ 20p e Slides ≤ 15 min)

**Auditor(a) Responsável:** `[Preencher Nome ao Escolher esta Frente]`  
**Papel na Auditoria:** Compilação do **Relatório de Fraquezas de Controle Interno (Produto 3.1)**, Edição do arquivo final **`GRUPO_X.pdf` (máximo rigoroso de 20 páginas)** e Montagem dos **Slides Executivos (máx. 15 minutos)**  
**Orçamento de Tempo:** **5h00** (Estruturação do documento e slides base à tarde: 1h30 | Compilação das entregas de P1–P6: 2h00 | Revisão final de paginação com Augusto P1 + fechamento dos slides: 1h30)

> **ATENÇÃO À REGRA DE ENTREGA DO ENUNCIADO:**  
> 1. Nome obrigatório do arquivo PDF no Classroom: **`GRUPO_X.pdf`** *(substituir `X` pela letra/nome oficial do grupo definido em sala!)*.  
> 2. Teto máximo absoluto: **20 páginas** (incluindo capa, questionários resumidos, 12 pontos, redução de custos e parecer).

---

## 1. Mapa Exato de Paginação para Cravar ≤ 20 Páginas (Sequência Oficial dos Slides da Aula)

Para não estourar as 20 páginas com 7 pessoas escrevendo, siga este orçamento fixo de páginas:

| Páginas | Seção do Relatório (Seguindo a Sequência da Aula — Prof. Eduardo Pelli) | Fonte Interna (Quem te entrega) |
| :---: | :--- | :--- |
| **Pág. 1** | **Capa Institucional + Identificação da Equipe (7 integrantes) + Sumário Compacto** | Você (P7) |
| **Págs. 2–3** | **1. Planejamento da Auditoria e Conhecimento do Ambiente:** Objetivo, escopo, técnicas, prazos, custos/indicador (`Horas / PC`) e síntese de RH, hardware/software, arquivos, telas e relatórios (quadro compacto da Pasta 3.5). | P1 — Augusto (`00_PLANO_MESTRE`) + P6 — Maria Eduarda (`PESSOA_6`) |
| **Pág. 4** | **2. Diagrama de Fluxo de Dados (DFD Nível 0 e Nível 1) com Localização de `PC01`–`PC12`** | P1 — Augusto (`00_PLANO_MESTRE`) |
| **Pág. 5** | **3. Análise de Risco e Hierarquização dos 12 Pontos de Controle:** Critérios de risco, escala oficial de Grau de Risco (`1 – Muito Fraco` a `5 – Muito forte`) e tabela hierarquizada dos 12 PCs + Programa de Trabalho/Horas da Equipe. | P1 — Augusto (`00_PLANO_MESTRE`) |
| **Págs. 6–7** | **4. Instrumentos Aplicados e Coleta em Campo:** Quadro consolidado do Questionário à Distância (18 perguntas + respostas obtidas), Síntese da Ata de Entrevista e Registro Formal da Visita *In Loco* (data, hora, presentes e constatações). | P6 — Maria Eduarda (`02_QUESTIONARIO` + `04_ATA`) + P2 — Ana Júlia (`03_VISITA`) |
| **Pág. 8** | **5. Resultados da Simulação de Dados (*Test Deck*):** Tabela das 5 situações testadas (inválidos, limites, incompletas, incompatíveis, duplicidade) + resultados automatizados do `test-deck.sh`. | P4 — Helen (`PESSOA_4` + `evidencias/`) |
| **Págs. 9–16** | **6. Relatório de Fraquezas de Controle Interno — Detalhamento dos 12 PCs (Produto 3.1):** *Orçamento exato: **1,5 ponto de controle por página** (8 páginas para os 12 PCs)*. Para cada PC usar o box padronizado: `[Grau de Risco | Parâmetro | Técnica | Análise e Problemas Encontrados | Alternativas de Solução Propostas]`. | P2 (Ana Júlia), P3, P4 (Helen) e P5 (3 PCs cada) |
| **Págs. 17–18** | **7. Matriz Consolidada de Recomendações Priorizadas + Relatório de Redução de Custos (Produto 3.3):** Tabela financeira de perdas evitadas, esforço de correção e *payback*/ROI para o PDI da empresa. | P1 — Augusto (`PESSOA_1`, Seção 2) |
| **Pág. 19** | **8. Certificado de Controle Interno — Parecer Final do Auditor (Produto 3.2):** Opinião global sintética (Boa, Razoável ou Má condição) assinada pela equipe. | P1 — Augusto (`PESSOA_1`, Seção 3) |
| **Pág. 20** | **Apêndice Visual Compacto:** 2 a 4 capturas de tela-chave das evidências mais críticas (ex.: `/ui/admin` aberto, pedido negativo aceito e `github/` sem ponto). | P2, P3, P4 e P5 |

---

## 2. Estrutura de Slides (12 Slides · Máx. 15 Minutos) — Estilo Executivo para a Empresa *Açaí do Vale*

> **Diretriz de Conduta (Enunciado + Slide 26, Deck 3):** Vocês estão apresentando um diagnóstico executivo **para os sócios/desenvolvedores da empresa Açaí do Vale**. Mantenham postura consultiva, respeitosa, objetiva e construtiva: valorizem os acertos arquiteturais deles antes de demonstrar os riscos e foquem no retorno prático das soluções!

| Slide | Título Sugerido | Conteúdo Visual (Pouco texto, visual limpo) | Porta-Voz e Tempo |
| :-: | :--- | :--- | :---: |
| **01** | Auditoria de Sistemas — Diagnóstico Executivo *Açaí do Vale* | Logo/Identidade, nomes dos 7 consultores-auditores e data (25/11/2026). | **Porta-Voz 1 (Augusto - P1)**<br>*(2 min: Slides 1–3)* |
| **02** | Escopo, Metodologia e Visão do Ambiente | Números do sistema (11 tabelas, 14 telas, 21 rotas API), DFD Nível 1 simplificado e técnicas aplicadas (Questionário, Entrevista, Visita *In Loco* e *Test Deck*). | 〃 |
| **03** | Pontos Fortes Reconhecidos + Mapa Geral de Risco | Elogio técnico genuíno (Clean Architecture, Prisma anti-SQLi, `bcrypt`, Docker non-root) → Gráfico/Termômetro dos 12 PCs por Grau de Risco (3× Grau 5, 4× Grau 4, 4× Grau 3, 1× Grau 2). | 〃 |
| **04** | Achado Crítico #1: Exposição de Acessos e Painéis (`PC01`, `PC04`, `PC05`) | Demonstração visual: `middleware.js` não cobrindo `/api/*`, painel `/ui/admin` aberto, `/api/seed` e exposição de endereços LGPD. | **Porta-Voz 2 (Frente Técnica A)**<br>*(3 min: Slides 4–5)* |
| **05** | Ambiente Físico, Micros e Continuidade (`PC09`, `PC10`, `PC11`) | Síntese objetiva da Visita *In Loco*, segurança das estações/rede, backup no Neon e necessidade de Plano de Contingência. | 〃 |
| **06** | Achado Crítico #2: Simulação *Test Deck* Financeira (`PC02`, `PC03`) | Tabela visual de impacto do *Test Deck*: preço adulterado no `localStorage` (`R$ -50,00`), cupom 100% sem trava de `usoMaximo` e pontos negativos. | **Porta-Voz 3 (Frente Técnica B)**<br>*(3 min: Slides 6–7)* |
| **07** | Fidedignidade Gerencial, Logs e Esteira CI/CD (`PC06`, `PC07`, `PC08`) | `DashboardStats` inflando receita com pedidos cancelados, exclusão física sem *Audit Trail* e achado cirúrgico das pastas `github/` e `husky/` sem ponto. | 〃 |
| **08** | Plano de Ação Recomendado (Quick Wins em 3 Ondas) | **Imediato (24h):** fechar `/api/*`, remover `/seed` e `/ui/admin`, adicionar `.` em `.github`. **Curto prazo (1 sem):** cálculo server-side + transação de cupom + filtro de receita. **Médio prazo:** `AuditLog`, perfis RBAC e backup testado. | **Porta-Voz 4 (Soluções / Custos)**<br>*(5 min: Slides 8–10)* |
| **09** | Relatório de Redução de Custos e ROI das Melhorias | Gráfico/Tabela comparativa: **~R\$ 1.460** de esforço único (~18h dev) vs. **~R\$ 30.000/ano** em perdas financeiras e retrabalho evitados (*Payback* < 2 meses). | 〃 |
| **10** | Contribuição para o Plano Diretor de Informática (PDI) | Como priorizar a evolução segura do *Açaí do Vale* antes do lançamento comercial real. | 〃 |
| **11** | Certificado de Controle Interno (Parecer Final) | Box executivo com a classificação global, justificativa sintética e recomendação de auditoria de retorno pós-implantação. | **Porta-Voz 1 (Augusto - P1)**<br>*(2 min: Slides 11–12)* |
| **12** | Agradecimento & Debate das Alternativas com a Empresa | Agradecimento à receptividade da equipe *Açaí do Vale* e abertura para discussão das soluções propostas. | 〃 |
