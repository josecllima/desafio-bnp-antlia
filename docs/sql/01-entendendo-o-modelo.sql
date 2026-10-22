/* =====================================================================
   01 - ENTENDENDO O MODELO
   Consultas ao catalogo do banco (INFORMATION_SCHEMA) para ver,
   na pratica, as colunas, as chaves primarias e as chaves estrangeiras.
   Nada aqui altera dados.
   ===================================================================== */


/* ---------------------------------------------------------------------
   1.1 As tres tabelas e suas colunas
   Mostra tipo, tamanho e se a coluna aceita nulo.
   Repare: em MOVIMENTO_MANUAL nenhuma coluna aceita nulo.
   --------------------------------------------------------------------- */
SELECT c.TABLE_NAME          AS TABELA,
       c.ORDINAL_POSITION    AS ORDEM,
       c.COLUMN_NAME         AS COLUNA,
       c.DATA_TYPE           AS TIPO,
       c.CHARACTER_MAXIMUM_LENGTH AS TAMANHO,
       c.NUMERIC_PRECISION   AS PRECISAO,
       c.NUMERIC_SCALE       AS DECIMAIS,
       c.IS_NULLABLE         AS ACEITA_NULO
  FROM INFORMATION_SCHEMA.COLUMNS c
 WHERE c.TABLE_SCHEMA = 'PUBLIC'
   AND c.TABLE_NAME IN ('PRODUTO', 'PRODUTO_COSIF', 'MOVIMENTO_MANUAL')
 ORDER BY CASE c.TABLE_NAME WHEN 'PRODUTO' THEN 1
                            WHEN 'PRODUTO_COSIF' THEN 2
                            ELSE 3 END,
          c.ORDINAL_POSITION;


/* ---------------------------------------------------------------------
   1.2 Chaves primarias (o que identifica UMA linha)

   PRODUTO          -> COD_PRODUTO
                       um codigo = um produto.
   PRODUTO_COSIF    -> COD_PRODUTO + COD_COSIF
                       o mesmo produto aparece varias vezes (uma por conta)
                       e a mesma conta pode aparecer para varios produtos;
                       o que nao pode repetir e o PAR.
   MOVIMENTO_MANUAL -> DAT_MES + DAT_ANO + NUM_LANCAMENTO
                       + COD_PRODUTO + COD_COSIF
   --------------------------------------------------------------------- */
SELECT tc.TABLE_NAME      AS TABELA,
       tc.CONSTRAINT_NAME AS RESTRICAO,
       kcu.COLUMN_NAME    AS COLUNA,
       kcu.ORDINAL_POSITION AS POSICAO_NA_CHAVE
  FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
  JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu
    ON kcu.CONSTRAINT_SCHEMA = tc.CONSTRAINT_SCHEMA
   AND kcu.CONSTRAINT_NAME   = tc.CONSTRAINT_NAME
 WHERE tc.TABLE_SCHEMA = 'PUBLIC'
   AND tc.CONSTRAINT_TYPE = 'PRIMARY KEY'
 ORDER BY tc.TABLE_NAME, kcu.ORDINAL_POSITION;


/* ---------------------------------------------------------------------
   1.3 Chaves estrangeiras (como as tabelas se ligam)

   FK_PRODUTO_COSIF_PRODUTO
     PRODUTO_COSIF.COD_PRODUTO -> PRODUTO.COD_PRODUTO
     "so posso ligar uma conta a um produto que existe".

   FK_MOVIMENTO_MANUAL_PRODUTO_COSIF  (FK COMPOSTA: 2 colunas juntas)
     MOVIMENTO_MANUAL.(COD_PRODUTO, COD_COSIF)
       -> PRODUTO_COSIF.(COD_PRODUTO, COD_COSIF)
     "so posso lancar num par produto + conta que esteja parametrizado".
     E esta FK que impede lancar um CDB numa conta de emprestimo.
   --------------------------------------------------------------------- */
SELECT tc.CONSTRAINT_NAME AS FK,
       tc.TABLE_NAME      AS TABELA_FILHA,
       kcu.COLUMN_NAME    AS COLUNA_FILHA,
       ccu.TABLE_NAME     AS TABELA_PAI,
       ccu.COLUMN_NAME    AS COLUNA_PAI
  FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS tc
  JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE kcu
    ON kcu.CONSTRAINT_SCHEMA = tc.CONSTRAINT_SCHEMA
   AND kcu.CONSTRAINT_NAME   = tc.CONSTRAINT_NAME
  JOIN INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS rc
    ON rc.CONSTRAINT_SCHEMA = tc.CONSTRAINT_SCHEMA
   AND rc.CONSTRAINT_NAME   = tc.CONSTRAINT_NAME
  JOIN INFORMATION_SCHEMA.KEY_COLUMN_USAGE ccu
    ON ccu.CONSTRAINT_SCHEMA = rc.UNIQUE_CONSTRAINT_SCHEMA
   AND ccu.CONSTRAINT_NAME   = rc.UNIQUE_CONSTRAINT_NAME
   AND ccu.ORDINAL_POSITION  = kcu.POSITION_IN_UNIQUE_CONSTRAINT
 WHERE tc.TABLE_SCHEMA = 'PUBLIC'
   AND tc.CONSTRAINT_TYPE = 'FOREIGN KEY'
 ORDER BY tc.CONSTRAINT_NAME, kcu.ORDINAL_POSITION;


/* ---------------------------------------------------------------------
   1.4 Quantas linhas existem em cada tabela
   Logo apos subir o backend: 4 produtos, 7 contas, 0 movimentos.
   --------------------------------------------------------------------- */
SELECT 'PRODUTO'          AS TABELA, COUNT(*) AS LINHAS FROM PRODUTO
UNION ALL
SELECT 'PRODUTO_COSIF',              COUNT(*)           FROM PRODUTO_COSIF
UNION ALL
SELECT 'MOVIMENTO_MANUAL',           COUNT(*)           FROM MOVIMENTO_MANUAL;


/* ---------------------------------------------------------------------
   1.5 A arvore completa: cada produto com suas contas permitidas
   e quantos lancamentos cada par ja recebeu.
   LEFT JOIN: mostra tambem produtos sem conta e contas sem lancamento.
   --------------------------------------------------------------------- */
SELECT p.COD_PRODUTO,
       p.DES_PRODUTO,
       pc.COD_COSIF,
       pc.COD_CLASSIFICACAO,
       COUNT(m.NUM_LANCAMENTO) AS QTD_LANCAMENTOS
  FROM PRODUTO p
  LEFT JOIN PRODUTO_COSIF pc
         ON pc.COD_PRODUTO = p.COD_PRODUTO
  LEFT JOIN MOVIMENTO_MANUAL m
         ON m.COD_PRODUTO = pc.COD_PRODUTO
        AND m.COD_COSIF   = pc.COD_COSIF
 GROUP BY p.COD_PRODUTO, p.DES_PRODUTO, pc.COD_COSIF, pc.COD_CLASSIFICACAO
 ORDER BY p.COD_PRODUTO, pc.COD_COSIF;
