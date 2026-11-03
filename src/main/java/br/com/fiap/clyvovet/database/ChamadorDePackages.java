package br.com.fiap.clyvovet.database;

import br.com.fiap.clyvovet.exception.ErroNoBancoException;
import org.springframework.jdbc.core.ConnectionCallback;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;

import java.sql.CallableStatement;
import java.sql.SQLException;
import java.sql.Types;
import java.util.List;

/**
 * Executa as chamadas aos packages do grupo dentro da transação do Spring (o JdbcTemplate usa a mesma
 * conexão do @Transactional do service, por isso o COMMIT/ROLLBACK é de quem chamou, como no Oracle).
 *
 * As PRC_INS_* do grupo não relançam erro: gravam em TB_CT_LOG_ERRO e terminam normalmente.
 * Por isso, depois de cada chamada, conferimos se apareceu um log novo daquela procedure; se apareceu,
 * a mensagem vira uma exceção para a tela e o @Transactional desfaz o que já tinha sido gravado.
 */
@Component
public class ChamadorDePackages {

    private final JdbcTemplate jdbc;

    public ChamadorDePackages(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    /** Procedure com p_id_gerado OUT. No H2 o id volta como retorno: {? = call PKG.PROCEDURE(...)}. */
    public Long chamarComId(String procedure, String chamada, Object... parametros) {
        long ultimoLog = ultimoLog();
        Long id = jdbc.execute((ConnectionCallback<Long>) conexao -> {
            try (CallableStatement comando = conexao.prepareCall(chamada)) {
                comando.registerOutParameter(1, Types.BIGINT);
                preencher(comando, 2, parametros);
                comando.execute();
                long valor = comando.getLong(1);
                return comando.wasNull() ? null : valor;
            }
        });
        verificarErro(procedure, ultimoLog);
        if (id == null) {
            throw new ErroNoBancoException(procedure, "o banco não devolveu o código gerado.");
        }
        return id;
    }

    /** Procedure sem parâmetro OUT: {call PKG.PROCEDURE(...)}. */
    public void chamar(String procedure, String chamada, Object... parametros) {
        long ultimoLog = ultimoLog();
        jdbc.execute((ConnectionCallback<Void>) conexao -> {
            try (CallableStatement comando = conexao.prepareCall(chamada)) {
                preencher(comando, 1, parametros);
                comando.execute();
                return null;
            }
        });
        verificarErro(procedure, ultimoLog);
    }

    /** Função que devolve texto: {? = call PKG.FUNCAO(...)}. */
    public String chamarFuncao(String chamada, Object... parametros) {
        return jdbc.execute((ConnectionCallback<String>) conexao -> {
            try (CallableStatement comando = conexao.prepareCall(chamada)) {
                comando.registerOutParameter(1, Types.VARCHAR);
                preencher(comando, 2, parametros);
                comando.execute();
                return comando.getString(1);
            }
        });
    }

    /** Procedure que no Oracle imprime com DBMS_OUTPUT: no H2 as linhas voltam como resultado (coluna LINHA). */
    public List<String> chamarComSaida(String chamada, Object... parametros) {
        return jdbc.query(chamada, (resultado, linha) -> resultado.getString("LINHA"), parametros);
    }

    /** Lê CURRVAL da sequence na mesma sessão, para as procedures que não devolvem o id gerado. */
    public Long valorAtualDaSequence(String sequence) {
        return jdbc.queryForObject("SELECT " + sequence + ".CURRVAL FROM DUAL", Long.class);
    }

    private long ultimoLog() {
        Long id = jdbc.queryForObject("SELECT NVL(MAX(id_log), 0) FROM TB_CT_LOG_ERRO", Long.class);
        return id == null ? 0 : id;
    }

    private void verificarErro(String procedure, long ultimoLogAntesDaChamada) {
        jdbc.query("""
                        SELECT mensagem_erro FROM TB_CT_LOG_ERRO
                        WHERE nome_procedure = ? AND id_log > ?
                        ORDER BY id_log DESC FETCH FIRST 1 ROWS ONLY""",
                (resultado, linha) -> resultado.getString(1), procedure, ultimoLogAntesDaChamada)
                .stream()
                .findFirst()
                .ifPresent(mensagem -> {
                    throw new ErroNoBancoException(procedure, mensagem);
                });
    }

    private static void preencher(CallableStatement comando, int primeiraPosicao, Object... parametros)
            throws SQLException {
        for (int i = 0; i < parametros.length; i++) {
            comando.setObject(primeiraPosicao + i, parametros[i]);
        }
    }
}
