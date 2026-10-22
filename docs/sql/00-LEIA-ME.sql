/* =====================================================================
   SCRIPTS DE ESTUDO DO MODELO — Movimentos Manuais (Desafio BNP & Antlia)
   =====================================================================

   OBJETIVO
   Entender o modelo de dados na pratica: o que cada tabela guarda,
   como elas se ligam e por que o banco recusa certos cadastros.

   COMO EXECUTAR (console do H2)
   1. Suba o backend (MovimentosApplication).
   2. Abra http://localhost:8080/h2-console
        JDBC URL : jdbc:h2:mem:movimentosdb
        Usuario  : sa
        Senha    : (vazia)
   3. Cole o conteudo de um arquivo e clique em "Run".
      Para rodar so um comando, selecione-o e clique em "Run Selected".

   ORDEM SUGERIDA
   01-entendendo-o-modelo.sql      estrutura, chaves e relacionamentos
   02-consultas-cadastros.sql      PRODUTO e PRODUTO_COSIF (por produto, por tipo...)
   03-insercao.sql                 cadastrar produto, contas e lancamentos
   04-consultas-movimentos.sql     grid, filtros, totais, auditoria
   05-alteracao-e-exclusao.sql     o que pode (e o que nao pode) ser alterado
   06-erros-de-integridade.sql     cadastros que o banco recusa, e por que
   07-novos-produtos-e-cosifs.sql  incluir mais produtos e contas nos combos

   ATENCAO
   - O banco e H2 EM MEMORIA: ao reiniciar o backend, tudo que foi
     incluido aqui some. PRODUTO e PRODUTO_COSIF voltam pelo data.sql.
   - Os codigos COSIF e as classificacoes sao ILUSTRATIVOS (nao sao
     contas reais do plano do Banco Central).
   - Rode o 03 antes do 04, para que as consultas de movimentos
     tenham dados.

   O MODELO EM UMA FRASE
   Um PRODUTO pode ser lancado em algumas contas COSIF (PRODUTO_COSIF);
   cada lancamento manual (MOVIMENTO_MANUAL) usa um desses pares
   produto + conta, em uma competencia (mes/ano).

        PRODUTO  1 ──── N  PRODUTO_COSIF  1 ──── N  MOVIMENTO_MANUAL
       (catalogo)          (contas permitidas)      (lancamentos)
   ===================================================================== */
