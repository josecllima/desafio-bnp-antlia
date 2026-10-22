-- =====================================================================
-- Desafio BNP Paribas & Antlia - Modelo de dados
-- Tipos, PKs e FKs conforme o diagrama do enunciado.
-- smalldatetime (SQL Server) -> TIMESTAMP(0) no H2
-- =====================================================================

DROP TABLE IF EXISTS MOVIMENTO_MANUAL;
DROP TABLE IF EXISTS PRODUTO_COSIF;
DROP TABLE IF EXISTS PRODUTO;

-- ---------------------------------------------------------------------
-- PRODUTO
-- ---------------------------------------------------------------------
CREATE TABLE PRODUTO (
    COD_PRODUTO   CHAR(4)      NOT NULL,
    DES_PRODUTO   VARCHAR(30)  NULL,
    STA_STATUS    CHAR(1)      NULL,
    CONSTRAINT PK_PRODUTO PRIMARY KEY (COD_PRODUTO)
);

-- ---------------------------------------------------------------------
-- PRODUTO_COSIF (1 produto : N cosifs)
-- ---------------------------------------------------------------------
CREATE TABLE PRODUTO_COSIF (
    COD_PRODUTO        CHAR(4)   NOT NULL,
    COD_COSIF          CHAR(11)  NOT NULL,
    COD_CLASSIFICACAO  CHAR(6)   NULL,
    STA_STATUS         CHAR(1)   NULL,
    CONSTRAINT PK_PRODUTO_COSIF PRIMARY KEY (COD_PRODUTO, COD_COSIF),
    CONSTRAINT FK_PRODUTO_COSIF_PRODUTO FOREIGN KEY (COD_PRODUTO)
        REFERENCES PRODUTO (COD_PRODUTO)
);

-- ---------------------------------------------------------------------
-- MOVIMENTO_MANUAL (1 produto_cosif : N movimentos)
-- Nenhum campo aceita nulo
-- ---------------------------------------------------------------------
CREATE TABLE MOVIMENTO_MANUAL (
    DAT_MES         NUMERIC(2,0)   NOT NULL,
    DAT_ANO         NUMERIC(4,0)   NOT NULL,
    NUM_LANCAMENTO  NUMERIC(18,0)  NOT NULL,
    COD_PRODUTO     CHAR(4)        NOT NULL,
    COD_COSIF       CHAR(11)       NOT NULL,
    DES_DESCRICAO   VARCHAR(50)    NOT NULL,
    DAT_MOVIMENTO   TIMESTAMP(0)   NOT NULL,
    COD_USUARIO     VARCHAR(15)    NOT NULL,
    VAL_VALOR       NUMERIC(18,2)  NOT NULL,
    CONSTRAINT PK_MOVIMENTO_MANUAL
        PRIMARY KEY (DAT_MES, DAT_ANO, NUM_LANCAMENTO, COD_PRODUTO, COD_COSIF),
    CONSTRAINT FK_MOVIMENTO_MANUAL_PRODUTO_COSIF FOREIGN KEY (COD_PRODUTO, COD_COSIF)
        REFERENCES PRODUTO_COSIF (COD_PRODUTO, COD_COSIF)
);
