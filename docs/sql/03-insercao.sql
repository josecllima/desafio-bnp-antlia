/* =====================================================================
   03 - INSERCAO
   Cadastra, na ordem obrigatoria, um produto novo, suas contas e
   lancamentos manuais. A ordem importa por causa das FKs:

     1o PRODUTO          (o pai de tudo)
     2o PRODUTO_COSIF    (precisa do produto)
     3o MOVIMENTO_MANUAL (precisa do par produto + conta)

   Rode o arquivo inteiro uma vez. Rodar de novo da erro de chave
   duplicada nos itens 3.1 e 3.2 (o que e esperado: o codigo ja existe).
   ===================================================================== */


/* ---------------------------------------------------------------------
   3.1 Novo PRODUTO
   Um produto e so um codigo + descricao + status.
   --------------------------------------------------------------------- */
INSERT INTO PRODUTO (COD_PRODUTO, DES_PRODUTO, STA_STATUS)
VALUES ('0005', 'Cartao de Credito', 'A');


/* ---------------------------------------------------------------------
   3.2 Contas permitidas para o novo produto (PRODUTO_COSIF)
   Cada linha diz: "o produto 0005 pode ser lancado nesta conta".
   Sem estas linhas, o combo Cosif fica vazio para o Cartao.

   A ultima linha liga ao Cartao uma conta que JA pertence ao
   produto 0003 (71110000005). E permitido: a chave e o PAR
   produto + conta, entao a mesma conta pode servir a dois produtos.
   --------------------------------------------------------------------- */
INSERT INTO PRODUTO_COSIF (COD_PRODUTO, COD_COSIF, COD_CLASSIFICACAO, STA_STATUS)
VALUES ('0005', '16130000008', 'ATIVO ', 'A');   -- valores a receber dos clientes do cartao

INSERT INTO PRODUTO_COSIF (COD_PRODUTO, COD_COSIF, COD_CLASSIFICACAO, STA_STATUS)
VALUES ('0005', '71130000009', 'RECEIT', 'A');   -- juros do rotativo / tarifas

INSERT INTO PRODUTO_COSIF (COD_PRODUTO, COD_COSIF, COD_CLASSIFICACAO, STA_STATUS)
VALUES ('0005', '71110000005', 'RECEIT', 'A');   -- mesma conta usada pelo consignado


/* ---------------------------------------------------------------------
   3.3 Lancamentos manuais (MOVIMENTO_MANUAL)
   Reproduz o exemplo do documento funcional: o fechamento de outubro.

   COMO A APLICACAO GERA O NUMERO DO LANCAMENTO
   NUM_LANCAMENTO = maior numero do MESMO mes/ano + 1, sem olhar o
   produto. O INSERT ... SELECT abaixo faz exatamente o calculo do
   service Java:

     SELECT COALESCE(MAX(NUM_LANCAMENTO), 0) + 1
       FROM MOVIMENTO_MANUAL
      WHERE DAT_MES = <mes> AND DAT_ANO = <ano>

   COALESCE(..., 0): se o mes ainda nao tem lancamento, MAX devolve
   NULL; o COALESCE troca por 0 e o primeiro numero fica 1.

   DAT_MOVIMENTO = LOCALTIMESTAMP(0) -> data/hora da gravacao, sem
   fracao de segundo. COD_USUARIO = 'TESTE' (fixo pelo enunciado).
   --------------------------------------------------------------------- */

-- 10/2026 nº 1: ajuste de juros do CDB (produto 0001, conta de despesa)
INSERT INTO MOVIMENTO_MANUAL
       (DAT_MES, DAT_ANO, NUM_LANCAMENTO, COD_PRODUTO, COD_COSIF,
        DES_DESCRICAO, DAT_MOVIMENTO, COD_USUARIO, VAL_VALOR)
SELECT 10, 2026, COALESCE(MAX(NUM_LANCAMENTO), 0) + 1, '0001', '81120000002',
       'Ajuste juros CDB outubro', LOCALTIMESTAMP(0), 'TESTE', 1250.00
  FROM MOVIMENTO_MANUAL
 WHERE DAT_MES = 10 AND DAT_ANO = 2026;

-- 10/2026 nº 2: OUTRO produto, mas a numeracao continua (o produto nao importa)
INSERT INTO MOVIMENTO_MANUAL
       (DAT_MES, DAT_ANO, NUM_LANCAMENTO, COD_PRODUTO, COD_COSIF,
        DES_DESCRICAO, DAT_MOVIMENTO, COD_USUARIO, VAL_VALOR)
SELECT 10, 2026, COALESCE(MAX(NUM_LANCAMENTO), 0) + 1, '0003', '71110000005',
       'Correcao receita consignado', LOCALTIMESTAMP(0), 'TESTE', 830.40
  FROM MOVIMENTO_MANUAL
 WHERE DAT_MES = 10 AND DAT_ANO = 2026;

-- 10/2026 nº 3: LCI
INSERT INTO MOVIMENTO_MANUAL
       (DAT_MES, DAT_ANO, NUM_LANCAMENTO, COD_PRODUTO, COD_COSIF,
        DES_DESCRICAO, DAT_MOVIMENTO, COD_USUARIO, VAL_VALOR)
SELECT 10, 2026, COALESCE(MAX(NUM_LANCAMENTO), 0) + 1, '0002', '41520000003',
       'Ajuste saldo LCI', LOCALTIMESTAMP(0), 'TESTE', 5000.00
  FROM MOVIMENTO_MANUAL
 WHERE DAT_MES = 10 AND DAT_ANO = 2026;

-- 10/2026 nº 4: o produto novo, numa conta compartilhada com o consignado
INSERT INTO MOVIMENTO_MANUAL
       (DAT_MES, DAT_ANO, NUM_LANCAMENTO, COD_PRODUTO, COD_COSIF,
        DES_DESCRICAO, DAT_MOVIMENTO, COD_USUARIO, VAL_VALOR)
SELECT 10, 2026, COALESCE(MAX(NUM_LANCAMENTO), 0) + 1, '0005', '71110000005',
       'Tarifa anuidade cartao', LOCALTIMESTAMP(0), 'TESTE', 199.90
  FROM MOVIMENTO_MANUAL
 WHERE DAT_MES = 10 AND DAT_ANO = 2026;

-- 11/2026 nº 1: competencia nova -> a numeracao RECOMECA em 1
INSERT INTO MOVIMENTO_MANUAL
       (DAT_MES, DAT_ANO, NUM_LANCAMENTO, COD_PRODUTO, COD_COSIF,
        DES_DESCRICAO, DAT_MOVIMENTO, COD_USUARIO, VAL_VALOR)
SELECT 11, 2026, COALESCE(MAX(NUM_LANCAMENTO), 0) + 1, '0004', '71810000007',
       'Receita cambio novembro', LOCALTIMESTAMP(0), 'TESTE', 312.75
  FROM MOVIMENTO_MANUAL
 WHERE DAT_MES = 11 AND DAT_ANO = 2026;

-- 11/2026 nº 2
INSERT INTO MOVIMENTO_MANUAL
       (DAT_MES, DAT_ANO, NUM_LANCAMENTO, COD_PRODUTO, COD_COSIF,
        DES_DESCRICAO, DAT_MOVIMENTO, COD_USUARIO, VAL_VALOR)
SELECT 11, 2026, COALESCE(MAX(NUM_LANCAMENTO), 0) + 1, '0001', '41510000001',
       'Captacao CDB nao processada', LOCALTIMESTAMP(0), 'TESTE', 25000.00
  FROM MOVIMENTO_MANUAL
 WHERE DAT_MES = 11 AND DAT_ANO = 2026;


/* ---------------------------------------------------------------------
   3.4 Conferencia: o resultado esperado e
     10/2026 -> 1, 2, 3, 4   (4 produtos diferentes, uma so sequencia)
     11/2026 -> 1, 2         (recomecou)
   --------------------------------------------------------------------- */
SELECT DAT_MES, DAT_ANO, NUM_LANCAMENTO, COD_PRODUTO, COD_COSIF,
       DES_DESCRICAO, VAL_VALOR, DAT_MOVIMENTO, COD_USUARIO
  FROM MOVIMENTO_MANUAL
 ORDER BY DAT_ANO, DAT_MES, NUM_LANCAMENTO;

/* Depois disso, abra http://localhost:4200: os mesmos lancamentos
   aparecem no grid da tela, porque tela e console usam o mesmo banco. */
