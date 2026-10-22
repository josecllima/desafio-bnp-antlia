/* =====================================================================
   06 - ERROS DE INTEGRIDADE: o que o banco RECUSA, e por que
   Cada bloco e um cadastro invalido. Execute UM POR VEZ
   (selecione o comando e clique em "Run Selected") e leia o erro.
   Nenhum deles grava nada: e o modelo protegendo os dados.
   ===================================================================== */


/* ---------------------------------------------------------------------
   6.1 Conta para um produto que NAO existe
   Regra: PRODUTO_COSIF.COD_PRODUTO precisa existir em PRODUTO.
   Erro esperado: violacao de FK (FK_PRODUTO_COSIF_PRODUTO).
   --------------------------------------------------------------------- */
INSERT INTO PRODUTO_COSIF (COD_PRODUTO, COD_COSIF, COD_CLASSIFICACAO, STA_STATUS)
VALUES ('9999', '41510000001', 'PASSIV', 'A');


/* ---------------------------------------------------------------------
   6.2 Lancamento numa conta que NAO pertence ao produto
   O produto 0002 (LCI) existe e a conta 71110000005 existe, mas o
   PAR (0002, 71110000005) nao esta em PRODUTO_COSIF.
   Erro esperado: violacao da FK composta
   (FK_MOVIMENTO_MANUAL_PRODUTO_COSIF).
   E a mesma regra que a API valida antes, devolvendo
   "Cosif 71110000005 nao pertence ao produto 0002".
   --------------------------------------------------------------------- */
INSERT INTO MOVIMENTO_MANUAL
       (DAT_MES, DAT_ANO, NUM_LANCAMENTO, COD_PRODUTO, COD_COSIF,
        DES_DESCRICAO, DAT_MOVIMENTO, COD_USUARIO, VAL_VALOR)
VALUES (12, 2026, 1, '0002', '71110000005',
        'Conta errada para LCI', LOCALTIMESTAMP(0), 'TESTE', 100.00);


/* ---------------------------------------------------------------------
   6.3 Mesmo par produto + conta duas vezes
   Regra: a PK de PRODUTO_COSIF e (COD_PRODUTO, COD_COSIF).
   Erro esperado: chave primaria duplicada.
   --------------------------------------------------------------------- */
INSERT INTO PRODUTO_COSIF (COD_PRODUTO, COD_COSIF, COD_CLASSIFICACAO, STA_STATUS)
VALUES ('0001', '41510000001', 'PASSIV', 'A');


/* ---------------------------------------------------------------------
   6.4 Lancamento com a MESMA chave de outro
   Rode o 03 antes: (10, 2026, 1, '0001', '81120000002') ja existe.
   Erro esperado: chave primaria duplicada.
   Na aplicacao, isso so aconteceria em inclusao simultanea, e a API
   devolve HTTP 409 ("Tente novamente").
   --------------------------------------------------------------------- */
INSERT INTO MOVIMENTO_MANUAL
       (DAT_MES, DAT_ANO, NUM_LANCAMENTO, COD_PRODUTO, COD_COSIF,
        DES_DESCRICAO, DAT_MOVIMENTO, COD_USUARIO, VAL_VALOR)
VALUES (10, 2026, 1, '0001', '81120000002',
        'Duplicado', LOCALTIMESTAMP(0), 'TESTE', 10.00);


/* ---------------------------------------------------------------------
   6.5 Ponto de atencao do modelo: MESMO NUMERO, PRODUTO DIFERENTE
   Este INSERT e ACEITO pelo banco, embora o numero 1 de 10/2026 ja
   exista. Motivo: a PK inclui produto e conta, entao (10, 2026, 1,
   '0003', ...) e uma chave diferente de (10, 2026, 1, '0001', ...).

   Ou seja: o BANCO nao garante numero unico por competencia; quem
   garante e a APLICACAO (MAX + 1). Em inclusoes simultaneas, dois
   usuarios poderiam receber o mesmo numero. O README descreve a
   mitigacao (lock pessimista ou sequence por competencia).

   Depois de rodar, desfaca com o DELETE logo abaixo.
   --------------------------------------------------------------------- */
INSERT INTO MOVIMENTO_MANUAL
       (DAT_MES, DAT_ANO, NUM_LANCAMENTO, COD_PRODUTO, COD_COSIF,
        DES_DESCRICAO, DAT_MOVIMENTO, COD_USUARIO, VAL_VALOR)
VALUES (10, 2026, 1, '0003', '16120000004',
        'Numero repetido em outro produto', LOCALTIMESTAMP(0), 'TESTE', 10.00);

-- Veja os dois "numero 1" de 10/2026:
SELECT DAT_MES, DAT_ANO, NUM_LANCAMENTO, COD_PRODUTO, COD_COSIF, DES_DESCRICAO
  FROM MOVIMENTO_MANUAL
 WHERE DAT_MES = 10 AND DAT_ANO = 2026 AND NUM_LANCAMENTO = 1;

-- Desfaz o exemplo:
DELETE FROM MOVIMENTO_MANUAL
 WHERE DAT_MES = 10 AND DAT_ANO = 2026 AND NUM_LANCAMENTO = 1
   AND COD_PRODUTO = '0003' AND COD_COSIF = '16120000004';


/* ---------------------------------------------------------------------
   6.6 Campo obrigatorio em branco
   Em MOVIMENTO_MANUAL todas as colunas sao NOT NULL.
   Erro esperado: NULL nao permitido para a coluna DES_DESCRICAO.
   --------------------------------------------------------------------- */
INSERT INTO MOVIMENTO_MANUAL
       (DAT_MES, DAT_ANO, NUM_LANCAMENTO, COD_PRODUTO, COD_COSIF,
        DES_DESCRICAO, DAT_MOVIMENTO, COD_USUARIO, VAL_VALOR)
VALUES (12, 2026, 1, '0001', '41510000001',
        NULL, LOCALTIMESTAMP(0), 'TESTE', 10.00);


/* ---------------------------------------------------------------------
   6.7 Valor maior que o tamanho da coluna
   DES_DESCRICAO e VARCHAR(50). Abaixo, 51 caracteres.
   Erro esperado: valor muito longo para a coluna.
   (A API e a tela barram antes, com "maximo 50 caracteres".)
   --------------------------------------------------------------------- */
INSERT INTO MOVIMENTO_MANUAL
       (DAT_MES, DAT_ANO, NUM_LANCAMENTO, COD_PRODUTO, COD_COSIF,
        DES_DESCRICAO, DAT_MOVIMENTO, COD_USUARIO, VAL_VALOR)
VALUES (12, 2026, 1, '0001', '41510000001',
        '123456789012345678901234567890123456789012345678901',
        LOCALTIMESTAMP(0), 'TESTE', 10.00);


/* ---------------------------------------------------------------------
   6.8 O que o BANCO aceita, mas a APLICACAO recusa
   O banco nao tem regra de "mes entre 1 e 12" nem "valor > 0":
   NUMERIC(2,0) aceita 13 e NUMERIC(18,2) aceita valor negativo.
   Essas regras vivem na aplicacao (Bean Validation no back e
   validacao no front). Este INSERT e ACEITO pelo banco:
   --------------------------------------------------------------------- */
INSERT INTO MOVIMENTO_MANUAL
       (DAT_MES, DAT_ANO, NUM_LANCAMENTO, COD_PRODUTO, COD_COSIF,
        DES_DESCRICAO, DAT_MOVIMENTO, COD_USUARIO, VAL_VALOR)
VALUES (13, 2026, 1, '0001', '41510000001',
        'Mes 13 e valor negativo', LOCALTIMESTAMP(0), 'TESTE', -50.00);

-- Desfaz o exemplo:
DELETE FROM MOVIMENTO_MANUAL WHERE DAT_MES = 13 AND DAT_ANO = 2026;

/* Uma evolucao possivel seria reforcar no proprio banco:
   ALTER TABLE MOVIMENTO_MANUAL ADD CONSTRAINT CK_MES   CHECK (DAT_MES BETWEEN 1 AND 12);
   ALTER TABLE MOVIMENTO_MANUAL ADD CONSTRAINT CK_VALOR CHECK (VAL_VALOR > 0);
   (Nao foi feito porque o enunciado pede o DDL exatamente como no diagrama.) */
