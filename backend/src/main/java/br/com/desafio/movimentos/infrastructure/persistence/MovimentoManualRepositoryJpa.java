package br.com.desafio.movimentos.infrastructure.persistence;

import br.com.desafio.movimentos.domain.model.MovimentoManual;
import br.com.desafio.movimentos.domain.repository.MovimentoManualRepository;
import jakarta.persistence.EntityManager;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
@RequiredArgsConstructor
public class MovimentoManualRepositoryJpa implements MovimentoManualRepository {

    private final SpringDataMovimentoManualRepository jpa;
    private final EntityManager entityManager;

    @Override
    public long obterUltimoNumeroLancamento(int mes, int ano) {
        return jpa.obterUltimoNumeroLancamento(mes, ano);
    }

    /**
     * Usa persist (sempre INSERT) em vez de jpa.save().
     * Como a chave e informada pela aplicacao, o save() faria merge: um SELECT antes
     * e, se a chave ja existisse, um UPDATE sobrescrevendo o lancamento de outro usuario.
     * Com persist, chave repetida gera erro de PK (tratado como HTTP 409).
     */
    @Override
    public MovimentoManual salvar(MovimentoManual movimento) {
        entityManager.persist(movimento);
        return movimento;
    }

    @Override
    public List<MovimentoManual> listar(Integer mes, Integer ano) {
        return jpa.listar(mes, ano);
    }
}
