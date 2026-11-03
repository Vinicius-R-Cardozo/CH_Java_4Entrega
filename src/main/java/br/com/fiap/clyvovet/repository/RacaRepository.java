package br.com.fiap.clyvovet.repository;

import br.com.fiap.clyvovet.model.Raca;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface RacaRepository extends JpaRepository<Raca, Long> {

    List<Raca> findAllByOrderByNome();
}
