package br.com.desafio.movimentos.infrastructure.persistence;

import br.com.desafio.movimentos.domain.model.ProdutoCosif;
import br.com.desafio.movimentos.domain.model.ProdutoCosifId;
import br.com.desafio.movimentos.domain.repository.ProdutoCosifRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
@RequiredArgsConstructor
public class ProdutoCosifRepositoryJpa implements ProdutoCosifRepository {
    private final SpringDataProdutoCosifRepository jpa;

    @Override
    public List<ProdutoCosif> listarPorProduto(String codProduto) {
        return jpa.findByIdCodProdutoOrderByIdCodCosifAsc(codProduto);
    }

    @Override
    public boolean existe(String codProduto, String codCosif) {
        return jpa.existsById(new ProdutoCosifId(codProduto, codCosif));
    }
}
