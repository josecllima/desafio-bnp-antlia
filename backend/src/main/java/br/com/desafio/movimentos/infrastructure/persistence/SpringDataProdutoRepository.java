package br.com.desafio.movimentos.infrastructure.persistence;

import br.com.desafio.movimentos.domain.model.Produto;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

/** Repositorio Spring Data (detalhe de infraestrutura, visivel so neste pacote). */
interface SpringDataProdutoRepository extends JpaRepository<Produto, String> {

    List<Produto> findAllByOrderByDescricaoAsc();
}
