package br.com.desafio.movimentos.application.dto;

import br.com.desafio.movimentos.domain.model.ProdutoCosif;

/**
 * Item do combo Cosif.
 * "exibicao" ja vem no formato da tela: COD_COSIF - (COD_CLASSIFICACAO).
 */
public record CosifResponse(String codCosif, String codClassificacao, String exibicao) {

    public static CosifResponse de(ProdutoCosif cosif) {
        String codCosif = cosif.getId().getCodCosif();
        // CHAR(6) vem com espacos a direita no banco (ex.: "ATIVO "); trim so para exibir
        String classificacao = cosif.getCodClassificacao() == null ? "" : cosif.getCodClassificacao().trim();
        return new CosifResponse(codCosif, classificacao, codCosif + " - (" + classificacao + ")");
    }
}
