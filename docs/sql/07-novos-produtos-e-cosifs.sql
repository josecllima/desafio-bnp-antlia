/* =====================================================================
   07 - CADASTRAR NOVOS PRODUTOS E CONTAS COSIF
   ---------------------------------------------------------------------
   Como incluir mais opcoes nos combos Produto e Cosif da tela.

   REGRAS DO MODELO (o que precisa ser respeitado)
   1. ORDEM: primeiro o PRODUTO, depois as contas dele (PRODUTO_COSIF).
      A FK nao deixa ligar conta a um produto que ainda nao existe.
   2. TAMANHOS (CHAR e fixo; o banco recusa valores maiores):
        COD_PRODUTO        CHAR(4)      ex.: '0006'
        DES_PRODUTO        VARCHAR(30)  ate 30 caracteres
        COD_COSIF          CHAR(11)     ex.: '41200000010' (11 digitos, sem pontos)
        COD_CLASSIFICACAO  CHAR(6)      ex.: 'PASSIV', 'ATIVO ', 'RECEIT', 'DESPES'
        STA_STATUS         CHAR(1)      'A' = ativo, 'I' = inativo
   3. CHAVES:
        PRODUTO       -> COD_PRODUTO nao pode repetir
        PRODUTO_COSIF -> o PAR (COD_PRODUTO, COD_COSIF) nao pode repetir;
                         a mesma conta pode ser ligada a varios produtos.
   4. Um produto SEM nenhuma conta aparece no combo Produto, mas o
      combo Cosif fica vazio: nao da para lancar nada nele.

   MERGE ... KEY (em vez de INSERT)
   E um "insere ou atualiza" do H2: se a chave ja existe, atualiza a
   linha; se nao existe, insere. Assim o script pode ser executado
   mais de uma vez sem erro de chave duplicada.

   ATENCAO: o banco e em memoria. O que for incluido aqui SOME ao
   reiniciar o back-end. Para deixar permanente, veja o final do arquivo.

   Os codigos COSIF sao ILUSTRATIVOS (seguem a logica do primeiro
   digito do plano COSIF, mas nao sao contas reais).
   ===================================================================== */


/* ---------------------------------------------------------------------
   MODELO PARA COPIAR
   Troque os valores entre < > e execute.
   ---------------------------------------------------------------------
MERGE INTO PRODUTO (COD_PRODUTO, DES_PRODUTO, STA_STATUS)
KEY (COD_PRODUTO)
VALUES ('<4 digitos>', '<descricao ate 30>', 'A');

MERGE INTO PRODUTO_COSIF (COD_PRODUTO, COD_COSIF, COD_CLASSIFICACAO, STA_STATUS)
KEY (COD_PRODUTO, COD_COSIF)
VALUES ('<mesmo codigo do produto>', '<11 digitos>', '<6 caracteres>', 'A');
   --------------------------------------------------------------------- */


/* =====================================================================
   1. PRODUTOS NOVOS
   ===================================================================== */
MERGE INTO PRODUTO (COD_PRODUTO, DES_PRODUTO, STA_STATUS) KEY (COD_PRODUTO)
VALUES ('0006', 'Poupanca', 'A');

MERGE INTO PRODUTO (COD_PRODUTO, DES_PRODUTO, STA_STATUS) KEY (COD_PRODUTO)
VALUES ('0007', 'Conta Corrente', 'A');

MERGE INTO PRODUTO (COD_PRODUTO, DES_PRODUTO, STA_STATUS) KEY (COD_PRODUTO)
VALUES ('0008', 'Credito Pessoal', 'A');

MERGE INTO PRODUTO (COD_PRODUTO, DES_PRODUTO, STA_STATUS) KEY (COD_PRODUTO)
VALUES ('0009', 'Financiamento Imobiliario', 'A');

MERGE INTO PRODUTO (COD_PRODUTO, DES_PRODUTO, STA_STATUS) KEY (COD_PRODUTO)
VALUES ('0010', 'Fundo de Investimento', 'A');


/* =====================================================================
   2. CONTAS PERMITIDAS PARA CADA PRODUTO NOVO
   Cada produto recebe a conta "de saldo" (ativo ou passivo) e a conta
   "de resultado" (receita ou despesa) que ele movimenta.
   ===================================================================== */

-- 0006 Poupanca: o dinheiro do cliente e uma obrigacao do banco (passivo);
--                o rendimento pago ao cliente e despesa do banco.
MERGE INTO PRODUTO_COSIF (COD_PRODUTO, COD_COSIF, COD_CLASSIFICACAO, STA_STATUS) KEY (COD_PRODUTO, COD_COSIF)
VALUES ('0006', '41200000010', 'PASSIV', 'A');   -- depositos de poupanca
MERGE INTO PRODUTO_COSIF (COD_PRODUTO, COD_COSIF, COD_CLASSIFICACAO, STA_STATUS) KEY (COD_PRODUTO, COD_COSIF)
VALUES ('0006', '81130000011', 'DESPES', 'A');   -- rendimento pago na poupanca

-- 0007 Conta Corrente: saldo do cliente = passivo; tarifas cobradas = receita.
MERGE INTO PRODUTO_COSIF (COD_PRODUTO, COD_COSIF, COD_CLASSIFICACAO, STA_STATUS) KEY (COD_PRODUTO, COD_COSIF)
VALUES ('0007', '41110000012', 'PASSIV', 'A');   -- depositos a vista
MERGE INTO PRODUTO_COSIF (COD_PRODUTO, COD_COSIF, COD_CLASSIFICACAO, STA_STATUS) KEY (COD_PRODUTO, COD_COSIF)
VALUES ('0007', '71790000013', 'RECEIT', 'A');   -- tarifas de conta

-- 0008 Credito Pessoal: valor emprestado = ativo (direito de receber);
--                       juros cobrados = receita.
MERGE INTO PRODUTO_COSIF (COD_PRODUTO, COD_COSIF, COD_CLASSIFICACAO, STA_STATUS) KEY (COD_PRODUTO, COD_COSIF)
VALUES ('0008', '16110000014', 'ATIVO ', 'A');   -- emprestimos a pessoas fisicas
MERGE INTO PRODUTO_COSIF (COD_PRODUTO, COD_COSIF, COD_CLASSIFICACAO, STA_STATUS) KEY (COD_PRODUTO, COD_COSIF)
VALUES ('0008', '71120000015', 'RECEIT', 'A');   -- juros do credito pessoal
-- Exemplo de conta COMPARTILHADA: a receita de juros do consignado
-- (71110000005, ja ligada ao produto 0003) tambem serve ao credito pessoal.
MERGE INTO PRODUTO_COSIF (COD_PRODUTO, COD_COSIF, COD_CLASSIFICACAO, STA_STATUS) KEY (COD_PRODUTO, COD_COSIF)
VALUES ('0008', '71110000005', 'RECEIT', 'A');

-- 0009 Financiamento Imobiliario: saldo financiado = ativo; juros = receita.
MERGE INTO PRODUTO_COSIF (COD_PRODUTO, COD_COSIF, COD_CLASSIFICACAO, STA_STATUS) KEY (COD_PRODUTO, COD_COSIF)
VALUES ('0009', '16140000016', 'ATIVO ', 'A');   -- financiamentos habitacionais
MERGE INTO PRODUTO_COSIF (COD_PRODUTO, COD_COSIF, COD_CLASSIFICACAO, STA_STATUS) KEY (COD_PRODUTO, COD_COSIF)
VALUES ('0009', '71140000017', 'RECEIT', 'A');   -- juros de financiamento

-- 0010 Fundo de Investimento: o banco administra e recebe taxa (receita).
--      O dinheiro aplicado e do fundo, nao do banco: por isso so ha conta
--      de resultado aqui.
MERGE INTO PRODUTO_COSIF (COD_PRODUTO, COD_COSIF, COD_CLASSIFICACAO, STA_STATUS) KEY (COD_PRODUTO, COD_COSIF)
VALUES ('0010', '71710000018', 'RECEIT', 'A');   -- taxa de administracao


/* =====================================================================
   3. ACRESCENTAR UMA CONTA A UM PRODUTO QUE JA EXISTIA
   Ex.: o CDB (0001) passa a aceitar tambem lancamentos de IOF retido.
   Nao precisa mexer na tabela PRODUTO: so cria o novo par.
   ===================================================================== */
MERGE INTO PRODUTO_COSIF (COD_PRODUTO, COD_COSIF, COD_CLASSIFICACAO, STA_STATUS) KEY (COD_PRODUTO, COD_COSIF)
VALUES ('0001', '49910000019', 'PASSIV', 'A');   -- impostos a recolher (IOF/IR)


/* =====================================================================
   4. CONFERENCIA
   ===================================================================== */

-- Todos os produtos e quantas contas cada um tem
SELECT p.COD_PRODUTO,
       p.DES_PRODUTO,
       p.STA_STATUS,
       COUNT(pc.COD_COSIF) AS QTD_CONTAS
  FROM PRODUTO p
  LEFT JOIN PRODUTO_COSIF pc ON pc.COD_PRODUTO = p.COD_PRODUTO
 GROUP BY p.COD_PRODUTO, p.DES_PRODUTO, p.STA_STATUS
 ORDER BY p.COD_PRODUTO;

-- Como cada conta vai aparecer no combo Cosif da tela
SELECT pc.COD_PRODUTO,
       p.DES_PRODUTO,
       CONCAT(pc.COD_COSIF, ' - (', TRIM(pc.COD_CLASSIFICACAO), ')') AS TEXTO_NO_COMBO
  FROM PRODUTO_COSIF pc
  JOIN PRODUTO p ON p.COD_PRODUTO = pc.COD_PRODUTO
 ORDER BY pc.COD_PRODUTO, pc.COD_COSIF;

/* Depois de rodar, recarregue a tela (F5) em http://localhost:4200:
   os produtos novos aparecem no combo e, ao escolher um, o combo
   Cosif mostra apenas as contas dele. */


/* =====================================================================
   5. COMO DEIXAR PERMANENTE (sobreviver ao reinicio do back-end)
   ---------------------------------------------------------------------
   Copie os comandos das partes 1, 2 e 3 para o final do arquivo
       backend/src/main/resources/data.sql
   trocando "MERGE INTO ... KEY (...)" por "INSERT INTO" (o data.sql
   roda num banco vazio, entao nao ha o que atualizar). Exemplo:

   INSERT INTO PRODUTO (COD_PRODUTO, DES_PRODUTO, STA_STATUS)
   VALUES ('0006', 'Poupanca', 'A');

   CUIDADO COM OS TESTES: o RepositoriosJpaTest confere que o
   data.sql tem exatamente 4 produtos (deveListarProdutosDoDataSql)
   e que o produto 0001 tem 2 contas. Se acrescentar produtos ou
   contas do 0001 no data.sql, ajuste esses numeros no teste.
   ===================================================================== */
