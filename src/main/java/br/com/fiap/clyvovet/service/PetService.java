package br.com.fiap.clyvovet.service;

import br.com.fiap.clyvovet.database.CadastroProcedures;
import br.com.fiap.clyvovet.exception.RecursoNaoEncontradoException;
import br.com.fiap.clyvovet.exception.RegraDeNegocioException;
import br.com.fiap.clyvovet.model.DadosDoPet;
import br.com.fiap.clyvovet.model.Pet;
import br.com.fiap.clyvovet.model.Raca;
import br.com.fiap.clyvovet.repository.AgendamentoRepository;
import br.com.fiap.clyvovet.repository.PetRepository;
import br.com.fiap.clyvovet.repository.ProntuarioRepository;
import br.com.fiap.clyvovet.repository.RacaRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class PetService {

    private final PetRepository petRepository;
    private final RacaRepository racaRepository;
    private final AgendamentoRepository agendamentoRepository;
    private final ProntuarioRepository prontuarioRepository;
    private final CadastroProcedures cadastroProcedures;

    public PetService(PetRepository petRepository, RacaRepository racaRepository,
                      AgendamentoRepository agendamentoRepository, ProntuarioRepository prontuarioRepository,
                      CadastroProcedures cadastroProcedures) {
        this.petRepository = petRepository;
        this.racaRepository = racaRepository;
        this.agendamentoRepository = agendamentoRepository;
        this.prontuarioRepository = prontuarioRepository;
        this.cadastroProcedures = cadastroProcedures;
    }

    public List<Pet> listarDoTutor(Long tutorId) {
        return petRepository.findByTutorIdOrderByNome(tutorId);
    }

    public List<Pet> listarTodos() {
        return petRepository.findAllByOrderByNome();
    }

    public Pet buscar(Long petId) {
        return petRepository.findById(petId).orElseThrow(PetService::petNaoEncontrado);
    }

    public Pet buscarDoTutor(Long tutorId, Long petId) {
        return petRepository.findByIdAndTutorId(petId, tutorId).orElseThrow(PetService::petNaoEncontrado);
    }

    /**
     * O cadastro passa pelas procedures do grupo: PRC_INS_PACIENTE grava o paciente (e a trigger audita)
     * e PRC_INS_PET liga o paciente ao tutor. As duas ficam na mesma transação: se a segunda falhar,
     * o paciente também é desfeito.
     */
    @Transactional
    public Pet cadastrar(Long tutorId, DadosDoPet dados) {
        Raca raca = buscarRaca(dados.idRaca());
        Long petId = cadastroProcedures.inserirPaciente(raca.getId(), dados.idade(), dados.nome().strip(),
                dados.sexo().name(), dados.porte().name());
        cadastroProcedures.inserirPet(tutorId, petId);
        return buscar(petId);
    }

    /** Edição pelo JPA (o grupo não tem procedure de UPDATE); a trigger registra o UPDATE na auditoria. */
    @Transactional
    public Pet atualizar(Long tutorId, Long petId, DadosDoPet dados) {
        Pet pet = buscarDoTutor(tutorId, petId);
        pet.setNome(dados.nome().strip());
        pet.setRaca(buscarRaca(dados.idRaca()));
        pet.setIdade(dados.idade());
        pet.setSexo(dados.sexo());
        pet.setPorte(dados.porte());
        return pet;
    }

    /**
     * Pet com consulta registrada faz parte do histórico clínico da clínica e não é apagado.
     * Sem consulta, saem antes os agendamentos e as alergias (que apontam para o paciente).
     */
    @Transactional
    public void excluir(Long tutorId, Long petId) {
        Pet pet = buscarDoTutor(tutorId, petId);
        if (prontuarioRepository.temConsulta(petId)) {
            throw new RegraDeNegocioException(
                    "%s já tem consultas registradas na clínica e o histórico clínico não pode ser apagado."
                            .formatted(pet.getNome()));
        }
        agendamentoRepository.deleteByPetId(petId);
        prontuarioRepository.excluirAlergias(petId);
        petRepository.delete(pet);
    }

    private Raca buscarRaca(Long idRaca) {
        return racaRepository.findById(idRaca)
                .orElseThrow(() -> new RegraDeNegocioException("Selecione uma raça da lista."));
    }

    private static RecursoNaoEncontradoException petNaoEncontrado() {
        return new RecursoNaoEncontradoException("Pet não encontrado.");
    }
}
