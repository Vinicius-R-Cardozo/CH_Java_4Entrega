package br.com.fiap.clyvovet.repository;

import br.com.fiap.clyvovet.model.Tutor;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface TutorRepository extends JpaRepository<Tutor, Long> {

    Optional<Tutor> findByUsuarioId(Long usuarioId);

    List<Tutor> findAllByOrderByUsuarioNome();
}
