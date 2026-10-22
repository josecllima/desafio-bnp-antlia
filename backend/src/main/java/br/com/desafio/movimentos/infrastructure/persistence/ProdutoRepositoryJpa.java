package br.com.desafio.movimentos.infrastructure.persistence;

import br.com.desafio.movimentos.domain.model.Produto;
import br.com.desafio.movimentos.domain.repository.ProdutoRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
@RequiredArgsConstructor
public class ProdutoRepositoryJpa implements ProdutoRepository {
    private final SpringDataProdutoRepository jpa;

    @Override
    public List<Produto> listarTodos() {
        return jpa.findAllByOrderByDescricaoAsc();
    }

    @Override
    public Optional<Produto> buscarPorCodigo(String codProduto) {
        return jpa.findById(codProduto);
    }
}
