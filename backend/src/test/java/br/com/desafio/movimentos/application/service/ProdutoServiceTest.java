package br.com.desafio.movimentos.application.service;

import br.com.desafio.movimentos.application.dto.CosifResponse;
import br.com.desafio.movimentos.domain.model.ProdutoCosif;
import br.com.desafio.movimentos.domain.model.ProdutoCosifId;
import br.com.desafio.movimentos.domain.repository.ProdutoCosifRepository;
import br.com.desafio.movimentos.domain.repository.ProdutoRepository;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class ProdutoServiceTest {

    @Mock
    private ProdutoRepository produtoRepository;
    @Mock
    private ProdutoCosifRepository produtoCosifRepository;

    @InjectMocks
    private ProdutoService service;

    @Test
    void deveFormatarCosifParaOCombo() {
        when(produtoCosifRepository.listarPorProduto("0003")).thenReturn(List.of(
                new ProdutoCosif(new ProdutoCosifId("0003", "16120000004"), "ATIVO ", "A")));

        List<CosifResponse> cosifs = service.listarCosifs("0003");

        assertThat(cosifs).singleElement()
                .extracting(CosifResponse::exibicao)
                .isEqualTo("16120000004 - (ATIVO)");
    }
}
