# Matriz do Test Deck — Simulação de Dados (Pessoa 4)

**Sistema auditado:** Açaí do Vale (`delivery-main`, branch `TPIII`, commit `2ceb6a1`)
**Auditora responsável:** Helen Gonçalves
**Execução:** 24/11/2026, 21h38–21h39 (UTC−3)
**Ambiente:** local, isolado e descartável. A aplicação foi executada a partir de cópia local em `http://localhost:3100`, com banco PostgreSQL em memória (PGlite) criado pelas migrações do projeto e descartado ao final. Não houve acesso à aplicação publicada nem a banco compartilhado.
**Delimitação:** os resultados referem-se à versão do código testada (commit `2ceb6a1`). Não se afirma que tenham sido reproduzidos no ambiente publicado.
**Ferramenta:** `auditoria/scripts/test-deck-local.sh`
**Evidências:** `auditoria/evidencias/P4_test_deck_local_resumo_20261124_213829.md` (resumo) e `auditoria/evidencias/P4_test_deck_local_log_20261124_213829.txt` (requisições e respostas completas, identificadas pelo ID do caso).
**Dados de entrada:** cliente fictício `id 1` (domínio reservado `exemplo.test`), sabores `id 1–3` e adicional `id 1` da migração `seed_base_data`, cupons fictícios `TDD567109` e `TDE567109`. Nenhuma requisição exigiu autenticação.

---

## 1. Matriz das cinco situações obrigatórias

| Caso | Situação | PC | Entrada utilizada | Resultado esperado | Resultado obtido | Classificação | Evidência (ID no log) |
| :-: | :--- | :-: | :--- | :--- | :--- | :--- | :-: |
| **TD-A** | Transação com campos inválidos | PC02 | `POST /api/pedidos` com sabor válido (`id 1`) e `valorTotal: -50.00` | HTTP 400; valor recalculado pelo servidor | HTTP 201; pedido `id 1` gravado com `valorTotal: -50`, confirmado por consulta posterior | **Falha confirmada em teste funcional** | TD-A1, TD-A1-VERIF |
| | | | `POST /api/v1/orders` com `flavorIds: [1]` e `totalValue: -50.00` | HTTP 400 | HTTP 201; `totalValue: -50` gravado | **Falha confirmada em teste funcional** | TD-A2 |
| **TD-B** | Transação com valores nos limites | PC03 | `POST /api/v1/loyalty` com `tipo: redeem`, `pontos: 9999`; saldo prévio 0 | HTTP 400; saldo inalterado | HTTP 200; saldo final **−9.999**; transação de −9.999 registrada | **Falha confirmada em teste funcional** | TD-B1-ANTES, TD-B1, TD-B1-DEPOIS |
| | | PC02 | `POST /api/pedidos` com `valorTotal: 0` e `descontoAplicado: 99999`, sem cupom | HTTP 400 | HTTP 201; desconto de 99.999 gravado | **Falha confirmada em teste funcional** | TD-B2 |
| **TD-C** | Transação incompleta | PC02 | `POST /api/pedidos` com `sabores: []` | HTTP 400 | HTTP 201; pedido gravado sem sabores | **Falha confirmada em teste funcional** | TD-C1 |
| | | | `POST /api/v1/orders` com `flavorIds: []` | HTTP 400 | HTTP 400, “At least one flavor is required” | **Controle aprovado** | TD-C2 |
| | | | `POST /api/pedidos` com `formaPagamento: ""` e `enderecoEntrega: ""` | HTTP 400 | HTTP 201; pedido gravado com campos vazios | **Falha confirmada em teste funcional** | TD-C3 |
| **TD-D** | Transação incompatível (operação administrativa por usuário não autenticado) | PC03 | `POST /api/v1/coupons` sem autenticação: cupom `TDD567109`, 100%, `usoMaximo: 1` | HTTP 401/403 | HTTP 201; cupom criado | **Falha confirmada em teste funcional** | TD-D1 |
| | | | `POST /api/v1/loyalty` sem autenticação: `tipo: earn`, `pontos: 50000` | HTTP 401/403 | HTTP 200; saldo de −9.997 para 40.003 | **Falha confirmada em teste funcional** | TD-D2 |
| | | | `PATCH /api/v1/coupons` sem autenticação: `ativo: false` | HTTP 401/403 | HTTP 200; cupom desativado | **Falha confirmada em teste funcional** | TD-D3 |
| **TD-E** | Transação em duplicidade | PC03 | Cupom `TDE567109` (10%, `usoMaximo: 1`). 1º `POST /api/pedidos` com o cupom | HTTP 201; `usosAtuais` 1 | HTTP 201; `usosAtuais` 1 | Fluxo normal (pré-condição) | TD-E0, TD-E1, TD-E2, TD-E2-VERIF |
| | | | `GET /api/v1/coupons/validate` após o 1º uso | HTTP 400 | HTTP 400, “Limite de uso atingido” | **Controle aprovado** | TD-E3 |
| | | | 2º `POST /api/pedidos` com o mesmo cupom | HTTP 400, “Limite de uso atingido” | HTTP 201; `usosAtuais` **2** (acima do limite 1) | **Falha confirmada em teste funcional** | TD-E4, TD-E4-VERIF |

---

**Nota de rastreabilidade:** no arquivo de resumo gerado em 24/11/2026 às 21h38, as linhas de duplicidade aparecem numeradas como TD-E1 (1º pedido), TD-E2 (validação após uso) e TD-E3 (2º pedido). No registro bruto, essas mesmas operações correspondem a TD-E2, TD-E3 e TD-E4, sendo TD-E1 a validação prévia (HTTP 200). A numeração do resumo foi alinhada à do registro bruto no script para execuções futuras; os arquivos de evidência já gerados foram preservados sem alteração.

## 2. Casos complementares

| ID | Objetivo | PC | Entrada | Esperado | Obtido | Classificação |
| :-: | :--- | :-: | :--- | :--- | :--- | :--- |
| TC-01 | Uso de cupom inativo | PC03 | `POST /api/pedidos` com cupom `TDD567109` desativado em TD-D3 | HTTP 400 | HTTP 201; `usosAtuais` 1 | **Falha confirmada em teste funcional** |
| TC-02 | Uso de cupom inexistente | PC03 | `POST /api/pedidos` com código não cadastrado e `descontoAplicado: 5.00` | HTTP 400 | HTTP 201 | **Falha confirmada em teste funcional** |
| TC-03 | Pontos calculados a partir do valor informado pelo cliente | PC02/PC03 | `POST /api/pedidos`, tamanho pequeno, `valorTotal: 1000.00` | Valor recalculado ou rejeitado | HTTP 201; saldo de 40.005 para 40.105 (+100 pontos) | **Falha confirmada em teste funcional** |
| TC-04 | Alteração de status sem identificação do responsável | PC06 | `PATCH /api/v1/admin/orders/10/status` sem autenticação, `status: Cancelado` | HTTP 401/403 | HTTP 200; status alterado | **Falha confirmada em teste funcional** |
| TC-05 | Exclusão sem preservação de histórico | PC06 | `DELETE /api/pedidos?id=10` sem autenticação | HTTP 401/403 ou exclusão lógica | HTTP 200; consulta posterior retorna 0 registros; pontos de TC-03 não estornados | **Falha confirmada em teste funcional** |
| TC-06 | Tratamento de erro | PC06 | `POST /api/pedidos` com `clienteId` inexistente | HTTP 4xx com mensagem genérica | HTTP 500 com mensagem genérica (“Erro ao adicionar pedido”) | **Controle aprovado** quanto à não exposição; código HTTP inadequado |

---

## 3. Síntese

| Situação | Casos executados | Controles aprovados | Falhas confirmadas em teste funcional |
| :--- | :-: | :-: | :-: |
| TD-A — Campos inválidos | 2 | 0 | 2 |
| TD-B — Valores nos limites | 2 | 0 | 2 |
| TD-C — Transação incompleta | 3 | 1 | 2 |
| TD-D — Transação incompatível | 3 | 0 | 3 |
| TD-E — Duplicidade | 2 (+1 pré-condição) | 1 | 1 |
| Complementares | 6 | 1 | 5 |

As cinco situações obrigatórias foram executadas e cada uma identificou ao menos uma falha. Nem todas as rotas falharam:

| Situação | Falha identificada | Controle que funcionou |
| :--- | :--- | :--- |
| TD-A | Valores negativos aceitos nas rotas legada e v1. | — |
| TD-B | Resgate gerou saldo de pontos negativo; desconto incoerente sem cupom aceito. | — |
| TD-C | Rota legada aceitou pedido sem sabores e sem pagamento/endereço. | A rota v1 rejeitou corretamente o pedido sem sabores (HTTP 400). |
| TD-D | Criação e desativação de cupom e crédito de pontos executados sem autenticação. | — |
| TD-E | Reutilização indevida do cupom de uso único na criação do pedido. | A rota de validação de cupom bloqueou corretamente o segundo uso (HTTP 400, “Limite de uso atingido”). |

Os controles que funcionaram não protegem o fluxo de compra: a interface grava pedidos pela rota legada, e a validação de cupom é apenas consultiva.

## 4. Observações sobre o script original `test-deck.sh`

O script `auditoria/scripts/test-deck.sh` foi revisado e mantido sem alterações. Ele não foi executado em modo `--live`, pelos seguintes motivos:

1. Envia requisições de exclusão (`DELETE`) e alteração (`PATCH`) ao final da execução e aceita qualquer URL, o que o torna inadequado para ambientes compartilhados.
2. Em TD-A e TD-E usa `sabores: []`, o que mistura a situação de campos inválidos com a de transação incompleta.
3. Em TD-E conclui pela falha apenas pelo código HTTP do 2º pedido, sem verificar o contador `usosAtuais`.
4. O modo `--static` sobrescreve `auditoria/evidencias/evidencia_estatica_inicial.md`. Por isso, as verificações estáticas foram reexecutadas em cópia temporária: os resultados foram idênticos ao arquivo existente, que permaneceu inalterado.

Essas questões foram tratadas na ferramenta complementar `test-deck-local.sh`. Essa ferramenta aceita somente `http://localhost[:porta]` ou `http://127.0.0.1[:porta]` e não executa exclusões de limpeza. As únicas operações de alteração e exclusão que envia (TC-04 e TC-05) atingem registros fictícios criados pela própria execução no banco local.

## 5. Dados fictícios e sanitização

- **Dados utilizados:** todos fictícios. O cliente “Cliente Ficticio TD” usa o e-mail `cliente.td.<timestamp>@exemplo.test`, de domínio reservado e não roteável, e o endereço “Rua Ficticia, 100”. A senha fictícia foi mascarada (`***`) em todos os registros.
- **Ausência de dados sensíveis:** os arquivos de evidência foram verificados e não contêm hashes de senha, tokens, chaves ou dados pessoais reais. Nenhuma sanitização posterior foi necessária, pois o mascaramento ocorreu no momento da gravação.
- **Nomes de arquivos de imagem:** os nomes que aparecem nas respostas de sabores (por exemplo, `/Gemini_Generated_Image_….png`) são dados cadastrados pela própria aplicação auditada (`delivery-main/data/sabores.json` e migração `seed_base_data`). Foram preservados por integrarem a resposta original do sistema.
