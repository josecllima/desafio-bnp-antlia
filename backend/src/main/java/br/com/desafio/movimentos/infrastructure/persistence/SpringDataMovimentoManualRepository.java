package br.com.desafio.movimentos.infrastructure.persistence;

import br.com.desafio.movimentos.domain.model.MovimentoManual;
import br.com.desafio.movimentos.domain.model.MovimentoManualId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;

interface SpringDataMovimentoManualRepository extends JpaRepository<MovimentoManual, MovimentoManualId> {
    @Query("""
            SELECT COALESCE(MAX(m.id.numeroLancamento), 0L)
              FROM MovimentoManual m
             WHERE m.id.mes = :mes
               AND m.id.ano = :ano
            """)
    Long obterUltimoNumeroLancamento(@Param("mes") Integer mes, @Param("ano") Integer ano);

    @Query("""
            SELECT m
              FROM MovimentoManual m
              JOIN FETCH m.produtoCosif pc
              JOIN FETCH pc.produto p
             WHERE (:mes IS NULL OR m.id.mes = :mes)
               AND (:ano IS NULL OR m.id.ano = :ano)
             ORDER BY m.id.ano DESC, m.id.mes DESC, m.id.numeroLancamento DESC
            """)
    List<MovimentoManual> listar(@Param("mes") Integer mes, @Param("ano") Integer ano);
}
