package br.com.desafio.movimentos.application.service;

import br.com.desafio.movimentos.application.dto.MovimentoRequest;
import br.com.desafio.movimentos.application.dto.MovimentoResponse;
import br.com.desafio.movimentos.application.exception.RegraNegocioException;
import br.com.desafio.movimentos.domain.model.MovimentoManual;
import br.com.desafio.movimentos.domain.model.MovimentoManualId;
import br.com.desafio.movimentos.domain.model.Produto;
import br.com.desafio.movimentos.domain.repository.MovimentoManualRepository;
import br.com.desafio.movimentos.domain.repository.ProdutoCosifRepository;
import br.com.desafio.movimentos.domain.repository.ProdutoRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Clock;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.util.List;

@Service
@RequiredArgsConstructor
public class MovimentoManualService {
    static final String USUARIO_PADRAO = "TESTE";

    private final MovimentoManualRepository movimentoRepository;
    private final ProdutoRepository produtoRepository;
    private final ProdutoCosifRepository produtoCosifRepository;
    private final Clock clock;

    @Transactional
    public MovimentoResponse incluir(MovimentoRequest request) {
        Produto produto = produtoRepository.buscarPorCodigo(request.codProduto())
                .orElseThrow(() -> new RegraNegocioException(
                        "Produto " + request.codProduto() + " nao encontrado"));

        if (!produtoCosifRepository.existe(request.codProduto(), request.codCosif())) {
            throw new RegraNegocioException(
                    "Cosif " + request.codCosif() + " nao pertence ao produto " + request.codProduto());
        }

        // sequencia por mes/ano, independente do produto
        long proximoLancamento =
                movimentoRepository.obterUltimoNumeroLancamento(request.mes(), request.ano()) + 1;

        MovimentoManual movimento = new MovimentoManual(
                new MovimentoManualId(
                        request.mes(),
                        request.ano(),
                        proximoLancamento,
                        request.codProduto(),
                        request.codCosif()),
                request.descricao().trim(),
                request.valor(),
                USUARIO_PADRAO,
                LocalDateTime.now(clock).truncatedTo(ChronoUnit.SECONDS)); // smalldatetime

        MovimentoManual salvo = movimentoRepository.salvar(movimento);

        // produtoCosif nao e carregado no persist; usa o produto ja buscado
        return MovimentoResponse.de(salvo, produto.getDescricao());
    }

    @Transactional(readOnly = true)
    public List<MovimentoResponse> listar(Integer mes, Integer ano) {
        return movimentoRepository.listar(mes, ano).stream()
                .map(m -> MovimentoResponse.de(m, m.getProdutoCosif().getProduto().getDescricao()))
                .toList();
    }
}
