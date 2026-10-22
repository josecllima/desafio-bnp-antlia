package br.com.desafio.movimentos.application.service;

import br.com.desafio.movimentos.application.dto.CosifResponse;
import br.com.desafio.movimentos.application.dto.ProdutoResponse;
import br.com.desafio.movimentos.domain.repository.ProdutoCosifRepository;
import br.com.desafio.movimentos.domain.repository.ProdutoRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

/** Alimenta os combos da tela (Produto e Cosif em cascata). */
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class ProdutoService {

    private final ProdutoRepository produtoRepository;
    private final ProdutoCosifRepository produtoCosifRepository;

    public List<ProdutoResponse> listarProdutos() {
        return produtoRepository.listarTodos().stream()
                .map(ProdutoResponse::de)
                .toList();
    }

    /** Combo em cascata: so os Cosifs do produto escolhido. */
    public List<CosifResponse> listarCosifs(String codProduto) {
        return produtoCosifRepository.listarPorProduto(codProduto).stream()
                .map(CosifResponse::de)
                .toList();
    }
}
