package br.com.desafio.movimentos.domain.repository;

import br.com.desafio.movimentos.domain.model.ProdutoCosif;

import java.util.List;

public interface ProdutoCosifRepository {

    /** Cosifs de um produto (combo em cascata). */
    List<ProdutoCosif> listarPorProduto(String codProduto);

    /** Valida se o Cosif pertence ao produto informado. */
    boolean existe(String codProduto, String codCosif);
}
