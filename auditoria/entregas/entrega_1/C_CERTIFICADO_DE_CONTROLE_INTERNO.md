# Certificado de Controle Interno — Parecer do Auditor (Produto 3.2)

**Responsável pela Emissão:** Augusto Henrique (Pessoa 1 — Líder da Equipe de Auditoria)  
**Entidade Auditada:** Empresa *Açaí do Vale* — Sistema de Delivery Digital (`acai_api`, **Grupo E**)  
**Data de Emissão:** 25 de novembro de 2026

---

## CERTIFICADO DE CONTROLE INTERNO

**Aos Gestores e Responsáveis Técnicos da Empresa Açaí do Vale,**

Conduzimos uma auditoria de sistemas sobre o ambiente computacional, a documentação técnica, o modelo de banco de dados, as interfaces de usuário, os relatórios gerenciais e as rotinas de processamento do **Sistema de Delivery Digital Açaí do Vale**. Nossos exames abrangeram **12 (doze) pontos de controle críticos** (`PC01` a `PC12`), contemplando obrigatoriamente o ambiente físico/infraestrutura, segurança lógica, teleprocessamento, banco de dados, sistema em operação e funções organizacionais, mediante aplicação combinada de questionário estruturado junto aos 8 integrantes do Grupo E, análise estática do código-fonte e simulação de dados (*Test Deck*) em ambiente local isolado e descartável.

### 1. Aspectos Positivos
Cumpre destacar os méritos de engenharia constatados na base avaliada: a organização modular de parte do núcleo segundo princípios de *Clean Architecture* e *DDD*, o emprego consistente do *Prisma ORM* com integridade referencial e unicidade verificadas em banco PostgreSQL (mitigando injeções SQL tradicionais), o armazenamento de senhas de clientes com *hash* criptográfico `bcrypt`, a execução do container de aplicação com usuário não privilegiado (*non-root*) e a rejeição adequada de chamadas sem segredo nos testes locais de `/api/seed` e `/api/create-admin`.

### 2. Síntese da Avaliação Frente aos Parâmetros de Controle Interno
Confrontando as evidências obtidas com os **oito parâmetros clássicos de Controle Interno**, registramos as seguintes conclusões globais:

1. **Segurança Lógica (`Insuficiente — Risco Muito Forte`):** As rotas `/api/*` e `/api/v1/*` não passam por controle de sessão ou perfil administrativo no servidor (`middleware.js` restrito a prefixos não utilizados pelas APIs), permitindo leitura, alteração de status e exclusão anônima de registros; adicionalmente, o endpoint `/api/jwt/login` emitiu tokens JWT válidos sem exigir senha, apoiado em segredo de *fallback* previsível, e as rotas de *seed* e criação de administrador permanecem ativas em produção.
2. **Obediência às Políticas e Regras de Negócio (`Insuficiente — Risco Muito Forte`):** Diferentemente da percepção declarada pela equipe de que o cálculo estaria protegido no *backend*, o *Test Deck* comprovou que o servidor persiste diretamente o `valorTotal` e o desconto enviados pelo navegador (aceitando pedidos de R\$ −50,00 e descontos sem cupom), além de permitir criação anônima de cupons de 100%, reuso de cupons únicos/inativos e geração de saldo negativo no programa de fidelidade.
3. **Confidencialidade e Obediência à Legislação em Vigor — LGPD (`Insuficiente — Risco Forte`):** A proteção visual do painel administrativo ocorre apenas no navegador (`AdminGuard`), coexistindo com o painel `/ui/admin` desprotegido e com a exposição pública, em `GET /api/pedidos`, de nomes, e-mails, endereços residenciais, perfil `isAdmin` e *hashes* de senha dos clientes.
4. **Fidelidade da Informação em Relação ao Dado (`Insuficiente — Risco Forte`):** Inexiste trilha cronológica de auditoria (*Audit Trail*) capaz de identificar autor e data/hora em mudanças de status ou exclusões físicas de pedidos, e os cartões financeiros do *Dashboard* somam pedidos sem segregar cancelamentos, períodos ou conciliação efetiva de pagamentos.
5. **Segurança Física, Continuidade e Backup (`Parcial/Deficiente — Risco Regular a Forte`):** Embora a hospedagem em nuvem (Vercel) transfira a guarda física de servidores ao provedor, os 8 contribuintes acessam os ambientes sem papéis formais, sem revisão obrigatória na *branch* principal e sem 2FA obrigatório; agrava o quadro a confirmação de inexistência de backup formalizado e de testes de restauração do banco de dados.
6. **Eficiência e Eficácia (`Parcial — Risco Fraco a Regular`):** O fluxo funcional atende à operação básica de venda, mas apresenta sobreposição de telas administrativas e de login, uso de ponto flutuante (`Float`) em campos monetários, suíte Jest com 7 de 14 testes falhando e esteira de CI/CD inativa devido à nomenclatura incorreta dos diretórios `github/` e `husky/` (sem o ponto inicial).

### 3. Opinião Global da Auditoria (Certificação)
Com fundamento nas evidências documentais e funcionais colhidas, que apontaram **4 pontos de controle em Grau de Risco 5 (Muito Forte)** e **4 pontos em Grau de Risco 4 (Forte)**, certificamos que o ambiente computacional do sistema **Açaí do Vale** encontra-se, na presente data, em **MÁ CONDIÇÃO** em relação aos parâmetros de controle interno exigidos para operação comercial aberta com dados e transações financeiras reais.

Ressaltamos, em caráter construtivo, que a base tecnológica escolhida pela empresa é sólida e que a totalidade das vulnerabilidades críticas decorre de lacunas pontuais de mediação no servidor e governança operacional, passíveis de **saneamento integral com baixo esforço estimado (~22 horas técnicas)** e elevado retorno financeiro (*payback* inferior a dois meses). Recomendamos a priorização imediata das medidas das Ondas 1 e 2 no Plano Diretor de Informática e a realização de **auditoria de acompanhamento** após a implantação das soluções propostas.

Diamantina/MG, 25 de novembro de 2026.

---

**Augusto Henrique** — *Auditor Líder (Planejamento, Supervisão e Parecer)*  
Em conjunto com o Corpo Técnico de Auditoria: *Ana Júlia Silveira, Maria Eduarda Silveira, Alisson de Souza Rocha, Helen Gonçalves, Rafael Gomes e José Inácio de Moraes Santos*.