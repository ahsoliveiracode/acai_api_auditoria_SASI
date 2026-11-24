# Formulário Oficial de Visita *In Loco* (5 Passos — Slide 9, *Técnicas de Auditoria*)

**Auditoras Responsáveis (Pessoa 2):** Ana Júlia Silveira e Maria Eduarda Silveira  
**Pontos de Controle Auditados:** `PC09` (Ambiente Físico — **Obrigatório**), `PC10` (Microinformática e Contingência) e `PC11` (Armazenamento e Backup)

---

## Passo 1 e Passo 3 — Agendamento e Identificação Formal da Visita
- **Data e Hora Agendadas:** `24/11/2026 — Início: ___:___ | Término: ___:___`
- **Local / Instalação Visitada:** `______________________________________________________________`
- **Auditores Presentes (Nomes):** `Ana Júlia Silveira, Maria Eduarda Silveira, ___________________`
- **Pessoal de Sistemas/Operação Recebedor (Nomes e Funções):** `_________________________________`

---

## Passo 2 — Anotação de Procedimentos Verificados e Acontecimentos Observados

*(Escala de **Grau de Risco**: `1 – Muito Fraco` | `2 – Fraco` | `3 – Regular` | `4 – Forte` | `5 – Muito forte`)*

### A. Segurança Física e Ambiental do Centro de Computação / Operação (`PC09` — Slide 24, Deck 1)

| Cód. | Item Inspecionado | Constatação Presencial | Grau de Risco (1–5) | Acontecimentos / Detalhes Anotados |
| :-: | :--- | :-: | :-: | :--- |
| **VF-01** | **Acesso Físico:** Controle de entrada no recinto (portaria, chave, crachá ou circulação livre de terceiros junto às máquinas). | [ ] Adequado<br>[ ] Falho | | |
| **VF-02** | **Infraestrutura Elétrica e Hidráulica:** Uso de no-break/estabilizador, aterramento, cabos protegidos e ausência de infiltrações/líquidos próximos aos equipamentos. | [ ] Adequado<br>[ ] Falho | | |
| **VF-03** | **Climatização e Sinistros:** Ventilação/ar-condicionado, proteção contra calor/poeira/queda (Slide 5, Deck 1) e disponibilidade de extintor contra incêndio no setor. | [ ] Adequado<br>[ ] Falho | | |
| **VF-04** | **Segurança Física de Relatórios e Telas:** Posicionamento dos monitores (evitando leitura de endereços/receita por estranhos) e descarte adequado de impressos/comandas. | [ ] Adequado<br>[ ] Falho | | |

### B. Microcomputadores, Rede de Comunicação e Contingência (`PC10` — Slides 18 e 24, Deck 1)

| Cód. | Item Inspecionado | Constatação Presencial | Grau de Risco (1–5) | Acontecimentos / Detalhes Anotados |
| :-: | :--- | :-: | :-: | :--- |
| **VF-05** | **Segurança Física e Lógica dos Terminais:** Bloqueio automático de tela por senha quando o operador se afasta da sessão `/dashboard` ou do terminal com `.env` aberto. | [ ] Adequado<br>[ ] Falho | | |
| **VF-06** | **Rede de Comunicação de Dados:** Segregação entre a rede Wi-Fi/cabeada usada pelos micros de administração e a rede pública de visitantes/clientes. | [ ] Adequado<br>[ ] Falho | | |
| **VF-07** | **Plano de Contingência:** Existência de procedimento operacional pronto caso caia a internet, o Docker local ou a Vercel durante o expediente. | [ ] Adequado<br>[ ] Falho | | |

### C. Dispositivos de Armazenamento e Backup (`PC11` — Slides 5 e 22, Deck 1)

| Cód. | Item Inspecionado | Constatação Presencial | Grau de Risco (1–5) | Acontecimentos / Detalhes Anotados |
| :-: | :--- | :-: | :-: | :--- |
| **VF-08** | **Guarda de Mídias e Cópias de Backup:** Localização segura de dumps/backups do banco (nuvem isolada/mídia protegida) fora da própria máquina de operação. | [ ] Adequado<br>[ ] Falho | | |
| **VF-09** | **Demonstração de Recuperação:** Capacidade da equipe de demonstrar onde ficam os snapshots/backups do Neon ou volume `postgres_data` e última data salva. | [ ] Adequado<br>[ ] Falho | | |

---

## Passo 4 — Análise da Documentação Obtida Durante a Visita
- Documentos/telas exibidos pela equipe auditada durante a visita (ex.: painel Neon, painel Vercel, configurações do equipamento):
  `__________________________________________________________________________________________`

---

## Passo 5 — Emissão de Opinião Técnica da Visita (Para envio a José Inácio de Moraes Santos — P7)
- **Grau de Risco Consolidado:** `PC09 = ___` | `PC10 = ___` | `PC11 = ___`
- **Parecer Sintético das Auditoras de Campo (Pessoa 2):**
  `__________________________________________________________________________________________`
  `__________________________________________________________________________________________`
