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

@Slf4j
@RestControllerAdvice
public class GlobalExceptionHandler {
    @ExceptionHandler(MethodArgumentNotValidException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ErroResponse tratarValidacao(MethodArgumentNotValidException ex) {
        List<ErroResponse.CampoInvalido> campos = ex.getBindingResult().getFieldErrors().stream()
                .map(e -> new ErroResponse.CampoInvalido(e.getField(), e.getDefaultMessage()))
                .toList();
        return ErroResponse.de(400, "Dados invalidos", "Um ou mais campos estao invalidos", campos);
    }

    @ExceptionHandler(RegraNegocioException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ErroResponse tratarRegraNegocio(RegraNegocioException ex) {
        return ErroResponse.de(400, "Regra de negocio", ex.getMessage());
    }

    @ExceptionHandler(HttpMessageNotReadableException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ErroResponse tratarJsonInvalido(HttpMessageNotReadableException ex) {
        return ErroResponse.de(400, "Requisicao invalida", "Corpo da requisicao invalido ou mal formado");
    }

    @ExceptionHandler(MethodArgumentTypeMismatchException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    public ErroResponse tratarParametroInvalido(MethodArgumentTypeMismatchException ex) {
        return ErroResponse.de(400, "Requisicao invalida", "Parametro '" + ex.getName() + "' invalido");
    }

    // PK duplicada: duas inclusoes simultaneas no mesmo mes/ano
    @ExceptionHandler(DataIntegrityViolationException.class)
    @ResponseStatus(HttpStatus.CONFLICT)
    public ErroResponse tratarConflito(DataIntegrityViolationException ex) {
        log.warn("Violacao de integridade ao gravar", ex);
        return ErroResponse.de(409, "Conflito",
                "Nao foi possivel gravar o lancamento (possivel inclusao simultanea). Tente novamente.");
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErroResponse> tratarErroInesperado(Exception ex) {
        // excecoes do Spring MVC (404, 405...) ja trazem o status correto
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
