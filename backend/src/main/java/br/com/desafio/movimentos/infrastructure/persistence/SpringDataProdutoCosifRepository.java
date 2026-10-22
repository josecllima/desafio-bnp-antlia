package br.com.desafio.movimentos.infrastructure.persistence;

import br.com.desafio.movimentos.domain.model.ProdutoCosif;
import br.com.desafio.movimentos.domain.model.ProdutoCosifId;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

interface SpringDataProdutoCosifRepository extends JpaRepository<ProdutoCosif, ProdutoCosifId> {

    /** Navega pela chave composta: id.codProduto / id.codCosif. */
    List<ProdutoCosif> findByIdCodProdutoOrderByIdCodCosifAsc(String codProduto);
}
