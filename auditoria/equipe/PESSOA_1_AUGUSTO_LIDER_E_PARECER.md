# Caderno da Pessoa 1 — Augusto Henrique (Líder, Planejamento, Supervisão e Parecer)

**Papel na Auditoria:** Líder da Equipe, Planejamento Geral, Supervisão/Revisão de Papéis e Autor dos Produtos **3.2 (Certificado de Controle Interno)** e **3.3 (Relatório de Redução de Custos)**  
**Orçamento de Tempo:** **5h00** (Planejamento: 1h30 | Supervisão e Revisão de Papéis: 1h30 | Redação do Certificado + Redução de Custos + Ensaio: 2h00)

---

## 1. Seu Roteiro de Liderança Hoje (24/11)

1. **Manhã (Já concluído com este kit):** Entregar o `00_PLANO_MESTRE_FASE1.md` (com o DFD e os 12 PCs hierarquizados pelo Grau de Risco 1–5) para a equipe e autorizar **Maria Eduarda — Duda (P6)** a enviar o Ofício + Questionário ao outro grupo.
2. **Meio do dia / Tarde (Supervisão e Revisão dos Papéis — Passos 3 e 4, Slide 21, Deck 3):**
   - Conferir se **Ana Júlia (P2)** registrou data, hora e nomes na Visita *In Loco*;
   - Conferir se **Pessoa 3**, **Helen (P4)** e **Pessoa 5** preencheram a conclusão e as alternativas de solução para seus 3 pontos cada (total = 12 PCs);
   - Coletar o **Tempo Real** gasto por cada colega para calcular o **Indicador de Qualidade da Auditoria** (Slide 30, Deck 1):
     $$\text{Indicador de Produtividade} = \frac{\text{Soma das Horas Reais da Equipe}}{12\text{ Pontos de Controle Validados}}$$
3. **Noite (17h00 – 20h00):** Ajustar os números finais nas duas minutas prontas abaixo (Seções 2 e 3) e enviar para a **Pessoa 7** fechar o PDF de até 20 páginas (`GRUPO_X.pdf`).
4. **Apresentação Amanhã (25/11 — 4 minutos totais seus):** Você abre a apresentação (**2 min**: escopo, metodologia e postura construtiva de parceria com a empresa *Açaí do Vale*) e encerra (**2 min**: leitura executiva do Certificado de Controle Interno e abertura para debate com a empresa auditada, conforme Slide 8 e Slide 26, Deck 3).

---

## 2. MINUTA PRONTA — Produto 3.3: Relatório de Redução de Custos e Custo/Benefício (Slide 25, Deck 3)

*(Texto já redigido para a Pessoa 7 inserir na seção de Custo-Benefício do PDF; ajuste apenas valores se desejar)*

### Relatório de Redução de Custos e Retorno sobre Investimento (ROI)

Conforme as diretrizes de Auditoria de Sistemas, este relatório explicita as economias financeiras diretas e as perdas evitadas pela empresa **Açaí do Vale** mediante a adoção das recomendações propostas pela auditoria, servindo de base para a priorização do Plano Diretor de Informática (PDI).

| Fraqueza Mitigada | Cenário de Perda Atual (Sem Correção) | Perda Mensal Estimada Evitada | Esforço Técnico de Correção | Economia Líquida Anual Estimada |
| :--- | :--- | :---: | :---: | :---: |
| **Manipulação de Preços e Totais (`PC02`)** | Clientes alterando `valorTotal` no navegador (`localStorage`) para R\$ 0,01 ou valores negativos (estimativa conservadora: 15 pedidos fraudulentos/mês de R\$ 35,00). | R\$ 525,00 / mês | 4h dev (~R\$ 320,00 único) | **R\$ 5.980,00 / ano** |
| **Abuso de Cupons e Pontos de Fidelidade (`PC03`)** | Criação não autenticada de cupons de 100%, reutilização acima do `usoMaximo` e resgate de pontos sem saldo (estimativa: 20 pedidos indevidos/mês). | R\$ 700,00 / mês | 3h dev (~R\$ 240,00 único) | **R\$ 8.160,00 / ano** |
| **Distorção de Faturamento e Falha de Conciliação (`PC07`)** | Pedidos `Cancelados`/`Pendentes` somados na receita e despacho sem confirmação de PIX, gerando perda de insumos e retrabalho administrativo (~8h/mês do gestor). | R\$ 600,00 / mês | 3h dev (~R\$ 240,00 único) | **R\$ 6.960,00 / ano** |
| **Sabotagem de Dados / Exclusão sem Backup Testado (`PC01`, `PC06`, `PC11`)** | Exclusão acidental ou maliciosa via `/ui/admin` ou `/api/clientes` abertos, exigindo reconstrução manual de cadastros e paralisação de vendas (1 incidente/semestre). | R\$ 450,00 / mês *(rateado)* | 5h dev (~R\$ 400,00 único) | **R\$ 5.000,00 / ano** |
| **Exposição de Dados Pessoais — LGPD (`PC04`)** | Vazamento de endereços residenciais e e-mails em `/api/clientes` e `/pedidos/acompanhar`, sujeitando a empresa a advertências, perda de reputação e sanções legais (Art. 52, LGPD). | Risco jurídico elevado *(mitigado)* | 3h dev (~R\$ 240,00 único) | **Prevenção de passivo legal** |
| **Ativação do CI/CD Existente (`PC06`)** | Código de testes já pago/desenvolvido (346h do projeto), mas inoperante porque as pastas `github/` e `husky/` estão sem ponto inicial, gerando retrabalho manual de QA. | R\$ 320,00 / mês *(4h QA)* | **0,2h (15 min — R\$ 20,00)** | **R\$ 3.820,00 / ano** |
| **TOTAL CONSOLIDADO** | — | **~R\$ 2.595,00 / mês** | **~18,2h (~R\$ 1.460,00)** | **~R\$ 29.920,00 / ano** |

**Análise de Retorno (Custo × Benefício):** Somando o custo estimado desta auditoria (**R\$ 2.800,00** para 35 horas-auditor) ao investimento único de correção (**R\$ 1.460,00** em horas de desenvolvimento, totalizando **R\$ 4.260,00**), o *payback* integral ocorre em **1,6 mês (aprox. 50 dias)** de operação comercial, gerando economia recorrente próxima a **R\$ 30 mil no primeiro ano**, além da blindagem reputacional da marca *Açaí do Vale*.

---

## 3. MINUTA PRONTA — Produto 3.2: Certificado de Controle Interno (Parecer do Auditor — Slide 24, Deck 3)

*(Nota ao Líder: nos slides do Prof. Eduardo Pelli, o Certificado indica em termos globais e sintéticos se o ambiente está em **BOA**, **RAZOÁVEL** ou **MÁ** condição frente aos parâmetros de controle interno. Diante de 3 pontos com Grau de Risco 5-Muito Forte e 4 pontos com Grau 4-Forte, a classificação técnica rigorosa atual é **MÁ CONDIÇÃO** — ou, caso os testes ao vivo mostrem bloqueios compensatórios em produção na Vercel, ajuste para **CONDIÇÃO RAZOÁVEL COM RESSALVAS CRÍTICAS**. O texto abaixo já está escrito no tom diplomático e profissional exigido para apresentar à empresa dos colegas!)*

### CERTIFICADO DE CONTROLE INTERNO (PARECER DA AUDITORIA DE SISTEMAS)

**À Diretoria e Equipe Técnica da Empresa Açaí do Vale,**

Examinamos o ambiente computacional, a documentação técnica, a infraestrutura de banco de dados, as interfaces operacionais e uma amostra representativa de transações simuladas (*test deck*) do **Sistema de Delivery Digital Açaí do Vale**, em trabalho conduzido em 24/11/2026 sobre **12 (doze) pontos de controle críticos**, abrangendo segurança física, lógica, teleprocessamento, operação e relatórios gerenciais.

Reconhecemos inicialmente os **méritos estruturais** alcançados pela engenharia da empresa, destacando-se a organização modular inspirada em *Clean Architecture/DDD*, o uso do *Prisma ORM* (prevenindo injeções SQL clássicas), o armazenamento criptográfico de senhas com *bcrypt* e a containerização em execução não privilegiada (*non-root*).

Todavia, em relação aos **oito parâmetros fundamentais de Controle Interno**, constatamos fragilidades severas nos controles de **Segurança Lógica**, **Fidelidade da Informação**, **Confidencialidade/Obediência à Legislação (LGPD)** e **Obediência às Regras de Negócio**, notadamente: (i) ausência de mediação de autorização server-side nas rotas `/api/*` e exposição do painel legado `/ui/admin` e de rotas de provisionamento (`/api/seed` e `/api/create-admin`); (ii) aceitação pelo servidor de valores monetários e descontos calculados exclusivamente no navegador do cliente, sem crítica de limites ou tabela autoritativa de preços; (iii) permissão indevida de manipulação anônima de cupons e pontos de fidelidade; (iv) exposição pública de dados cadastrais e endereços de entrega de clientes; e (v) inexistência de trilha cronológica de auditoria (*Audit Trail*), somada à contabilização de pedidos cancelados na receita bruta do *Dashboard* e à inativação acidental da esteira automatizada de CI/CD (`github/workflows` sem ponto inicial).

**OPINIÃO GLOBAL DA AUDITORIA:**  
Em face das evidências colhidas, certificamos que o ambiente computacional do sistema *Açaí do Vale* encontra-se, na presente data, em **MÁ CONDIÇÃO** *(ou ajustar para RAZOÁVEL CONDIÇÃO COM RESSALVAS CRÍTICAS caso mitigado em produção)* quanto à suficiência de seus parâmetros de controle interno para operação comercial aberta ao público. Ressaltamos, contudo, que a arquitetura limpa já construída pela equipe permite a **saneabilidade rápida e de baixo custo (~18 horas técnicas)** das vulnerabilidades apontadas, bastando implementar o plano de ação priorizado neste relatório antes da exposição comercial em larga escala, ocasião em que recomendamos nova auditoria de validação da solução implantada.

Diamantina/MG, 24 de novembro de 2026.  
**Augusto Henrique** — *Auditor Líder* & Equipe de Auditoria de Sistemas (UFVJM)
