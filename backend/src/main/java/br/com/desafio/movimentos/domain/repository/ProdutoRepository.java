package br.com.desafio.movimentos.domain.repository;

import br.com.desafio.movimentos.domain.model.Produto;

import java.util.List;
import java.util.Optional;

public interface ProdutoRepository {
    List<Produto> listarTodos();

    Optional<Produto> buscarPorCodigo(String codProduto);
}
