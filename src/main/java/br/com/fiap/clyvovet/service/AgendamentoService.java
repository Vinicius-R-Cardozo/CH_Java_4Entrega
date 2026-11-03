package br.com.fiap.clyvovet.service;

import br.com.fiap.clyvovet.database.CadastroProcedures;
import br.com.fiap.clyvovet.exception.RecursoNaoEncontradoException;
import br.com.fiap.clyvovet.exception.RegraDeNegocioException;
import br.com.fiap.clyvovet.model.Agendamento;
import br.com.fiap.clyvovet.model.DadosDoAtendimento;
import br.com.fiap.clyvovet.model.Pet;
import br.com.fiap.clyvovet.model.StatusAgendamento;
import br.com.fiap.clyvovet.model.TipoCuidado;
import br.com.fiap.clyvovet.repository.AgendamentoRepository;
import br.com.fiap.clyvovet.repository.CatalogoRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalTime;
import java.time.temporal.ChronoUnit;
import java.util.List;

@Service
public class AgendamentoService {

    private final AgendamentoRepository agendamentoRepository;
    private final PetService petService;
    private final AlergiaService alergiaService;
    private final CatalogoRepository catalogoRepository;
    private final CadastroProcedures cadastroProcedures;

    public AgendamentoService(AgendamentoRepository agendamentoRepository, PetService petService,
                              AlergiaService alergiaService, CatalogoRepository catalogoRepository,
                              CadastroProcedures cadastroProcedures) {
        this.agendamentoRepository = agendamentoRepository;
        this.petService = petService;
        this.alergiaService = alergiaService;
        this.catalogoRepository = catalogoRepository;
        this.cadastroProcedures = cadastroProcedures;
    }

    public Agendamento solicitar(Long tutorId, Long petId, TipoCuidado tipo, LocalDate data) {
        Pet pet = petService.buscarDoTutor(tutorId, petId);
        if (!tipo.aplicaA(pet.getEspecie())) {
            throw new RegraDeNegocioException("Para %s a clínica acompanha com check-up; %s não se aplica."
                    .formatted(pet.getNome(), tipo.getDescricao().toLowerCase()));
        }
        boolean jaExisteEmAberto = agendamentoRepository
                .existsByPetIdAndTipoAndStatusIn(pet.getId(), tipo, StatusAgendamento.EM_ABERTO);
        if (jaExisteEmAberto) {
            throw new RegraDeNegocioException("%s já tem um agendamento de %s em aberto."
                    .formatted(pet.getNome(), tipo.getDescricao().toLowerCase()));
        }

        Agendamento agendamento = new Agendamento();
        agendamento.setPet(pet);
        agendamento.setTipo(tipo);
        agendamento.setData(data);
        return agendamentoRepository.save(agendamento);
    }

    public List<Agendamento> listarDoTutor(Long tutorId) {
        return agendamentoRepository.findByPetTutorIdOrderByDataDesc(tutorId);
    }

    public List<Agendamento> listarEmAberto() {
        return agendamentoRepository.findByStatusInOrderByData(StatusAgendamento.EM_ABERTO);
    }

    public Agendamento buscar(Long id) {
        return agendamentoRepository.findById(id)
                .orElseThrow(() -> new RecursoNaoEncontradoException("Agendamento não encontrado."));
    }

    public Agendamento confirmar(Long id) {
        Agendamento agendamento = buscar(id);
        agendamento.confirmar();
        return agendamentoRepository.save(agendamento);
    }

    public Agendamento recusar(Long id) {
        Agendamento agendamento = buscar(id);
        agendamento.recusar();
        return agendamentoRepository.save(agendamento);
    }

    /**
     * Registra o atendimento no banco do grupo, nesta ordem e na mesma transação:
     * PRC_INS_PAGAMENTO → PRC_INS_CONSULTA → PRC_INS_PRESCRICAO. Se qualquer procedure registrar erro
     * em TB_CT_LOG_ERRO, nada fica gravado (o log fica, porque é autônomo).
     * TB_CT_PRESCRICAO exige medicamento e exame: quando o veterinário não prescreve, entram os itens
     * "Nenhum" da carga do grupo, como o próprio script de carga faz.
     */
    @Transactional
    public Agendamento concluir(Long id, Long veterinarioId, DadosDoAtendimento dados) {
        Agendamento agendamento = buscar(id);
        agendamento.garantirQuePodeSerConcluido();
        Pet pet = agendamento.getPet();

        Long medicamentoId = dados.idMedicamento() == null ? CatalogoRepository.NENHUM_MEDICAMENTO : dados.idMedicamento();
        Long exameId = dados.idExame() == null ? CatalogoRepository.NENHUM_EXAME : dados.idExame();
        if (!catalogoRepository.existeExame(exameId)) {
            throw new RegraDeNegocioException("Selecione um exame da lista.");
        }
        alergiaService.verificarPrescricao(pet, medicamentoId, dados.alergiaConfirmada());

        String observacao = dados.observacao().strip();
        Long pagamentoId = cadastroProcedures.inserirPagamento(dados.pagamento().name());
        Long consultaId = cadastroProcedures.inserirConsulta(pagamentoId, veterinarioId, pet.getTutor().getId(),
                pet.getId(), observacao, dados.orientacao().strip(),
                agendamento.getData().atTime(LocalTime.now().truncatedTo(ChronoUnit.SECONDS)));
        cadastroProcedures.inserirPrescricao(medicamentoId, exameId, consultaId);

        agendamento.concluir(observacao, consultaId);
        return agendamento;
    }
}
