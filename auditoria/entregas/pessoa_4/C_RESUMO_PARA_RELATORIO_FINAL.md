# Sistema em Operação e Simulação de Dados — Resumo para o Relatório Final

**Pontos de controle:** PC02, PC03 e PC06 · **Responsável:** Helen Gonçalves (Pessoa 4) · **Data de execução:** 24/11/2026

## 1. Objetivo e metodologia

O objetivo foi avaliar se o sistema calcula e valida corretamente os pedidos, se controla a atualização de cupons e pontos de fidelidade e se mantém rastreabilidade e rotinas de verificação de qualidade.

Foram aplicadas:

- análise do programa fonte;
- rastreamento do fluxo de dados da interface até o banco;
- simulação de dados (*Test Deck*) nas cinco situações exigidas;
- execução das rotinas de teste do próprio projeto.

Os testes funcionais foram realizados em ambiente local, isolado e descartável, com banco PostgreSQL em memória, sobre a versão do código do commit `2ceb6a1`. O ambiente publicado não foi testado, e os resultados não afirmam a reprodução das falhas nele.

## 2. Pontos de controle

| PC | Escopo | Grau de risco |
| :-: | :--- | :-: |
| PC02 | Cálculo e consistência financeira dos pedidos | 5 – Muito forte |
| PC03 | Atualização de cupons e pontos de fidelidade | 5 – Muito forte |
| PC06 | Trilha de auditoria, tratamento de erros e CI/CD | 4 – Forte |

## 3. Principais falhas confirmadas em teste funcional

- **PC02:** o servidor grava o valor do pedido enviado pelo navegador, sem recálculo (não há tabela de preços no banco). Foram aceitos pedidos com valor negativo, com desconto incoerente sem cupom e sem sabores, este último apenas na rota legada usada pela interface. Pontos de fidelidade são calculados a partir desse valor não verificado.
- **PC03:** criação e desativação de cupons e crédito de pontos foram executados sem autenticação. Um resgate acima do saldo gerou saldo negativo. Na gravação do pedido, foram aceitos cupom de uso único reutilizado, cupom inativo e cupom inexistente.
- **PC06:** alteração de status e exclusão física de pedido foram executadas sem autenticação e sem registro de autoria; não há trilha de auditoria no sistema.
- **PC06, rotinas de qualidade (confirmado em execução):**
  - a suíte Jest falha em 7 de 14 testes;
  - o hook de pré-commit chama um script `lint` inexistente;
  - o `package-lock.json` está dessincronizado.
- **PC06, configuração (análise estática):** workflow e hooks estão em `github/` e `husky/`, sem o ponto inicial, e não são reconhecidos pelas ferramentas. A consulta ao GitHub não encontrou workflows nem execuções no repositório da auditoria; o repositório original não foi consultado, e essa ausência não comprova a inexistência histórica de CI.

**Achado incidental (PC04/PC05).** A consulta de pedidos sem autenticação retornou o hash da senha e o campo `isAdmin` dos clientes. O achado foi encaminhado a Rafael Gomes (P5) e Alisson de Souza Rocha (P3).

## 4. Resultados do Test Deck

| Caso | Situação | Resultado | Controle que funcionou |
| :-: | :--- | :--- | :--- |
| TD-A | Campos inválidos | Falha: pedido de R$ −50,00 aceito nas rotas legada e v1 | — |
| TD-B | Valores nos limites | Falha: saldo de pontos −9.999; desconto de 99.999 sem cupom | — |
| TD-C | Transação incompleta | Falha na rota legada (pedido sem sabores aceito) | Rota v1 rejeitou o pedido sem sabores |
| TD-D | Transação incompatível | Falha: cupom de 100% e 50.000 pontos criados sem autenticação | — |
| TD-E | Duplicidade | Falha: cupom de uso único reutilizado na criação do pedido | Rota de validação bloqueou o 2º uso |

## 5. Recomendações prioritárias

1. Recalcular no servidor o valor, o desconto e os pontos do pedido a partir de tabela de preços no banco, rejeitando pedidos incompletos ou com valores inválidos.
2. Exigir autenticação e perfil administrativo nas rotas de escrita de cupons, pontos e status de pedido.
3. Validar o cupom na gravação do pedido e atualizar pedido, uso do cupom e pontos numa única transação, com saldo não negativo.
4. Implantar trilha de auditoria imutável e exclusão lógica de pedidos.
5. Corrigir a localização e o conteúdo do workflow e dos hooks, atualizar a suíte Jest e não executar testes automatizados contra produção.

## 6. Limitações

- Testes em modo de desenvolvimento e com banco em memória; o ambiente publicado não foi testado.
- Concorrência no uso de cupons não avaliada.
- Suíte Java não executada.
- Consulta ao GitHub restrita ao repositório da auditoria.
- Respostas às questões 11 a 14 do questionário não recebidas até a conclusão.

*Detalhamento e evidências:* `auditoria/entregas/pessoa_4/A_RELATORIO_PONTOS_DE_CONTROLE_PC02_PC03_PC06.md`, `B_MATRIZ_TEST_DECK.md` e `auditoria/evidencias/P4_*`.
