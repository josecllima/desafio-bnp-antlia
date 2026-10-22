package br.com.desafio.movimentos.domain.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.AccessLevel;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;

@Entity
@Table(name = "PRODUTO")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
@AllArgsConstructor
public class Produto {
    @Id
    @Column(name = "COD_PRODUTO", length = 4)
    private String codProduto;

    @Column(name = "DES_PRODUTO", length = 30)
    private String descricao;

    @Column(name = "STA_STATUS", length = 1)
    private String status;
}
