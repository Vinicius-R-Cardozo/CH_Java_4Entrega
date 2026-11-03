package br.com.fiap.clyvovet;

import com.jayway.jsonpath.JsonPath;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.http.MediaType;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.TestPropertySource;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.request.RequestPostProcessor;

import static org.assertj.core.api.Assertions.assertThat;
import static org.hamcrest.Matchers.containsString;
import static org.hamcrest.Matchers.greaterThan;
import static org.hamcrest.Matchers.hasSize;
import static org.springframework.security.test.web.servlet.request.SecurityMockMvcRequestPostProcessors.httpBasic;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.delete;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.patch;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

/** Fluxos principais pela API, com a autenticação real e o banco do grupo num H2 em memória. */
@SpringBootTest
@AutoConfigureMockMvc
@TestPropertySource(properties = {
        "spring.datasource.url=jdbc:h2:mem:fluxos;MODE=Oracle;DEFAULT_NULL_ORDERING=HIGH;DB_CLOSE_DELAY=-1",
        "spring.h2.console.enabled=false"})
class FluxosDaClinicaTest {

    private static final RequestPostProcessor VETERINARIO = httpBasic("vet@clyvo.com", "vet123");
    private static final RequestPostProcessor TUTOR = httpBasic("tutor@clyvo.com", "tutor123");

    @Autowired
    private MockMvc mvc;

    @Autowired
    private JdbcTemplate jdbc;

    @Test
    void loginDevolveOPerfilDeCadaUsuario() throws Exception {
        mvc.perform(post("/login").with(VETERINARIO)).andExpect(status().isOk())
                .andExpect(jsonPath("$.perfil").value("VETERINARIO"));
        mvc.perform(post("/login").with(TUTOR)).andExpect(status().isOk())
                .andExpect(jsonPath("$.perfil").value("TUTOR"));
        mvc.perform(post("/login").with(httpBasic("tutor@clyvo.com", "errada"))).andExpect(status().isUnauthorized());
    }

    @Test
    void rotasSaoProtegidasPorPerfil() throws Exception {
        mvc.perform(get("/pets")).andExpect(status().isUnauthorized());
        mvc.perform(get("/pets").with(VETERINARIO)).andExpect(status().isForbidden());
        mvc.perform(get("/auditoria/operacoes").with(TUTOR)).andExpect(status().isForbidden());
        mvc.perform(get("/pets").with(TUTOR)).andExpect(status().isOk()).andExpect(jsonPath("$", hasSize(3)));
    }

    @Test
    void cadastroDeTutorPassaPelasProceduresEDesfazTudoQuandoOCpfSeRepete() throws Exception {
        String cadastro = """
                {"nome": "Paula Teste", "cpf": "12345678901", "sexo": "F", "login": "paula", "email": "paula@teste.com",
                 "telefone": "11988887777", "senha": "segredo1", "cep": "01310000", "logradouro": "Avenida Paulista",
                 "numero": 1000, "complemento": "", "cidade": "São Paulo", "uf": "SP"}""";
        mvc.perform(post("/cadastro").contentType(MediaType.APPLICATION_JSON).content(cadastro))
                .andExpect(status().isCreated());
        mvc.perform(post("/login").with(httpBasic("paula@teste.com", "segredo1")))
                .andExpect(jsonPath("$.perfil").value("TUTOR"));

        String cpfRepetido = cadastro.replace("paula@teste.com", "outra@teste.com");
        mvc.perform(post("/cadastro").contentType(MediaType.APPLICATION_JSON).content(cpfRepetido))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.mensagem").value(containsString("CPF ja existente no sistema (UK).")));

        assertThat(jdbc.queryForObject("SELECT COUNT(*) FROM TB_CT_CONTATO WHERE email = 'outra@teste.com'", Integer.class))
                .as("o contato inserido antes do erro é desfeito").isZero();
        assertThat(jdbc.queryForObject("SELECT COUNT(*) FROM TB_CT_LOG_ERRO WHERE nome_procedure = 'PRC_INS_USUARIO'", Integer.class))
                .as("o log fica, como na transação autônoma do Oracle").isPositive();
    }

    @Test
    void crudDePetGeraAuditoriaPelaTrigger() throws Exception {
        String pet = """
                {"nome": "Paçoca", "idRaca": 1, "idade": 0, "sexo": "F", "porte": "SPD"}""";
        String resposta = mvc.perform(post("/pets").with(TUTOR).contentType(MediaType.APPLICATION_JSON).content(pet))
                .andExpect(status().isCreated())
                .andExpect(jsonPath("$.faseVida").value("FILHOTE"))
                .andReturn().getResponse().getContentAsString();
        long id = ((Number) JsonPath.read(resposta, "$.id")).longValue();

        mvc.perform(put("/pets/" + id).with(TUTOR).contentType(MediaType.APPLICATION_JSON)
                        .content(pet.replace("\"idade\": 0", "\"idade\": 3")))
                .andExpect(status().isOk()).andExpect(jsonPath("$.faseVida").value("ADULTO"));
        mvc.perform(delete("/pets/" + id).with(TUTOR)).andExpect(status().isNoContent());

        assertThat(jdbc.queryForList("""
                        SELECT tipo_operacao FROM TB_CT_AUDITORIA_DML
                        WHERE valores_novos LIKE ? OR valores_anteriores LIKE ? ORDER BY id_auditoria""",
                String.class, "ID_PACIENTE=" + id + ";%", "ID_PACIENTE=" + id + ";%"))
                .containsExactly("INSERT", "UPDATE", "DELETE");
    }

    @Test
    void atendimentoGravaConsultaEBloqueiaAlergiaGrave() throws Exception {
        Long agendamento = jdbc.queryForObject(
                "SELECT MIN(id_agendamento) FROM TB_CT_AGENDAMENTO WHERE status = 'CONFIRMADO'", Long.class);
        Long pet = jdbc.queryForObject(
                "SELECT id_paciente FROM TB_CT_AGENDAMENTO WHERE id_agendamento = ?", Long.class, agendamento);
        Long medicamentoComAlergiaGrave = jdbc.queryForObject(
                "SELECT MIN(id_medicamento) FROM TB_CT_ALERGIA WHERE id_paciente = ? AND gravidade_alergia = 'GRAVE'",
                Long.class, pet);
        assertThat(medicamentoComAlergiaGrave).as("na carga do grupo o primeiro paciente é alérgico grave").isNotNull();

        String atendimento = """
                {"pagamento": "PIX", "observacao": "Check-up anual", "orientacao": "Retorno em 6 meses",
                 "idMedicamento": %d, "idExame": 2}""";
        mvc.perform(patch("/agendamentos/" + agendamento + "/concluir").with(VETERINARIO)
                        .contentType(MediaType.APPLICATION_JSON).content(atendimento.formatted(medicamentoComAlergiaGrave)))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.mensagem").value(containsString("alergia grave")));

        int consultasAntes = jdbc.queryForObject("SELECT COUNT(*) FROM TB_CT_CONSULTA", Integer.class);
        mvc.perform(patch("/agendamentos/" + agendamento + "/concluir").with(VETERINARIO)
                        .contentType(MediaType.APPLICATION_JSON).content(atendimento.formatted(4)))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.status").value("REALIZADO"))
                .andExpect(jsonPath("$.idConsulta").isNumber());
        assertThat(jdbc.queryForObject("SELECT COUNT(*) FROM TB_CT_CONSULTA", Integer.class)).isEqualTo(consultasAntes + 1);

        mvc.perform(get("/pacientes/" + pet + "/carteira").with(VETERINARIO))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$.atendimentos[0].orientacao").value("Retorno em 6 meses"))
                .andExpect(jsonPath("$.alergias", hasSize(greaterThan(0))));
    }

    @Test
    void campanhaERelatoriosUsamOsPackagesDoGrupo() throws Exception {
        mvc.perform(get("/campanhas").param("faixa", "ADULTO").with(VETERINARIO))
                .andExpect(status().isOk()).andExpect(jsonPath("$", hasSize(greaterThan(0))))
                .andExpect(jsonPath("$[0].nomePet").isString())
                .andExpect(jsonPath("$[0].nomeTutor").isString());
        mvc.perform(get("/campanhas").param("faixa", "VELHO").with(VETERINARIO))
                .andExpect(status().isBadRequest())
                .andExpect(jsonPath("$.mensagem").value("Faixa etaria invalida. Utilize JOVEM, ADULTO ou IDOSO."));
        mvc.perform(get("/relatorios/pets-do-tutor/1").with(VETERINARIO))
                .andExpect(status().isOk()).andExpect(jsonPath("$", hasSize(3)))
                .andExpect(jsonPath("$[0].idPaciente").isNumber());
        mvc.perform(get("/relatorios/resumo-idade-porte").with(VETERINARIO))
                .andExpect(status().isOk())
                .andExpect(jsonPath("$[1]").value("========== RELATORIO: SOMA DE IDADES POR FAIXA E PORTE =========="));
        mvc.perform(get("/auditoria/erros").with(VETERINARIO)).andExpect(status().isOk());
    }
}
