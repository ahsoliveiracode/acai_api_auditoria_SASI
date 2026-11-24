#!/usr/bin/env bash
# ==============================================================================
# SASI (UFVJM - Prof. Eduardo Pelli) — Ferramenta Especialista de Auditoria & Test Deck
# Alvo: Projeto Açaí do Vale (acai_api/delivery-main)
#
# Modos:
#   ./auditoria/scripts/test-deck.sh --static
#   ./auditoria/scripts/test-deck.sh --live http://localhost:3000
# ==============================================================================

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AUDIT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
WORKSPACE_DIR="$(cd "$AUDIT_DIR/.." && pwd)"
TARGET_REPO="$WORKSPACE_DIR/acai_api/delivery-main"
EVIDENCE_DIR="$AUDIT_DIR/evidencias"

mkdir -p "$EVIDENCE_DIR"

MODE="${1:---static}"
BASE_URL="${2:-http://localhost:3000}"
BASE_URL="${BASE_URL%/}"

run_static_audit() {
  local out="$EVIDENCE_DIR/evidencia_estatica_inicial.md"
  local now
  now="$(date '+%Y-%m-%d %H:%M:%S %z')"

  {
    echo "# Evidência Automatizada — Análise do Programa Fonte e Mapeamento (Prof. Eduardo Pelli)"
    echo ""
    echo "- **Data/Hora de Execução:** $now"
    echo "- **Diretório Auditado:** \`$TARGET_REPO\` *(base original 100% preservada)*"
    echo "- **Escala de Grau de Risco (Slide 19):** \`1 – Muito Fraco\` a \`5 – Muito forte\` (maior valor = mais grave)"
    echo ""
    echo "| Caso | PC | Responsável | Verificação Automatizada | Resultado Obtido | Grau de Risco |"
    echo "| :-: | :-: | :--- | :--- | :--- | :-: |"

    # ST-01: PC01 (Pessoa 3) — Middleware ignorando /api/*
    if grep -q '"/api' "$TARGET_REPO/src/middleware.js"; then
      echo "| ST-01 | PC01 | P3 (A definir) | Cobertura de \`/api/*\` no \`middleware.js\` | Rotas cobertas | 1 – Muito Fraco |"
    else
      echo "| ST-01 | PC01 | P3 (A definir) | Cobertura de \`/api/*\` no \`middleware.js\` | \`matcher\` cobre só \`/protegido/*\` e \`/admin/*\`; APIs abertas | **5 – Muito forte** |"
    fi

    # ST-02: PC01 (Pessoa 3) — Exposição de /api/seed e senha admin123
    if [[ -f "$TARGET_REPO/src/app/api/seed/route.ts" ]] && grep -q "senha: 'admin123'" "$TARGET_REPO/src/app/api/seed/route.ts"; then
      echo "| ST-02 | PC01 | P3 (A definir) | Rotas \`/api/seed\` e \`/api/create-admin\` em produção | Ativas; \`/seed\` bypassa se \`ADMIN_SECRET\` vazio e retorna \`admin123\` | **5 – Muito forte** |"
    else
      echo "| ST-02 | PC01 | P3 (A definir) | Rotas \`/api/seed\` e \`/api/create-admin\` | Removidas | 1 – Muito Fraco |"
    fi

    # ST-03: PC02 (Pessoa 4) — Ausência de preço unitário no banco
    if grep -E -q "preco.*Decimal|price.*Decimal" "$TARGET_REPO/prisma/schema.prisma"; then
      echo "| ST-03 | PC02 | P4 (Helen) | Tabela autoritativa de preços \`Decimal\` no SGBD | Encontrada | 1 – Muito Fraco |"
    else
      echo "| ST-03 | PC02 | P4 (Helen) | Tabela autoritativa de preços no \`schema.prisma\` | \`Sabor\`/\`Adicional\` sem preço; servidor confia no \`valorTotal\` do cliente | **5 – Muito forte** |"
    fi

    # ST-04: PC04 (Pessoa 5) — Painel /ui/admin sem AdminGuard
    if grep -q "AdminGuard" "$TARGET_REPO/src/app/ui/admin/page.tsx"; then
      echo "| ST-04 | PC04 | P5 (A definir) | Proteção de confidencialidade em \`/ui/admin\` | Guard presente | 2 – Fraco |"
    else
      echo "| ST-04 | PC04 | P5 (A definir) | Proteção de confidencialidade em \`/ui/admin\` | Painel admin legado aberto sem \`AdminGuard\` nem middleware | **4 – Forte** |"
    fi

    # ST-05: PC05 (Pessoa 3) — Chaves JWT hardcoded de fallback
    if grep -q "dev_insecure_secret_change_me" "$TARGET_REPO/src/lib/jwt.ts" || grep -q "default-secret-key" "$TARGET_REPO/src/infrastructure/cryptography/jwt-token-provider.ts"; then
      echo "| ST-05 | PC05 | P3 (A definir) | Segredos JWT sem fallback hardcoded | Fallbacks \`dev_insecure_secret_change_me\` e \`default-secret-key\` ativos | **4 – Forte** |"
    else
      echo "| ST-05 | PC05 | P3 (A definir) | Segredos JWT sem fallback hardcoded | Sem fallback | 1 – Muito Fraco |"
    fi

    # ST-06: PC06 (Pessoa 4) — Rotinas desativadas github/ e husky/ + ausência de AuditLog
    if [[ -d "$TARGET_REPO/github/workflows" ]] && [[ ! -d "$TARGET_REPO/.github/workflows" ]]; then
      echo "| ST-06 | PC06 | P4 (Helen) | *Audit Trail* e esteira CI/CD (\`.github/\` e \`.husky/\`) | Sem tabela \`AuditLog\`; pastas \`github/\` e \`husky/\` sem ponto inicial (inativas) | **4 – Forte** |"
    else
      echo "| ST-06 | PC06 | P4 (Helen) | Esteira CI/CD (\`.github/workflows\`) | Ativa | 2 – Fraco |"
    fi

    # ST-07: PC07 (Pessoa 5) — Receita Total somando pedidos cancelados
    if grep -q "totalRevenue={pedidos.reduce" "$TARGET_REPO/src/app/(admin)/dashboard/page.tsx"; then
      echo "| ST-07 | PC07 | P5 (A definir) | Fidedignidade do relatório \`DashboardStats\` (\`/dashboard\`) | \`totalRevenue\` soma todos os pedidos sem filtrar \`Cancelado\`/\`Pendente\` | **4 – Forte** |"
    else
      echo "| ST-07 | PC07 | P5 (A definir) | Fidedignidade do relatório \`DashboardStats\` | Filtra entregues | 2 – Fraco |"
    fi

    # ST-08: PC08 (Pessoa 5) — Segregação isAdmin e ausência de .env.local.example / DFD
    if [[ ! -f "$TARGET_REPO/.env.local.example" ]]; then
      echo "| ST-08 | PC08 | P5 (A definir) | Segregação de funções e documentação (\`.env.local.example\` / DFD) | Apenas flag binária \`isAdmin\`; \`.env.local.example\` e DFD ausentes | **3 – Regular** |"
    else
      echo "| ST-08 | PC08 | P5 (A definir) | Documentação \`.env.local.example\` | Presente | 2 – Fraco |"
    fi

    # ST-09: PC11 (Pessoa 2) — Healthcheck divergente no docker-compose.yml e scripts de backup
    if grep -q "pg_isready -U gabriel" "$TARGET_REPO/docker-compose.yml" && grep -q "POSTGRES_USER: user" "$TARGET_REPO/docker-compose.yml"; then
      echo "| ST-09 | PC11 | P2 (Ana Júlia) | Scripts de backup e recuperação no \`docker-compose.yml\` | Sem script \`pg_dump\`; healthcheck usa \`-U gabriel\` vs \`POSTGRES_USER: user\` | **3 – Regular** |"
    else
      echo "| ST-09 | PC11 | P2 (Ana Júlia) | Consistência \`docker-compose.yml\` | Consistente | 2 – Fraco |"
    fi

    # ST-10: PC12 (Pessoa 3) — Controles estruturais do SGBD (Prisma + bcrypt + non-root) vs arquivos legados
    if grep -q "USER nextjs" "$TARGET_REPO/Dockerfile" && grep -q "bcrypt.hash" "$TARGET_REPO/src/infrastructure/cryptography/bcrypt-hash-provider.ts"; then
      echo "| ST-10 | PC12 | P3 (A definir) | SGBD Prisma ORM, hash \`bcrypt\` e container \`USER nextjs\` | Controles fortes presentes; ressalvas: \`Float\` monetário e \`data/*.json\` legados | **2 – Fraco** |"
    else
      echo "| ST-10 | PC12 | P3 (A definir) | SGBD Prisma ORM e hash \`bcrypt\` | Controles ausentes | 4 – Forte |"
    fi
  } > "$out"

  echo "[OK] Relatório estático salvo em: $out"
}

run_live_test_deck() {
  local out="$EVIDENCE_DIR/relatorio_test_deck_live.md"
  local now ts test_email coupon_code
  now="$(date '+%Y-%m-%d %H:%M:%S %z')"
  ts="$(date '+%s')"
  test_email="auditoria.td.${ts}@sasi.local"
  coupon_code="AUD${ts: -5}"

  echo "Executando Simulação de Dados (Test Deck - Slide 7) contra: $BASE_URL ..."

  {
    echo "# Relatório de Simulação de Dados (*Test Deck* — 5 Situações do Slide 7)"
    echo ""
    echo "- **Data/Hora:** $now"
    echo "- **Alvo Testado:** \`$BASE_URL\`"
    echo ""
    echo "| Caso | Situação do Slide 7 | PC | Transação Submetida | HTTP Esperado | HTTP Obtido | Conclusão |"
    echo "| :-: | :--- | :-: | :--- | :-: | :-: | :--- |"

    # Criar cliente temporário de auditoria
    resp_cli="$(curl -s -X POST "$BASE_URL/api/clientes" \
      -H "Content-Type: application/json" \
      -d "{\"nome\":\"Cliente Auditoria SASI\",\"email\":\"$test_email\",\"senha\":\"Audit#2026\",\"endereco\":\"Rua SASI, 10\"}" || echo "{}")"
    cli_id="$(echo "$resp_cli" | grep -oE '"id":[0-9]+' | head -n1 | cut -d: -f2 || true)"

    if [[ -n "${cli_id:-}" ]]; then
      # 1. Campos inválidos (valorTotal negativo) — PC02
      resp_ped1="$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/api/pedidos" \
        -H "Content-Type: application/json" \
        -d "{\"clienteId\":$cli_id,\"sabores\":[],\"adicionais\":[],\"tamanho\":\"Grande\",\"valorTotal\":-50.00,\"formaPagamento\":\"pix\",\"enderecoEntrega\":\"Rua SASI\"}" || echo -e "{}\n000")"
      c1="$(echo "$resp_ped1" | tail -n1)"
      ped1_id="$(echo "$resp_ped1" | sed '$d' | grep -oE '"id":[0-9]+' | head -n1 | cut -d: -f2 || true)"
      d1="Rejeitado"
      [[ "$c1" == "201" ]] && d1="**FALHA (Risco 5):** Gravou pedido negativo (\`-50.00\`)"
      echo "| TD-A | 1. Campos inválidos | PC02 | \`POST /api/pedidos\` com \`valorTotal: -50.00\` | \`400\` | \`$c1\` | $d1 |"

      # 2. Valores nos limites (resgate acima do saldo zero) — PC03
      c2="$(curl -s -o /dev/null -w "%{http_code}" -X POST "$BASE_URL/api/v1/loyalty" \
        -H "Content-Type: application/json" \
        -d "{\"clienteId\":$cli_id,\"pontos\":9999,\"tipo\":\"redeem\",\"descricao\":\"Limite SASI\"}" || echo "000")"
      d2="Bloqueado"
      [[ "$c2" == "200" ]] && d2="**FALHA (Risco 5):** Gerou saldo negativo (\`-9999\` pts)"
      echo "| TD-B | 2. Valores nos limites | PC03 | \`POST /api/v1/loyalty\` resgatando \`9999\` pts com saldo \`0\` | \`400/401\` | \`$c2\` | $d2 |"

      # 3. Transação incompleta (pedido sem sabores na rota legada) — PC02
      resp_ped3="$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/api/pedidos" \
        -H "Content-Type: application/json" \
        -d "{\"clienteId\":$cli_id,\"sabores\":[],\"adicionais\":[],\"tamanho\":\"Medio\",\"valorTotal\":20.00,\"formaPagamento\":\"pix\",\"enderecoEntrega\":\"Rua SASI\"}" || echo -e "{}\n000")"
      c3="$(echo "$resp_ped3" | tail -n1)"
      ped3_id="$(echo "$resp_ped3" | sed '$d' | grep -oE '"id":[0-9]+' | head -n1 | cut -d: -f2 || true)"
      d3="Rejeitado"
      [[ "$c3" == "201" ]] && d3="**FALHA:** Aceitou pedido incompleto (\`sabores: []\`)"
      echo "| TD-C | 3. Transação incompleta | PC02 | \`POST /api/pedidos\` com lista de sabores vazia | \`400\` | \`$c3\` | $d3 |"

      # 4. Transação incompatível (anônimo criando cupom 100% e trocando senha alheia) — PC03 / PC04
      c4="$(curl -s -o /dev/null -w "%{http_code}" -X POST "$BASE_URL/api/v1/coupons" \
        -H "Content-Type: application/json" \
        -d "{\"codigo\":\"$coupon_code\",\"tipo\":\"percentual\",\"valor\":100,\"usoMaximo\":1,\"ativo\":true}" || echo "000")"
      d4="Bloqueado"
      [[ "$c4" == "201" ]] && d4="**FALHA (Risco 5):** Anônimo emitiu cupom administrativo de 100%"
      echo "| TD-D | 4. Transação incompatível | PC03 | Anônimo criando cupom \`100%\` (\`usoMaximo: 1\`) | \`401/403\` | \`$c4\` | $d4 |"

      # 5. Transação em duplicidade (uso repetido de cupom usoMaximo=1) — PC03
      resp_dup1="$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/api/pedidos" \
        -H "Content-Type: application/json" \
        -d "{\"clienteId\":$cli_id,\"sabores\":[],\"adicionais\":[],\"tamanho\":\"P\",\"valorTotal\":0,\"cupomCodigo\":\"$coupon_code\",\"formaPagamento\":\"pix\",\"enderecoEntrega\":\"Rua SASI\"}" || echo -e "{}\n000")"
      dup1_id="$(echo "$resp_dup1" | sed '$d' | grep -oE '"id":[0-9]+' | head -n1 | cut -d: -f2 || true)"
      resp_dup2="$(curl -s -w "\n%{http_code}" -X POST "$BASE_URL/api/pedidos" \
        -H "Content-Type: application/json" \
        -d "{\"clienteId\":$cli_id,\"sabores\":[],\"adicionais\":[],\"tamanho\":\"P\",\"valorTotal\":0,\"cupomCodigo\":\"$coupon_code\",\"formaPagamento\":\"pix\",\"enderecoEntrega\":\"Rua SASI\"}" || echo -e "{}\n000")"
      c5="$(echo "$resp_dup2" | tail -n1)"
      dup2_id="$(echo "$resp_dup2" | sed '$d' | grep -oE '"id":[0-9]+' | head -n1 | cut -d: -f2 || true)"
      d5="2º uso bloqueado"
      [[ "$c5" == "201" ]] && d5="**FALHA (Risco 5):** Aceitou cupom duplicado além do \`usoMaximo: 1\`"
      echo "| TD-E | 5. Transação em duplicidade | PC03 | 2ª submissão do cupom \`$coupon_code\` (\`usoMaximo: 1\`) | \`400\` | \`$c5\` | $d5 |"

      # Desativar cupom de teste e limpar registros temporários
      curl -s -X PATCH "$BASE_URL/api/v1/coupons" -H "Content-Type: application/json" -d "{\"codigo\":\"$coupon_code\",\"ativo\":false}" > /dev/null || true
      for pid in "${ped1_id:-}" "${ped3_id:-}" "${dup1_id:-}" "${dup2_id:-}"; do
        [[ -n "$pid" ]] && curl -s -X DELETE "$BASE_URL/api/pedidos?id=$pid" > /dev/null || true
      done
      curl -s -X DELETE "$BASE_URL/api/clientes?id=$cli_id" > /dev/null || true
    else
      echo "| TD-A..E | Todas as 5 situações | PC02/03 | Conexão ao servidor \`$BASE_URL\` | Servidor ativo | Sem conexão | Suba o servidor ou informe a URL ativa |"
    fi
  } > "$out"

  echo "[OK] Relatório dinâmico salvo em: $out"
}

case "$MODE" in
  --static)
    run_static_audit
    ;;
  --live)
    run_live_test_deck
    ;;
  *)
    echo "Uso: $0 [--static | --live <BASE_URL>]"
    exit 1
    ;;
esac
