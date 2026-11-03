package br.com.fiap.clyvovet.database.packages;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Map;

/**
 * O padrão que se repete em todas as PRC_INS_* do PKG_CT_CADASTRO, escrito uma vez só:
 *
 * <pre>
 * BEGIN
 *     INSERT ... [RETURNING id INTO p_id_gerado];
 * EXCEPTION
 *     WHEN EX_... THEN PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG('PRC_...', SQLCODE, 'Erro: ...');
 *     WHEN OTHERS THEN PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG('PRC_...', SQLCODE, SQLERRM);
 * END;
 * </pre>
 *
 * Como no original, o erro é registrado em TB_CT_LOG_ERRO e não é relançado: quem chamou percebe
 * a falha pelo id nulo ou pelo log.
 */
final class InsercaoComLog {

    private InsercaoComLog() {
    }

    /** INSERT sem RETURNING (procedures sem parâmetro OUT). */
    static void executar(Connection conexao, String procedure, Map<ErroOracle, String> mensagens,
                         String sql, Object... valores) throws SQLException {
        executar(conexao, procedure, mensagens, null, sql, valores);
    }

    /**
     * INSERT com RETURNING coluna INTO p_id_gerado. O H2 não tem parâmetro OUT em procedures,
     * então o id gerado volta como retorno da função (ou null se o INSERT falhou).
     */
    static Long executar(Connection conexao, String procedure, Map<ErroOracle, String> mensagens,
                         String colunaId, String sql, Object... valores) throws SQLException {
        try (PreparedStatement comando = colunaId == null
                ? conexao.prepareStatement(sql)
                : conexao.prepareStatement(sql, new String[]{colunaId})) {
            for (int i = 0; i < valores.length; i++) {
                comando.setObject(i + 1, valores[i]);
            }
            comando.executeUpdate();
            return colunaId == null ? null : idGerado(comando);
        } catch (SQLException excecao) {
            String mensagem = ErroOracle.de(excecao)
                    .map(mensagens::get)
                    .orElse(excecao.getMessage());
            PkgCtAuditoria.prcRegistrarLog(conexao, procedure, ErroOracle.sqlcode(excecao), mensagem);
            return null;
        }
    }

    private static Long idGerado(PreparedStatement comando) throws SQLException {
        try (ResultSet chaves = comando.getGeneratedKeys()) {
            return chaves.next() ? chaves.getLong(1) : null;
        }
    }
}
