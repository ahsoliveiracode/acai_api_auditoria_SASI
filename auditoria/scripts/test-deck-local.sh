#!/usr/bin/env bash
# ==============================================================================
# SASI (UFVJM) — Test Deck em ambiente local isolado (Pessoa 4 — PC02, PC03, PC06)
# Sistema auditado: Açaí do Vale (delivery-main, branch TPIII)
#
# Ferramenta complementar a auditoria/scripts/test-deck.sh, que permanece inalterado.
# Diferenças em relação ao script original:
#   - executa somente contra localhost/127.0.0.1 (recusa URLs remotas);
#   - não executa exclusões de limpeza (o banco de teste deve ser descartável);
#   - registra requisição, código HTTP, corpo da resposta e estado antes/depois;
#   - isola as variáveis de cada caso (TD-A usa sabor válido; TD-C isola a lista vazia);
#   - em TD-E, verifica o contador usosAtuais do cupom após cada submissão;
#   - mascara o campo "senha" nos registros.
#
# Uso:
#   ./auditoria/scripts/test-deck-local.sh http://localhost:3100
#
# Pré-requisitos: bash, curl e node (usado apenas para ler campos JSON).
# A aplicação deve estar conectada a um banco local descartável, com as
# migrações do projeto aplicadas (sabores id 1..3 e adicionais id 1..n).
# ==============================================================================

set -uo pipefail

BASE_URL="${1:-http://localhost:3100}"
BASE_URL="${BASE_URL%/}"

# Aceita somente http://localhost[:porta] ou http://127.0.0.1[:porta], sem caminho,
# credenciais (@) ou qualquer outro host. Impede execução contra ambientes publicados.
if [[ ! "$BASE_URL" =~ ^http://(localhost|127\.0\.0\.1)(:[0-9]{1,5})?$ ]]; then
  echo "Recusado: este script executa somente contra ambiente local (http://localhost[:porta] ou http://127.0.0.1[:porta])."
  exit 2
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EVIDENCE_DIR="$(cd "$SCRIPT_DIR/.." && pwd)/evidencias"
mkdir -p "$EVIDENCE_DIR"

STAMP="$(date '+%Y%m%d_%H%M%S')"
LOG="$EVIDENCE_DIR/P4_test_deck_local_log_${STAMP}.txt"
SUMMARY="$EVIDENCE_DIR/P4_test_deck_local_resumo_${STAMP}.md"
TS="$(date '+%s')"

HTTP_CODE=""
HTTP_BODY=""
ROWS=()

json_get() {
  # json_get '<json>' 'expr'  -> avalia expr sobre o objeto j (ex.: j.id, j[0].usosAtuais)
  node -e '
    let j; try { j = JSON.parse(process.argv[1]); } catch (e) { process.stdout.write(""); process.exit(0); }
    try { const v = eval(process.argv[2]); process.stdout.write(v === undefined || v === null ? "" : String(v)); }
    catch (e) { process.stdout.write(""); }
  ' "$1" "$2"
}

mask() { sed -E 's/("senha":")[^"]*"/\1***"/g'; }

req() {
  # req <ID> <METODO> <CAMINHO> [CORPO_JSON]
  local id="$1" method="$2" path="$3" body="${4:-}" raw
  if [[ -n "$body" ]]; then
    raw="$(curl -s -w $'\n%{http_code}' -X "$method" "$BASE_URL$path" -H 'Content-Type: application/json' -d "$body" || printf '\n000')"
  else
    raw="$(curl -s -w $'\n%{http_code}' -X "$method" "$BASE_URL$path" || printf '\n000')"
  fi
  HTTP_CODE="$(printf '%s' "$raw" | tail -n1)"
  HTTP_BODY="$(printf '%s' "$raw" | sed '$d')"
  {
    echo "------------------------------------------------------------------"
    echo "[$id] $(date '+%Y-%m-%d %H:%M:%S %z')"
    echo "REQUISICAO: $method $path"
    [[ -n "$body" ]] && echo "CORPO: $(printf '%s' "$body" | mask)"
    echo "HTTP: $HTTP_CODE"
    echo "RESPOSTA: $(printf '%s' "$HTTP_BODY" | mask | cut -c1-1500)"
  } >> "$LOG"
}

note() { echo "[$1] OBSERVACAO: $2" >> "$LOG"; }

row() {
  # row <ID> <Situação> <PC> <Entrada> <Esperado> <Obtido> <Controle>
  ROWS+=("| $1 | $2 | $3 | $4 | $5 | $6 | $7 |")
}

pontos_cliente() {
  req "$1" GET "/api/v1/loyalty"
  json_get "$HTTP_BODY" "(j.find(c => String(c.id) === '$2') || {}).pontosFidelidade"
}

usos_cupom() {
  req "$1" GET "/api/v1/coupons"
  json_get "$HTTP_BODY" "(j.find(c => c.codigo === '$2') || {}).usosAtuais"
}

{
  echo "REGISTRO BRUTO — TEST DECK LOCAL (PC02, PC03, PC06)"
  echo "Alvo: $BASE_URL"
  echo "Inicio: $(date '+%Y-%m-%d %H:%M:%S %z')"
} > "$LOG"

# ------------------------------------------------------------------ Preparação
EMAIL="cliente.td.${TS}@exemplo.test"
req "SETUP-1" POST "/api/clientes" "{\"nome\":\"Cliente Ficticio TD\",\"email\":\"$EMAIL\",\"senha\":\"Ficticia#2026\",\"endereco\":\"Rua Ficticia, 100\"}"
CLI="$(json_get "$HTTP_BODY" 'j.id')"
if [[ -z "$CLI" ]]; then
  echo "Falha na preparação: cliente fictício não criado (HTTP $HTTP_CODE). Consulte $LOG"
  exit 1
fi
note "SETUP-1" "cliente ficticio criado com id=$CLI"

# ------------------------------------------------------------------ TD-A
req "TD-A1" POST "/api/pedidos" "{\"clienteId\":$CLI,\"sabores\":[{\"id\":1}],\"adicionais\":[{\"id\":1}],\"tamanho\":\"grande\",\"valorTotal\":-50.00,\"formaPagamento\":\"pix\",\"enderecoEntrega\":\"Rua Ficticia, 100\"}"
A1="$HTTP_CODE"; A1_ID="$(json_get "$HTTP_BODY" 'j.id')"; A1_VAL="$(json_get "$HTTP_BODY" 'j.valorTotal')"
if [[ -n "$A1_ID" ]]; then
  req "TD-A1-VERIF" GET "/api/pedidos?id=$A1_ID"
  note "TD-A1-VERIF" "valorTotal persistido=$(json_get "$HTTP_BODY" 'j[0] && j[0].valorTotal')"
fi
row "TD-A1" "Campos inválidos" "PC02" "\`POST /api/pedidos\` sabor válido, \`valorTotal: -50.00\`" "400" "$A1 (valorTotal gravado: ${A1_VAL:-n/a})" "$([[ $A1 == 201 ]] && echo 'Ausente' || echo 'Presente')"

req "TD-A2" POST "/api/v1/orders" "{\"customerId\":$CLI,\"flavorIds\":[1],\"additionalIds\":[],\"size\":\"grande\",\"totalValue\":-50.00,\"paymentMethod\":\"pix\",\"deliveryAddress\":\"Rua Ficticia, 100\"}"
A2="$HTTP_CODE"; A2_VAL="$(json_get "$HTTP_BODY" 'j.totalValue')"
row "TD-A2" "Campos inválidos" "PC02" "\`POST /api/v1/orders\` \`totalValue: -50.00\`" "400" "$A2 (totalValue gravado: ${A2_VAL:-n/a})" "$([[ $A2 == 201 ]] && echo 'Ausente' || echo 'Presente')"

# ------------------------------------------------------------------ TD-B
P0="$(pontos_cliente "TD-B1-ANTES" "$CLI")"
req "TD-B1" POST "/api/v1/loyalty" "{\"clienteId\":$CLI,\"pontos\":9999,\"tipo\":\"redeem\",\"descricao\":\"Resgate limite TD\"}"
B1="$HTTP_CODE"
P1="$(pontos_cliente "TD-B1-DEPOIS" "$CLI")"
note "TD-B1" "saldo antes=$P0 depois=$P1"
row "TD-B1" "Valores nos limites" "PC03" "\`POST /api/v1/loyalty\` resgate de 9999 pts (saldo prévio: $P0)" "400" "$B1 (saldo após: $P1)" "$([[ $B1 == 200 && -n $P1 && $P1 -lt 0 ]] && echo 'Ausente' || echo 'Presente')"

req "TD-B2" POST "/api/pedidos" "{\"clienteId\":$CLI,\"sabores\":[{\"id\":2}],\"adicionais\":[],\"tamanho\":\"grande\",\"valorTotal\":0,\"descontoAplicado\":99999,\"formaPagamento\":\"pix\",\"enderecoEntrega\":\"Rua Ficticia, 100\"}"
B2="$HTTP_CODE"
row "TD-B2" "Valores nos limites" "PC02" "\`POST /api/pedidos\` \`valorTotal: 0\`, \`descontoAplicado: 99999\`, sem cupom" "400" "$B2 (desconto gravado: $(json_get "$HTTP_BODY" 'j.descontoAplicado'))" "$([[ $B2 == 201 ]] && echo 'Ausente' || echo 'Presente')"

# ------------------------------------------------------------------ TD-C
req "TD-C1" POST "/api/pedidos" "{\"clienteId\":$CLI,\"sabores\":[],\"adicionais\":[],\"tamanho\":\"medio\",\"valorTotal\":15.00,\"formaPagamento\":\"pix\",\"enderecoEntrega\":\"Rua Ficticia, 100\"}"
C1="$HTTP_CODE"
row "TD-C1" "Transação incompleta" "PC02" "\`POST /api/pedidos\` com \`sabores: []\`" "400" "$C1 (sabores gravados: $(json_get "$HTTP_BODY" 'Array.isArray(j.sabores) ? j.sabores.length : ""'))" "$([[ $C1 == 201 ]] && echo 'Ausente' || echo 'Presente')"

req "TD-C2" POST "/api/v1/orders" "{\"customerId\":$CLI,\"flavorIds\":[],\"additionalIds\":[],\"size\":\"medio\",\"totalValue\":15.00,\"paymentMethod\":\"pix\",\"deliveryAddress\":\"Rua Ficticia, 100\"}"
C2="$HTTP_CODE"
row "TD-C2" "Transação incompleta" "PC02" "\`POST /api/v1/orders\` com \`flavorIds: []\`" "400" "$C2 ($(json_get "$HTTP_BODY" 'j.error'))" "$([[ $C2 == 400 ]] && echo 'Presente' || echo 'Ausente')"

req "TD-C3" POST "/api/pedidos" "{\"clienteId\":$CLI,\"sabores\":[{\"id\":1}],\"adicionais\":[],\"tamanho\":\"medio\",\"valorTotal\":15.00,\"formaPagamento\":\"\",\"enderecoEntrega\":\"\"}"
C3="$HTTP_CODE"
row "TD-C3" "Transação incompleta" "PC02" "\`POST /api/pedidos\` com \`formaPagamento\` e \`enderecoEntrega\` vazios" "400" "$C3" "$([[ $C3 == 201 ]] && echo 'Ausente' || echo 'Presente')"

# ------------------------------------------------------------------ TD-D
CUP_D="TDD${TS: -6}"
req "TD-D1" POST "/api/v1/coupons" "{\"codigo\":\"$CUP_D\",\"tipo\":\"percentual\",\"valor\":100,\"usoMaximo\":1,\"ativo\":true}"
D1="$HTTP_CODE"
row "TD-D1" "Transação incompatível" "PC03" "\`POST /api/v1/coupons\` sem autenticação, cupom de 100%" "401/403" "$D1" "$([[ $D1 == 201 ]] && echo 'Ausente' || echo 'Presente')"

P2="$(pontos_cliente "TD-D2-ANTES" "$CLI")"
req "TD-D2" POST "/api/v1/loyalty" "{\"clienteId\":$CLI,\"pontos\":50000,\"tipo\":\"earn\",\"descricao\":\"Credito sem autenticacao TD\"}"
D2="$HTTP_CODE"
P3="$(pontos_cliente "TD-D2-DEPOIS" "$CLI")"
row "TD-D2" "Transação incompatível" "PC03" "\`POST /api/v1/loyalty\` sem autenticação, \`earn: 50000\`" "401/403" "$D2 (saldo $P2 → $P3)" "$([[ $D2 == 200 ]] && echo 'Ausente' || echo 'Presente')"

req "TD-D3" PATCH "/api/v1/coupons" "{\"codigo\":\"$CUP_D\",\"ativo\":false}"
D3="$HTTP_CODE"
row "TD-D3" "Transação incompatível" "PC03" "\`PATCH /api/v1/coupons\` sem autenticação (desativação)" "401/403" "$D3" "$([[ $D3 == 200 ]] && echo 'Ausente' || echo 'Presente')"

# ------------------------------------------------------------------ TD-E
CUP_E="TDE${TS: -6}"
req "TD-E0" POST "/api/v1/coupons" "{\"codigo\":\"$CUP_E\",\"tipo\":\"percentual\",\"valor\":10,\"usoMaximo\":1,\"ativo\":true}"
note "TD-E0" "cupom de teste $CUP_E (10%, usoMaximo=1) criado com HTTP $HTTP_CODE"

req "TD-E1" GET "/api/v1/coupons/validate?codigo=$CUP_E&valorTotal=20"
E1="$HTTP_CODE"
PED_E="{\"clienteId\":$CLI,\"sabores\":[{\"id\":3}],\"adicionais\":[],\"tamanho\":\"grande\",\"valorTotal\":18.00,\"descontoAplicado\":2.00,\"cupomCodigo\":\"$CUP_E\",\"formaPagamento\":\"pix\",\"enderecoEntrega\":\"Rua Ficticia, 100\"}"
req "TD-E2" POST "/api/pedidos" "$PED_E"
E2="$HTTP_CODE"
U1="$(usos_cupom "TD-E2-VERIF" "$CUP_E")"
req "TD-E3" GET "/api/v1/coupons/validate?codigo=$CUP_E&valorTotal=20"
E3="$HTTP_CODE"; E3_MSG="$(json_get "$HTTP_BODY" 'j.error')"
req "TD-E4" POST "/api/pedidos" "$PED_E"
E4="$HTTP_CODE"
U2="$(usos_cupom "TD-E4-VERIF" "$CUP_E")"
note "TD-E" "validacao1=$E1 pedido1=$E2 usos=$U1 validacao2=$E3 ($E3_MSG) pedido2=$E4 usos=$U2"
row "TD-E2" "Duplicidade" "PC03" "1º pedido com cupom \`$CUP_E\` (\`usoMaximo: 1\`; validação prévia HTTP $E1)" "201" "$E2 (usosAtuais: $U1)" "Fluxo normal"
row "TD-E3" "Duplicidade" "PC03" "\`GET /coupons/validate\` após 1º uso" "400" "$E3 ($E3_MSG)" "$([[ $E3 == 400 ]] && echo 'Presente' || echo 'Ausente')"
row "TD-E4" "Duplicidade" "PC03" "2º \`POST /api/pedidos\` com o mesmo cupom" "400" "$E4 (usosAtuais: $U2)" "$([[ $E4 == 201 ]] && echo 'Ausente' || echo 'Presente')"

# ------------------------------------------------------------------ Complementares
req "TC-01" POST "/api/pedidos" "{\"clienteId\":$CLI,\"sabores\":[{\"id\":1}],\"adicionais\":[],\"tamanho\":\"pequeno\",\"valorTotal\":0,\"descontoAplicado\":0,\"cupomCodigo\":\"$CUP_D\",\"formaPagamento\":\"pix\",\"enderecoEntrega\":\"Rua Ficticia, 100\"}"
TC1="$HTTP_CODE"; UD="$(usos_cupom "TC-01-VERIF" "$CUP_D")"
row "TC-01" "Cupom inativo" "PC03" "\`POST /api/pedidos\` com cupom desativado em TD-D3" "400" "$TC1 (usosAtuais: $UD)" "$([[ $TC1 == 201 ]] && echo 'Ausente' || echo 'Presente')"

req "TC-02" POST "/api/pedidos" "{\"clienteId\":$CLI,\"sabores\":[{\"id\":1}],\"adicionais\":[],\"tamanho\":\"pequeno\",\"valorTotal\":5.00,\"descontoAplicado\":5.00,\"cupomCodigo\":\"INEXISTENTE${TS: -4}\",\"formaPagamento\":\"pix\",\"enderecoEntrega\":\"Rua Ficticia, 100\"}"
TC2="$HTTP_CODE"
row "TC-02" "Cupom inexistente" "PC03" "\`POST /api/pedidos\` com código de cupom não cadastrado" "400" "$TC2" "$([[ $TC2 == 201 ]] && echo 'Ausente' || echo 'Presente')"

P4="$(pontos_cliente "TC-03-ANTES" "$CLI")"
req "TC-03" POST "/api/pedidos" "{\"clienteId\":$CLI,\"sabores\":[{\"id\":2}],\"adicionais\":[],\"tamanho\":\"pequeno\",\"valorTotal\":1000.00,\"formaPagamento\":\"pix\",\"enderecoEntrega\":\"Rua Ficticia, 100\"}"
TC3="$HTTP_CODE"; TC3_ID="$(json_get "$HTTP_BODY" 'j.id')"
P5="$(pontos_cliente "TC-03-DEPOIS" "$CLI")"
row "TC-03" "Pontos a partir de valor informado pelo cliente" "PC02/PC03" "\`POST /api/pedidos\` tamanho pequeno com \`valorTotal: 1000.00\`" "Valor recalculado; 400" "$TC3 (saldo $P4 → $P5)" "$([[ $TC3 == 201 ]] && echo 'Ausente' || echo 'Presente')"

if [[ -n "$TC3_ID" ]]; then
  req "TC-04" PATCH "/api/v1/admin/orders/$TC3_ID/status" "{\"status\":\"Cancelado\"}"
  TC4="$HTTP_CODE"
  row "TC-04" "Alteração sem identificação do autor" "PC06" "\`PATCH /api/v1/admin/orders/$TC3_ID/status\` sem autenticação" "401/403" "$TC4 (status: $(json_get "$HTTP_BODY" 'j.status'))" "$([[ $TC4 == 200 ]] && echo 'Ausente' || echo 'Presente')"

  req "TC-05" DELETE "/api/pedidos?id=$TC3_ID"
  TC5="$HTTP_CODE"
  req "TC-05-VERIF" GET "/api/pedidos?id=$TC3_ID"
  REM="$(json_get "$HTTP_BODY" 'Array.isArray(j) ? j.length : ""')"
  P6="$(pontos_cliente "TC-05-PONTOS" "$CLI")"
  row "TC-05" "Exclusão sem trilha" "PC06" "\`DELETE /api/pedidos?id=$TC3_ID\` sem autenticação" "401/403 ou exclusão lógica" "$TC5 (registros restantes: $REM; saldo de pontos após exclusão: $P6)" "$([[ $TC5 == 200 && $REM == 0 ]] && echo 'Ausente' || echo 'Presente')"
fi

req "TC-06" POST "/api/pedidos" "{\"clienteId\":987654321,\"sabores\":[{\"id\":1}],\"adicionais\":[],\"tamanho\":\"pequeno\",\"valorTotal\":10,\"formaPagamento\":\"pix\",\"enderecoEntrega\":\"Rua Ficticia, 100\"}"
TC6="$HTTP_CODE"
row "TC-06" "Tratamento de erro" "PC06" "\`POST /api/pedidos\` com \`clienteId\` inexistente" "4xx com mensagem genérica" "$TC6 ($(json_get "$HTTP_BODY" 'j.error'))" "$([[ $HTTP_BODY == *prisma* || $HTTP_BODY == *Prisma* || $HTTP_BODY == *stack* ]] && echo 'Expõe detalhes' || echo 'Mensagem genérica')"

echo "Fim: $(date '+%Y-%m-%d %H:%M:%S %z')" >> "$LOG"

# ------------------------------------------------------------------ Resumo
{
  echo "# Test Deck Local — Resumo da Execução (Pessoa 4)"
  echo ""
  echo "- **Data/hora:** $(date '+%Y-%m-%d %H:%M:%S %z')"
  echo "- **Alvo:** \`$BASE_URL\` (ambiente local, banco descartável)"
  echo "- **Registro bruto:** \`$(basename "$LOG")\`"
  echo "- **Cliente fictício:** id \`$CLI\` (e-mail no domínio reservado \`exemplo.test\`)"
  echo ""
  echo "A coluna *Controle* indica apenas se a crítica esperada foi observada na resposta. A classificação final de auditoria consta do relatório da Pessoa 4."
  echo ""
  echo "| ID | Situação | PC | Entrada | Esperado | Obtido | Controle |"
  echo "| :-: | :--- | :-: | :--- | :-: | :--- | :-: |"
  printf '%s\n' "${ROWS[@]}"
} > "$SUMMARY"

echo "[OK] Resumo: $SUMMARY"
echo "[OK] Registro bruto: $LOG"
