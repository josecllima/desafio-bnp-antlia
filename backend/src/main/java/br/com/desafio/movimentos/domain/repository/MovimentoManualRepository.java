package br.com.desafio.movimentos.domain.repository;

import br.com.desafio.movimentos.domain.model.MovimentoManual;

import java.util.List;

public interface MovimentoManualRepository {

    /**
     * Maior NUM_LANCAMENTO do mes/ano (sem considerar o produto).
     * Retorna 0 quando ainda nao ha lancamentos no periodo.
     */
    long obterUltimoNumeroLancamento(int mes, int ano);

    MovimentoManual salvar(MovimentoManual movimento);

    /** Lista os movimentos com produto carregado; mes e ano sao filtros opcionais (null = todos). */
    List<MovimentoManual> listar(Integer mes, Integer ano);
}
