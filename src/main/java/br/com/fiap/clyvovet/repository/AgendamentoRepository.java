package br.com.fiap.clyvovet.repository;

import br.com.fiap.clyvovet.model.Agendamento;
import br.com.fiap.clyvovet.model.StatusAgendamento;
import br.com.fiap.clyvovet.model.TipoCuidado;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Collection;
import java.util.List;

public interface AgendamentoRepository extends JpaRepository<Agendamento, Long> {

    List<Agendamento> findByPetTutorIdOrderByDataDesc(Long tutorId);

    List<Agendamento> findByStatusInOrderByData(Collection<StatusAgendamento> status);

    List<Agendamento> findByPetIdAndStatusOrderByDataDesc(Long petId, StatusAgendamento status);

    List<Agendamento> findByPetIdAndStatusIn(Long petId, Collection<StatusAgendamento> status);

    boolean existsByPetIdAndTipoAndStatusIn(Long petId, TipoCuidado tipo, Collection<StatusAgendamento> status);

    void deleteByPetId(Long petId);
}
