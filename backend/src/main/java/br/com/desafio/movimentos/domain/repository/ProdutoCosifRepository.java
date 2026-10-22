package br.com.desafio.movimentos.domain.repository;

import br.com.desafio.movimentos.domain.model.ProdutoCosif;

import java.util.List;

public interface ProdutoCosifRepository {
    List<ProdutoCosif> listarPorProduto(String codProduto);

    boolean existe(String codProduto, String codCosif);
}
