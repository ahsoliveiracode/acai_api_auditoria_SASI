# Questionário à Distância — Avaliação dos Parâmetros de Controle Interno

**Sistema Auditado:** Açaí do Vale (`acai_api/delivery-main`)  
**Coordenação de Remessa e Recebimento (Pessoa 6):** Maria Eduarda Silveira  

---

## Controle Metodológico dos 9 Passos (Slide 6 — *Técnicas de Auditoria*)

1. **Pontos de Controle Analisados:** `PC01` a `PC12` (segurança física, lógica, redes, BD, eficiência e eficácia).
2. **Profissionais Selecionados para Responder:**
   - *Bloco 1 (Infra/Físico/Backup):* DevOps (`Ana Clara Azevedo` ou representante)
   - *Bloco 2 (BD/Redes/Segurança Lógica):* Arquitetura/Backend (`Pávila Cardoso` ou representante)
   - *Bloco 3 e 4 (Operação/Telas/Funções):* Full Stack / Product Lead (`Murilo Santiago` / `Gabriel Castro`)
3. **Instruções ao Respondente:** Marque `[X]` em **Sim**, **Não** ou **Parcial** conforme o estado real atual do sistema e descreva brevemente a evidência ou procedimento adotado.
4. **Controle de Remessa e Recebimento:**
   - Data/Hora de Envio: `24/11/2026 às ___:___` | Canal: `_____________________`
   - Data/Hora de Devolução pelo Auditado: `24/11/2026 às ___:___` | Respondente(s): `_________________________`

---

### Bloco 1 — Ambiente Físico, Microcomputadores e Backup (Frente Pessoa 2 · `PC09`, `PC10`, `PC11`)

| Nº | Pergunta | Sim | Não | Parcial | Observação / Evidência do Auditado |
| :-: | :--- | :-: | :-: | :-: | :--- |
| 01 | Os microcomputadores/notebooks utilizados para administrar o sistema e acessar produção possuem inventário mínimo (usuário responsável, SO, antivírus/atualizações e senha de bloqueio)? | [ ] | [ ] | [ ] | |
| 02 | O ambiente onde ficam os equipamentos de operação/desenvolvimento conta com proteção elétrica (no-break/filtro), ventilação e restrição de acesso físico a terceiros? | [ ] | [ ] | [ ] | |
| 03 | Existe rotina configurada de backup automático do banco PostgreSQL (Neon/Docker) e armazenamento externo seguro das cópias? | [ ] | [ ] | [ ] | |
| 04 | A equipe já realizou algum teste prático de restauração (*restore*) verificando a última transação processada vs. a última recuperada após queda? | [ ] | [ ] | [ ] | |
| 05 | Existe Plano de Contingência documentado para manter o atendimento de pedidos caso a Vercel, a internet local ou o banco Neon saiam do ar? | [ ] | [ ] | [ ] | |

---

### Bloco 2 — Teleprocessamento, Banco de Dados e Redes (Frente Pessoa 3 · `PC01`, `PC05`, `PC12`)

| Nº | Pergunta | Sim | Não | Parcial | Observação / Evidência do Auditado |
| :-: | :--- | :-: | :-: | :-: | :--- |
| 06 | Existe profissional designado formalmente para a função de **Administrador de Dados / Analista de BD** (responsável pelo dicionário de dados, monitoramento e controle de acesso ao SGBD)? | [ ] | [ ] | [ ] | |
| 07 | As variáveis críticas (`JWT_SECRET`, `NEXTAUTH_SECRET`, `ADMIN_SECRET` e URL do banco) em produção possuem chaves fortes e distintas dos valores default do código? | [ ] | [ ] | [ ] | |
| 08 | As rotas de setup inicial (`/api/seed` com usuário `admin@delivery.com`/`admin123` e `/api/create-admin`) foram bloqueadas ou removidas em produção? | [ ] | [ ] | [ ] | |
| 09 | Há normas definidas para uso de *passwords* (tamanho mínimo, complexidade, troca periódica e bloqueio após tentativas inválidas)? | [ ] | [ ] | [ ] | |
| 10 | Os arquivos JSON na pasta `/data` ainda são utilizados em produção ou o PostgreSQL é a fonte única de dados (unicidade do dado)? | [ ] | [ ] | [ ] | |

---

### Bloco 3 — Sistema em Operação, Cálculos e Logs (Frente Pessoa 4 · `PC02`, `PC03`, `PC06`)

| Nº | Pergunta | Sim | Não | Parcial | Observação / Evidência do Auditado |
| :-: | :--- | :-: | :-: | :-: | :--- |
| 11 | O servidor recalcula/valida o valor total do pedido e dos descontos antes de gravar no banco, independentemente do valor enviado pelo navegador? | [ ] | [ ] | [ ] | |
| 12 | Como o operador confirma a liquidação financeira (PIX/Cartão) antes de iniciar o preparo e a entrega do pedido? | [ ] | [ ] | [ ] | |
| 13 | O sistema mantém *Audit Trail* (log cronológico de quem incluiu, alterou status ou excluiu pedidos, clientes e cupons) e registro de erros não corrigidos? | [ ] | [ ] | [ ] | |
| 14 | A pipeline de testes automatizados (GitHub Actions e hooks Husky) está executando efetivamente a cada Pull Request na branch `main`? | [ ] | [ ] | [ ] | |

---

### Bloco 4 — Relatórios, Telas e Auditoria de Funções (Frente Pessoa 5 · `PC04`, `PC07`, `PC08`)

| Nº | Pergunta | Sim | Não | Parcial | Observação / Evidência do Auditado |
| :-: | :--- | :-: | :-: | :-: | :--- |
| 15 | Qual dos painéis administrativos existentes no código (`/dashboard`, `/dashboard/pedidos` ou `/ui/admin`) é o oficial utilizado pela operação, e quem tem acesso a ele? | [ ] | [ ] | [ ] | |
| 16 | Os usuários/operadores consideram os relatórios atuais do Dashboard suficientes e confiáveis (natureza, periodicidade e exatidão da Receita Total) para tomada de decisão? | [ ] | [ ] | [ ] | |
| 17 | Existe separação de funções para que um atendente comum da cozinha não possa excluir clientes/pedidos nem emitir cupons promocionais sem autorização gerencial? | [ ] | [ ] | [ ] | |
| 18 | Há manuais de normas/procedimentos distribuídos aos usuários finais e preocupação formal com sigilo de endereço/dados pessoais (LGPD) nas telas de consulta? | [ ] | [ ] | [ ] | |

---

### Espaço Reservado à Auditoria (Passos 8 e 9: Análise das Respostas e Formação de Opinião — P6 + P1)
- **Consistência entre respostas declaradas e código-fonte inspecionado:** `________________________________________`
- **Pontos que exigiram aprofundamento em teste/visita:** `_____________________________________________________`
