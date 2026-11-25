# Guia de Integração no PDF (Para P7) e Roteiro de Falas da Pessoa 1

**Responsável:** Augusto Henrique (Pessoa 1)  
**Para:** José Inácio de Moraes Santos (Pessoa 7 — Consolidação do PDF ≤ 20 págs e Slides ≤ 15 min)

---

## 1. Onde Encaixar Cada Arquivo da `entrega_1/` no PDF Final (`GRUPO_X.pdf`)

1. **`A_PLANEJAMENTO_AMBIENTE_DFD_E_SUPERVISAO.md`** → Vai na **abertura técnica do relatório (Páginas 2 a 5)**: cobre o mapeamento do ambiente, os 2 DFDs, os objetivos/técnicas/custos/indicador de qualidade (`2,92h/PC`) e a Matriz Final Hierarquizada dos 12 Pontos de Controle já alinhada com os achados de todos os colegas.
2. **`B_RELATORIO_DE_REDUCAO_DE_CUSTOS.md`** → Vai logo **após os 12 Pontos de Controle (Páginas 17 e 18)**: cumpre o Produto 3.3 da disciplina (economias financeiras de R\$ 31.420/ano após engenharia, ROI de +627,6%, *payback* de 1,65 mês e ondas de priorização do PDI).
3. **`C_CERTIFICADO_DE_CONTROLE_INTERNO.md`** → Vai no **fechamento nobre do relatório (Página 19)**: cumpre o Produto 3.2 (parecer formal do auditor indicando **Má Condição** atual com plano construtivo de saneamento em 22h).

---

## 2. Roteiro Cronometrado de Fala — Augusto Henrique (4 Minutos Totais na Apresentação de 15 min)

### Bloco 1 — Abertura Executiva e Metodologia (2 minutos · Slides 1 a 3)

> *"Bom dia/boa tarde a todos, e em especial aos colegas da diretoria e engenharia da **Açaí do Vale**. Nosso papel aqui hoje, como equipe de auditoria independente, não é avaliar pessoas, mas entregar um diagnóstico executivo que proteja o caixa, os dados dos clientes e a continuidade do negócio de vocês antes de escalar comercialmente.*
>
> *Auditamos o sistema fim a fim sobre **12 pontos de controle críticos** — do ambiente em nuvem e backup até o banco PostgreSQL, APIs, cálculos financeiros e relatórios — combinando o questionário respondido pela equipe de vocês, inspeção estática do código, elaboração do DFD e **simulação prática de dados (Test Deck)** em ambiente local isolado, sem tocar na produção.*
>
> *Antes dos pontos críticos, fazemos questão de reconhecer os **acertos arquiteturais** do projeto: a base em Next.js com Prisma ORM garantiu integridade referencial e proteção contra SQL Injection, e o uso de `bcrypt` e container `non-root` mostra boa fundação técnica. Onde encontramos risco severo — 4 pontos em Grau Máximo 5 e 4 pontos em Grau 4 — foi justamente na **mediação de segurança no servidor** e na **governança operacional**, que nossos especialistas técnicos vão demonstrar agora."*

---

### Bloco 4 — Certificado de Controle Interno, Custo-Benefício Final e Encerramento (2 minutos · Slides 11 e 12)

> *"Consolidando o diagnóstico no nosso **Relatório de Redução de Custos**, estimamos de forma conservadora que fechar essas brechas evita cerca de **R\$ 2.765 por mês** em perdas diretas com pedidos adulterados, abuso de cupons, retrabalho de conciliação e paradas sem backup — mais de **R\$ 31 mil ao ano**, sem contar o risco jurídico de LGPD.*
>
> *O melhor dado para a gestão de vocês é o custo-benefício: como a arquitetura já é limpa, todo o pacote de correção leva cerca de **22 horas de desenvolvimento** (~R\$ 1.760). Somando o investimento da auditoria e das melhorias, o **payback é de apenas 50 dias**.*
>
> *Por isso, no nosso **Certificado de Controle Interno**, em face dos 4 controles de risco muito forte em segurança lógica, regras financeiras e confidencialidade, certificamos que o ambiente encontra-se hoje em **Má Condição para operação comercial aberta com dados reais** — porém **plenamente saneável no curto prazo**. Recomendamos atacar imediatamente a Onda 1 (ativar 2FA, backup testado no banco, fechar as rotas de API/JWT e renomear o `.github`) e nos colocamos à disposição para debater cada alternativa com a equipe da Açaí do Vale. Muito obrigado!"*
