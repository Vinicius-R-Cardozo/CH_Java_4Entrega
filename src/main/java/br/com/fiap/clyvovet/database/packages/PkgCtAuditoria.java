package br.com.fiap.clyvovet.database.packages;

import javax.sql.DataSource;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;

/** Porte do PKG_CT_AUDITORIA (docs/database/PACKAGES_CELTICSTECH.sql). */
public final class PkgCtAuditoria {

    private static final int TAMANHO_MAXIMO_MENSAGEM = 250;

    private PkgCtAuditoria() {
    }

    /**
     * PRC_REGISTRAR_LOG(p_nome_proc, p_cod_erro, p_msg_erro).
     * No Oracle ela é PRAGMA AUTONOMOUS_TRANSACTION: o log fica gravado mesmo se a transação de quem
     * chamou for desfeita. Aqui isso é feito gravando por uma conexão separada, com commit automático.
     */
    public static void prcRegistrarLog(Connection conexao, String nomeProc, Integer codErro, String msgErro)
            throws SQLException {
        DataSource dataSource = ConexaoAutonoma.dataSource();
        if (dataSource == null) {
            inserirLog(conexao, nomeProc, codErro, msgErro);
            return;
        }
        try (Connection autonoma = dataSource.getConnection()) {
            autonoma.setAutoCommit(true);
            inserirLog(autonoma, nomeProc, codErro, msgErro);
        }
    }

    /** PRC_AUDITAR_PACIENTE(p_tipo_operacao, p_valores_anteriores, p_valores_novos), chamada pela trigger. */
    public static void prcAuditarPaciente(Connection conexao, String tipoOperacao, String valoresAnteriores,
                                          String valoresNovos) throws SQLException {
        String sql = """
                INSERT INTO TB_CT_AUDITORIA_DML
                    (NOME_TABELA, USUARIO_BANCO, TIPO_OPERACAO, DATA_HORA, VALORES_ANTERIORES, VALORES_NOVOS)
                VALUES ('TB_CT_PACIENTE', ?, ?, SYSDATE, ?, ?)""";
        try (PreparedStatement comando = conexao.prepareStatement(sql)) {
            comando.setString(1, usuarioDoBanco(conexao));
            comando.setString(2, tipoOperacao);
            comando.setString(3, valoresAnteriores);
            comando.setString(4, valoresNovos);
            comando.executeUpdate();
        } catch (SQLException excecao) {
            prcRegistrarLog(conexao, "PKG_CT_AUDITORIA.PRC_AUDITAR_PACIENTE",
                    ErroOracle.sqlcode(excecao), excecao.getMessage());
            throw excecao;
        }
    }

    private static void inserirLog(Connection conexao, String nomeProc, Integer codErro, String msgErro)
            throws SQLException {
        String sql = """
                INSERT INTO TB_CT_LOG_ERRO (id_log, nome_procedure, usuario_banco, data_ocorrencia, mensagem_erro)
                VALUES (NULL, ?, ?, SYSDATE, ?)""";
        try (PreparedStatement comando = conexao.prepareStatement(sql)) {
            comando.setString(1, nomeProc);
            comando.setString(2, usuarioDoBanco(conexao));
            comando.setString(3, "Cod: " + codErro + " - " + primeiros(msgErro, TAMANHO_MAXIMO_MENSAGEM));
            comando.executeUpdate();
        }
    }

    /** Equivalente ao USER / SYS_CONTEXT('USERENV','SESSION_USER') do Oracle. */
    static String usuarioDoBanco(Connection conexao) throws SQLException {
        return conexao.getMetaData().getUserName();
    }

    private static String primeiros(String texto, int tamanho) {
        if (texto == null) {
            return null;
        }
        return texto.length() <= tamanho ? texto : texto.substring(0, tamanho);
    }
}
