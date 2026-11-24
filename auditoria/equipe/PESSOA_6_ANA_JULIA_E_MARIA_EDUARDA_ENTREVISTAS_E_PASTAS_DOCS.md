# Caderno da Pessoa 6 — Ana Júlia Silveira e Maria Eduarda Silveira (Entrevistas, Questionários e Pastas de Documentação)

**Auditoras Responsáveis (em dupla — P2/P6):** Ana Júlia Silveira e Maria Eduarda Silveira  
**Papel na Auditoria:** Coordenação de Comunicação com o Auditado, Entrevista/Ata e Guardiãs dos Produtos **3.4 (Manual de Auditoria)** e **3.5 (Pastas de Documentação da Auditoria)**  
**Orçamento de Tempo:** **5h00 (em dupla)** | **Prazo Interno para Entregar a José Inácio de Moraes Santos (P7):** Hoje, até **17h00**

---

## 1. Suas 3 Entregas Práticas Hoje

1. **Disparo Externo Imediato (Passo 5 do Slide 6, Deck 2):**
   - Enviar ao grupo *Açaí do Vale* o `auditoria/disparo/01_OFICIO_SOLICITACAO_ACESSO_E_DOCS.md` junto com o `02_QUESTIONARIO_CONTROLES_INTERNOS.md` e anotar o horário exato de remessa e de recebimento.
2. **Entrevista + Ata da Reunião (Passos 1 a 7 do Slide 12, Deck 2):**
   - Conduzir a reunião de 20 minutos usando `auditoria/disparo/04_ATA_ENTREVISTA_AMBIENTE_COMPUTACIONAL.md`, preencher a Ata com nomes, horários e declarações dos colegas auditados e compartilhar imediatamente as respostas com Alisson (P3), Helen (P4) e Rafael (P5).
3. **Até 17h00 — Entregar a José Inácio de Moraes Santos (P7) os quadros consolidados da Pasta de Documentação (Produto 3.5 — Slide 25, Deck 3):**
   - O Slide 25 exige: **relação de programas, relação de arquivos do sistema, relação de relatórios e telas, fluxos e atas de reunião**. As três relações técnicas já estão **100% levantadas abaixo** para vocês revisarem e entregarem prontas!

---

## 2. INVENTÁRIO PRONTO — Produto 3.5: Relação de Programas, Arquivos, Telas e Relatórios

### A. Relação de Programas e Rotinas Auditadas (`src/`)

| Categoria | Programas / Rotinas Principais Identificados | Situação Encontrada |
| :--- | :--- | :--- |
| **Middleware e Auth (4)** | `src/middleware.js`, `src/lib/auth.ts`, `src/lib/jwt.ts`, `src/infrastructure/cryptography/jwt-token-provider.ts` | Híbrido; `middleware.js` não intercepta `/api/*` nem `/ui/admin`. |
| **Rotas API Legadas (7)** | `/api/clientes`, `/api/pedidos`, `/api/sabores`, `/api/adicionais`, `/api/jwt/login`, `/api/seed`, `/api/create-admin` | Ativas e acopladas direto ao Prisma; `/seed` e `/create-admin` expostos. |
| **Rotas API v1 REST (10)** | `/api/v1/auth/login`, `/v1/customers` (`+[id]`), `/v1/orders` (`+[id]`), `/v1/flavors` (`+[id]`), `/v1/additionals` (`+[id]`), `/v1/coupons` (`+/validate`), `/v1/loyalty`, `/v1/favorites`, `/v1/admin/dashboard/stats`, `/v1/admin/orders/[id]/status` | Parcialmente em Clean Architecture (`/coupons`, `/loyalty` e `/favorites` acoplados direto ao Prisma; todas sem auth server-side). |
| **Casos de Uso DDD (18)** | `customer/*` (6), `order/*` (5), `flavor/*` (2), `additional/*` (2), `auth/authenticate-customer` (1), `admin/*` (2) | Bem modularizados e cobertos por testes unitários Jest. |
| **Automação e Infra (5)** | `Dockerfile`, `docker-compose.yml`, `scripts/create-admin.ts`, `github/workflows/deploy.yml`, `husky/pre-commit` | `github/` e `husky/` inativos por erro de nomenclatura (falta do `.`). |

### B. Relação de Arquivos de Dados e Tabelas do Sistema

| Tipo de Armazenamento | Identificação dos Arquivos / Tabelas | Observação de Controle |
| :--- | :--- | :--- |
| **Tabelas Principais SGBD (6)** | `Cliente`, `Pedido`, `Sabor`, `Adicional`, `Cupom`, `FidelidadeTransacao` (`prisma/schema.prisma`) | PostgreSQL; valores financeiros em `Float`; sem tabela `AuditLog`. |
| **Tabelas Associativas/Auxiliares (5)** | `PedidoSabor`, `PedidoAdicional`, `Favorito`, `FavoritoSabor`, `FavoritoAdicional` | Exclusão física configurada com `onDelete: Cascade`. |
| **Arquivos Planos Legados (4)** | `data/clientes.json`, `data/pedidos.json`, `data/sabores.json`, `data/adicionais.json` | Resíduos legados lidos pela rotina `/api/seed`. |
| **Armazenamento no Cliente (2)** | `localStorage` (`PedidoContext` / `cart`) e Cookies/JWT de sessão | Preços e descontos ficam editáveis no navegador do usuário. |

### C. Relação Consolidada de Telas (14) e Relatórios/Consultas (4)

- **Telas de Cliente (11):** `/` (Home), `/login`, `/ui/cliente/login`, `/ui/cliente/cadastro`, `/ui/clientes`, `/ui/pedido/login`, `/ui/pedido/tamanho` *(+ arquivo morto `page-refactored.example.tsx`)*, `/ui/pedido/sabores`, `/ui/pedido/adicionais`, `/ui/pedido/carrinho`, `/ui/pedido/pagamento`, `/ui/pedido/endereco`, `/pedidos/acompanhar`.
- **Telas Administrativas (3):** `/dashboard` (`src/app/(admin)/dashboard/page.tsx`), `/dashboard/pedidos` e `/ui/admin` (desprotegido).
- **Relatórios e Consultas Geradas (4):** (1) *Resumo Financeiro e Operacional (`DashboardStats`)*; (2) *Monitor de Pedidos Totais vs. Entregues*; (3) *Extrato de Pontos e Transações de Fidelidade*; (4) *Consulta de Rastreamento de Pedidos*.
