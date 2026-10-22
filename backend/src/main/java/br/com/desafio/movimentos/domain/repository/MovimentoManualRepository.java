package br.com.desafio.movimentos.domain.repository;

import br.com.desafio.movimentos.domain.model.MovimentoManual;

import java.util.List;

public interface MovimentoManualRepository {
    long obterUltimoNumeroLancamento(int mes, int ano);

    MovimentoManual salvar(MovimentoManual movimento);

    List<MovimentoManual> listar(Integer mes, Integer ano);
}
