package br.com.desafio.movimentos.domain.model;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.io.Serializable;

@Embeddable
@Getter
@EqualsAndHashCode
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
public class ProdutoCosifId implements Serializable {
    @Column(name = "COD_PRODUTO", length = 4)
    private String codProduto;

    @Column(name = "COD_COSIF", length = 11)
    private String codCosif;
}
