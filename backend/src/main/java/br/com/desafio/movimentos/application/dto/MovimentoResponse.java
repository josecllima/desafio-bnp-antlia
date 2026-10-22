package br.com.desafio.movimentos.application.dto;

import br.com.desafio.movimentos.domain.model.MovimentoManual;
import br.com.desafio.movimentos.domain.model.MovimentoManualId;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public record MovimentoResponse(
        Integer mes,
        Integer ano,
        String codProduto,
        String descricaoProduto,
        Long numeroLancamento,
        String codCosif,
        String descricao,
        BigDecimal valor,
        LocalDateTime dataMovimento,
        String codUsuario
) {
    public static MovimentoResponse de(MovimentoManual movimento, String descricaoProduto) {
        MovimentoManualId id = movimento.getId();
        return new MovimentoResponse(
                id.getMes(),
                id.getAno(),
                id.getCodProduto(),
                descricaoProduto,
                id.getNumeroLancamento(),
                id.getCodCosif(),
                movimento.getDescricao(),
                movimento.getValor(),
                movimento.getDataMovimento(),
                movimento.getCodUsuario());
    }
}
