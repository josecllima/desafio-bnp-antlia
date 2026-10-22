package br.com.desafio.movimentos.application.service;

import br.com.desafio.movimentos.application.dto.MovimentoRequest;
import br.com.desafio.movimentos.application.dto.MovimentoResponse;
import br.com.desafio.movimentos.application.exception.RegraNegocioException;
import br.com.desafio.movimentos.domain.model.MovimentoManual;
import br.com.desafio.movimentos.domain.model.Produto;
import br.com.desafio.movimentos.domain.repository.MovimentoManualRepository;
import br.com.desafio.movimentos.domain.repository.ProdutoCosifRepository;
import br.com.desafio.movimentos.domain.repository.ProdutoRepository;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.time.Clock;
import java.time.Instant;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class MovimentoManualServiceTest {
    private static final ZoneId ZONA = ZoneId.of("America/Sao_Paulo");
    private static final Clock RELOGIO_FIXO =
            Clock.fixed(Instant.parse("2026-10-21T13:45:30.789Z"), ZONA);

    @Mock
    private MovimentoManualRepository movimentoRepository;
    @Mock
    private ProdutoRepository produtoRepository;
    @Mock
    private ProdutoCosifRepository produtoCosifRepository;

    private MovimentoManualService service;

    @BeforeEach
    void setUp() {
        service = new MovimentoManualService(
                movimentoRepository, produtoRepository, produtoCosifRepository, RELOGIO_FIXO);
    }

    @Test
    void deveIncluirComProximoLancamentoDataEUsuario() {
        when(produtoRepository.buscarPorCodigo("0001"))
                .thenReturn(Optional.of(new Produto("0001", "CDB Pos-Fixado", "A")));
        when(produtoCosifRepository.existe("0001", "41510000001")).thenReturn(true);
        when(movimentoRepository.obterUltimoNumeroLancamento(10, 2026)).thenReturn(7L);
        when(movimentoRepository.salvar(any())).thenAnswer(inv -> inv.getArgument(0));

        MovimentoResponse resposta = service.incluir(requestValido());

        ArgumentCaptor<MovimentoManual> captor = ArgumentCaptor.forClass(MovimentoManual.class);
        verify(movimentoRepository).salvar(captor.capture());
        MovimentoManual gravado = captor.getValue();

        assertThat(gravado.getId().getNumeroLancamento()).isEqualTo(8L);
        assertThat(gravado.getCodUsuario()).isEqualTo("TESTE");
        assertThat(gravado.getDataMovimento())
                .isEqualTo(LocalDateTime.of(2026, 10, 21, 10, 45, 30));
        assertThat(gravado.getDescricao()).isEqualTo("Ajuste manual");      // trim aplicado

        assertThat(resposta.descricaoProduto()).isEqualTo("CDB Pos-Fixado");
        assertThat(resposta.numeroLancamento()).isEqualTo(8L);
    }

    @Test
    void primeiroLancamentoDoMesDeveSerUm() {
        when(produtoRepository.buscarPorCodigo("0001"))
                .thenReturn(Optional.of(new Produto("0001", "CDB Pos-Fixado", "A")));
        when(produtoCosifRepository.existe("0001", "41510000001")).thenReturn(true);
        when(movimentoRepository.obterUltimoNumeroLancamento(10, 2026)).thenReturn(0L);
        when(movimentoRepository.salvar(any())).thenAnswer(inv -> inv.getArgument(0));

        assertThat(service.incluir(requestValido()).numeroLancamento()).isEqualTo(1L);
    }

    @Test
    void deveRejeitarProdutoInexistente() {
        when(produtoRepository.buscarPorCodigo("0001")).thenReturn(Optional.empty());

        assertThatThrownBy(() -> service.incluir(requestValido()))
                .isInstanceOf(RegraNegocioException.class)
                .hasMessageContaining("nao encontrado");

        verify(movimentoRepository, never()).salvar(any());
    }

    @Test
    void deveRejeitarCosifQueNaoPertenceAoProduto() {
        when(produtoRepository.buscarPorCodigo("0001"))
                .thenReturn(Optional.of(new Produto("0001", "CDB Pos-Fixado", "A")));
        when(produtoCosifRepository.existe("0001", "41510000001")).thenReturn(false);

        assertThatThrownBy(() -> service.incluir(requestValido()))
                .isInstanceOf(RegraNegocioException.class)
                .hasMessageContaining("nao pertence ao produto");

        verify(movimentoRepository, never()).salvar(any());
    }

    private MovimentoRequest requestValido() {
        return new MovimentoRequest(10, 2026, "0001", "41510000001",
                new BigDecimal("150.75"), "  Ajuste manual  ");
    }
}
