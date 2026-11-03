package br.com.fiap.clyvovet.database.packages;

import org.flywaydb.core.Flyway;
import org.junit.jupiter.api.AfterAll;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

/**
 * Roda as migrations num H2 em memória e chama os packages pelo SQL, do mesmo jeito que a aplicação.
 * Não sobe o Spring: o objetivo é conferir que o porte se comporta como o PL/SQL do grupo.
 */
class PackagesCelticsTechTest {

    private static final String URL = "jdbc:h2:mem:packages;MODE=Oracle;DEFAULT_NULL_ORDERING=HIGH;DB_CLOSE_DELAY=-1";
    private static Connection conexao;

    @BeforeAll
    static void criarBanco() throws SQLException {
        Flyway.configure().dataSource(URL, "sa", "").load().migrate();
        conexao = DriverManager.getConnection(URL, "sa", "");
    }

    @AfterAll
    static void fecharConexao() throws SQLException {
        conexao.close();
    }

    @Test
    void cargaInicialSegueAsQuantidadesDoScriptDoGrupo() throws SQLException {
        assertThat(contar("TB_CT_ESPECIE")).isEqualTo(87);
        assertThat(contar("TB_CT_PREDISPOSICAO_ESP")).isEqualTo(31);
        assertThat(contar("TB_CT_RESTRICAO_ESP")).isEqualTo(30);
        assertThat(contar("TB_CT_MEDICAMENTO")).isEqualTo(11);
        assertThat(contar("TB_CT_EXAME")).isEqualTo(11);
        assertThat(contar("TB_CT_USUARIO")).isEqualTo(100);
        assertThat(contar("TB_CT_DADOS_PESSOAIS")).isEqualTo(100);
        assertThat(contar("TB_CT_VETERINARIO")).isEqualTo(10);
        assertThat(contar("TB_CT_TUTOR")).isEqualTo(90);
        assertThat(contar("TB_CT_PACIENTE")).isGreaterThanOrEqualTo(60);
        assertThat(contar("TB_CT_ALERGIA")).isEqualTo(5);
        assertThat(contar("TB_CT_CONSULTA")).isEqualTo(30);
        assertThat(contar("TB_CT_PRESCRICAO")).isEqualTo(30);
        assertThat(contar("TB_CT_CUIDADO")).isPositive();
        assertThat(texto("SELECT nome_medicamento FROM TB_CT_MEDICAMENTO WHERE id_medicamento = 1"))
                .isEqualTo("Nenhum Medicamento Prescrito");
    }

    @Test
    void usuariosDeDemonstracaoEntramComAsSenhasDocumentadas() throws SQLException {
        var bcrypt = new BCryptPasswordEncoder();
        assertThat(bcrypt.matches("vet123", texto(senhaPorEmail("vet@clyvo.com")))).isTrue();
        assertThat(bcrypt.matches("tutor123", texto(senhaPorEmail("tutor@clyvo.com")))).isTrue();
        assertThat(bcrypt.matches("tutor123", texto(senhaPorEmail("tutora@clyvo.com")))).isTrue();
    }

    @Test
    void prcInsPagamentoDevolveOIdGerado() throws SQLException {
        assertThat(chamarComId("{? = call PKG_CT_CADASTRO.PRC_INS_PAGAMENTO(?)}", "PIX")).isPositive();
    }

    @Test
    void prcInsPagamentoInvalidoGravaLogENaoRelanca() throws SQLException {
        assertThat(chamarComId("{? = call PKG_CT_CADASTRO.PRC_INS_PAGAMENTO(?)}", "BOLETO")).isNull();
        assertThat(ultimoLog("PRC_INS_PAGAMENTO"))
                .isEqualTo("Cod: -2290 - Erro: Forma de pagamento invalida na regra CHECK.");
    }

    @Test
    void prcInsUsuarioComCpfDuplicadoGravaLog() throws SQLException {
        String cpfExistente = texto("SELECT cpf FROM TB_CT_USUARIO WHERE id_usuario = 5");
        Long id = chamarComId("{? = call PKG_CT_CADASTRO.PRC_INS_USUARIO(?, ?, ?, ?, ?)}",
                "teste01", "hash", cpfExistente, "Teste da Silva", "M");
        assertThat(id).isNull();
        assertThat(ultimoLog("PRC_INS_USUARIO")).isEqualTo("Cod: -1 - Erro: CPF ja existente no sistema (UK).");
    }

    @Test
    void prcInsConsultaComChaveInexistenteGravaLog() throws SQLException {
        Long id = chamarComId("{? = call PKG_CT_CADASTRO.PRC_INS_CONSULTA(?, ?, ?, ?, ?, ?, ?)}",
                99999, 1, 1, 1, "obs", "orientação", java.time.LocalDateTime.now());
        assertThat(id).isNull();
        assertThat(ultimoLog("PRC_INS_CONSULTA"))
                .isEqualTo("Cod: -2291 - Erro: Um dos IDs relacionais (Vet/Tutor/Pet/Pagto) nao existe.");
    }

    @Test
    void triggerAuditaInsertUpdateEDeleteDePaciente() throws SQLException {
        try (CallableStatement chamada = conexao.prepareCall("{call PKG_CT_CADASTRO.PRC_INS_PACIENTE(?, ?, ?, ?, ?)}")) {
            chamada.setInt(1, 1);
            chamada.setInt(2, 4);
            chamada.setString(3, "Bidu");
            chamada.setString(4, "M");
            chamada.setString(5, "PEQUENO");
            chamada.execute();
        }
        long id = Long.parseLong(texto("SELECT TB_CT_PACIENTE_ID_PACIENTE_SEQ.CURRVAL FROM DUAL"));
        assertThat(texto("SELECT nome_paciente FROM TB_CT_PACIENTE WHERE id_paciente = " + id)).isEqualTo("Bidu");

        executar("UPDATE TB_CT_PACIENTE SET idade_paciente = 5 WHERE id_paciente = " + id);
        executar("DELETE FROM TB_CT_PACIENTE WHERE id_paciente = " + id);

        List<String> operacoes = linhas("""
                SELECT tipo_operacao || ' ' || NVL(valores_anteriores, '-') || ' => ' || NVL(valores_novos, '-')
                FROM TB_CT_AUDITORIA_DML WHERE valores_novos LIKE 'ID_PACIENTE=%s;%%' OR valores_anteriores LIKE 'ID_PACIENTE=%s;%%'
                ORDER BY id_auditoria""".formatted(id, id));
        assertThat(operacoes).hasSize(3);
        assertThat(operacoes.get(0)).isEqualTo("INSERT - => ID_PACIENTE=" + id
                + "; ID_ESPECIE=1; IDADE_PACIENTE=4; NOME_PACIENTE=Bidu; SEXO_PACIENTE=M; PORTE_PACIENTE=PEQUENO");
        assertThat(operacoes.get(1)).startsWith("UPDATE ID_PACIENTE=" + id).contains("IDADE_PACIENTE=5");
        assertThat(operacoes.get(2)).startsWith("DELETE ID_PACIENTE=" + id).endsWith("=> -");
    }

    @Test
    void fnCtRelacionalJsonMontaOObjeto() throws SQLException {
        assertThat(texto("SELECT PKG_CT_JSON.FN_CT_RELACIONAL_JSON('a', '1', 'b', 'x\"y', 'c', '3') FROM DUAL"))
                .isEqualTo("{\"a\":\"1\",\"b\":\"x\\\"y\",\"c\":\"3\"}");
        assertThat(texto("SELECT PKG_CT_JSON.FN_CT_RELACIONAL_JSON('a', NULL, 'b', '2', 'c', '3') FROM DUAL"))
                .isEqualTo("{\"erro\":\"Valor de campo obrigatorio nao pode ser nulo\"}");
    }

    @Test
    void fnCtMarketingPetsDevolveArrayOuErro() throws SQLException {
        String todos = funcaoMarketing(null, null);
        assertThat(todos).startsWith("[\n  {\"id_paciente\":").endsWith("}\n]");
        assertThat(funcaoMarketing("velho", null))
                .isEqualTo("{\"erro\":\"Faixa etaria invalida. Utilize JOVEM, ADULTO ou IDOSO.\"}");
        assertThat(funcaoMarketing(null, "AC")).isEqualTo("{\"erro\":\"UF invalida ou sem registros na base.\"}");
    }

    @Test
    void prcCtBuscaPetsPorTutorImprimeUmJsonPorPet() throws SQLException {
        List<String> saida = linhas("CALL PKG_CT_RELATORIOS.PRC_CT_BUSCA_PETS_POR_TUTOR(1)");
        assertThat(saida).hasSize(3).allMatch(linha -> linha.startsWith("{\"id_paciente\":"));
        assertThat(linhas("CALL PKG_CT_RELATORIOS.PRC_CT_BUSCA_PETS_POR_TUTOR(99999)"))
                .containsExactly("Erro: tutor informado nao existe");
    }

    @Test
    void prcCtResumoIdadePorteImprimeORelatorio() throws SQLException {
        List<String> saida = linhas("CALL PKG_CT_RELATORIOS.PRC_CT_RESUMO_IDADE_PORTE(NULL, NULL)");
        assertThat(saida.get(1)).isEqualTo("========== RELATORIO: SOMA DE IDADES POR FAIXA E PORTE ==========");
        assertThat(saida.get(saida.size() - 2)).startsWith("NULL                 | NULL            | ");
        assertThat(linhas("CALL PKG_CT_RELATORIOS.PRC_CT_RESUMO_IDADE_PORTE('JOVEM', NULL)"))
                .containsExactly("Erro: faixa etaria invalida. Utilize FILHOTE/JOVEM, ADULTO ou IDOSO.");
    }

    private static String senhaPorEmail(String email) {
        return """
                SELECT u.senha FROM TB_CT_USUARIO u
                JOIN TB_CT_DADOS_PESSOAIS dp ON dp.id_usuario = u.id_usuario
                JOIN TB_CT_CONTATO c ON c.id_contato = dp.id_contato
                WHERE c.email = '%s'""".formatted(email);
    }

    private static String funcaoMarketing(String faixa, String uf) throws SQLException {
        try (CallableStatement chamada = conexao.prepareCall("{? = call PKG_CT_RELATORIOS.FN_CT_MARKETING_PETS(?, ?)}")) {
            chamada.registerOutParameter(1, Types.VARCHAR);
            chamada.setString(2, faixa);
            chamada.setString(3, uf);
            chamada.execute();
            return chamada.getString(1);
        }
    }

    private static Long chamarComId(String sql, Object... parametros) throws SQLException {
        try (CallableStatement chamada = conexao.prepareCall(sql)) {
            chamada.registerOutParameter(1, Types.BIGINT);
            for (int i = 0; i < parametros.length; i++) {
                chamada.setObject(i + 2, parametros[i]);
            }
            chamada.execute();
            long id = chamada.getLong(1);
            return chamada.wasNull() ? null : id;
        }
    }

    private static String ultimoLog(String procedure) throws SQLException {
        return texto("SELECT mensagem_erro FROM TB_CT_LOG_ERRO WHERE nome_procedure = '" + procedure
                + "' ORDER BY id_log DESC FETCH FIRST 1 ROWS ONLY");
    }

    private static int contar(String tabela) throws SQLException {
        return Integer.parseInt(texto("SELECT COUNT(*) FROM " + tabela));
    }

    private static String texto(String sql) throws SQLException {
        try (PreparedStatement consulta = conexao.prepareStatement(sql); ResultSet r = consulta.executeQuery()) {
            return r.next() ? r.getString(1) : null;
        }
    }

    private static List<String> linhas(String sql) throws SQLException {
        List<String> resultado = new ArrayList<>();
        try (PreparedStatement consulta = conexao.prepareStatement(sql); ResultSet r = consulta.executeQuery()) {
            while (r.next()) {
                resultado.add(r.getString(1));
            }
        }
        return resultado;
    }

    private static void executar(String sql) throws SQLException {
        try (PreparedStatement comando = conexao.prepareStatement(sql)) {
            comando.executeUpdate();
        }
    }
}
