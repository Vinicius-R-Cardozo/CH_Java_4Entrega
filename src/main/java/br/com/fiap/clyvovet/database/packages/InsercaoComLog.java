package br.com.fiap.clyvovet.database.packages;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Map;


final class InsercaoComLog {

    private InsercaoComLog() {
    }

    static void executar(Connection conexao, String procedure, Map<ErroOracle, String> mensagens,
                         String sql, Object... valores) throws SQLException {
        executar(conexao, procedure, mensagens, null, sql, valores);
    }

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
