# Caderno da Pessoa 3 — `[A definir: Rafael Gomes / José Inácio / Alisson]` (Banco de Dados, Teleprocessamento e Redes)

**Auditor(a) Responsável:** `[Preencher Nome ao Escolher esta Frente]`  
**Papel na Auditoria:** Auditoria de Teleprocessamento, Banco de Dados, Redes e Segurança Lógica de Cadastros  
**Pontos sob sua Responsabilidade (3 PCs):**
- **`PC01` (Grau de Risco: 5 – Muito forte · 1º Mais Grave):** Controle de Acesso ao Teleprocessamento/APIs e Rotas Admin (`/api/*`, `/api/seed`, `/api/create-admin`)
- **`PC05` (Grau de Risco: 4 – Forte · 5º):** Gestão de Passwords, Sessões JWT/OAuth e Segurança em Redes
- **`PC12` (Grau de Risco: 2 – Fraco · 12º):** Administração de Banco de Dados, Unicidade do Dado, Dicionário e Eficiência de Arquivos

**Orçamento de Tempo:** **5h00** (Inspeção Técnica de BD/Rotas: 1h30 | Testes de Acesso e Senhas: 2h00 | Redação dos 3 PCs para a Pessoa 7: 1h30)  
**Prazo Interno para Entregar à Pessoa 7:** Hoje, até **17h00**

---

## 1. Base Técnica Já Levantada no Código para Seus Testes (Slides 5, 20–23 e 25, Deck 1)

### Para `PC01` (Controle de Acesso ao Teleprocessamento e APIs):
- **Evidência no Código:**
  1. `src/middleware.js` (linhas 25–28) define `matcher: ["/protegido/:path*", "/admin/:path*"]`. **Nenhuma rota de `/api/*` ou `/api/v1/*` passa pelo middleware**, nem possuem checagem de sessão nos Controllers! Isso permite *leitura/extração, alteração e exclusão de dados por entidade não autorizada* (problemas listados no **Slide 21, Deck 1**).
  2. `src/app/api/seed/route.ts` (linhas 11–17 e 86): compara `if (secret !== process.env.ADMIN_SECRET)`. Se `ADMIN_SECRET` não estiver setado no servidor (`undefined`), enviar `{}` faz `undefined !== undefined` dar **falso**, executando o seed, criando o admin `admin@delivery.com` e **devolvendo `"senha": "admin123"` em texto claro na resposta HTTP**!
  3. `src/app/api/create-admin/route.ts` (linha 7): mantém endpoint web ativo apesar do comentário `"REMOVER APÓS CRIAR O PRIMEIRO ADMIN"`.
- **Teste Prático:** Testar `curl -i <URL>/api/v1/customers` sem token e checar retorno `200 OK`.

### Para `PC05` (Passwords, Sessões JWT/OAuth e Protocolos de Rede):
- **Evidência no Código:**
  1. Chaves secretas de fallback chumbadas no código: `src/lib/jwt.ts` (`'dev_insecure_secret_change_me'`) e `src/infrastructure/cryptography/jwt-token-provider.ts` (`'default-secret-key'`).
  2. Três mecanismos de autenticação paralelos (`/api/auth/[...nextauth]`, `/api/v1/auth/login` e `/api/jwt/login`), tokens com validade longa (`7d`) sem lista de revogação, ausência de complexidade mínima de senha no cadastro e ausência de bloqueio contra força bruta (*rate limit*).
  3. Em `src/lib/auth.ts` (linhas 59–66), o login via Google vincula automaticamente contas existentes pelo e-mail sem checar `profile.email_verified`.

### Para `PC12` (Administração de BD, Unicidade, Dicionário e Eficiência de Arquivos — Slide 5 e Slide 20, Deck 1):
- **Pontos Positivos Encontrados (Justificam Grau de Risco 2 – Fraco):** Presença de SGBD relacional robusto (**PostgreSQL**), queries parametrizadas via **Prisma ORM** (evitando SQL Injection), senhas gravadas com **hash `bcrypt` (custo 10)** e container Docker de produção rodando com usuário sem privilégio root (`USER nextjs`).
- **Ressalvas Encontradas:**
  1. **Quebra de Unicidade do Dado e Eficiência de Arquivos:** Coexistência de arquivos JSON legados na pasta `/data` (`clientes.json`, `pedidos.json`, `sabores.json`, `adicionais.json`) junto ao PostgreSQL, além de migrations duplicadas (`20260413000000_add_endereco_to_cliente` e `20260425111500_add_endereco_to_cliente`).
  2. **Precisão de Tipos:** Uso de `Float` em vez de `Decimal(10,2)` em `Pedido.valorTotal`, `Pedido.descontoAplicado`, `Cupom.valor` e `Favorito.preco`.
  3. **Ausência da Função de Administrador de Dados (DBA) e Dicionário Formal:** Confirmar com Q06 e Q10 do Questionário recebido pela Maria Eduarda (P6).

---

## 2. Modelo Pronto de Entrega para Enviar à Pessoa 7 até 17h00

### Ponto de Controle `PC01` — Controle de Acesso Lógico às APIs e Endpoints Administrativos *(Grau de Risco: 5 – Muito forte)*
- **Técnicas Aplicadas:** Análise do programa fonte (`middleware.js`, `seed/route.ts`, `create-admin/route.ts`), Simulação de acesso e Questionário (Q08).
- **Análise Realizada:** Verificou-se a exigência de autorização de acesso aos dados em trânsito/teleprocessamento antes da leitura ou atualização do Banco de Dados (Slide 22, Deck 1).
- **Problemas Encontrados:** O `middleware.js` restringe apenas `/protegido/*` e `/admin/*`, deixando 100% dos endpoints `/api/*` e `/api/v1/*` abertos a requisições anônimas para listar, alterar ou excluir clientes e pedidos. Adicionalmente, as rotas `/api/create-admin` e `/api/seed` permanecem expostas na aplicação web, sendo que `/api/seed` permite bypass caso `ADMIN_SECRET` esteja indefinido e expõe a senha padrão `admin123` no corpo JSON.
- **Sugestões de Melhoria:** Implementar validação obrigatória de sessão e perfil (`RBAC` server-side) em todas as rotas `/api/*` e `/api/v1/*`, além de remover definitivamente os endpoints `/api/seed` e `/api/create-admin` do servidor web (restritos a scripts CLI locais).

### Ponto de Controle `PC05` — Gestão de Passwords, Sessões JWT/OAuth e Segurança em Redes *(Grau de Risco: 4 – Forte)*
- **Técnicas Aplicadas:** Análise do programa fonte (`jwt.ts`, `jwt-token-provider.ts`, `auth.ts`), Simulação de força bruta e Questionário (Q07, Q09).
- **Análise Realizada:** Avaliaram-se as normas de *passwords*, proteção criptográfica de tokens de sessão e protocolos de comunicação HTTPS/OAuth (Slides 22–23, Deck 1).
- **Problemas Encontrados:** Existência de chaves secretas de fallback hardcoded no código (`dev_insecure_secret_change_me` e `default-secret-key`), ausência de regras mínimas de complexidade de senha e de *rate limiting* no login, coexistência desnecessária de três rotas distintas de login com tokens válidos por 7 dias sem mecanismo de revogação, e falta de verificação explícita de `email_verified` no vínculo OAuth.
- **Sugestões de Melhoria:** Remover todo segredo hardcoded exigindo falha imediata de inicialização (*fail-fast*) caso faltem variáveis de ambiente, unificar autenticação exclusivamente via NextAuth sob HTTPS/TLS estrito, reduzir o tempo de vida do token, aplicar política de senha forte (mín. 8 caracteres) e *rate limit* por IP.

### Ponto de Controle `PC12` — Administração de Banco de Dados, Unicidade e Eficiência de Arquivos *(Grau de Risco: 2 – Fraco)*
- **Técnicas Aplicadas:** Inspeção do `schema.prisma`, histórico de `migrations/`, arquivos `/data` e Questionário (Q06, Q10).
- **Análise Realizada:** Avaliou-se a governança do SGBD PostgreSQL, unicidade do dado, integridade referencial, criptografia de senhas em repouso e eficiência de organização dos arquivos (Slides 5 e 20, Deck 1).
- **Problemas Encontrados:** Apesar da boa base estrutural (uso de Prisma ORM prevenindo SQL Injection e hash `bcrypt` com salt 10), identificou-se ausência de Dicionário de Dados formal e de responsável designado como Administrador de Dados (DBA), resíduos de arquivos planos `data/*.json` ferindo a unicidade, duas migrações repetidas de endereço e uso do tipo impreciso `Float` para valores monetários.
- **Sugestões de Melhoria:** Designar formalmente um Administrador de Dados na equipe, publicar o Dicionário de Dados atualizado, eliminar arquivos JSON legados em favor da fonte única no PostgreSQL e converter todas as colunas financeiras de `Float` para `Decimal(10,2)`.
