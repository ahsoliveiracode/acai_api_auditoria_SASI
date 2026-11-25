# Relatório de Redução de Custos e Análise de Custo-Benefício (Produto 3.3)

**Responsável:** Augusto Henrique (Pessoa 1 — Líder, Planejamento e Parecer)  
**Destinatário:** Diretoria e Equipe Técnica da Empresa *Açaí do Vale* (Grupo E)  
**Data:** 25/11/2026

---

## 1. Objetivo e Premissas de Cálculo

Em conformidade com a metodologia de Auditoria de Sistemas (Produto 3.3 — *Relatório de Redução de Custos*), este documento explicita as economias financeiras diretas, a redução de retrabalho operacional e os passivos evitados pela empresa **Açaí do Vale** com a adoção das recomendações propostas pela auditoria, subsidiando a priorização do **Plano Diretor de Informática (PDI)**.

Para manter conservadorismo e transparência executiva, adotaram-se premissas compatíveis com uma operação real de pequeno/médio porte de delivery de açaí:
- **Ticket médio por pedido:** R\$ 35,00 (volume estimado de 600 pedidos/mês = faturamento bruto de R\$ 21.000,00/mês);
- **Custo-hora técnico de referência (desenvolvimento/manutenção):** R\$ 80,00/hora;
- **Custo-hora administrativo/operacional de conferência manual:** R\$ 35,00/hora.

---

## 2. Demonstrativo de Perdas Evitadas vs. Esforço de Correção

| Ponto(s) de Controle | Fraqueza Comprovada na Auditoria | Impacto Financeiro / Operacional Sem Correção | Perda Mensal Evitada (Estimada) | Esforço Único de Correção | Economia Líquida no 1º Ano |
| :--- | :--- | :--- | :---: | :---: | :---: |
| **`PC02`**<br>*(Cálculo de Pedidos)* | Servidor aceita `valorTotal` negativo (`-50.00`), zerado ou abaixo do cardápio e gera pontos sobre valor arbitrário informado pelo cliente (`TD-A1`, `TD-B2`, `TC-03`). | Evasão direta de receita e entrega de produtos sem cobertura de custo (estimativa conservadora: 2,5% dos pedidos = 15 pedidos/mês). | **R\$ 525,00 / mês** | 5h dev<br>*(R\$ 400,00)* | **R\$ 5.900,00** |
| **`PC03`**<br>*(Cupons e Fidelidade)* | Emissão anônima de cupons de 100%, aceitação de cupons inativos/inexistentes/duplicados na criação do pedido e saldo negativo de pontos (`TD-B1`, `TD-D`, `TD-E3`, `TC-01/02`). | Sangria promocional não autorizada e resgates indevidos no programa de fidelidade (~20 pedidos/mês impactados). | **R\$ 700,00 / mês** | 4h dev<br>*(R\$ 320,00)* | **R\$ 8.080,00** |
| **`PC01` e `PC05`**<br>*(APIs Abertas e JWT sem Senha)* | Emissão de JWT sem senha (`/api/jwt/login`), alteração de status/cadastros sem sessão e 8 contas sem 2FA/RBAC acessando produção. | Cancelamento/adulteração maliciosa de pedidos em horário de pico e paralisação operacional (1 incidente relevante a cada trimestre). | **R\$ 420,00 / mês** *(rateado)* | 5h dev<br>*(R\$ 400,00)* | **R\$ 4.640,00** |
| **`PC11` e `PC10`**<br>*(Ausência de Backup e Contingência)* | Banco sem backup formalizado, sem teste de restauração e branch `main` alterável pelos 8 membros sem revisão obrigatória de PR. | Perda irreversível de histórico de clientes/pedidos/fidelidade e tempo de inatividade em falha de deploy ou corrupção de banco. | **R\$ 380,00 / mês** *(risco rateado)* | 2h DevOps<br>*(R\$ 160,00)* | **R\$ 4.400,00** |
| **`PC07` e `PC08`**<br>*(Relatórios sem Conferência e Telas Duplicadas)* | `DashboardStats` sem recorte de período/cancelamentos, falta de rotina de conferência de caixa e manutenção duplicada de 3 painéis admin e 3 telas de login. | ~12h operacionais/mês (× R\$ 35/h) de conciliação manual de caixa e retrabalho administrativo. | **R\$ 420,00 / mês** | 3h dev<br>*(R\$ 240,00)* | **R\$ 4.800,00** |
| **`PC06`**<br>*(CI/CD Inativo e Suíte Jest Quebrada)* | Pastas `github/` e `husky/` sem ponto inicial e 7 de 14 testes Jest falhando, desperdiçando o investimento já feito em testes no projeto. | ~4h técnicas/mês (× R\$ 80/h) de testes regressivos manuais e correção tardia de *bugs*. | **R\$ 320,00 / mês** | 2h dev<br>*(R\$ 160,00)* | **R\$ 3.680,00** |
| **`PC04`**<br>*(Vazamento LGPD e Hashes em `/api/pedidos`)* | Exposição sem login de nome, e-mail, endereço residencial, `isAdmin` e hash `bcrypt` de clientes em `GET /api/pedidos` e `/v1/customers`. | Exposição a reclamações de titulares, dano severo de imagem e sanções administrativas da ANPD (Art. 52 da LGPD — até 2% do faturamento). | **Passivo legal evitado** *(não monetizado)* | 1h dev<br>*(R\$ 80,00)* | **−R\$ 80,00** *(+ blindagem LGPD)* |
| **TOTAL** | — | — | **R\$ 2.765,00 / mês** | **22h (R\$ 1.760,00)** | **R\$ 31.420,00 / ano** |

---

## 3. Viabilidade Econômica, *Payback* e Direcionamento ao PDI

1. **Investimento Total (Auditoria + Implantação das Soluções):**
   - Custo orçado desta Auditoria Interna/Consultiva (35h × R\$ 80,00): **R\$ 2.800,00**
   - Custo estimado de Engenharia para saneamento completo (22h × R\$ 80,00): **R\$ 1.760,00**
   - **Investimento Global:** **R\$ 4.560,00**
2. **Indicadores de Retorno Financeiro:**
   - **Economia Bruta Anual Estimada:** **R\$ 33.180,00** (R\$ 2.765,00 × 12 meses)
   - **Economia Anual Após Custo de Engenharia:** **R\$ 31.420,00** (R\$ 33.180,00 − R\$ 1.760,00)
   - **Benefício Líquido no 1º Ano (após pagar auditoria + correções):** **R\$ 28.620,00** (R\$ 33.180,00 − R\$ 4.560,00)
   - **Retorno sobre o Investimento (ROI de 12 meses):** **+627,6%** (`28.620 / 4.560`)
   - **Prazo de Retorno (*Payback*):** **1,65 mês (~50 dias)** de operação (`4.560 / 2.765`).
3. **Recomendação Estratégica para o Plano Diretor de Informática (PDI):**
   - **Onda 1 — Custo Zero / *Quick Wins* (4 horas — R\$ 320,00):** Ativar 2FA e *Branch Protection* no GitHub/Vercel, configurar rotina de backup automático + 1º teste de *restore* no PostgreSQL, remover `/api/jwt/login`, `/api/seed`, `/api/create-admin` e `/ui/admin`, e renomear `.github/` e `.husky/`.
   - **Onda 2 — Blindagem Transacional e LGPD (11 horas — R\$ 880,00):** Implementar autenticação/RBAC server-side em todas as APIs, omitir `senha` nas respostas de pedidos (`select`/DTO), criar tabela de preços no banco com recálculo server-side e unificar validação transacional de cupons/fidelidade.
   - **Onda 3 — Governança e Gestão (7 horas — R\$ 560,00):** Criar tabela imutável `AuditLog` com cancelamento lógico, corrigir a suíte Jest e segregar receita bruta, descontos, cancelados e receita líquida por período no *Dashboard*.
