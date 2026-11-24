# Evidência Automatizada — Análise do Programa Fonte e Mapeamento (Prof. Eduardo Pelli)

- **Data/Hora de Execução:** 2026-11-24 13:42:58 -0300
- **Diretório Auditado:** `/home/ahsoliveira/Documentos/Faculdade/SASI/acai_api/delivery-main` *(base original 100% preservada)*
- **Escala de Grau de Risco (Slide 19):** `1 – Muito Fraco` a `5 – Muito forte` (maior valor = mais grave)

| Caso | PC | Responsável | Verificação Automatizada | Resultado Obtido | Grau de Risco |
| :-: | :-: | :--- | :--- | :--- | :-: |
| ST-01 | PC01 | P3 (Alisson de Souza Rocha) | Cobertura de `/api/*` no `middleware.js` | `matcher` cobre só `/protegido/*` e `/admin/*`; APIs abertas | **5 – Muito forte** |
| ST-02 | PC01 | P3 (Alisson de Souza Rocha) | Rotas `/api/seed` e `/api/create-admin` | Removidas | 1 – Muito Fraco |
| ST-03 | PC02 | P4 (Helen Gonçalves) | Tabela autoritativa de preços no `schema.prisma` | `Sabor`/`Adicional` sem preço; servidor confia no `valorTotal` do cliente | **5 – Muito forte** |
| ST-04 | PC04 | P5 (Rafael Gomes) | Proteção de confidencialidade em `/ui/admin` | Painel admin legado aberto sem `AdminGuard` nem middleware | **4 – Forte** |
| ST-05 | PC05 | P3 (Alisson de Souza Rocha) | Segredos JWT sem fallback hardcoded | Fallbacks `dev_insecure_secret_change_me` e `default-secret-key` ativos | **4 – Forte** |
| ST-06 | PC06 | P4 (Helen Gonçalves) | *Audit Trail* e esteira CI/CD (`.github/` e `.husky/`) | Sem tabela `AuditLog`; pastas `github/` e `husky/` sem ponto inicial (inativas) | **4 – Forte** |
| ST-07 | PC07 | P5 (Rafael Gomes) | Fidedignidade do relatório `DashboardStats` (`/dashboard`) | `totalRevenue` soma todos os pedidos sem filtrar `Cancelado`/`Pendente` | **4 – Forte** |
| ST-08 | PC08 | P5 (Rafael Gomes) | Segregação de funções e documentação (`.env.local.example` / DFD) | Apenas flag binária `isAdmin`; `.env.local.example` e DFD ausentes | **3 – Regular** |
| ST-09 | PC11 | P2 (Ana Júlia Silveira e Maria Eduarda Silveira) | Consistência `docker-compose.yml` | Consistente | 2 – Fraco |
| ST-10 | PC12 | P3 (Alisson de Souza Rocha) | SGBD Prisma ORM, hash `bcrypt` e container `USER nextjs` | Controles fortes presentes; ressalvas: `Float` monetário e `data/*.json` legados | **2 – Fraco** |
