package br.com.desafio.movimentos.api.controller;

import br.com.desafio.movimentos.application.dto.CosifResponse;
import br.com.desafio.movimentos.application.dto.ProdutoResponse;
import br.com.desafio.movimentos.application.service.ProdutoService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/produtos")
@RequiredArgsConstructor
@Tag(name = "Produtos", description = "Combos de Produto e Cosif")
public class ProdutoController {
    private final ProdutoService produtoService;

    @GetMapping
    @Operation(summary = "Lista os produtos (combo Produto)")
    public List<ProdutoResponse> listarProdutos() {
        return produtoService.listarProdutos();
    }

    @GetMapping("/{codProduto}/cosifs")
    @Operation(summary = "Lista os Cosifs de um produto (combo em cascata)")
    public List<CosifResponse> listarCosifs(@PathVariable String codProduto) {
        return produtoService.listarCosifs(codProduto);
    }
}
