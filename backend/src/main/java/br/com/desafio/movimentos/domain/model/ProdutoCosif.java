package br.com.desafio.movimentos.domain.model;

import jakarta.persistence.Column;
import jakarta.persistence.EmbeddedId;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

/**
 * Tabela PRODUTO_COSIF. Um PRODUTO possui N Cosifs (1:N).
 */
@Entity
@Table(name = "PRODUTO_COSIF")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class ProdutoCosif {

    @EmbeddedId
    private ProdutoCosifId id;

    @Column(name = "COD_CLASSIFICACAO", length = 6)
    private String codClassificacao;

    @Column(name = "STA_STATUS", length = 1)
    private String status;

    /**
     * FK para PRODUTO. A coluna COD_PRODUTO ja e gravada pela chave (id),
     * por isso o relacionamento e somente leitura (insertable/updatable = false).
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "COD_PRODUTO", insertable = false, updatable = false)
    private Produto produto;

    public ProdutoCosif(ProdutoCosifId id, String codClassificacao, String status) {
        this.id = id;
        this.codClassificacao = codClassificacao;
        this.status = status;
    }
}
