/* =====================================================================
   04 - CONSULTAS DE MOVIMENTOS
   Rode o 03-insercao.sql antes, para ter dados.
   Nada aqui altera dados.
   ===================================================================== */


/* ---------------------------------------------------------------------
   4.1 GERAL: a mesma consulta do grid da tela
   Junta MOVIMENTO_MANUAL -> PRODUTO_COSIF -> PRODUTO para trazer a
   descricao do produto. Formata mes e numero com zeros a esquerda,
   como no prototipo (02, 001). Mais recentes primeiro.
   --------------------------------------------------------------------- */
SELECT LPAD(CAST(m.DAT_MES AS VARCHAR), 2, '0')        AS MES,
       m.DAT_ANO                                        AS ANO,
       m.COD_PRODUTO                                    AS CODIGO_DO_PRODUTO,
       p.DES_PRODUTO                                    AS DESCRICAO_DO_PRODUTO,
       LPAD(CAST(m.NUM_LANCAMENTO AS VARCHAR), 3, '0') AS NR_LANCAMENTO,
       m.DES_DESCRICAO                                  AS DESCRICAO,
       m.VAL_VALOR                                      AS VALOR
  FROM MOVIMENTO_MANUAL m
  JOIN PRODUTO_COSIF pc
    ON pc.COD_PRODUTO = m.COD_PRODUTO
   AND pc.COD_COSIF   = m.COD_COSIF
  JOIN PRODUTO p
    ON p.COD_PRODUTO  = pc.COD_PRODUTO
 ORDER BY m.DAT_ANO DESC, m.DAT_MES DESC, m.NUM_LANCAMENTO DESC;


/* ---------------------------------------------------------------------
   4.2 POR COMPETENCIA (mes/ano)
   E o filtro opcional da API: GET /api/movimentos?mes=10&ano=2026
   --------------------------------------------------------------------- */
SELECT m.NUM_LANCAMENTO, m.COD_PRODUTO, m.COD_COSIF,
       m.DES_DESCRICAO, m.VAL_VALOR
  FROM MOVIMENTO_MANUAL m
 WHERE m.DAT_MES = 10
   AND m.DAT_ANO = 2026
 ORDER BY m.NUM_LANCAMENTO;


/* ---------------------------------------------------------------------
   4.3 POR PRODUTO
   Todos os lancamentos de um produto, em qualquer competencia.
   Troque '0001' pelo produto desejado.
   --------------------------------------------------------------------- */
SELECT m.DAT_MES, m.DAT_ANO, m.NUM_LANCAMENTO,
       p.DES_PRODUTO, m.COD_COSIF, m.DES_DESCRICAO, m.VAL_VALOR
  FROM MOVIMENTO_MANUAL m
  JOIN PRODUTO p
    ON p.COD_PRODUTO = m.COD_PRODUTO
 WHERE m.COD_PRODUTO = '0001'
 ORDER BY m.DAT_ANO, m.DAT_MES, m.NUM_LANCAMENTO;


/* ---------------------------------------------------------------------
   4.4 POR CONTA COSIF
   Uma conta pode receber lancamentos de mais de um produto
   (ex.: 71110000005 e usada pelo consignado e pelo cartao).
   --------------------------------------------------------------------- */
SELECT m.COD_COSIF, p.DES_PRODUTO, m.DAT_MES, m.DAT_ANO,
       m.NUM_LANCAMENTO, m.DES_DESCRICAO, m.VAL_VALOR
  FROM MOVIMENTO_MANUAL m
  JOIN PRODUTO p
    ON p.COD_PRODUTO = m.COD_PRODUTO
 WHERE m.COD_COSIF = '71110000005'
 ORDER BY m.DAT_ANO, m.DAT_MES, m.NUM_LANCAMENTO;


/* ---------------------------------------------------------------------
   4.5 POR TIPO (classificacao da conta)
   A classificacao NAO esta em MOVIMENTO_MANUAL: vem do par
   produto + conta em PRODUTO_COSIF. Por isso o JOIN e pelas DUAS
   colunas da FK composta.
   --------------------------------------------------------------------- */
SELECT TRIM(pc.COD_CLASSIFICACAO) AS TIPO,
       m.DAT_MES, m.DAT_ANO, m.NUM_LANCAMENTO,
       m.COD_PRODUTO, m.COD_COSIF, m.VAL_VALOR
  FROM MOVIMENTO_MANUAL m
  JOIN PRODUTO_COSIF pc
    ON pc.COD_PRODUTO = m.COD_PRODUTO
   AND pc.COD_COSIF   = m.COD_COSIF
 WHERE TRIM(pc.COD_CLASSIFICACAO) = 'RECEIT'
 ORDER BY m.DAT_ANO, m.DAT_MES, m.NUM_LANCAMENTO;


/* ---------------------------------------------------------------------
   4.6 TOTAIS POR PRODUTO
   --------------------------------------------------------------------- */
SELECT p.COD_PRODUTO,
       p.DES_PRODUTO,
       COUNT(m.NUM_LANCAMENTO)       AS QTD_LANCAMENTOS,
       COALESCE(SUM(m.VAL_VALOR), 0) AS TOTAL
  FROM PRODUTO p
  LEFT JOIN MOVIMENTO_MANUAL m
         ON m.COD_PRODUTO = p.COD_PRODUTO
 GROUP BY p.COD_PRODUTO, p.DES_PRODUTO
 ORDER BY TOTAL DESC;


/* ---------------------------------------------------------------------
   4.7 TOTAIS POR COMPETENCIA
   Quantos ajustes manuais houve em cada fechamento e o ultimo numero.
   Em cada competencia, QTD = ULTIMO_NUMERO (a sequencia nao tem buracos,
   pois nao ha exclusao pela tela).
   --------------------------------------------------------------------- */
SELECT m.DAT_ANO,
       m.DAT_MES,
       COUNT(*)              AS QTD_LANCAMENTOS,
       MAX(m.NUM_LANCAMENTO) AS ULTIMO_NUMERO,
       SUM(m.VAL_VALOR)      AS TOTAL
  FROM MOVIMENTO_MANUAL m
 GROUP BY m.DAT_ANO, m.DAT_MES
 ORDER BY m.DAT_ANO, m.DAT_MES;


/* ---------------------------------------------------------------------
   4.8 TOTAIS POR TIPO E COMPETENCIA
   Visao "contabil": quanto foi ajustado em ativo, passivo,
   receita e despesa em cada mes.
   --------------------------------------------------------------------- */
SELECT m.DAT_ANO,
       m.DAT_MES,
       TRIM(pc.COD_CLASSIFICACAO) AS TIPO,
       COUNT(*)                   AS QTD,
       SUM(m.VAL_VALOR)           AS TOTAL
  FROM MOVIMENTO_MANUAL m
  JOIN PRODUTO_COSIF pc
    ON pc.COD_PRODUTO = m.COD_PRODUTO
   AND pc.COD_COSIF   = m.COD_COSIF
 GROUP BY m.DAT_ANO, m.DAT_MES, TRIM(pc.COD_CLASSIFICACAO)
 ORDER BY m.DAT_ANO, m.DAT_MES, TIPO;


/* ---------------------------------------------------------------------
   4.9 PROXIMO NUMERO de cada competencia
   O que a aplicacao usaria na proxima inclusao.
   --------------------------------------------------------------------- */
SELECT m.DAT_MES,
       m.DAT_ANO,
       MAX(m.NUM_LANCAMENTO) + 1 AS PROXIMO_NUMERO
  FROM MOVIMENTO_MANUAL m
 GROUP BY m.DAT_ANO, m.DAT_MES
 ORDER BY m.DAT_ANO, m.DAT_MES;

-- Para uma competencia ainda sem lancamentos, o resultado e 1:
SELECT COALESCE(MAX(NUM_LANCAMENTO), 0) + 1 AS PROXIMO_NUMERO
  FROM MOVIMENTO_MANUAL
 WHERE DAT_MES = 12 AND DAT_ANO = 2026;


/* ---------------------------------------------------------------------
   4.10 AUDITORIA: quem lancou e quando
   DAT_MOVIMENTO (quando foi digitado) e diferente da competencia
   (a qual fechamento pertence).
   --------------------------------------------------------------------- */
SELECT m.COD_USUARIO,
       m.DAT_MOVIMENTO,
       CONCAT(LPAD(CAST(m.DAT_MES AS VARCHAR), 2, '0'), '/', m.DAT_ANO) AS COMPETENCIA,
       m.NUM_LANCAMENTO,
       m.DES_DESCRICAO,
       m.VAL_VALOR
  FROM MOVIMENTO_MANUAL m
 ORDER BY m.DAT_MOVIMENTO DESC;

-- Lancamentos digitados HOJE
SELECT *
  FROM MOVIMENTO_MANUAL
 WHERE CAST(DAT_MOVIMENTO AS DATE) = CURRENT_DATE;


/* ---------------------------------------------------------------------
   4.11 Busca por texto na descricao
   --------------------------------------------------------------------- */
SELECT DAT_MES, DAT_ANO, NUM_LANCAMENTO, DES_DESCRICAO, VAL_VALOR
  FROM MOVIMENTO_MANUAL
 WHERE UPPER(DES_DESCRICAO) LIKE '%CDB%';
