package br.com.fiap.clyvovet.repository;

import br.com.fiap.clyvovet.model.Pagina;
import br.com.fiap.clyvovet.model.RegistroDeAuditoria;
import br.com.fiap.clyvovet.model.RegistroDeErro;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

import java.util.List;

/** Leitura paginada das tabelas preenchidas pela trigger (TB_CT_AUDITORIA_DML) e pelos packages (TB_CT_LOG_ERRO). */
@Repository
public class AuditoriaRepository {

    private final JdbcTemplate jdbc;

    public AuditoriaRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public Pagina<RegistroDeAuditoria> listarOperacoes(int pagina, int tamanho) {
        return paginar("TB_CT_AUDITORIA_DML", """
                        SELECT id_auditoria, nome_tabela, usuario_banco, tipo_operacao, data_hora,
                               valores_anteriores, valores_novos
                        FROM TB_CT_AUDITORIA_DML ORDER BY id_auditoria DESC""",
                (r, linha) -> new RegistroDeAuditoria(r.getLong(1), r.getString(2), r.getString(3), r.getString(4),
                        r.getTimestamp(5).toLocalDateTime(), r.getString(6), r.getString(7)),
                pagina, tamanho);
    }

    public Pagina<RegistroDeErro> listarErros(int pagina, int tamanho) {
        return paginar("TB_CT_LOG_ERRO", """
                        SELECT id_log, nome_procedure, usuario_banco, data_ocorrencia, mensagem_erro
                        FROM TB_CT_LOG_ERRO ORDER BY id_log DESC""",
                (r, linha) -> new RegistroDeErro(r.getLong(1), r.getString(2), r.getString(3),
                        r.getTimestamp(4).toLocalDateTime(), r.getString(5)),
                pagina, tamanho);
    }

    private <T> Pagina<T> paginar(String tabela, String sql, RowMapper<T> mapeador, int pagina, int tamanho) {
        Long total = jdbc.queryForObject("SELECT COUNT(*) FROM " + tabela, Long.class);
        List<T> itens = jdbc.query(sql + " OFFSET ? ROWS FETCH NEXT ? ROWS ONLY", mapeador,
                (long) pagina * tamanho, tamanho);
        return Pagina.de(itens, pagina, tamanho, total == null ? 0 : total);
    }
}
