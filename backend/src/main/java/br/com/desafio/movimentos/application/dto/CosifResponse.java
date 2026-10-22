package br.com.desafio.movimentos.application.dto;

import br.com.desafio.movimentos.domain.model.ProdutoCosif;

public record CosifResponse(String codCosif, String codClassificacao, String exibicao) {
    public static CosifResponse de(ProdutoCosif cosif) {
        String codCosif = cosif.getId().getCodCosif();
        // CHAR(6) vem completado com espacos
        String classificacao = cosif.getCodClassificacao() == null ? "" : cosif.getCodClassificacao().trim();
        return new CosifResponse(codCosif, classificacao, codCosif + " - (" + classificacao + ")");
    }
}
