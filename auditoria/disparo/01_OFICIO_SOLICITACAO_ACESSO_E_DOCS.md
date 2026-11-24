# Ofício de Solicitação de Acesso, Entrevista e Documentação — Auditoria SASI

**Para:** Equipe da Empresa *Açaí do Vale* (A/C: Gabriel Castro — Product Lead, Pávila Cardoso — Arquitetura/BD e Ana Clara Azevedo — DevOps)  
**De:** Equipe de Auditoria de Sistemas — Líder: **Augusto Henrique (P1)** | Coord. Entrevistas/Docs: **Ana Júlia Silveira e Maria Eduarda Silveira (P6)**  
**Data:** 24/11/2026 | **Prazo Solicitado de Retorno Inicial:** Hoje, o quanto antes

---

Prezados(as),

Iniciamos a auditoria de controles internos do sistema **Açaí do Vale** (TPIII). Para cumprirmos as etapas metodológicas de levantamento, entrevista, visita *in loco* e simulação de dados (*test deck*) previstas na disciplina, solicitamos:

### 1. Acesso ao Sistema para Simulação (*Test Deck*) e Análise de Telas/Relatórios
- **URL ativa** da aplicação (Vercel ou ambiente homologado em execução hoje);
- **01 credencial de Cliente** (`isAdmin = false`) e **01 credencial de Administrador** (`isAdmin = true`);
- **Template `.env.local.example`** (referenciado no `README.md`, mas ausente no repositório, sem chaves reais).

### 2. Documentação Complementar do Ambiente
- **Diagrama de Fluxo de Dados (DFD)** e **Dicionário de Dados**, caso existam fora da pasta `/docs` (na ausência, validaremos durante a entrevista o DFD elaborado pela nossa equipe);
- **Evidência/descrição da rotina de Backup** do banco PostgreSQL (Neon/Docker) e relação de quem detém permissão de administrador no GitHub, Vercel e Neon.

### 3. Confirmação de Agenda de Hoje (24/11)
1. **Questionário à Distância** (`02_QUESTIONARIO_CONTROLES_INTERNOS.md`): preenchimento remoto pelos responsáveis técnicos hoje;
2. **Entrevista no Ambiente Computacional + Visita *In Loco*** (duração total: **25 minutos**, conduzidas por **Ana Júlia Silveira** e **Maria Eduarda Silveira**): confirmação da melhor janela hoje.

Atenciosamente,  
**Augusto Henrique** (Líder da Auditoria) & Equipe SASI
