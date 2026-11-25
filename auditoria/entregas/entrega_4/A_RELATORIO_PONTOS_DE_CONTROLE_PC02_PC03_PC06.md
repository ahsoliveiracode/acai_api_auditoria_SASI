# Relatório dos Pontos de Controle PC02, PC03 e PC06 — Sistema em Operação

**Sistema auditado:** Açaí do Vale (`delivery-main`, branch `TPIII`)
**Auditora responsável:** Helen Gonçalves (Pessoa 4)
**Data de execução:** 24/11/2026
**Técnicas aplicadas:** análise do programa fonte, rastreamento de programas (fluxo de dados da interface até o banco), simulação de dados (*Test Deck*), execução das rotinas de teste existentes e mapeamento de rotinas de CI/CD.
**Escala de grau de risco:** 1 – Muito fraco · 2 – Fraco · 3 – Regular · 4 – Forte · 5 – Muito forte.

---

## 1. Ambiente e procedimentos de execução

Os testes funcionais foram executados exclusivamente em ambiente local, isolado e descartável, com banco de dados em memória. Nenhum teste foi direcionado à aplicação publicada nem a banco de dados compartilhado.

**Delimitação:** as conclusões funcionais referem-se à versão do código efetivamente testada, o commit `2ceb6a1` da branch `TPIII`. Não se afirma que os mesmos comportamentos tenham sido reproduzidos no ambiente publicado, que não foi testado. Eventuais diferenças de configuração em produção (variáveis de ambiente, camadas de proxy ou versão implantada) não foram avaliadas.

| Item | Configuração utilizada |
| :--- | :--- |
| Código executado | Cópia temporária de `delivery-main` (commit `2ceb6a1`) fora do repositório; o diretório original não foi alterado. |
| Banco de dados | PostgreSQL em memória (PGlite 0.3, protocolo PostgreSQL), descartado ao final; esquema criado com `prisma migrate deploy` a partir das migrações do próprio projeto. |
| Servidor | `next dev` (Next.js 15.5.7) em `http://localhost:3100` e, para a suíte Jest, `http://localhost:3000`. |
| Massa de teste | Um cliente fictício (`cliente.td.<timestamp>@exemplo.test`), sabores e adicionais criados pela migração `seed_base_data`, cupons fictícios `TDD…` e `TDE…`. |
| Ferramenta | `auditoria/scripts/test-deck-local.sh` (registra requisição, código HTTP, resposta e estado antes/depois; restrito a `localhost`; mascara o campo `senha`). |
| Evidências | `auditoria/evidencias/P4_test_deck_local_resumo_20261124_213829.md`, `P4_test_deck_local_log_20261124_213829.txt` e `P4_execucao_suite_jest_20261124.txt`. |

**Classificações utilizadas:**

| Classificação | Critério |
| :--- | :--- |
| **Falha confirmada em teste funcional** | Comportamento indevido observado em requisição HTTP executada no ambiente local, registrado no log de evidências. |
| **Falha confirmada em execução de rotina** | Falha observada ao executar uma rotina do próprio projeto (suíte Jest, `npm run lint`, `npm ci`), com saída registrada. |
| **Indício identificado por análise estática** | Conclusão obtida pela leitura do código ou da configuração, sem execução que a comprove. |
| **Controle aprovado** | Controle esperado observado em funcionamento. |
| **Não executado** | Verificação prevista e não realizada, com o motivo indicado. |
| **Limitação do ambiente ou do escopo** | Resultado cuja interpretação depende de condição externa ao ambiente testado. |

---

## 2. PC02 — Programas de cálculo e consistência financeira dos pedidos

**Objetivo:** verificar se o valor dos pedidos é calculado e validado pelo servidor e se entradas inválidas, incoerentes ou incompletas são rejeitadas.
**Grau de risco previsto no planejamento:** 5 – Muito forte.

### 2.1 Rastreamento do fluxo de cálculo

1. O preço de cada pote é definido na interface: `src/app/ui/pedido/tamanho/page.tsx` (L6–8: Pequeno R$ 10, Médio R$ 15, Grande R$ 20) e armazenado no contexto do navegador (`PedidoContext`).
2. O subtotal e o total com desconto são calculados no navegador: `src/app/ui/pedido/endereco/page.tsx` (L22–25).
3. O payload enviado contém `valorTotal` e `descontoAplicado` calculados pelo cliente (L159–166) e é submetido à rota legada `POST /api/pedidos` (L171), não à rota `POST /api/v1/orders`.
4. A rota `src/app/api/pedidos/route.ts` grava `valorTotal` e `descontoAplicado` exatamente como recebidos (L47–57 e L75–79), sem validação de tipo, sinal ou coerência.
5. O modelo `Sabor` e o modelo `Adicional` em `prisma/schema.prisma` (L14–27) não possuem atributo de preço; não existe, portanto, fonte de preço no servidor que permita recálculo.
6. A rota `POST /api/v1/orders` (`create-order.use-case.ts`, L41–51) valida campos obrigatórios e a existência de ao menos um sabor, mas também aceita `totalValue` informado pelo cliente sem verificação.

### 2.2 Resultados

| Nº | Verificação | Evidência | Classificação |
| :-: | :--- | :--- | :--- |
| 2.1 | Recálculo do valor no servidor | `schema.prisma` L14–27; `pedidos/route.ts` L75–79; TD-A1, TD-B2, TC-03 | **Falha confirmada em teste funcional** |
| 2.2 | Rejeição de valor negativo | TD-A1 (`/api/pedidos`, HTTP 201, `valorTotal` gravado −50) e TD-A2 (`/api/v1/orders`, HTTP 201, −50) | **Falha confirmada em teste funcional** |
| 2.3 | Rejeição de desconto incoerente sem cupom | TD-B2 (`valorTotal` 0 e `descontoAplicado` 99999 aceitos, HTTP 201) | **Falha confirmada em teste funcional** |
| 2.4 | Rejeição de pedido sem sabores — rota legada | TD-C1 (HTTP 201, pedido gravado com 0 sabores) | **Falha confirmada em teste funcional** |
| 2.5 | Rejeição de pedido sem sabores — rota v1 | TD-C2 (HTTP 400, “At least one flavor is required”) | **Controle aprovado** |
| 2.6 | Rejeição de forma de pagamento e endereço vazios | TD-C3 (HTTP 201 com `formaPagamento: ""` e `enderecoEntrega: ""`) | **Falha confirmada em teste funcional** |
| 2.7 | Valor informado pelo cliente gera pontos de fidelidade | TC-03 (pote pequeno declarado a R$ 1.000,00; HTTP 201; saldo +100 pontos), `pedidos/route.ts` L104–121 | **Falha confirmada em teste funcional** |
| 2.8 | Tabela de preços única | Interface usa R$ 10/15/20 (`tamanho/page.tsx` L6–8); `src/constants/index.ts` L15–23 define R$ 25/35/45, usado apenas em arquivo de exemplo | **Indício identificado por análise estática** |
| 2.9 | Tipo monetário adequado | `valorTotal` e `descontoAplicado` declarados como `Float` (`schema.prisma` L50 e L55), sujeito a erro de arredondamento | **Indício identificado por análise estática** |

### 2.3 Conclusão e grau de risco

Na versão testada, o controle de integridade financeira dos pedidos é inexistente na rota efetivamente utilizada pela interface. O servidor não dispõe de tabela de preços e persiste qualquer valor recebido, inclusive negativo ou zerado com desconto arbitrário. Como as rotas não exigem autenticação (verificação a cargo do PC01), a exploração requer apenas uma requisição HTTP.

**Grau de risco atribuído: 5 – Muito forte.** Justificativa: impacto financeiro direto (receita, faturamento e relatórios de receita), exploração trivial confirmada em teste e efeito em cadeia sobre o programa de fidelidade (item 2.7). A rota v1 apresenta crítica parcial de campos obrigatórios, mas não é utilizada pelo fluxo de compra.

### 2.4 Recomendações

1. Cadastrar preços de tamanhos e adicionais no banco (tipo `Decimal`) e calcular `valorTotal` exclusivamente no servidor, ignorando valores monetários enviados pelo navegador.
2. Validar o payload com esquema declarativo (por exemplo, Zod): sabores ≥ 1, identificadores existentes, tamanhos de uma lista fechada, forma de pagamento de uma lista fechada e endereço obrigatório.
3. Calcular o desconto no servidor a partir do cupom validado, limitado ao subtotal.
4. Unificar a criação de pedidos em uma única rota (v1) e desativar `POST /api/pedidos`.
5. Calcular pontos de fidelidade somente após a confirmação do pagamento ou da entrega, a partir do valor recalculado.

---

## 3. PC03 — Rotinas de atualização de cupons e fidelidade

**Objetivo:** verificar permissões, limites, validade, atomicidade e consistência das operações sobre cupons e pontos de fidelidade.
**Grau de risco previsto no planejamento:** 5 – Muito forte.

### 3.1 Análise do programa fonte

- `src/app/api/v1/coupons/route.ts`: `POST` (L12–64) cria ou sobrescreve cupom via `upsert` e `PATCH` (L66–91) altera a situação ativa, sem nenhuma verificação de sessão, token ou perfil administrativo.
- `src/app/api/v1/coupons/validate/route.ts` (L18–36): verifica situação ativa, expiração, limite de uso e valor mínimo. É um controle correto, porém apenas consultivo: é chamado pelo carrinho (`carrinho/page.tsx` L51) e não pela rota que grava o pedido.
- `src/app/api/pedidos/route.ts` (L97–102): ao receber `cupomCodigo`, apenas incrementa `usosAtuais` com `updateMany`, sem verificar existência, situação, validade ou limite.
- `src/app/api/v1/loyalty/route.ts` (L42–64): converte `redeem` em ajuste negativo e aplica `increment` sem verificar saldo. A atualização do saldo e o registro em `FidelidadeTransacao` ocorrem na mesma transação (`prisma.$transaction`), o que constitui controle de atomicidade adequado para essa operação.
- Em `POST /api/pedidos`, a criação do pedido (L62), o incremento do cupom (L98) e o crédito de pontos (L107) são operações independentes. Uma falha intermediária deixa o estado parcialmente atualizado.

### 3.2 Resultados

| Nº | Verificação | Evidência | Classificação |
| :-: | :--- | :--- | :--- |
| 3.1 | Criação de cupom restrita a administrador | TD-D1: cupom de 100% criado sem autenticação (HTTP 201) | **Falha confirmada em teste funcional** |
| 3.2 | Alteração de cupom restrita a administrador | TD-D3: desativação sem autenticação (HTTP 200) | **Falha confirmada em teste funcional** |
| 3.3 | Crédito de pontos restrito a administrador | TD-D2: `earn` de 50.000 pontos sem autenticação (HTTP 200; saldo −9.997 → 40.003) | **Falha confirmada em teste funcional** |
| 3.4 | Bloqueio de resgate acima do saldo | TD-B1: resgate de 9.999 com saldo 0 (HTTP 200; saldo final −9.999) | **Falha confirmada em teste funcional** |
| 3.5 | Limite de uso na validação do cupom | TD-E3: após o 1º uso, `GET /coupons/validate` retorna 400 “Limite de uso atingido” | **Controle aprovado** |
| 3.6 | Limite de uso na gravação do pedido | TD-E4: 2º pedido com cupom `usoMaximo: 1` aceito (HTTP 201; `usosAtuais` 2) | **Falha confirmada em teste funcional** |
| 3.7 | Rejeição de cupom inativo no pedido | TC-01: cupom desativado em TD-D3 aceito (HTTP 201; `usosAtuais` 1) | **Falha confirmada em teste funcional** |
| 3.8 | Rejeição de cupom inexistente no pedido | TC-02: código não cadastrado aceito com desconto informado pelo cliente (HTTP 201) | **Falha confirmada em teste funcional** |
| 3.9 | Rejeição de cupom expirado ou abaixo do valor mínimo no pedido | `pedidos/route.ts` L97–102 não consulta `expiraEm` nem `valorMinimo` | **Indício identificado por análise estática** |
| 3.10 | Sobrescrita de cupom existente | `POST /coupons` usa `upsert` (L33–54): reenvio do mesmo código altera valor, `usoMaximo` e situação | **Indício identificado por análise estática** |
| 3.11 | Atomicidade de saldo e extrato de pontos | `loyalty/route.ts` L44–64 (`$transaction`); TD-B1 registrou a transação correspondente | **Controle aprovado** |
| 3.12 | Atomicidade pedido + cupom + pontos | Três operações separadas em `pedidos/route.ts` L62, L98 e L107 | **Indício identificado por análise estática** |
| 3.13 | Estorno de pontos na exclusão do pedido | TC-05: após excluir o pedido de TC-03, o saldo permaneceu 40.105 (pontos não estornados) | **Falha confirmada em teste funcional** |
| 3.14 | Uso concorrente do mesmo cupom (condição de corrida) | Teste de concorrência não realizado; o banco local em memória não reproduz o comportamento concorrente do PostgreSQL de produção | **Não executado** (limitação do ambiente) |

### 3.3 Conclusão e grau de risco

Na versão testada, as regras de negócio de cupons existem apenas na rota de validação consultiva, que bloqueou corretamente o segundo uso (TD-E3). A rota que efetivamente grava o pedido não as aplica, e as operações administrativas de cupons e de pontos não possuem controle de acesso. Além da validação consultiva, o controle efetivo observado é a transação atômica entre saldo e extrato de pontos.

**Grau de risco atribuído: 5 – Muito forte.** Justificativa: qualquer pessoa, sem autenticação, pode emitir cupons de 100%, creditar pontos ilimitados, gerar saldo negativo e reutilizar cupons de uso único. Há perda financeira direta e comprometimento da confiabilidade do programa de fidelidade, com exploração confirmada em teste.

### 3.4 Recomendações

1. Exigir sessão autenticada com perfil administrativo em `POST`/`PATCH /api/v1/coupons` e `POST /api/v1/loyalty`, com verificação no servidor.
2. Na criação do pedido, reaplicar no servidor as mesmas regras de `coupons/validate` (existência, situação ativa, validade, valor mínimo e limite).
3. Incrementar o uso do cupom de forma condicional e atômica (`UPDATE … WHERE usosAtuais < usoMaximo`) dentro da mesma `prisma.$transaction` que cria o pedido e credita os pontos.
4. Bloquear resgates superiores ao saldo e incluir restrição `CHECK (pontosFidelidade >= 0)` no banco.
5. Separar criação (`POST`) e alteração (`PATCH`) de cupons e não permitir sobrescrita silenciosa via `upsert`.
6. Estornar pontos e uso de cupom no cancelamento do pedido, por lançamento compensatório, sem exclusão.

---

## 4. PC06 — Fidelidade da informação, logs, erros e CI/CD

**Objetivo:** avaliar a rastreabilidade das operações, o tratamento de erros e a efetividade das rotinas automatizadas de verificação.
**Grau de risco previsto no planejamento:** 4 – Forte.

### 4.1 Trilha de auditoria e preservação do histórico

- Não há modelo de log de auditoria no `schema.prisma` nem biblioteca de logging no projeto. A busca por `audit`, `logger`, `winston`, `pino`, `deletedAt`, `createdBy` e `updatedBy` em `src/` e `prisma/` não retornou ocorrências. Os registros existentes limitam-se a `console.error`/`console.log` (34 ocorrências em `src/app/api` e `src/infrastructure`), que vão para a saída padrão do processo, sem identificação do usuário.
- `FidelidadeTransacao` funciona como extrato parcial de pontos, mas não registra o autor da operação e é excluída em cascata com o cliente (`schema.prisma` L124).
- A relação `Pedido → Cliente` é `ON DELETE RESTRICT` (migração `20251109130904_init`, L69): um cliente com pedidos não pode ser excluído. Os itens do pedido (`PedidoSabor`, `PedidoAdicional`) são excluídos em cascata com o pedido (L60 e L69).

### 4.2 Tratamento de erros

- `POST /api/pedidos`, `/api/v1/coupons`, `/api/v1/loyalty` e os controladores v1 retornam mensagens genéricas para erros internos (TC-06: HTTP 500, “Erro ao adicionar pedido”).
- `src/app/api/create-admin/route.ts` (L59) e `src/app/api/seed/route.ts` (L73) retornam `details: error.message` ao cliente. O teste não foi executado porque essas rotas exigem `ADMIN_SECRET` válido, que não foi configurado no ambiente de teste.
- `POST /api/pedidos` retorna HTTP 500 para `clienteId` inexistente, quando o adequado seria HTTP 4xx. A falha de validação é tratada como erro interno.

### 4.3 Testes automatizados, GitHub Actions e Husky

**a) Configuração dos arquivos de workflow e hooks (análise estática).** Os arquivos estão em `delivery-main/github/workflows/deploy.yml` e `delivery-main/husky/`, sem o ponto inicial e fora da raiz do repositório. O GitHub Actions reconhece apenas `.github/workflows` na raiz do repositório, e o Husky 9 utiliza `.husky/` por padrão. Na configuração atual, portanto, esses arquivos não são reconhecidos pelas ferramentas. Também no conteúdo do workflow:

- usa `cache: pnpm` sem etapa de instalação do pnpm (L33) e o comando `pnpm ci` (L43);
- executa apenas a suíte Java, e não a suíte Jest;
- a suíte Java aponta para uma URL de produção na Vercel (`TestEndpoint.java` L29), onde cria e exclui registros.

**b) Resultado da consulta ao GitHub.** A API pública do GitHub foi consultada em 24/11/2026 às 21h42 (`/repos/ahsoliveiracode/acai_api_auditoria_SASI/actions/workflows` e `/actions/runs`). O retorno foi `total_count: 0` para workflows e para execuções.

**c) Limitação do escopo dessa consulta.** A consulta abrange apenas o repositório da auditoria, e não o repositório original do grupo desenvolvedor, cujo histórico não foi consultado. O resultado indica que nenhum workflow está registrado ou foi executado no repositório consultado. Ele **não comprova** a inexistência histórica de execuções de CI/CD no repositório original. A conclusão sobre a inoperância do CI apoia-se na configuração descrita no item (a), e não nessa consulta.

**d) Hooks Husky.** O hook `pre-commit` executa `npm run lint`, mas `package.json` não define o script `lint`. A execução de `npm run lint` no ambiente local retornou `Missing script: "lint"`. No clone local, a configuração `core.hooksPath` não está definida.

**e) Suíte Jest.** A suíte foi executada no ambiente isolado e resultou em **7 falhas em 14 testes**.

- A causa principal é a criação do cliente de teste sem `endereco`, campo hoje obrigatório (HTTP 400); os testes dependentes falham em cadeia.
- O primeiro teste é aprovado indevidamente, pois compara dois valores `undefined` (análise estática do código do teste).
- O `beforeAll`/`afterAll` executa `deleteMany` em todas as tabelas, o que torna a suíte destrutiva se apontada para um banco real.

**f) Reprodutibilidade das dependências.** `npm ci` falhou com `EUSAGE` porque `package-lock.json` está dessincronizado do `package.json` (por exemplo, `wait-on@8.0.5` ausente do lock).

### 4.4 Resultados

| Nº | Verificação | Evidência | Classificação |
| :-: | :--- | :--- | :--- |
| 6.1 | Existência de trilha de auditoria com autor, data e estado anterior | Inspeção do `schema.prisma` e busca no código-fonte | **Indício identificado por análise estática** |
| 6.2 | Alteração de status de pedido com identificação do responsável | TC-04: `PATCH /api/v1/admin/orders/10/status` sem autenticação (HTTP 200, status “Cancelado”) | **Falha confirmada em teste funcional** |
| 6.3 | Preservação do histórico na exclusão de pedido | TC-05: `DELETE /api/pedidos?id=10` sem autenticação (HTTP 200); consulta posterior retornou 0 registros | **Falha confirmada em teste funcional** |
| 6.4 | Registro do extrato de pontos (`FidelidadeTransacao`) | Registro gerado em TD-B1 e TD-D2. Ressalva: não identifica o autor e é excluído com o cliente | **Controle aprovado** (parcial) |
| 6.5 | Mensagens genéricas em erros internos das rotas de negócio | TC-06 (HTTP 500, mensagem genérica; código HTTP inadequado) | **Controle aprovado** |
| 6.6 | Exposição de `error.message` em `create-admin` e `seed` | `create-admin/route.ts` L59; `seed/route.ts` L73. Teste **não executado** por exigir `ADMIN_SECRET` válido | **Indício identificado por análise estática** |
| 6.7 | Reconhecimento dos arquivos de workflow pelo GitHub Actions | Diretório `delivery-main/github/workflows`, sem ponto e fora da raiz | **Indício identificado por análise estática** |
| 6.8 | Corretude do conteúdo do workflow | `deploy.yml` L33 e L43; suíte Jest não executada; suíte Java apontando para produção | **Indício identificado por análise estática** |
| 6.9 | Execuções de CI registradas | API do GitHub: 0 workflows e 0 execuções no repositório da auditoria; repositório original não consultado | **Limitação do escopo** (não comprova inexistência histórica) |
| 6.10 | Reconhecimento dos hooks Husky | Diretório `husky/` sem ponto; `core.hooksPath` indefinido no clone local | **Indício identificado por análise estática** |
| 6.11 | Hook `pre-commit` executável | `npm run lint` → `Missing script: "lint"` | **Falha confirmada em execução de rotina** |
| 6.12 | Suíte Jest funcional | 7 de 14 testes falham (`P4_execucao_suite_jest_20261124.txt`) | **Falha confirmada em execução de rotina** |
| 6.13 | Reprodutibilidade das dependências | `npm ci` → `EUSAGE` (lock dessincronizado) | **Falha confirmada em execução de rotina** |
| 6.14 | Suíte Java | Java/Maven indisponíveis no ambiente; a suíte aponta para produção, o que impede execução segura | **Não executado** (limitação do ambiente) |

### 4.5 Conclusão e grau de risco

Na versão testada, não foi identificada trilha de auditoria capaz de apontar quem alterou ou excluiu pedidos, cupons e pontos. As exclusões são físicas e, em teste funcional, alteração e exclusão de pedido foram realizadas sem autenticação.

As rotinas de garantia de qualidade existem como arquivos, mas apresentam deficiências:

- workflow e hooks estão em diretórios que as ferramentas não reconhecem (análise estática);
- o hook de pré-commit referencia um script inexistente (confirmado em execução);
- a suíte Jest está desatualizada em relação ao código (confirmado em execução).

A ausência de execuções no repositório consultado é registrada apenas como observação de escopo limitado.

**Grau de risco atribuído: 4 – Forte.** Justificativa: a ausência de rastreabilidade impede apurar fraudes como as confirmadas em PC02 e PC03, e as deficiências das rotinas de teste reduzem a capacidade de detectar regressões antes da implantação. O impacto financeiro é indireto, razão pela qual o grau é inferior ao dos PC02 e PC03.

### 4.6 Recomendações

1. Criar tabela de auditoria imutável (`AuditLog`: usuário, data/hora, IP, entidade, operação, estado anterior e novo) alimentada em todas as operações de escrita de pedidos, cupons, pontos e clientes.
2. Substituir exclusão física por exclusão lógica (`deletedAt`) ou pelo status “Cancelado”, preservando o histórico financeiro.
3. Adotar logger estruturado com retenção controlada e remover `details: error.message` das respostas de `create-admin` e `seed`.
4. Mover o workflow para `.github/workflows/` na raiz do repositório e corrigi-lo: instalação do pnpm, `pnpm install --frozen-lockfile`, execução da suíte Jest e testes contra ambiente efêmero, nunca contra produção.
5. Mover os hooks para `.husky/`, criar o script `lint` e corrigir os dados de teste da suíte Jest (incluir `endereco` e eliminar o falso positivo do primeiro teste).
6. Sincronizar `package-lock.json` ou padronizar um único gerenciador de pacotes.

---

## 5. Achado incidental encaminhado a outros pontos de controle

Durante o *Test Deck* constatou-se que `GET /api/pedidos`, sem autenticação, retorna para cada pedido o objeto `cliente` completo, inclusive o hash bcrypt do campo `senha` e o atributo `isAdmin` (`pedidos/route.ts` L25–41, `include: { cliente: true }`). A resposta de `POST /api/v1/loyalty` também inclui o hash. **Classificação: Falha confirmada em teste funcional** (ambiente local, versão testada). A presença do campo e o formato bcrypt do valor foram verificados sem registrá-lo: o campo `senha` foi mascarado no registro bruto e nenhum hash consta das evidências.

O achado pertence principalmente aos pontos **PC04** (confidencialidade — Rafael Gomes, Pessoa 5) e **PC05** (gestão de senhas — Alisson de Souza Rocha, Pessoa 3) e foi comunicado aos responsáveis para avaliação nos respectivos relatórios, que não foram alterados por esta auditoria.

---

## 6. Divergências em relação ao planejamento inicial

| Afirmação do planejamento | Situação verificada |
| :--- | :--- |
| “Nos testes simulados, o sistema aceitou valores negativos, zerados e pedidos sem sabores” | Confirmado na rota legada. A rota v1 rejeita pedido sem sabores (TD-C2), mas aceita valor negativo (TD-A2). |
| “`POST /api/pedidos` incrementa `usosAtuais` sem validar” | Confirmado (TD-E). A rota `coupons/validate` aplica corretamente o limite, mas apenas de forma consultiva. |
| “Exclusão física com `onDelete: Cascade` de pedidos e clientes” | Parcialmente correto. A exclusão de pedido é física e remove os itens em cascata. A exclusão de cliente com pedidos é bloqueada (`RESTRICT`); a de cliente sem pedidos remove em cascata favoritos e extrato de pontos (análise estática do esquema). |
| “`seed/route.ts` bypassa se `ADMIN_SECRET` vazio e retorna `admin123`” (ST-02) | Não confirmado na versão atual: a rota exige `ADMIN_SECRET` definido e não contém a senha padrão. As rotas, porém, continuam existentes (assunto do PC01). |
| Resultado do TD-B como “Aceita (`200/201`)” | Confirmado para fidelidade (TD-B1) e para desconto incoerente (TD-B2). |

---

## 7. Limitações

1. Os testes foram executados em modo de desenvolvimento (`next dev`) e com PostgreSQL em memória (PGlite), não com o build de produção nem com o Neon PostgreSQL. As conclusões sobre validação e autorização independem dessas diferenças; o comportamento sob concorrência não foi avaliado.
2. Não foram executados testes contra a aplicação publicada, por determinação do plano de trabalho. As conclusões funcionais referem-se ao commit `2ceb6a1` executado localmente e não afirmam a reprodução das falhas no ambiente publicado.
3. A suíte Java não foi executada (ausência de Java/Maven e alvo apontado para produção).
4. A consulta ao GitHub Actions refere-se ao repositório da auditoria (`ahsoliveiracode/acai_api_auditoria_SASI`). O histórico de execuções do repositório original da equipe desenvolvedora não foi consultado, de modo que a ausência de execuções observadas não comprova a inexistência histórica de CI/CD.
5. Após a geração das evidências, o script `test-deck-local.sh` recebeu dois ajustes que não alteram os resultados registrados: alinhamento da numeração das linhas de TD-E no resumo e validação mais estrita do endereço de destino. As evidências geradas foram preservadas sem alteração.
6. As respostas às questões 11 a 14 do questionário de controles internos não estavam disponíveis até a conclusão deste relatório; recomenda-se confrontá-las com os resultados acima.
