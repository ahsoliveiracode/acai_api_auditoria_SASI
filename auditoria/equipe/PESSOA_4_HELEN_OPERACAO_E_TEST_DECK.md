# Caderno da Pessoa 4 — Helen Gonçalves (Sistema em Operação e Simulação *Test Deck*)

**Auditora Responsável:** Helen Gonçalves *(Confirmada)*  
**Papel na Auditoria:** Auditora de Sistemas em Operação (Transformação de Dados em Informação) e Executora do *Test Deck*  
**Pontos sob sua Responsabilidade (3 PCs):**
- **`PC02` (Grau de Risco: 5 – Muito forte · 2º Mais Grave):** Programas de Cálculo e Crítica de Entrada de Pedidos (`valorTotal` enviado pelo cliente)
- **`PC03` (Grau de Risco: 5 – Muito forte · 3º Mais Grave):** Rotinas de Atualização de Cupons Promocionais e Saldo de Fidelidade (`/coupons` e `/loyalty`)
- **`PC06` (Grau de Risco: 4 – Forte · 6º):** Fidelidade da Informação, *Audit Trail* (Logs), Arquivos de Erros e Pipeline CI/CD (`github/`, `husky/`)

**Orçamento de Tempo:** **5h00** (Compreensão da lógica e preparação da massa: 1h00 | Execução do *Test Deck* `test-deck.sh` + navegador: 2h30 | Redação dos 3 PCs e tabela do *Test Deck* para a Pessoa 7: 1h30)  
**Prazo Interno para Entregar à Pessoa 7:** Hoje, até **17h00**

---

## 1. Sua Matriz Obrigatória de Simulação de Dados (*Test Deck* — Slides 7 e 8, Deck 2)

O Prof. Eduardo Pelli exige no **Slide 7 (*Técnicas de Auditoria*)** que o *Test Deck* preveja **5 situações específicas**. Abaixo já estão os **5 casos exatos** prontos para você rodar contra o sistema (via `./auditoria/scripts/test-deck.sh --live <URL>` e navegador) e incluir na sua entrega!

| Caso | Situação Obrigatória (Slide 7) | Ponto | Entrada Simulada (*Massa de Teste*) | Resultado Esperado (Crítica Ideal) | Resultado no Código Atual |
| :-: | :--- | :-: | :--- | :--- | :--- |
| **TD-A** | **1. Transação com campos inválidos** | `PC02` | `POST /api/pedidos` com `valorTotal: -50.00` (preço negativo adulterado) | Rejeitar (`400`) e recalcular o preço real pelos itens no servidor | **Aceita (`201`)** e persiste pedido de R\$ -50,00 no banco (`pedidos/route.ts` L62) |
| **TD-B** | **2. Transação com valores nos limites** | `PC02` / `PC03` | Pedido com `valorTotal: 0.00` / `descontoAplicado: 99999` e resgate (`redeem`) de `9999` pontos para cliente com `0` pontos | Bloquear pedido zerado sem cupom válido e impedir saldo de fidelidade `< 0` | **Aceita (`200`/`201`)**, gerando compra grátis e saldo negativo de `-9999` pontos (`loyalty/route.ts` L42) |
| **TD-C** | **3. Transação incompleta** | `PC02` | `POST /api/pedidos` sem sabores (`sabores: []`), sem `formaPagamento` válida ou `enderecoEntrega: ""` | Rejeitar por crítica de integridade de campos obrigatórios | Na rota legada `/api/pedidos`, aceita `sabores: []` (pote vazio) sem crítica de domínio |
| **TD-D** | **4. Transação incompatível** | `PC03` | Usuário **anônimo/cliente comum** enviando `POST /api/v1/coupons` (`valor: 100%`) e `POST /api/v1/loyalty` (`earn: 50000`) | Rejeitar (`401/403`) por incompatibilidade entre perfil do ator e operação administrativa | **Aceita (`201`/`200`)**, permitindo autoemissão de cupons de 100% e pontos livres |
| **TD-E** | **5. Transação em duplicidade** | `PC03` | Cupom criado com `usoMaximo: 1` submetido repetidamente em múltiplos `POST /api/pedidos` | Bloquear a partir da 2ª submissão (`Limite de uso atingido`) | `POST /api/pedidos` (L97–102) apenas incrementa `usosAtuais` (`2/1, 3/1...`) **sem validar nem bloquear** o limite! |

### Evidências de Código Adicionais para `PC06` (*Audit Trail*, Erros e Mapeamento de Rotinas Inativas — Slide 14, Deck 3 & Slide 10, Deck 2):
1. **Ausência de AIC / *Audit Trail* e Exclusão Destrutiva:** Não existe tabela de log de auditoria no `schema.prisma`; quando um pedido ou cliente é removido (`DELETE /api/pedidos` ou `/api/clientes`), o banco executa deleção física com `onDelete: Cascade`, destruindo a memória contábil da transação sem registrar autor, data/hora ou estado anterior.
2. **Vazamento de Erros de Processamento:** `create-admin/route.ts` (L59) e `seed/route.ts` (L95) devolvem `details: error.message` diretamente ao cliente externo, em vez de gravar em arquivo controlado de erros.
3. **Mapeamento de Rotinas Existentes mas Desativadas (Slide 10, Deck 2):** As pastas `github/workflows/deploy.yml` e `husky/pre-commit` estão salvas **sem o ponto inicial** (`.` ausente; deveriam ser `.github/workflows` e `.husky`), fazendo com que toda a suíte automatizada de testes (Jest + Java Maven) **nunca execute nos commits e PRs**!

---

## 2. Modelo Pronto de Entrega para Enviar à Pessoa 7 até 17h00

### Ponto de Controle `PC02` — Programas de Cálculo e Consistência Financeira de Pedidos *(Grau de Risco: 5 – Muito forte)*
- **Técnicas Aplicadas:** Simulação de dados (*Test Deck* — casos `TD-A`, `TD-B`, `TD-C`), Rastreamento de programas (`PedidoContext.tsx` → `api/pedidos/route.ts` e `create-order.use-case.ts`) e Questionário (Q11).
- **Análise Realizada:** Auditou-se o processo de captação, crítica de consistência e cálculo financeiro na transformação dos dados do carrinho em pedidos gravados no SGBD (Slide 3, Deck 1 e Slide 13, Deck 3).
- **Problemas Encontrados:** Tanto a rota legada (`POST /api/pedidos`) quanto a rota v1 (`POST /api/v1/orders`) confiam integralmente nos campos `valorTotal` e `descontoAplicado` enviados pelo cliente (armazenados em `localStorage`), inexistindo tabela de preços no banco para recálculo no servidor. Nos testes simulados, o sistema aceitou valores negativos (`-50.00`), zerados e pedidos sem sabores.
- **Sugestões de Melhoria:** Cadastrar tabela oficial de preços por tamanho e adicional no PostgreSQL, ignorar valores monetários vindos do frontend e implementar rotina de crítica e cálculo 100% server-side rejeitando totais inválidos ou potes vazios.

### Ponto de Controle `PC03` — Rotinas de Atualização de Cupons e Saldo de Fidelidade *(Grau de Risco: 5 – Muito forte)*
- **Técnicas Aplicadas:** Simulação de dados (*Test Deck* — casos `TD-B`, `TD-D`, `TD-E`) e Análise do programa fonte (`coupons/route.ts`, `loyalty/route.ts` e `pedidos/route.ts`).
- **Análise Realizada:** Verificou-se a aderência às regras de negócio e controles contra inclusão/alteração indevida nos arquivos de movimento de cupons e fidelidade (Slide 16, Deck 3).
- **Problemas Encontrados:** Ausência total de autenticação em `/api/v1/coupons` e `/api/v1/loyalty` (permitindo criação anônima de cupons de 100% e crédito arbitrário de pontos); falta de crítica de saldo mínimo no resgate (`redeem`), gerando pontuação negativa; e falha de duplicidade/atomicidade em `POST /api/pedidos`, que incrementa `usosAtuais` do cupom sem verificar se ele está ativo, dentro da validade ou abaixo do `usoMaximo`.
- **Sugestões de Melhoria:** Proteger as rotas de escrita de cupons e fidelidade com verificação de administrador, validar e decrementar `usoMaximo` do cupom dentro da mesma transação atômica (`prisma.$transaction`) de criação do pedido e bloquear resgates superiores ao `pontosFidelidade` disponível.

### Ponto de Controle `PC06` — Fidelidade da Informação (*Audit Trail*), Tratamento de Erros e CI/CD *(Grau de Risco: 4 – Forte)*
- **Técnicas Aplicadas:** Análise de log/accounting, Mapeamento de rotinas (`github/` e `husky/`), Inspeção de banco e Questionário (Q13, Q14).
- **Análise Realizada:** Avaliou-se a existência de `AUDIT TRAIL` cronológico, arquivos de controle de erros (Slide 14, Deck 3) e funcionamento efetivo das rotinas de verificação de qualidade no ciclo de vida.
- **Problemas Encontrados:** Inexistência de tabela ou serviço de log de auditoria; uso de exclusão física em cascata (`DELETE`) em pedidos e clientes (impedindo rastreamento de fraudes ou estornos); exposição de `error.message` interno em respostas HTTP 500; e inoperância total do GitHub Actions e do Husky devido à ausência do ponto inicial nos diretórios `github/workflows` e `husky`.
- **Sugestões de Melhoria:** Adotar exclusão lógica (`deletedAt` / status `Cancelado`), criar tabela imutável `AuditLog` registrando usuário, IP, timestamp e payload anterior/novo em operações críticas, padronizar tratamento seguro de erros e renomear imediatamente as pastas para `.github/workflows` e `.husky`.
