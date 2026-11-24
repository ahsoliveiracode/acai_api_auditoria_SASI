# Caderno da Pessoa 2 — Ana Júlia Silveira (Ambiente Físico, Microinformática e Backup)

**Papel na Auditoria:** Auditora de Segurança Física/Ambiental, Microcomputadores e Rotinas de Backup  
**Pontos sob sua Responsabilidade (3 PCs):**
- **`PC09` (Grau de Risco: 3 – Regular · OBRIGATÓRIO):** Segurança Física e Ambiental do Centro de Computação / Local de Operação
- **`PC10` (Grau de Risco: 3 – Regular):** Ambiente de Microinformática, Terminais de Operação e Plano de Contingência
- **`PC11` (Grau de Risco: 3 – Regular):** Armazenamento, Rotinas de Backup e Recuperação de Transações no SGBD

**Orçamento de Tempo:** **5h00** (Revisão do Questionário Bloco 1: 30 min | Visita *In Loco*: 1h30 | Análise de Infra/Backup: 1h30 | Redação dos 3 PCs para a Pessoa 7: 1h30)  
**Prazo Interno para Entregar à Pessoa 7:** Hoje, até **17h00**

---

## 1. Seus Procedimentos Passo a Passo (Conforme Slides do Prof. Eduardo Pelli)

1. **Conduzir a Visita *In Loco* (Slide 9, Deck 2):**
   - Use o formulário pronto em `auditoria/disparo/03_CHECKLIST_VISITA_IN_LOCO.md`.
   - **Obrigatório anotar (exigência do slide!):** data, hora de início/fim, nomes das pessoas visitadas, procedimentos observados e acontecimentos durante a visita!
2. **Analisar Respostas do Bloco 1 do Questionário (Questões 01 a 05):**
   - Receber de **Maria Eduarda — Duda (P6)** as respostas sobre inventário de micros, proteção elétrica, backup no Neon/Docker, teste de *restore* e plano de contingência.
3. **Inspeção Técnica de Infraestrutura já Levantada no Repositório (Use nos seus achados!):**
   - No arquivo `acai_api/delivery-main/docker-compose.yml`:
     - Porta `5432:5432` do PostgreSQL exposta diretamente para a máquina/rede local com credencial fraca (`POSTGRES_USER: user` / `POSTGRES_PASSWORD: password`);
     - `healthcheck` na linha 17 testa `pg_isready -U gabriel` (usuário diferente de `user`), prejudicando a recuperação limpa do container;
     - Não há script de backup automatizado (`pg_dump` agendado) na pasta `scripts/` (`scripts/` só possui `setup-dev.sh`, `create-admin.ts` e `create-admin-prod.sh`), dependendo 100% da configuração padrão da conta gratuita do Neon em produção;
     - Não existe documento de **Plano de Contingência** na pasta `docs/`.

---

## 2. Modelo Pronto de Entrega para Enviar à Pessoa 7 até 17h00

*(Copie, preencha os dados reais observados na Visita In Loco e envie para a Pessoa 7 consolidar no PDF)*

### Ponto de Controle `PC09` — Segurança Física e Ambiental do Ambiente Computacional *(Grau de Risco: `[3 - Regular ou ajustar após visita]`)*
- **Técnicas Aplicadas:** Visita *in loco* (em 24/11/2026 às `___:___`, acompanhada por `_________`) e Questionário à distância (Q02).
- **Análise Realizada:** Verificou-se a infraestrutura elétrica, ventilação, exposição a calor/poeira/umidade/queda, restrição de acesso físico ao local onde operam os equipamentos e posicionamento visual das telas administrativas (Slide 5 e Slide 24, Deck 1).
- **Problemas Encontrados:** `[Descrever o que viu na visita: ex.: ausência de no-break dedicado para o equipamento/roteador, livre circulação de terceiros próximo às estações, telas administrativas visíveis lateralmente sem filtro de privacidade e inexistência de controle formal de descarte de anotações físicas]`.
- **Sugestões de Melhoria:** Instalar proteção elétrica (no-break/filtro de linha) nos equipamentos de caixa/operação, posicionar o terminal do `/dashboard` em balcão restrito fora do campo visual de clientes e restringir fisicamente o acesso às estações de trabalho.

### Ponto de Controle `PC10` — Ambiente de Microinformática, Terminais e Plano de Contingência *(Grau de Risco: `[3 - Regular ou ajustar]`)*
- **Técnicas Aplicadas:** Visita *in loco*, Questionário aos usuários de microcomputadores (Q01 e Q05 — Slide 19, Deck 1) e inspeção de configuração de rede/Docker.
- **Análise Realizada:** Avaliou-se o inventário e configuração dos microcomputadores da equipe/operação, o bloqueio lógico de tela em sessões administrativas, o isolamento da rede Wi-Fi e a existência de Plano de Contingência operacional.
- **Problemas Encontrados:** Inexistência de inventário formal de estações e de política padronizada de bloqueio automático de tela em até 3 minutos; porta do banco local (`5432`) exposta no `docker-compose.yml`; `[complementar com rede Wi-Fi observada]`; e ausência total de Plano de Contingência documentado caso a Vercel ou o link de internet fiquem indisponíveis em horário de pico.
- **Sugestões de Melhoria:** Implantar bloqueio automático por senha nas estações administrativas, segregar a rede Wi-Fi operacional da rede de clientes, restringir o bind do PostgreSQL local a `127.0.0.1:5432` e instituir Plano de Contingência operacional (formulário offline/planilha padronizada com posterior digitação controlada).

### Ponto de Controle `PC11` — Armazenamento, Rotinas de Backup e Recuperação de Quedas *(Grau de Risco: `[3 - Regular ou 4 - Forte se não houver backup]`)*
- **Técnicas Aplicadas:** Questionário à distância (Q03 e Q04), inspeção da pasta `scripts/` e verificação na Visita *In Loco*.
- **Análise Realizada:** Verificou-se a política de cópias de segurança do banco PostgreSQL, guarda segura de mídias/dumps, consistência do `healthcheck` de recuperação de containers e validação entre a última transação processada e a última transação recuperada em caso de queda (Slide 22, Deck 1).
- **Problemas Encontrados:** Ausência de script automatizado de `pg_dump`/retenção externa no repositório, divergência no `healthcheck` do `docker-compose.yml` (`-U gabriel` vs `user`) e ausência de evidência documentada de testes periódicos de restauração (*restore*) validando a recuperação da última transação. `[Complementar com resposta da Q03/Q04]`.
- **Sugestões de Melhoria:** Automatizar rotina diária de `pg_dump` criptografado em armazenamento em nuvem segregado (além do PITR nativo do Neon), corrigir o `healthcheck` do Docker e realizar simulado trimestral documentado de *restore* conferindo o último `Pedido.id` gravado.
