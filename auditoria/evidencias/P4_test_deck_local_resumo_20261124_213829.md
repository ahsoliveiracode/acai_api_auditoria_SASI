# Test Deck Local — Resumo da Execução (Pessoa 4)

- **Data/hora:** 2026-11-24 21:39:03 -0300
- **Alvo:** `http://localhost:3100` (ambiente local, banco descartável)
- **Registro bruto:** `P4_test_deck_local_log_20261124_213829.txt`
- **Cliente fictício:** id `1` (e-mail no domínio reservado `exemplo.test`)

A coluna *Controle* indica apenas se a crítica esperada foi observada na resposta. A classificação final de auditoria consta do relatório da Pessoa 4.

| ID | Situação | PC | Entrada | Esperado | Obtido | Controle |
| :-: | :--- | :-: | :--- | :-: | :--- | :-: |
| TD-A1 | Campos inválidos | PC02 | `POST /api/pedidos` sabor válido, `valorTotal: -50.00` | 400 | 201 (valorTotal gravado: -50) | Ausente |
| TD-A2 | Campos inválidos | PC02 | `POST /api/v1/orders` `totalValue: -50.00` | 400 | 201 (totalValue gravado: -50) | Ausente |
| TD-B1 | Valores nos limites | PC03 | `POST /api/v1/loyalty` resgate de 9999 pts (saldo prévio: 0) | 400 | 200 (saldo após: -9999) | Ausente |
| TD-B2 | Valores nos limites | PC02 | `POST /api/pedidos` `valorTotal: 0`, `descontoAplicado: 99999`, sem cupom | 400 | 201 (desconto gravado: 99999) | Ausente |
| TD-C1 | Transação incompleta | PC02 | `POST /api/pedidos` com `sabores: []` | 400 | 201 (sabores gravados: 0) | Ausente |
| TD-C2 | Transação incompleta | PC02 | `POST /api/v1/orders` com `flavorIds: []` | 400 | 400 (At least one flavor is required) | Presente |
| TD-C3 | Transação incompleta | PC02 | `POST /api/pedidos` com `formaPagamento` e `enderecoEntrega` vazios | 400 | 201 | Ausente |
| TD-D1 | Transação incompatível | PC03 | `POST /api/v1/coupons` sem autenticação, cupom de 100% | 401/403 | 201 | Ausente |
| TD-D2 | Transação incompatível | PC03 | `POST /api/v1/loyalty` sem autenticação, `earn: 50000` | 401/403 | 200 (saldo -9997 → 40003) | Ausente |
| TD-D3 | Transação incompatível | PC03 | `PATCH /api/v1/coupons` sem autenticação (desativação) | 401/403 | 200 | Ausente |
| TD-E1 | Duplicidade | PC03 | 1º pedido com cupom `TDE567109` (`usoMaximo: 1`) | 201 | 201 (usosAtuais: 1) | Fluxo normal |
| TD-E2 | Duplicidade | PC03 | `GET /coupons/validate` após 1º uso | 400 | 400 (Limite de uso atingido) | Presente |
| TD-E3 | Duplicidade | PC03 | 2º `POST /api/pedidos` com o mesmo cupom | 400 | 201 (usosAtuais: 2) | Ausente |
| TC-01 | Cupom inativo | PC03 | `POST /api/pedidos` com cupom desativado em TD-D3 | 400 | 201 (usosAtuais: 1) | Ausente |
| TC-02 | Cupom inexistente | PC03 | `POST /api/pedidos` com código de cupom não cadastrado | 400 | 201 | Ausente |
| TC-03 | Pontos a partir de valor informado pelo cliente | PC02/PC03 | `POST /api/pedidos` tamanho pequeno com `valorTotal: 1000.00` | Valor recalculado; 400 | 201 (saldo 40005 → 40105) | Ausente |
| TC-04 | Alteração sem identificação do autor | PC06 | `PATCH /api/v1/admin/orders/10/status` sem autenticação | 401/403 | 200 (status: Cancelado) | Ausente |
| TC-05 | Exclusão sem trilha | PC06 | `DELETE /api/pedidos?id=10` sem autenticação | 401/403 ou exclusão lógica | 200 (registros restantes: 0; saldo de pontos após exclusão: 40105) | Ausente |
| TC-06 | Tratamento de erro | PC06 | `POST /api/pedidos` com `clienteId` inexistente | 4xx com mensagem genérica | 500 (Erro ao adicionar pedido) | Mensagem genérica |
