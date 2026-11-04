package br.com.fiap.clyvovet.database;

import org.springframework.stereotype.Component;

import java.time.LocalDateTime;


@Component
public class CadastroProcedures {

    private final ChamadorDePackages chamador;

    public CadastroProcedures(ChamadorDePackages chamador) {
        this.chamador = chamador;
    }

    public Long inserirEndereco(String logradouro, Integer numero, String complemento, String cidade, String uf,
                                String cep) {
        return chamador.chamarComId("PRC_INS_ENDERECO",
                "{? = call PKG_CT_CADASTRO.PRC_INS_ENDERECO(?, ?, ?, ?, ?, ?)}",
                logradouro, numero, complemento, cidade, uf, cep);
    }

    public Long inserirContato(String telefone, String email) {
        return chamador.chamarComId("PRC_INS_CONTATO",
                "{? = call PKG_CT_CADASTRO.PRC_INS_CONTATO(?, ?)}", telefone, email);
    }

    public Long inserirUsuario(String login, String senhaComHash, String cpf, String nome, String sexo) {
        return chamador.chamarComId("PRC_INS_USUARIO",
                "{? = call PKG_CT_CADASTRO.PRC_INS_USUARIO(?, ?, ?, ?, ?)}", login, senhaComHash, cpf, nome, sexo);
    }

    public void inserirDadosPessoais(Long idContato, Long idEndereco, Long idUsuario) {
        chamador.chamar("PRC_INS_DADOS_PESSOAIS",
                "{call PKG_CT_CADASTRO.PRC_INS_DADOS_PESSOAIS(?, ?, ?)}", idContato, idEndereco, idUsuario);
    }

    public void inserirTutor(Long idUsuario) {
        chamador.chamar("PRC_INS_TUTOR", "{call PKG_CT_CADASTRO.PRC_INS_TUTOR(?)}", idUsuario);
    }

    /** PRC_INS_PACIENTE não tem p_id_gerado: o id é lido do CURRVAL da sequence logo depois. */
    public Long inserirPaciente(Long idEspecie, Integer idade, String nome, String sexo, String porte) {
        chamador.chamar("PRC_INS_PACIENTE",
                "{call PKG_CT_CADASTRO.PRC_INS_PACIENTE(?, ?, ?, ?, ?)}", idEspecie, idade, nome, sexo, porte);
        return chamador.valorAtualDaSequence("TB_CT_PACIENTE_ID_PACIENTE_SEQ");
    }

    public void inserirPet(Long idTutor, Long idPaciente) {
        chamador.chamar("PRC_INS_PET", "{call PKG_CT_CADASTRO.PRC_INS_PET(?, ?)}", idTutor, idPaciente);
    }

    public void inserirAlergia(Long idPaciente, Long idMedicamento, String gravidade) {
        chamador.chamar("PRC_INS_ALERGIA",
                "{call PKG_CT_CADASTRO.PRC_INS_ALERGIA(?, ?, ?)}", idPaciente, idMedicamento, gravidade);
    }

    public Long inserirPagamento(String tipoPagamento) {
        return chamador.chamarComId("PRC_INS_PAGAMENTO",
                "{? = call PKG_CT_CADASTRO.PRC_INS_PAGAMENTO(?)}", tipoPagamento);
    }

    public Long inserirConsulta(Long idPagamento, Long idVeterinario, Long idTutor, Long idPaciente,
                                String observacoes, String orientacao, LocalDateTime dataConsulta) {
        return chamador.chamarComId("PRC_INS_CONSULTA",
                "{? = call PKG_CT_CADASTRO.PRC_INS_CONSULTA(?, ?, ?, ?, ?, ?, ?)}",
                idPagamento, idVeterinario, idTutor, idPaciente, observacoes, orientacao, dataConsulta);
    }

    public void inserirPrescricao(Long idMedicamento, Long idExame, Long idConsulta) {
        chamador.chamar("PRC_INS_PRESCRICAO",
                "{call PKG_CT_CADASTRO.PRC_INS_PRESCRICAO(?, ?, ?)}", idMedicamento, idExame, idConsulta);
    }
}
