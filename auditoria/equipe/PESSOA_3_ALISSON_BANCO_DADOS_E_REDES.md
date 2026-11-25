# Caderno da Pessoa 3 — Alisson de Souza Rocha (Banco de Dados, Teleprocessamento e Redes)

**Auditor Responsável:** Alisson de Souza Rocha  
**Papel na Auditoria:** Auditoria de Teleprocessamento, Banco de Dados, Redes e Segurança Lógica de Cadastros  
**Branch da Auditoria:** `TPIII`
**Pontos sob sua Responsabilidade (3 PCs):**
- **`PC01` (Grau de Risco: 5 – Muito forte · 1º Mais Grave):** Controle de Acesso ao Teleprocessamento/APIs e Rotas Admin (`/api/*`, `/api/seed`, `/api/create-admin`)
- **`PC05` (Grau de Risco: 5 – Muito forte · Problemas Críticos):** Gestão de Passwords, Sessões JWT/OAuth e Segurança em Redes
- **`PC12` (Grau de Risco: 2 – Fraco · 12º):** Administração de Banco de Dados, Unicidade do Dado, Dicionário e Eficiência de Arquivos

**Orçamento de Tempo:** **5h00** (Inspeção Técnica de BD/Rotas: 1h30 | Testes de Acesso e Senhas: 2h00 | Redação dos 3 PCs para José Inácio — P7: 1h30)  
**Prazo Interno para Entregar a José Inácio de Moraes Santos (P7):** Hoje, até **17h00**

---

## 1. Base Técnica e Resultados dos Testes de Integração (24/11/2026)

### Metodologia aplicada

Os resultados desta seção combinam análise estática do programa fonte e testes de integração em ambiente local isolado:

- Aplicação Next.js 15.5.7 executada apenas em `127.0.0.1` em portas temporárias.
- PostgreSQL 17 temporário, publicado somente em `127.0.0.1` e executado sem volume persistente.
- Rede Docker exclusiva da auditoria e dados exclusivamente fictícios.
- Requisições HTTP reais contra os handlers da aplicação local.
- Verificações diretas no PostgreSQL temporário.
- Aplicação das migrations sem execução de seeds automáticos.
- Não houve acesso à produção, dados reais, requisições externas ou ataques de força bruta.
- Evidências sanitizadas da Pessoa 3 publicadas em `auditoria/evidencias/pessoa3/`:
  - `integration-results.json`: resultados integrados por teste, sem credenciais, senhas ou tokens completos;
  - `summary.txt`: resumo do ambiente e das limitações;
  - `environment.txt`: identificação sanitizada do ambiente temporário.
- Os arquivos locais originais permaneceram em `/tmp/acai-auditoria-integracao/evidencias/` como evidências de trabalho; nesta entrega são versionadas apenas as cópias sanitizadas da pasta indicada.

### Para `PC01` — Controle de acesso às APIs *(Grau de Risco: 5 — Muito forte)*

#### Vulnerabilidades reproduzidas

1. **Consulta anônima de clientes e pedidos:**
   - `GET /api/v1/customers` sem autenticação respondeu `200` e devolveu uma lista de clientes.
   - `GET /api/v1/orders` sem autenticação respondeu `200` e devolveu uma lista de pedidos.
   - Evidência: `src/app/api/v1/customers/route.ts:11-20` e `src/app/api/v1/orders/route.ts:10-18`.

2. **Atualização de cliente sem sessão:**
   - `PUT /api/clientes` alterou o nome de um cliente fictício usando o e-mail do próprio recurso, sem autenticação.
   - Resultado observado: `200` com o nome alterado.
   - Evidência: `src/app/api/clientes/route.ts:91-132`.

3. **Criação de pedido sem vinculação segura à sessão:**
   - `POST /api/pedidos` criou pedido fictício anônimo com `clienteId` informado pelo chamador.
   - Resultado observado: `201` com identificador do pedido.
   - Evidência: `src/app/api/pedidos/route.ts:33-104`.

4. **Acesso administrativo anônimo:**
   - `GET /api/v1/admin/dashboard/stats` respondeu `200` sem sessão ou privilégio administrativo.
   - Evidência: `src/app/api/v1/admin/dashboard/stats/route.ts:21-23`.

5. **Alteração administrativa sem autenticação:**
   - `PATCH /api/v1/admin/orders/[id]/status` alterou o status de um pedido fictício sem sessão e sem validação de `isAdmin`.
   - Resultado observado: `200`.
   - Evidência: `src/app/api/v1/admin/orders/[id]/status/route.ts:31-49`.

#### Controles positivos e correções da análise anterior

- `/api/seed` com corpo vazio respondeu `401`.
- `/api/create-admin` com segredo inválido respondeu `401`.
- Evidência: `src/app/api/seed/route.ts:10-15` e `src/app/api/create-admin/route.ts:7-14`.
- Essas rotas continuam presentes na aplicação web e devem ser removidas ou substituídas por operações administrativas CLI fora do servidor web.
- Foi corrigida a afirmação anterior de bypass de `ADMIN_SECRET`: o código exige `!process.env.ADMIN_SECRET || secret !== process.env.ADMIN_SECRET`. Quando o segredo está ausente, o acesso é negado. Não foi reproduzida a criação do administrador fixo nem a exposição de senha fixa na resposta.

#### Evidência técnica complementar

- `src/middleware.js:25-28` limita o `matcher` a `/protegido/:path*` e `/admin/:path*`; rotas `/api/*` e `/api/v1/*` não passam pela proteção indicada.
- Os controllers não verificaram sessão ou perfil nos handlers reproduzidos.

#### Recomendação prioritária

- Exigir sessão autenticada e RBAC no servidor para todas as APIs sensíveis.
- Derivar o cliente autenticado da sessão em consultas e pedidos.
- Validar propriedade do objeto antes de consultas, alterações e exclusões.
- Exigir `isAdmin` em estatísticas e alterações administrativas.
- Remover `/api/seed` e `/api/create-admin` da aplicação implantada.

### Para `PC05` — Senhas, JWT e redes *(Grau de Risco: 5 — Muito forte para falhas críticas de autenticação)*

#### Vulnerabilidades reproduzidas

1. **Emissão JWT sem autenticação:**
   - `POST /api/jwt/login` emitiu JWT com dados fictícios sem validar senha ou sessão.
   - Resultado observado: `200` e token emitido pela biblioteca real.
   - Evidência: `src/app/api/jwt/login/route.ts:7-17` e `src/lib/jwt.ts:10-17`.

2. **Fallback JWT previsível sem `JWT_SECRET`:**
   - Em uma instância local iniciada sem `JWT_SECRET`, `/api/jwt/login` respondeu `200` e emitiu token assinado pelo fallback.
   - A assinatura emitida foi verificada localmente com o fallback previsível definido no código-fonte, sem publicar seu valor.
   - Evidência: `src/lib/jwt.ts:3-6`.
   - Não foi publicado token completo em nenhuma evidência.

#### Controles positivos

- Login fictício correto em `/api/v1/auth/login` respondeu `200`.
- Login fictício incorreto respondeu `401` com uma única tentativa; não houve ataque de força bruta.
- Os cadastros fictícios armazenaram hashes bcrypt válidos no banco temporário.
- A comparação bcrypt de uma credencial correta foi positiva.
- Evidências: `src/core/application/use-cases/auth/authenticate-customer.use-case.ts:24-45`, `src/app/api/clientes/route.ts:80` e `src/infrastructure/cryptography/bcrypt-hash-provider.ts:9-16`.

#### Suspeitas e limitações

- Não foi executado teste real de OAuth com Google.
- Não foi concluída uma validação dinâmica de rate limit ou bloqueio; a ausência não foi testada por ataque de força bruta.
- O vínculo OAuth por e-mail continua sendo uma suspeita que exige validação, não uma vulnerabilidade concluída por este teste.
- Evidência de análise: `src/lib/auth.ts:57-85`.

#### Recomendação prioritária

- Remover `/api/jwt/login` ou exigir autenticação completa antes da emissão.
- Remover todos os fallbacks de segredo e falhar a inicialização quando `JWT_SECRET` estiver ausente.
- Reduzir o tempo de vida dos tokens e implementar revogação.
- Implementar rate limiting por conta, IP e dispositivo.
- Adotar política mínima de complexidade e tamanho de senha.

### Para `PC12` — Banco de dados *(Grau de Risco: 2 — Fraco)*

#### Resultados confirmados

- O schema foi aplicado em PostgreSQL temporário e resultou em **8 migrations aplicadas**.
- Foram criadas **12 tabelas** no banco descartável.
- A unicidade de e-mail foi confirmada: segundo cliente fictício com o mesmo e-mail foi rejeitado com `P2002`.
- A unicidade de código de cupom foi confirmada: cupom duplicado foi rejeitado com `P2002`.
- A integridade referencial foi confirmada: pedido com cliente inexistente foi rejeitado com `P2003`.
- PostgreSQL temporário ficou restrito à interface `127.0.0.1:55565`; Docker informou binding loopback e nenhum volume persistente.
- Evidências: `prisma/schema.prisma:29-30`, `prisma/schema.prisma:45-47`, `prisma/schema.prisma:80-81`.

#### Controle positivo

- Modelo relacional robusto, uso de Prisma, chaves primárias, relacionamentos com chave estrangeira e cascatas definidas.
- Evidência estrutural: `prisma/schema.prisma:20-113`.

#### Risco potencial de precisão monetária

- `Pedido.valorTotal`, `Pedido.descontoAplicado`, `Cupom.valor`, `Cupom.valorMinimo` e `Favorito.preco` utilizam `Float`.
- O PostgreSQL confirmou `double precision` para esses campos.
- Evidência: `prisma/schema.prisma:50-55`, `prisma/schema.prisma:82-83` e `prisma/schema.prisma:98`.
- A integração não demonstrou uma divergência financeira real. Portanto, este achado é registrado como **risco técnico potencial de imprecisão**, não como perda monetária confirmada.
- Grau de risco do achado potencial: **4 — Forte**.

#### Limitações PC12

- Não foram usados dados reais nem um volume PostgreSQL existente.
- Não houve restauração ou contingência dinâmica.
- Não foi confirmado uso dos JSON legados em ambiente de produção.
- A coexistência de JSON permanece uma suspeita limitada ao uso demonstrado em seeds, não uma violação dinâmica de fonte única.
- Evidência: `src/app/api/seed/route.ts:21-22` e `prisma/seed.ts:15-16`.

#### Recomendação prioritária

- Migrar valores financeiros de `Float` para `Decimal(10,2)` ou precisão equivalente.
- Manter as restrições únicas e integridade referencial.
- Confirmar PostgreSQL como única fonte de dados em produção.
- Consolidar o histórico das migrations duplicadas de endereço.
- Designar formalmente um responsável por administração do banco e publicar o dicionário de dados.

---

## 2. Modelo Pronto de Entrega para Enviar a José Inácio de Moraes Santos (Pessoa 7) até 17h00

### Ponto de Controle `PC01` — Controle de Acesso Lógico às APIs e Endpoints Administrativos *(Grau de Risco: 5 — Muito forte)*

- **Técnicas Aplicadas:** Análise estática, requisições HTTP reais em Next.js local e PostgreSQL temporário com dados fictícios.
- **Análise Realizada:** Confirmou-se acesso anônimo a clientes e pedidos, atualização de cliente por objeto sem sessão, criação anônima de pedido, acesso administrativo anônimo e alteração administrativa de status.
- **Problemas Encontrados:** APIs sensíveis não exigiram sessão nem perfil. `/api/seed` e `/api/create-admin` negaram segredo vazio ou inválido, mas permanecem expostas como rotas web.
- **Sugestões de Melhoria:** Aplicar sessão e RBAC no servidor, validar propriedade do objeto e remover endpoints web de inicialização.

### Ponto de Controle `PC05` — Gestão de Passwords, Sessões JWT/OAuth e Segurança em Redes *(Grau de Risco: 5 — Muito forte)*

- **Técnicas Aplicadas:** Análise estática e integração local da biblioteca real de JWT e bcrypt.
- **Análise Realizada:** Confirmou-se emissão JWT sem autenticação em `/api/jwt/login`; com `JWT_SECRET` ausente, o fallback foi utilizado. Login válido foi aceito, login inválido foi rejeitado e os hashes bcrypt foram validados no banco fictício.
- **Limitações:** Não houve teste real de OAuth nem ataque de força bruta.
- **Sugestões de Melhoria:** Remover `/api/jwt/login`, remover fallbacks e aplicar fail-fast, revogação, redução de validade e rate limiting.

### Ponto de Controle `PC12` — Administração de Banco de Dados, Unicidade e Eficiência de Arquivos *(Grau de Risco: 2 — Fraco)*

- **Técnicas Aplicadas:** Inspeção do `schema.prisma`, aplicação das migrations em PostgreSQL temporário e verificações com dados fictícios.
- **Análise Realizada:** Confirmadas 8 migrations, 12 tabelas, unicidade de e-mail e cupom, integridade referencial e binding loopback. Confirmado também o uso de `Float`/`double precision` em valores financeiros.
- **Limitações:** Não foi demonstrada uma divergência financeira efetiva, apenas o risco técnico de imprecisão.
- **Sugestões de Melhoria:** Converter campos monetários para `Decimal(10,2)`, consolidar migrations duplicadas e confirmar fonte única de dados em produção.
