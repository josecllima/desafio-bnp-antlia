package br.com.desafio.movimentos.api.exception;

import br.com.desafio.movimentos.application.exception.RegraNegocioException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;

import java.util.List;

/**
 * Converte excecoes em respostas HTTP padronizadas (ErroResponse).
 * Equivale a um middleware de excecao / IExceptionFilter no ASP.NET.
 */
@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {

    /** Falha nas anotacoes do MovimentoRequest (@NotNull, @Size, @Min...). */
    @ExceptionHandler(MethodArgumentNotValidException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ErroResponse tratarValidacao(MethodArgumentNotValidException ex) {
        List<ErroResponse.CampoInvalido> campos = ex.getBindingResult().getFieldErrors().stream()
                .map(e -> new ErroResponse.CampoInvalido(e.getField(), e.getDefaultMessage()))
                .toList();
        return ErroResponse.de(400, "Dados invalidos", "Um ou mais campos estao invalidos", campos);
    }

    /** Regra de negocio violada no service (ex.: Cosif de outro produto). */
    @ExceptionHandler(RegraNegocioException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ErroResponse tratarRegraNegocio(RegraNegocioException ex) {
        return ErroResponse.de(400, "Regra de negocio", ex.getMessage());
    }

    /** JSON mal formado ou tipo errado no corpo (ex.: "mes": "abc"). */
    @ExceptionHandler(HttpMessageNotReadableException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ErroResponse tratarJsonInvalido(HttpMessageNotReadableException ex) {
        return ErroResponse.de(400, "Requisicao invalida", "Corpo da requisicao invalido ou mal formado");
    }

    /** Tipo errado em parametro de URL (ex.: ?mes=abc). */
    @ExceptionHandler(MethodArgumentTypeMismatchException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ErroResponse tratarParametroInvalido(MethodArgumentTypeMismatchException ex) {
        return ErroResponse.de(400, "Requisicao invalida", "Parametro '" + ex.getName() + "' invalido");
    }

    /**
     * Violacao de PK/FK no banco. Cenario tipico: dois usuarios incluindo no mesmo
     * mes/ano ao mesmo tempo e gerando o mesmo NUM_LANCAMENTO. Basta tentar de novo.
     */
    @ExceptionHandler(DataIntegrityViolationException.class)
    @ResponseStatus(HttpStatus.CONFLICT)
    public ErroResponse tratarConflito(DataIntegrityViolationException ex) {
        log.warn("Violacao de integridade ao gravar", ex);
        return ErroResponse.de(409, "Conflito",
                "Nao foi possivel gravar o lancamento (possivel inclusao simultanea). Tente novamente.");
    }

    /**
     * Qualquer outro erro.
     * Excecoes do proprio Spring MVC (404 rota inexistente, 405 metodo nao suportado...)
     * ja carregam o status correto: mantem esse status.
     * O resto vira 500, sem expor detalhes internos ao cliente.
     */
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErroResponse> tratarErroInesperado(Exception ex) {
        if (ex instanceof org.springframework.web.ErrorResponse erroSpring) {
            int status = erroSpring.getStatusCode().value();
            return ResponseEntity.status(status)
                    .body(ErroResponse.de(status, "Requisicao invalida", ex.getMessage()));
        }
        log.error("Erro inesperado", ex);
        return ResponseEntity.internalServerError()
                .body(ErroResponse.de(500, "Erro interno", "Ocorreu um erro inesperado. Tente novamente mais tarde."));
    }
}
