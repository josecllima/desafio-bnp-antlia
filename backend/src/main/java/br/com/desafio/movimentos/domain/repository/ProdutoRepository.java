package br.com.desafio.movimentos.domain.repository;

import br.com.desafio.movimentos.domain.model.Produto;

import java.util.List;
import java.util.Optional;

/**
 * Contrato do dominio (nao depende de JPA/Spring).
 * A implementacao fica em infrastructure.persistence (inversao de dependencia - SOLID "D").
 */
public interface ProdutoRepository {

    List<Produto> listarTodos();

    Optional<Produto> buscarPorCodigo(String codProduto);
}
