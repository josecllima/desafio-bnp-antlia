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

/**
 * Casos de uso da tela de Movimentos Manuais: incluir e listar.
 * Depende apenas das interfaces do dominio (nao conhece JPA).
 */
@Service
@RequiredArgsConstructor
public class MovimentoManualService {

    /** COD_USUARIO fixo, conforme o enunciado. */
    static final String USUARIO_PADRAO = "TESTE";

    private final MovimentoManualRepository movimentoRepository;
    private final ProdutoRepository produtoRepository;
    private final ProdutoCosifRepository produtoCosifRepository;
    private final Clock clock;

    /**
     * Inclui um movimento manual.
     * Regras:
     *  - o produto deve existir e o Cosif deve pertencer a ele;
     *  - NUM_LANCAMENTO = maior lancamento do mesmo mes/ano + 1 (sem considerar o produto);
     *  - DAT_MOVIMENTO = data/hora da gravacao;
     *  - COD_USUARIO = "TESTE".
     * Tudo numa unica transacao (consulta do MAX + INSERT).
     */
    @Transactional
    public MovimentoResponse incluir(MovimentoRequest request) {
        Produto produto = produtoRepository.buscarPorCodigo(request.codProduto())
                .orElseThrow(() -> new RegraNegocioException(
                        "Produto " + request.codProduto() + " nao encontrado"));

        if (!produtoCosifRepository.existe(request.codProduto(), request.codCosif())) {
            throw new RegraNegocioException(
                    "Cosif " + request.codCosif() + " nao pertence ao produto " + request.codProduto());
        }

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
                // smalldatetime nao guarda fracao de segundo
                LocalDateTime.now(clock).truncatedTo(ChronoUnit.SECONDS));

        MovimentoManual salvo = movimentoRepository.salvar(movimento);

        // A descricao vem do produto ja carregado: o objeto salvo tem produtoCosif = null
        // (relacionamento somente leitura; ver comentario no RepositoriosJpaTest).
        return MovimentoResponse.de(salvo, produto.getDescricao());
    }

    /**
     * Movimentos para o grid. Mes e ano sao filtros opcionais (null = todos).
     */
    @Transactional(readOnly = true)
    public List<MovimentoResponse> listar(Integer mes, Integer ano) {
        return movimentoRepository.listar(mes, ano).stream()
                .map(m -> MovimentoResponse.de(m, m.getProdutoCosif().getProduto().getDescricao()))
                .toList();
    }
}
