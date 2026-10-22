package br.com.desafio.movimentos.application.dto;

import br.com.desafio.movimentos.domain.model.Produto;

/** Item do combo Produto: exibe a descricao, envia o codigo. */
public record ProdutoResponse(String codProduto, String descricao) {

    public static ProdutoResponse de(Produto produto) {
        return new ProdutoResponse(produto.getCodProduto(), produto.getDescricao());
    }
}
