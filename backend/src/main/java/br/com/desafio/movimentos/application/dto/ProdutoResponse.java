package br.com.desafio.movimentos.application.dto;

import br.com.desafio.movimentos.domain.model.Produto;

public record ProdutoResponse(String codProduto, String descricao) {
    public static ProdutoResponse de(Produto produto) {
        return new ProdutoResponse(produto.getCodProduto(), produto.getDescricao());
    }
}
