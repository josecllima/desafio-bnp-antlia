package br.com.desafio.movimentos.api.controller;

import br.com.desafio.movimentos.application.dto.MovimentoRequest;
import br.com.desafio.movimentos.application.dto.MovimentoResponse;
import br.com.desafio.movimentos.application.service.MovimentoManualService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/movimentos")
@RequiredArgsConstructor
@Tag(name = "Movimentos Manuais", description = "Consulta e inclusao de movimentos")
public class MovimentoManualController {
    private final MovimentoManualService movimentoService;

    @GetMapping
    @Operation(summary = "Lista os movimentos do grid (filtros mes/ano opcionais)")
    public List<MovimentoResponse> listar(@RequestParam(required = false) Integer mes,
                                          @RequestParam(required = false) Integer ano) {
        return movimentoService.listar(mes, ano);
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    @Operation(summary = "Inclui um movimento manual")
    public MovimentoResponse incluir(@Valid @RequestBody MovimentoRequest request) {
        return movimentoService.incluir(request);
    }
}
