# Roteiro e Ata de Entrevista no Ambiente Computacional (7 Passos — Slide 12, *Técnicas de Auditoria*)

**Auditora Condutora (Pessoa 6):** Maria Eduarda Silveira *(Apoio sugerido: Augusto Henrique — P1 / Pessoa 5)*  
**Objetivo:** Esclarecer com os auditados o fluxo real de operação, desenvolvimento, funções, relatórios e controles compensatórios que não constam apenas no código-fonte.

---

## Passos 1 a 3 — Planejamento da Reunião e Roteiro da Entrevista

- **Pontos de Controle Foco da Entrevista:** `PC01` (Acessos/Admin), `PC07` (Satisfação e uso de Relatórios/Telas), `PC08` (Divisão de Funções e Documentação) e `PC12` (Administração do BD).
- **Data / Horário Planejado:** `24/11/2026 às ___:___` (Duração máxima: **20 minutos**)
- **Canal / Local:** `[ ] Presencial (Sala/Lab ______)   [ ] Videoconferência (Link)`

### Perguntas-Guia para Condução Oral (Não ler mecanicamente; anotar as falas-chave):
1. **Fluxo Real vs. Legado (`PC01`, `PC12`):** *"Notamos duas estruturas no código (`/api/*` e `/api/v1/*`, além de `/dashboard` e `/ui/admin`). Na prática, qual fluxo o sistema usa hoje em produção e por que as rotas antigas permaneceram ativas?"*
2. **Controle Financeiro e Operacional (`PC02`, `PC03`, `PC07`):** *"Quando entra um pedido pago via PIX ou com cupom de desconto, o que o atendente faz antes de preparar e entregar? Alguém confere se o valor cobrado bate com o tamanho e adicionais?"*
3. **Relatórios e Satisfação do Usuário (`PC07` — Slide 14, Deck 2):** *"Quem consulta o relatório do Dashboard no dia a dia? As informações de Receita Total e Pedidos atendem à gestão ou falta algum relatório (ex.: vendas por período, cancelamentos, ticket médio)?"*
4. **Funções, Acessos e Contingência (`PC08`, `PC10`, `PC12`):** *"Como vocês dividiram a administração do banco de dados, os segredos da Vercel e as aprovações no GitHub? Se o banco ou a Vercel caírem num domingo à noite, qual é o procedimento?"*

---

## Passos 4 e 5 — Ata Oficial da Reunião de Auditoria

- **Data:** 24/11/2026 | **Início:** `___:___` | **Encerramento:** `___:___`
- **Representantes da Auditoria Presentes:** `Maria Eduarda Silveira, ________________________`
- **Representantes da Empresa Auditada (*Açaí do Vale*) Presentes:** `____________________________`

### Registro Objetivo das Declarações e Esclarecimentos Obtidos:
1. **Sobre arquitetura, banco de dados e rotas legadas:**
   `_________________________________________________________________________________________`
2. **Sobre conferência de preços, cupons, pagamentos e relatórios gerenciais:**
   `_________________________________________________________________________________________`
3. **Sobre administração de acessos, testes/CI-CD, backup e contingência:**
   `_________________________________________________________________________________________`
4. **Compromissos / Documentos entregues na reunião:**
   `_________________________________________________________________________________________`

---

## Passos 6 e 7 — Análise da Entrevista e Opinião para o Relatório Final
- **Convergências/Divergências entre o relato da equipe e os testes técnicos:**
  `_________________________________________________________________________________________`
- **Conclusão do Entrevistador (Pessoa 6):**
  `_________________________________________________________________________________________`
