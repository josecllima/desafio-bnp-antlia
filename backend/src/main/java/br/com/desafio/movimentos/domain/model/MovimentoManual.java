package br.com.desafio.movimentos.domain.model;

import jakarta.persistence.Column;
import jakarta.persistence.EmbeddedId;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinColumns;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.AccessLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDateTime;

/**
 * Tabela MOVIMENTO_MANUAL. Um PRODUTO_COSIF possui N movimentos (1:N).
 * Nenhum campo aceita nulo.
 */
@Entity
@Table(name = "MOVIMENTO_MANUAL")
@Getter
@NoArgsConstructor(access = AccessLevel.PROTECTED)
public class MovimentoManual {

    @EmbeddedId
    private MovimentoManualId id;

    @Column(name = "DES_DESCRICAO", length = 50, nullable = false)
    private String descricao;

    @Column(name = "DAT_MOVIMENTO", nullable = false)
    private LocalDateTime dataMovimento;

    @Column(name = "COD_USUARIO", length = 15, nullable = false)
    private String codUsuario;

    @Column(name = "VAL_VALOR", precision = 18, scale = 2, nullable = false)
    private BigDecimal valor;

    /**
     * FK composta para PRODUTO_COSIF. As colunas ja sao gravadas pela chave (id),
     * entao o relacionamento e somente leitura. Usado para exibir DES_PRODUTO no grid.
     */
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumns({
            @JoinColumn(name = "COD_PRODUTO", referencedColumnName = "COD_PRODUTO",
                    insertable = false, updatable = false),
            @JoinColumn(name = "COD_COSIF", referencedColumnName = "COD_COSIF",
                    insertable = false, updatable = false)
    })
    private ProdutoCosif produtoCosif;

    public MovimentoManual(MovimentoManualId id,
                           String descricao,
                           BigDecimal valor,
                           String codUsuario,
                           LocalDateTime dataMovimento) {
        this.id = id;
        this.descricao = descricao;
        this.valor = valor;
        this.codUsuario = codUsuario;
        this.dataMovimento = dataMovimento;
    }
}
