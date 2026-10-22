package br.com.desafio.movimentos.application.dto;

import jakarta.validation.constraints.DecimalMin;
import jakarta.validation.constraints.Digits;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.math.BigDecimal;

public record MovimentoRequest(

        @NotNull(message = "Mes e obrigatorio")
        @Min(value = 1, message = "Mes deve estar entre 1 e 12")
        @Max(value = 12, message = "Mes deve estar entre 1 e 12")
        Integer mes,

        @NotNull(message = "Ano e obrigatorio")
        @Min(value = 1000, message = "Ano deve ter 4 digitos")
        @Max(value = 9999, message = "Ano deve ter 4 digitos")
        Integer ano,

        @NotBlank(message = "Produto e obrigatorio")
        @Size(max = 4, message = "Codigo do produto deve ter no maximo 4 caracteres")
        String codProduto,

        @NotBlank(message = "Cosif e obrigatorio")
        @Size(max = 11, message = "Codigo do Cosif deve ter no maximo 11 caracteres")
        String codCosif,

        @NotNull(message = "Valor e obrigatorio")
        @DecimalMin(value = "0.01", message = "Valor deve ser maior que zero")
        @Digits(integer = 16, fraction = 2, message = "Valor deve ter no maximo 16 inteiros e 2 decimais")
        BigDecimal valor,

        @NotBlank(message = "Descricao e obrigatoria")
        @Size(max = 50, message = "Descricao deve ter no maximo 50 caracteres")
        String descricao
) {
}
