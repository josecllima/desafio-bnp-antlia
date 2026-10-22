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

    // persist em vez de save(): como a chave vem preenchida, o save() faria merge
    // e poderia sobrescrever um lancamento existente em vez de falhar por PK.
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
