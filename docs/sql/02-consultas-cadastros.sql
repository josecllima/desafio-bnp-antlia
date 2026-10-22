/* =====================================================================
   02 - CONSULTAS DOS CADASTROS (PRODUTO e PRODUTO_COSIF)
   As duas tabelas que a tela so LE: alimentam os combos.
   Nada aqui altera dados.
   ===================================================================== */


/* ---------------------------------------------------------------------
   2.1 Combo PRODUTO (o que a tela mostra)
   A API devolve os produtos ordenados pela descricao.
   STA_STATUS: 'A' = ativo, 'I' = inativo (premissa do projeto).
   --------------------------------------------------------------------- */
SELECT COD_PRODUTO,
       DES_PRODUTO,
       STA_STATUS
  FROM PRODUTO
 ORDER BY DES_PRODUTO;


/* ---------------------------------------------------------------------
   2.2 Combo COSIF de UM produto (a cascata)
   Quando o usuario escolhe o produto 0001, a tela so oferece estas
   contas. O texto exibido segue o enunciado:
   COD_COSIF - (COD_CLASSIFICACAO)
   Troque '0001' por outro codigo para ver a lista mudar.
   --------------------------------------------------------------------- */
SELECT pc.COD_COSIF,
       pc.COD_CLASSIFICACAO,
       CONCAT(pc.COD_COSIF, ' - (', TRIM(pc.COD_CLASSIFICACAO), ')') AS TEXTO_NO_COMBO
  FROM PRODUTO_COSIF pc
 WHERE pc.COD_PRODUTO = '0001'
 ORDER BY pc.COD_COSIF;


/* ---------------------------------------------------------------------
   2.3 Todas as contas permitidas, POR PRODUTO
   Le-se: "o produto X pode ser lancado nas contas Y e Z".
   --------------------------------------------------------------------- */
SELECT p.COD_PRODUTO,
       p.DES_PRODUTO,
       pc.COD_COSIF,
       pc.COD_CLASSIFICACAO,
       pc.STA_STATUS AS STATUS_DA_LIGACAO
  FROM PRODUTO p
  JOIN PRODUTO_COSIF pc
    ON pc.COD_PRODUTO = p.COD_PRODUTO
 ORDER BY p.COD_PRODUTO, pc.COD_COSIF;


/* ---------------------------------------------------------------------
   2.4 Contas POR TIPO (classificacao)
   COD_CLASSIFICACAO foi usado como a natureza da conta:
     ATIVO  = direito do banco (ex.: emprestimo concedido)
     PASSIV = obrigacao do banco (ex.: CDB captado)
     RECEIT = receita (ex.: juros recebidos)
     DESPES = despesa (ex.: juros pagos)
   --------------------------------------------------------------------- */
SELECT TRIM(pc.COD_CLASSIFICACAO) AS TIPO,
       pc.COD_COSIF,
       p.COD_PRODUTO,
       p.DES_PRODUTO
  FROM PRODUTO_COSIF pc
  JOIN PRODUTO p
    ON p.COD_PRODUTO = pc.COD_PRODUTO
 ORDER BY TIPO, pc.COD_COSIF;

-- Quantas contas de cada tipo existem
SELECT TRIM(COD_CLASSIFICACAO) AS TIPO,
       COUNT(*)                AS QTD_CONTAS
  FROM PRODUTO_COSIF
 GROUP BY TRIM(COD_CLASSIFICACAO)
 ORDER BY TIPO;


/* ---------------------------------------------------------------------
   2.5 Contas POR GRUPO DO PLANO COSIF (primeiro digito do codigo)
   No COSIF, o primeiro digito indica o grande grupo da conta.
   E outra forma de "tipo", independente da classificacao cadastrada.
   --------------------------------------------------------------------- */
SELECT SUBSTRING(pc.COD_COSIF, 1, 1) AS GRUPO,
       CASE SUBSTRING(pc.COD_COSIF, 1, 1)
            WHEN '1' THEN 'Ativo circulante e realizavel a longo prazo'
            WHEN '2' THEN 'Ativo permanente'
            WHEN '3' THEN 'Compensacao (ativo)'
            WHEN '4' THEN 'Passivo circulante e exigivel a longo prazo'
            WHEN '6' THEN 'Patrimonio liquido'
            WHEN '7' THEN 'Contas de resultado credoras (receitas)'
            WHEN '8' THEN 'Contas de resultado devedoras (despesas)'
            WHEN '9' THEN 'Compensacao (passivo)'
            ELSE 'Outro'
       END AS DESCRICAO_DO_GRUPO,
       pc.COD_COSIF,
       p.DES_PRODUTO
  FROM PRODUTO_COSIF pc
  JOIN PRODUTO p
    ON p.COD_PRODUTO = pc.COD_PRODUTO
 ORDER BY GRUPO, pc.COD_COSIF;


/* ---------------------------------------------------------------------
   2.6 Quantas contas cada produto tem
   --------------------------------------------------------------------- */
SELECT p.COD_PRODUTO,
       p.DES_PRODUTO,
       COUNT(pc.COD_COSIF) AS QTD_CONTAS_PERMITIDAS
  FROM PRODUTO p
  LEFT JOIN PRODUTO_COSIF pc
         ON pc.COD_PRODUTO = p.COD_PRODUTO
 GROUP BY p.COD_PRODUTO, p.DES_PRODUTO
 ORDER BY p.COD_PRODUTO;


/* ---------------------------------------------------------------------
   2.7 Produtos SEM nenhuma conta parametrizada
   Um produto assim aparece no combo Produto, mas o combo Cosif
   fica vazio: nao da para lancar nada nele.
   (Logo apos subir o backend, retorna vazio.)
   --------------------------------------------------------------------- */
SELECT p.COD_PRODUTO,
       p.DES_PRODUTO
  FROM PRODUTO p
 WHERE NOT EXISTS (SELECT 1
                     FROM PRODUTO_COSIF pc
                    WHERE pc.COD_PRODUTO = p.COD_PRODUTO);


/* ---------------------------------------------------------------------
   2.8 Uma mesma conta ligada a MAIS DE UM produto
   O modelo permite (a chave e o par produto + conta).
   (Com o data.sql original, retorna vazio; o script 03 cria um caso.)
   --------------------------------------------------------------------- */
SELECT pc.COD_COSIF,
       COUNT(*) AS QTD_PRODUTOS
  FROM PRODUTO_COSIF pc
 GROUP BY pc.COD_COSIF
HAVING COUNT(*) > 1;
