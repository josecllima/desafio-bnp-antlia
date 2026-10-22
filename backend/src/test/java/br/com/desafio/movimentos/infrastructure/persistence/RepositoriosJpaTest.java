package br.com.desafio.movimentos.infrastructure.persistence;

import br.com.desafio.movimentos.domain.model.MovimentoManual;
import br.com.desafio.movimentos.domain.model.MovimentoManualId;
import br.com.desafio.movimentos.domain.model.ProdutoCosif;
import br.com.desafio.movimentos.domain.repository.MovimentoManualRepository;
import br.com.desafio.movimentos.domain.repository.ProdutoCosifRepository;
import br.com.desafio.movimentos.domain.repository.ProdutoRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.jdbc.AutoConfigureTestDatabase;
import org.springframework.boot.test.autoconfigure.orm.jpa.DataJpaTest;
import org.springframework.boot.test.autoconfigure.orm.jpa.TestEntityManager;
import org.springframework.context.annotation.Import;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

@DataJpaTest
@AutoConfigureTestDatabase(replace = AutoConfigureTestDatabase.Replace.NONE)
@Import({ProdutoRepositoryJpa.class, ProdutoCosifRepositoryJpa.class, MovimentoManualRepositoryJpa.class})
class RepositoriosJpaTest {
    @Autowired
    private ProdutoRepository produtoRepository;

    @Autowired
    private ProdutoCosifRepository produtoCosifRepository;

    @Autowired
    private MovimentoManualRepository movimentoRepository;

    @Autowired
    private TestEntityManager entityManager;

    @Test
    void deveListarProdutosDoDataSql() {
        assertThat(produtoRepository.listarTodos()).hasSize(4);
    }

    @Test
    void deveListarCosifsSomenteDoProdutoInformado() {
        List<ProdutoCosif> cosifs = produtoCosifRepository.listarPorProduto("0001");

        assertThat(cosifs).hasSize(2)
                .allMatch(c -> c.getId().getCodProduto().equals("0001"));
    }

    @Test
    void deveValidarSeCosifPertenceAoProduto() {
        assertThat(produtoCosifRepository.existe("0001", "41510000001")).isTrue();
        assertThat(produtoCosifRepository.existe("0002", "41510000001")).isFalse();
    }

    @Test
    void deveRetornarZeroQuandoNaoHaLancamentoNoMes() {
        assertThat(movimentoRepository.obterUltimoNumeroLancamento(1, 2026)).isZero();
    }

    @Test
    void deveSalvarEListarMovimentoComDescricaoDoProduto() {
        movimentoRepository.salvar(novoMovimento(10, 2026, 1L, "0001", "41510000001"));
        movimentoRepository.salvar(novoMovimento(10, 2026, 2L, "0003", "16120000004"));
        movimentoRepository.salvar(novoMovimento(11, 2026, 1L, "0002", "41520000003"));

        // forca o listar() a ler do banco, como numa requisicao nova
        entityManager.flush();
        entityManager.clear();

        assertThat(movimentoRepository.obterUltimoNumeroLancamento(10, 2026)).isEqualTo(2L);

        assertThat(movimentoRepository.listar(10, 2026)).hasSize(2);

        List<MovimentoManual> todos = movimentoRepository.listar(null, null);
        assertThat(todos).hasSize(3);
        assertThat(todos.get(0).getProdutoCosif().getProduto().getDescricao()).isEqualTo("LCI");
    }

    private MovimentoManual novoMovimento(int mes, int ano, long lancamento, String produto, String cosif) {
        return new MovimentoManual(
                new MovimentoManualId(mes, ano, lancamento, produto, cosif),
                "Teste de lancamento",
                new BigDecimal("150.75"),
                "TESTE",
                LocalDateTime.now());
    }
}
