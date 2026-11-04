package br.com.fiap.clyvovet.model;

import br.com.fiap.clyvovet.exception.RegraDeNegocioException;
import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.SequenceGenerator;
import jakarta.persistence.Table;
import lombok.Data;

import java.time.LocalDate;

@Data
@Entity
@Table(name = "TB_CT_AGENDAMENTO")
public class Agendamento {

    @Id
    @Column(name = "id_agendamento")
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "agendamento")
    @SequenceGenerator(name = "agendamento", sequenceName = "TB_CT_AGENDAMENTO_ID_SEQ", allocationSize = 1)
    private Long id;

    @ManyToOne(optional = false)
    @JoinColumn(name = "id_paciente")
    private Pet pet;

    @Enumerated(EnumType.STRING)
    @Column(name = "tipo_cuidado")
    private TipoCuidado tipo;

    @Column(name = "data_agendada")
    private LocalDate data;

    @Enumerated(EnumType.STRING)
    private StatusAgendamento status = StatusAgendamento.SOLICITADO;

    private String observacao;

    /** Consulta gravada em TB_CT_CONSULTA quando o atendimento é registrado. */
    @Column(name = "id_consulta")
    private Long idConsulta;

    @JsonProperty
    public boolean aguardaConfirmacao() {
        return status == StatusAgendamento.SOLICITADO;
    }

    @JsonProperty
    public boolean podeSerConcluido() {
        return status == StatusAgendamento.CONFIRMADO && !data.isAfter(LocalDate.now());
    }

    public void confirmar() {
        garantirQueAguardaConfirmacao();
        status = StatusAgendamento.CONFIRMADO;
    }

    public void recusar() {
        garantirQueAguardaConfirmacao();
        status = StatusAgendamento.RECUSADO;
    }

    public void garantirQuePodeSerConcluido() {
        if (!podeSerConcluido()) {
            throw new RegraDeNegocioException(
                    "Só é possível registrar atendimentos confirmados e com data até hoje.");
        }
    }

    public void concluir(String observacao, Long idConsulta) {
        garantirQuePodeSerConcluido();
        this.observacao = observacao;
        this.idConsulta = idConsulta;
        status = StatusAgendamento.REALIZADO;
    }

    private void garantirQueAguardaConfirmacao() {
        if (!aguardaConfirmacao()) {
            throw new RegraDeNegocioException("Este agendamento não está mais aguardando confirmação.");
        }
    }
}
