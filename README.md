# Movimentos Manuais

Desafio técnico BNP Paribas / Antlia: tela de inclusão e consulta de movimentos manuais.

- Back-end: Java 17, Spring Boot 3.3, Spring Data JPA, H2
- Front-end: Angular 22

## Como rodar

Requisitos: JDK 17+, Maven 3.9+ e Node 22.22+ (testei com Node 24).

Back-end (porta 8080):

```
cd backend
mvn spring-boot:run
```

- Swagger: http://localhost:8080/swagger-ui.html
- Console do H2: http://localhost:8080/h2-console (JDBC URL `jdbc:h2:mem:movimentosdb`, usuário `sa`, sem senha)

Front-end (porta 4200):

```
cd frontend
npm install
npm start
```

Testes:

```
cd backend && mvn test
cd frontend && npx ng test --watch=false
```

## Estrutura do back-end

- `domain` - entidades e interfaces dos repositórios
- `application` - services com as regras de negócio e DTOs
- `infrastructure` - implementação JPA dos repositórios
- `api` - controllers, tratamento de erros e CORS

## Endpoints

```
GET  /api/produtos
GET  /api/produtos/{codProduto}/cosifs
GET  /api/movimentos?mes=&ano=
POST /api/movimentos
```

## Observações

- O DDL está no `schema.sql`, com os tipos do diagrama do enunciado; o Hibernate não gera as tabelas. Como o H2 não tem `smalldatetime`, usei `TIMESTAMP(0)`.
- PRODUTO e PRODUTO_COSIF são carregados pelo `data.sql`, com códigos fictícios.
- O número do lançamento é o maior do mesmo mês/ano + 1, calculado na mesma transação do insert. Com acesso concorrente, duas inclusões podem pegar o mesmo número; em produção eu usaria uma tabela de controle com `SELECT ... FOR UPDATE` ou uma sequence por competência.
- A gravação usa `persist` em vez de `save` para não sobrescrever um lançamento com a mesma chave. Nesse caso a API devolve 409.
- O protótipo não tem filtro de mês/ano separado dos campos de inclusão, então o grid lista todos os lançamentos. A API já aceita `mes` e `ano` como filtro.
- O banco é em memória: os lançamentos se perdem ao reiniciar o back-end.
