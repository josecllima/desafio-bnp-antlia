package br.com.desafio.movimentos.application.exception;

/**
 * Lancada quando uma regra de negocio e violada
 * (ex.: Cosif que nao pertence ao produto).
 * No passo 5 o GlobalExceptionHandler converte em HTTP 400.
 */
public class RegraNegocioException extends RuntimeException {

    public RegraNegocioException(String mensagem) {
        super(mensagem);
    }
}
