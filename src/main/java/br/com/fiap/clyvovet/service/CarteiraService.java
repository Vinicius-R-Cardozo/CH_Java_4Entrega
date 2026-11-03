package br.com.fiap.clyvovet.service;

import br.com.fiap.clyvovet.model.Agendamento;
import br.com.fiap.clyvovet.model.CarteiraPet;
import br.com.fiap.clyvovet.model.Pet;
import br.com.fiap.clyvovet.model.ProximoCuidado;
import br.com.fiap.clyvovet.model.SituacaoCuidado;
import br.com.fiap.clyvovet.model.StatusAgendamento;
import br.com.fiap.clyvovet.model.TipoCuidado;
import br.com.fiap.clyvovet.repository.AgendamentoRepository;
import br.com.fiap.clyvovet.repository.ProntuarioRepository;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.Arrays;
import java.util.List;

@Service
public class CarteiraService {

    private final AgendamentoRepository agendamentoRepository;
    private final ProntuarioRepository prontuarioRepository;

    public CarteiraService(AgendamentoRepository agendamentoRepository, ProntuarioRepository prontuarioRepository) {
        this.agendamentoRepository = agendamentoRepository;
        this.prontuarioRepository = prontuarioRepository;
    }

    /**
     * Junta o que o app calcula (próximos cuidados por espécie e fase de vida) com o que está no banco
     * do grupo: consultas, cuidados recomendados para a espécie (TB_CT_CUIDADO) e alergias.
     */
    public CarteiraPet montar(Pet pet) {
        List<Agendamento> historico = agendamentoRepository
                .findByPetIdAndStatusOrderByDataDesc(pet.getId(), StatusAgendamento.REALIZADO);
        List<Agendamento> emAberto = agendamentoRepository
                .findByPetIdAndStatusIn(pet.getId(), StatusAgendamento.EM_ABERTO);

        List<ProximoCuidado> proximosCuidados = Arrays.stream(TipoCuidado.values())
                .filter(tipo -> tipo.aplicaA(pet.getEspecie()))
                .map(tipo -> calcularProximoCuidado(pet, tipo, historico, emAberto))
                .toList();

        return new CarteiraPet(pet, proximosCuidados, historico,
                prontuarioRepository.listarAtendimentos(pet.getId()),
                prontuarioRepository.listarCuidadosDaEspecie(pet.getRaca().getId()),
                prontuarioRepository.listarAlergias(pet.getId()));
    }

    private ProximoCuidado calcularProximoCuidado(Pet pet, TipoCuidado tipo,
                                                  List<Agendamento> historico, List<Agendamento> emAberto) {
        boolean agendado = emAberto.stream().anyMatch(agendamento -> agendamento.getTipo() == tipo);

        return historico.stream()
                .filter(agendamento -> agendamento.getTipo() == tipo)
                .findFirst()
                .map(ultimo -> {
                    LocalDate dataPrevista = ultimo.getData().plusDays(tipo.intervaloEmDias(pet.getFaseVida()));
                    SituacaoCuidado situacao = SituacaoCuidado.para(dataPrevista, LocalDate.now());
                    return new ProximoCuidado(tipo, ultimo.getData(), dataPrevista, situacao, agendado);
                })
                .orElseGet(() -> ProximoCuidado.semRegistro(tipo, agendado));
    }
}
