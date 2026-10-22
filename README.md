# Desafio BNP Paribas & Antlia — Movimentos Manuais

Aplicação em camadas para **inclusão e consulta de movimentos manuais**, construída a partir do protótipo e do modelo de dados do enunciado.

| Camada | Tecnologia |
|---|---|
| Front-end | Angular 22 (standalone components, signals, Reactive Forms) |
| Back-end | Java 17 + Spring Boot 3.3 (API REST) |
| Persistência | Spring Data JPA / Hibernate |
| Banco de dados | H2 em memória (modo compatível com SQL Server) |
| Documentação da API | Swagger / OpenAPI (springdoc) |
| Testes | JUnit 5, Mockito, AssertJ, MockMvc (back) · Vitest + TestBed (front) |

---

## Como executar

### Pré-requisitos
- **JDK 17** ou superior
- **Maven 3.9+** (ou uma IDE com Maven embutido, como IntelliJ IDEA)
- **Node.js 24 LTS** (ou 22.22.3+) e **npm**

### 1. Back-end (porta 8080)
```bash
cd backend
mvn spring-boot:run
```
Ou, no IntelliJ: abrir a pasta `backend` e executar a classe `MovimentosApplication`.

| Recurso | URL |
|---|---|
| Swagger UI | http://localhost:8080/swagger-ui.html |
| Console do H2 | http://localhost:8080/h2-console — JDBC URL `jdbc:h2:mem:movimentosdb`, usuário `sa`, senha vazia |

### 2. Front-end (porta 4200)
```bash
cd frontend
npm install
npm start          # equivale a: ng serve
```
Acessar **http://localhost:4200** (o back-end precisa estar rodando).

### 3. Testes
```bash
# back-end: 14 testes (unitários, integração JPA e camada web)
cd backend
mvn test

# front-end: 7 testes (services e componente)
cd frontend
npm test
```

---

## Estrutura do projeto

```
desafio-bnp-antlia/
├── backend/                         API REST (Spring Boot)
│   └── src/main/java/br/com/desafio/movimentos/
│       ├── domain/
│       │   ├── model/               entidades JPA e chaves compostas (@EmbeddedId)
│       │   └── repository/          interfaces (contratos) dos repositórios
│       ├── application/
│       │   ├── service/             casos de uso e regras de negócio
│       │   ├── dto/                 objetos de entrada/saída (records)
│       │   └── exception/           exceção de regra de negócio
│       ├── infrastructure/
│       │   ├── persistence/         implementações JPA dos repositórios
│       │   └── config/              beans de infraestrutura (Clock)
│       └── api/
│           ├── controller/          endpoints REST
│           ├── exception/           tratamento global de erros (@RestControllerAdvice)
│           └── config/              CORS
│   └── src/main/resources/
│       ├── schema.sql               DDL com os tipos, PKs e FKs do enunciado
│       └── data.sql                 carga inicial de PRODUTO e PRODUTO_COSIF
└── frontend/                        Angular
    └── src/app/
        ├── core/services/           acesso à API (ProdutoService, MovimentoService)
        ├── models/                  interfaces TypeScript (espelham os DTOs)
        └── movimentos-manuais/      tela (formulário + grid)
```

### Arquitetura do back-end
Arquitetura em camadas inspirada em Clean Architecture / DDD, com as **dependências apontando para o domínio**:

```
api  ──►  application  ──►  domain  ◄──  infrastructure
                              (interfaces)    (implementa com JPA)
```

- **domain** não depende de nenhuma outra camada; define as entidades e os contratos dos repositórios.
- **application** contém as regras de negócio e depende apenas das interfaces do domínio (inversão de dependência), o que permite testá-la com mocks, sem banco.
- **infrastructure** implementa os contratos com Spring Data JPA.
- **api** só traduz HTTP ⇄ DTO e delega para os services.

---

## API REST

| Método | Endpoint | Descrição |
|---|---|---|
| `GET` | `/api/produtos` | Combo Produto (exibe `DES_PRODUTO`) |
| `GET` | `/api/produtos/{codProduto}/cosifs` | Combo Cosif em cascata (exibe `COD_COSIF - (COD_CLASSIFICACAO)`) |
| `GET` | `/api/movimentos?mes=&ano=` | Grid; `mes` e `ano` são filtros opcionais |
| `POST` | `/api/movimentos` | Inclui um movimento → `201 Created` |

Exemplo de inclusão:
```json
POST /api/movimentos
{
  "mes": 10,
  "ano": 2026,
  "codProduto": "0001",
  "codCosif": "41510000001",
  "valor": 150.75,
  "descricao": "Ajuste manual"
}
```

Erros seguem um formato padronizado:
```json
{
  "dataHora": "2026-10-22T10:00:00",
  "status": 400,
  "erro": "Dados invalidos",
  "mensagem": "Um ou mais campos estao invalidos",
  "campos": [{ "campo": "mes", "mensagem": "Mes deve estar entre 1 e 12" }]
}
```

| Status | Quando |
|---|---|
| 400 | Campo inválido (Bean Validation) ou regra de negócio violada |
| 409 | Conflito de chave ao gravar (inclusão simultânea) |
| 500 | Erro inesperado (sem expor detalhes internos) |

---

## Regras de negócio implementadas

| # | Regra do enunciado | Onde |
|---|---|---|
| 1 | Grid sempre preenchido por consulta automática ao banco | Front consulta a API ao abrir a tela e após cada inclusão |
| 2a | Botão **Novo** habilita os campos | `MovimentosManuais.novo()` |
| 2b | Mês e ano digitados | Inputs validados (mês 1–12, ano com 4 dígitos) no front e no back |
| 2c | Combos Produto e Cosif carregados das tabelas | `ProdutoService` / `ProdutoController`; Cosif filtrado pelo produto |
| 2d | `NUM_LANCAMENTO` = último lançamento do **mesmo mês/ano** + 1 | `MovimentoManualService.incluir()` (independe do produto) |
| 2e | `VAL_VALOR` e `DES_DESCRICAO` digitados | Valor > 0; descrição até 50 caracteres |
| 2f | `DAT_MOVIMENTO` = data/hora da gravação | Gerada no back (`Clock` injetado) |
| 2g | `COD_USUARIO` fixo `"TESTE"` | Definido no back |
| 2h | Após incluir: grid atualizado e campos desabilitados | `MovimentosManuais.incluir()` |

Validação adicional: o back-end rejeita um Cosif que não pertença ao produto informado.

---

## Decisões e premissas

- **Consulta por mês/ano.** O protótipo não tem campos de filtro separados dos campos de inclusão. O grid exibe todos os movimentos (ordenados por ano, mês e lançamento, do mais recente para o mais antigo), e a API aceita `mes` e `ano` como filtros opcionais, prontos para uso.
- **Modelo de dados.** O DDL está em `schema.sql`, escrito à mão para respeitar exatamente os tipos, PKs e FKs do diagrama. O Hibernate **não** gera as tabelas (`ddl-auto=none`). Como o H2 não tem `smalldatetime`, `DAT_MOVIMENTO` usa `TIMESTAMP(0)`, e a aplicação grava sem fração de segundo.
- **Chaves compostas.** Mapeadas com `@EmbeddedId` (`ProdutoCosifId` e `MovimentoManualId`).
- **Gravação com `persist` em vez de `save`.** Como a chave é informada pela aplicação, o `save()` do Spring Data faria *merge*: um SELECT prévio e, se a chave já existisse, um UPDATE que sobrescreveria outro lançamento. Com `persist`, a gravação é sempre um INSERT, e uma chave duplicada gera erro de PK, devolvido como **409**.
- **Concorrência na numeração.** O cálculo `MAX(NUM_LANCAMENTO) + 1` e o INSERT ocorrem na mesma transação. Em um cenário de alta concorrência, duas inclusões simultâneas no mesmo mês/ano poderiam calcular o mesmo número. Como a PK também contém produto e Cosif, isso nem sempre viola a PK. Alternativas para produção: tabela de controle de numeração por mês/ano com **lock pessimista** (`SELECT ... FOR UPDATE`), ou *sequence* por período, com retry em caso de conflito.
- **Banco em memória.** Os dados de `MOVIMENTO_MANUAL` são perdidos ao reiniciar o back-end. `PRODUTO` e `PRODUTO_COSIF` são recarregados pelo `data.sql`. A troca para Oracle ou SQL Server exige apenas outro datasource e o DDL correspondente.
- **CORS.** Liberado para `http://localhost:4200`, configurável em `app.cors.allowed-origins`.

---

## Possíveis evoluções
- Numeração de lançamento com controle de concorrência (lock pessimista ou *sequence*).
- Perfis Spring para Oracle/SQL Server e migrações versionadas (Flyway).
- Filtro de mês/ano e paginação no grid.
- Componentes Spring Cloud (Config Server, Gateway) e containerização com Docker.
