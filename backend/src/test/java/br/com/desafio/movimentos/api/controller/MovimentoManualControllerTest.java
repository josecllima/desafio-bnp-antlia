package br.com.desafio.movimentos.api.controller;

import br.com.desafio.movimentos.application.dto.MovimentoRequest;
import br.com.desafio.movimentos.application.dto.MovimentoResponse;
import br.com.desafio.movimentos.application.exception.RegraNegocioException;
import br.com.desafio.movimentos.application.service.MovimentoManualService;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.MediaType;
import org.springframework.test.web.servlet.MockMvc;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.List;

import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.verifyNoInteractions;
import static org.mockito.Mockito.when;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

@WebMvcTest(MovimentoManualController.class)
class MovimentoManualControllerTest {
    @Autowired
    private MockMvc mockMvc;

    @MockBean
    private MovimentoManualService movimentoService;

    private static final String JSON_VALIDO = """
            {"mes": 10, "ano": 2026, "codProduto": "0001", "codCosif": "41510000001",
             "valor": 150.75, "descricao": "Ajuste manual"}
            """;

    @Test
    void postValidoDeveRetornar201() throws Exception {
        when(movimentoService.incluir(any(MovimentoRequest.class))).thenReturn(respostaExemplo());

        mockMvc.perform(post("/api/movimentos").contentType(MediaType.APPLICATION_JSON).content(JSON_VALIDO))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.numeroLancamento").value(8))
                .andExpect(jsonPath("$.descricaoProduto").value("CDB Pos-Fixado"));
    }

    @Test
    void mesInvalidoDeveRetornar400ComCampo() throws Exception {
        String json = JSON_VALIDO.replace("\"mes\": 10", "\"mes\": 13");

        mockMvc.perform(post("/api/movimentos").contentType(MediaType.APPLICATION_JSON).content(json))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.campos[0].campo").value("mes"))
                .andExpect(jsonPath("$.campos[0].mensagem").value("Mes deve estar entre 1 e 12"));

        verifyNoInteractions(movimentoService);
    }

    @Test
    void regraDeNegocioDeveRetornar400ComMensagem() throws Exception {
        when(movimentoService.incluir(any(MovimentoRequest.class)))
                .thenThrow(new RegraNegocioException("Cosif 41510000001 nao pertence ao produto 0002"));

        mockMvc.perform(post("/api/movimentos").contentType(MediaType.APPLICATION_JSON).content(JSON_VALIDO))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.mensagem").value("Cosif 41510000001 nao pertence ao produto 0002"));
    }

    @Test
    void getDeveRetornarListaDoGrid() throws Exception {
        when(movimentoService.listar(10, 2026)).thenReturn(List.of(respostaExemplo()));

        mockMvc.perform(get("/api/movimentos").param("mes", "10").param("ano", "2026"))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[0].codProduto").value("0001"));
    }

    private MovimentoResponse respostaExemplo() {
        return new MovimentoResponse(10, 2026, "0001", "CDB Pos-Fixado", 8L, "41510000001",
                "Ajuste manual", new BigDecimal("150.75"), LocalDateTime.of(2026, 10, 21, 18, 30), "TESTE");
    }
}
