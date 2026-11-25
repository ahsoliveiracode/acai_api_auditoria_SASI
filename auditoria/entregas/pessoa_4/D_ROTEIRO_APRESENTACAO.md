# Roteiro de Apresentação — Pessoa 4 (aprox. 1 minuto)

**Apresentadora:** Helen Gonçalves · **Pontos de controle:** PC02, PC03 e PC06

---

Fiquei responsável pelo sistema em operação: o cálculo dos pedidos, as rotinas de cupons e de fidelidade e a rastreabilidade das operações.

Apliquei análise do código-fonte e a técnica de simulação de dados, o *Test Deck*, nas cinco situações exigidas. Os testes foram feitos numa cópia local da aplicação, com banco em memória e descartável. Os resultados valem para a versão testada; não testamos o ambiente publicado.

Os cinco cenários identificaram falhas. O servidor grava o valor enviado pelo navegador: aceitou um pedido de menos cinquenta reais e um desconto de quase cem mil reais. Sem login, conseguimos criar um cupom de cem por cento e creditar cinquenta mil pontos, e um resgate deixou o saldo negativo. Um cupom de uso único foi aceito duas vezes na criação do pedido, e um pedido foi excluído sem deixar registro.

Alguns controles funcionaram. A rota nova rejeita pedido sem sabores, e a rota de validação bloqueia o segundo uso do cupom. O problema é que o fluxo de compra não passa por esses controles.

Também vimos que o CI e os hooks estão em pastas que as ferramentas não reconhecem, e que metade da suíte de testes falha.

Recomendamos:

- calcular preço, desconto e pontos no servidor;
- exigir perfil administrativo nas rotas de cupons e pontos;
- validar o cupom na mesma transação do pedido;
- implantar uma trilha de auditoria e corrigir a esteira de testes.
