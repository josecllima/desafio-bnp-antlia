/* =====================================================================
   05 - ALTERACAO E EXCLUSAO
   A tela do desafio so INCLUI e CONSULTA. Estes comandos existem
   para estudo: mostram o que o modelo permite mudar com seguranca
   e o que nao deve ser mudado.
   Rode o 03-insercao.sql antes.
   ===================================================================== */


/* ---------------------------------------------------------------------
   5.1 Alterar a DESCRICAO de um produto
   Seguro: DES_PRODUTO nao e chave. Os lancamentos ja feitos passam
   a exibir o nome novo no grid, porque o grid busca a descricao
   pelo JOIN (ela nao e copiada para MOVIMENTO_MANUAL).
   --------------------------------------------------------------------- */
UPDATE PRODUTO
   SET DES_PRODUTO = 'Cartao de Credito PF'
 WHERE COD_PRODUTO = '0005';

SELECT COD_PRODUTO, DES_PRODUTO FROM PRODUTO WHERE COD_PRODUTO = '0005';


/* ---------------------------------------------------------------------
   5.2 INATIVAR um produto (em vez de apagar)
   STA_STATUS = 'I'. O historico continua intacto.
   Observacao: a API atual nao filtra por status; o produto inativo
   continuaria aparecendo no combo. Filtrar STA_STATUS = 'A' seria
   uma evolucao natural.
   --------------------------------------------------------------------- */
UPDATE PRODUTO
   SET STA_STATUS = 'I'
 WHERE COD_PRODUTO = '0005';

-- Como seria o combo considerando apenas produtos ativos:
SELECT COD_PRODUTO, DES_PRODUTO
  FROM PRODUTO
 WHERE STA_STATUS = 'A'
 ORDER BY DES_PRODUTO;

-- Reativa, para os proximos exemplos
UPDATE PRODUTO SET STA_STATUS = 'A' WHERE COD_PRODUTO = '0005';


/* ---------------------------------------------------------------------
   5.3 Alterar a CLASSIFICACAO de uma conta do produto
   Seguro: COD_CLASSIFICACAO nao e chave. Muda o texto do combo
   ("COD_COSIF - (CLASSIFICACAO)") e os totais "por tipo" do 04.
   --------------------------------------------------------------------- */
UPDATE PRODUTO_COSIF
   SET COD_CLASSIFICACAO = 'RECEIT'
 WHERE COD_PRODUTO = '0005'
   AND COD_COSIF   = '71130000009';


/* ---------------------------------------------------------------------
   5.4 Corrigir VALOR ou DESCRICAO de um lancamento
   Tecnicamente possivel (nao sao chave), mas em contabilidade o
   correto e NAO editar o que foi lancado: corrige-se com um novo
   lancamento (estorno + lancamento certo), preservando o historico.
   O UPDATE abaixo existe so para mostrar a sintaxe.
   --------------------------------------------------------------------- */
UPDATE MOVIMENTO_MANUAL
   SET DES_DESCRICAO = 'Ajuste juros CDB outubro (revisado)'
 WHERE DAT_MES = 10
   AND DAT_ANO = 2026
   AND NUM_LANCAMENTO = 1
   AND COD_PRODUTO = '0001'
   AND COD_COSIF   = '81120000002';
-- Repare: o WHERE usa a CHAVE PRIMARIA COMPLETA (5 colunas),
-- garantindo que exatamente UMA linha seja alterada.


/* ---------------------------------------------------------------------
   5.5 Por que NAO alterar colunas de chave
   - COD_PRODUTO de PRODUTO: os filhos (PRODUTO_COSIF, MOVIMENTO_MANUAL)
     apontam para o codigo antigo; o banco recusa (FK sem ON UPDATE).
   - Mes/ano/numero de um lancamento: quebraria a sequencia da
     competencia e a trilha de auditoria.
   Se um lancamento foi feito no mes errado, o caminho e lancar de
   novo na competencia certa (e, numa versao completa, estornar o
   errado).

   Exemplo do que o banco recusa (descomente para ver o erro):
   --------------------------------------------------------------------- */
-- UPDATE PRODUTO SET COD_PRODUTO = '0099' WHERE COD_PRODUTO = '0001';
--   -> erro de integridade referencial: existem PRODUTO_COSIF e
--      MOVIMENTO_MANUAL apontando para '0001'.


/* ---------------------------------------------------------------------
   5.6 EXCLUSAO: a ordem e a inversa da insercao
     1o MOVIMENTO_MANUAL   (filhos)
     2o PRODUTO_COSIF
     3o PRODUTO            (pai)
   Apagar o pai antes dos filhos e recusado pela FK.

   Exemplo: remover completamente o produto 0005 (Cartao).
   --------------------------------------------------------------------- */

-- 1o: os lancamentos do produto
DELETE FROM MOVIMENTO_MANUAL
 WHERE COD_PRODUTO = '0005';

-- 2o: as contas permitidas do produto
DELETE FROM PRODUTO_COSIF
 WHERE COD_PRODUTO = '0005';

-- 3o: o produto
DELETE FROM PRODUTO
 WHERE COD_PRODUTO = '0005';

-- Conferencia: nada do 0005 sobrou
SELECT 'PRODUTO' AS TABELA, COUNT(*) AS QTD FROM PRODUTO          WHERE COD_PRODUTO = '0005'
UNION ALL
SELECT 'PRODUTO_COSIF',     COUNT(*)        FROM PRODUTO_COSIF    WHERE COD_PRODUTO = '0005'
UNION ALL
SELECT 'MOVIMENTO_MANUAL',  COUNT(*)        FROM MOVIMENTO_MANUAL WHERE COD_PRODUTO = '0005';

/* Efeito colateral para observar: o lancamento nº 4 de 10/2026 era
   do cartao e foi apagado. Rode a consulta 4.7 do arquivo 04:
   em 10/2026, QTD_LANCAMENTOS passa a ser 3, mas ULTIMO_NUMERO
   continua 4. A sequencia ficou com um BURACO. E por isso que,
   em contabilidade, nao se apaga lancamento: estorna-se. */
