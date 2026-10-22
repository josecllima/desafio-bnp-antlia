package br.com.desafio.movimentos.api.exception;

import java.time.LocalDateTime;
import java.util.List;

/**
 * Corpo padronizado de erro devolvido pela API.
 * Exemplo:
 * {
 *   "dataHora": "2026-10-21T18:30:00",
 *   "status": 400,
 *   "erro": "Dados invalidos",
 *   "mensagem": "Um ou mais campos estao invalidos",
 *   "campos": [ { "campo": "mes", "mensagem": "Mes deve estar entre 1 e 12" } ]
 * }
 */
public record ErroResponse(
        LocalDateTime dataHora,
        int status,
        String erro,
        String mensagem,
        List<CampoInvalido> campos
) {

    public record CampoInvalido(String campo, String mensagem) {
    }

    public static ErroResponse de(int status, String erro, String mensagem) {
        return new ErroResponse(LocalDateTime.now(), status, erro, mensagem, List.of());
    }

    public static ErroResponse de(int status, String erro, String mensagem, List<CampoInvalido> campos) {
        return new ErroResponse(LocalDateTime.now(), status, erro, mensagem, campos);
    }
}
