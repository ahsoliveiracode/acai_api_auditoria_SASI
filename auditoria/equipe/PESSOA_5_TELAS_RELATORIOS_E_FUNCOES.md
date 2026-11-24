# Caderno da Pessoa 5 — `[A definir: Rafael Gomes / José Inácio / Alisson]` (Relatórios, Telas e Funções)

**Auditor(a) Responsável:** `[Preencher Nome ao Escolher esta Frente]`  
**Papel na Auditoria:** Auditoria de Relatórios, Interfaces (Telas), Confidencialidade Visual e Auditoria de Funções/Documentação  
**Pontos sob sua Responsabilidade (3 PCs):**
- **`PC04` (Grau de Risco: 4 – Forte · 4º):** Confidencialidade em Telas/Consultas (`/ui/admin` aberto, `/pedidos/acompanhar` e `PUT /api/clientes`)
- **`PC07` (Grau de Risco: 4 – Forte · 7º):** Eficácia, Correção Contábil e Padronização dos Relatórios Emitidos e Telas (`DashboardStats`)
- **`PC08` (Grau de Risco: 3 – Regular · 8º):** Auditoria de Funções (Segregação `isAdmin`) e Normas/Documentação do Sistema

**Orçamento de Tempo:** **5h00** (Checklist das 14 telas e 4 relatórios: 2h00 | Entrevista rápida de satisfação com usuário/auditado junto à Duda P6: 1h00 | Redação dos 3 PCs para a Pessoa 7: 2h00)  
**Prazo Interno para Entregar à Pessoa 7:** Hoje, até **17h00**

---

## 1. Levantamento Já Mapeado de Relatórios e Telas (Slide 4, Deck 1 & Slides 13–14, Deck 2)

Use esta tabela (já extraída de todo o código `src/app/`) para cumprir os passos do **Slide 14 (*Relacionar telas e relatórios por usuário e detectar telas não utilizadas, layout inadequado e confidencialidade não respeitada*)**:

| Tela / Relatório | Rota no Sistema | Usuário Previsto | Achado de Auditoria (Layout, Utilização, Integração e Confidencialidade) |
| :--- | :--- | :--- | :--- |
| **Painel Admin Paralelo** | `/ui/admin` | Admin | **CONFIDENCIALIDADE VIOLADA + TELA DUPLICADA:** Sem `AdminGuard` e fora do `middleware.js`! Qualquer visitante vê e exclui clientes, pedidos e cardápio. Layout antigo conflitante com `/dashboard`. |
| **Dashboard Executivo + KPIs (`DashboardStats`)** | `/dashboard` | Admin | **ERRO DE FIDEDIGNIDADE NO RELATÓRIO:** Na linha 415 de `(admin)/dashboard/page.tsx`, o relatório `totalRevenue` soma **todos** os pedidos, incluindo `Pendente` e `Cancelado`, distorcendo a receita! Proteção `AdminGuard` apenas no navegador (client-side). |
| **Monitor Operacional de Pedidos** | `/dashboard/pedidos` | Admin | **FALTA DE PADRONIZAÇÃO:** Terceira tela administrativa distinta! Usa lista de status diferente (`"Saiu para entrega"` vs `"Saiu para a entrega"` em `/ui/admin`, quebrando filtros!). |
| **Acompanhamento e Favoritos** | `/pedidos/acompanhar` | Cliente | **CONFIDENCIALIDADE / LGPD VIOLADA:** Permite consultar sem login qualquer e-mail ou número de pedido (`1, 2, 3...`), expondo endereço residencial completo e itens de terceiros. |
| **Listagem Legada de Clientes** | `/ui/clientes` | Indefinido | **TELA EXPOSTA / NÃO UTILIZADA:** Página legada acessível por URL direta expondo cadastro de clientes. |
| **Telas de Login Multiplicadas (3x!)** | `/login`, `/ui/cliente/login`, `/ui/pedido/login` | Cliente / Admin | **BAIXA PADRONIZAÇÃO E INTEGRAÇÃO:** Três telas diferentes de autenticação no mesmo sistema, confundindo o usuário. |
| **Fluxo de Compra (6 telas)** | `/ui/pedido/tamanho`, `/sabores`, `/adicionais`, `/carrinho`, `/pagamento`, `/endereco` | Cliente | **ARQUIVO MORTO + FALTA DE CONCILIAÇÃO:** Existe arquivo abandonado `tamanho/page-refactored.example.tsx` no projeto; tela `/pagamento` apenas coleta texto (`pix`, `credito`) sem comprovante/integração. |

### Achados Adicionais para `PC08` (Auditoria de Funções e Documentação — Slides 6, 12, 16 e 17, Deck 1):
1. **Segregação de Funções Inexistente:** O modelo `Cliente` possui apenas `isAdmin: Boolean`. Não há separação de funções entre *Atendente/Cozinha* (que só deveria ver fila e mudar status de preparo), *Caixa/Financeiro* (relatórios de receita e conciliação) e *Gerente/TI* (cupons, cardápio e usuários).
2. **Inconsistências na Documentação do Desenvolvimento (Slide 12, Deck 1):**
   - Inexistência original de **DFD** (exigido pelo Slide 6, Deck 1) e ausência do arquivo `.env.local.example` citado no Quickstart;
   - `docs/RELATORIO_FINAL.md` descreve entidade `Endereco` separada, tipo `Decimal` e endpoint `POST /api/v1/auth/register`, divergindo do sistema real em operação;
   - `README.md` apresenta trecho inteiro colado em duplicidade (linhas 47–100) e credenciais divergentes do `docker-compose.yml` (`delivery123` vs `password`).

---

## 2. Modelo Pronto de Entrega para Enviar à Pessoa 7 até 17h00

### Ponto de Controle `PC04` — Confidencialidade de Telas, Painel `/ui/admin` e Privacidade/LGPD *(Grau de Risco: 4 – Forte)*
- **Técnicas Aplicadas:** Análise de relatórios e telas (Slides 13–14, Deck 2), Simulação de acesso anônimo e Questionário (Q15, Q18).
- **Análise Realizada:** Verificou-se o grau de confidencialidade das informações exibidas em tela, o respeito à LGPD e a restrição de distribuição das interfaces administrativas.
- **Problemas Encontrados:** O painel administrativo legado `/ui/admin` encontra-se integralmente aberto na web sem verificação de login, expondo toda a base de clientes e pedidos com botões ativos de remoção. Na tela pública `/pedidos/acompanhar`, qualquer pessoa pode enumerar IDs sequenciais ou informar e-mails de terceiros para visualizar endereços residenciais completos; além disso, `PUT /api/clientes` permite alterar a senha de qualquer cliente sabendo apenas seu e-mail.
- **Sugestões de Melhoria:** Descontinuar/remover imediatamente as telas legadas `/ui/admin` e `/ui/clientes`, aplicar proteção server-side no layout de `/dashboard`, exigir autenticação do titular (ou token único não sequencial) em `/pedidos/acompanhar` e condicionar alteração cadastral à sessão ativa do próprio usuário.

### Ponto de Controle `PC07` — Eficácia, Correção Contábil e Padronização de Relatórios e Telas *(Grau de Risco: 4 – Forte)*
- **Técnicas Aplicadas:** Análise de relatórios e telas (Slide 4, Deck 1 e Slide 13, Deck 2) e Entrevista/Questionário com usuários (Q12, Q16).
- **Análise Realizada:** Avaliou-se a eficácia dos relatórios emitidos quanto à natureza, correção das informações, periodicidade, apresentação sintética/analítica, integração e padronização de layouts.
- **Problemas Encontrados:** Falha grave de correção na informação gerencial do relatório `DashboardStats` (`/dashboard`), cujo cálculo de `Receita Total` soma pedidos `Pendente` e `Cancelado` junto aos entregues, induzindo a gestão a erro financeiro; ausência de filtros por período (diário/mensal) e de conciliação de pagamentos; divergência de nomenclatura de status entre painéis (`"Saiu para entrega"` vs `"Saiu para a entrega"`); e coexistência de telas duplicadas/abandonadas (3 telas de login e `page-refactored.example.tsx`).
- **Sugestões de Melhoria:** Corrigir o indicador de Receita Realizada para contabilizar apenas pedidos efetivamente pagos e `Entregues` (exibindo cancelados à parte), incluir filtro por data e exportação analítica, padronizar enum único de status e higienizar telas duplicadas/inativas.

### Ponto de Controle `PC08` — Auditoria de Funções e Consistência da Documentação e Normas *(Grau de Risco: 3 – Regular)*
- **Técnicas Aplicadas:** Auditoria de funções e normas/procedimentos (Slides 12, 16 e 17, Deck 1), Questionário (Q17) e Entrevista.
- **Análise Realizada:** Avaliou-se a adequação do fluxo de informações e permissões entre setores/usuários e a fidelidade da documentação técnica e operacional do sistema.
- **Problemas Encontrados:** Concentração excessiva de privilégios na flag binária `isAdmin`, permitindo que operadores de preparo/entrega acessem dados sensíveis, emitam cupons e apaguem registros financeiros; ausência de DFD e de manual operacional do usuário; ausência do arquivo `.env.local.example` citado no manual de instalação; e divergências técnicas entre o `RELATORIO_FINAL.md` e o banco implementado.
- **Sugestões de Melhoria:** Segregar o acesso em perfis funcionais (`CLIENTE`, `ATENDENTE_COZINHA`, `CAIXA`, `GERENTE`), incorporar ao repositório o DFD elaborado nesta auditoria e o `.env.local.example`, e revisar a documentação em `/docs` para refletir fielmente o código em produção.
