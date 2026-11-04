package br.com.fiap.clyvovet.repository;

import br.com.fiap.clyvovet.model.AlergiaDoPet;
import br.com.fiap.clyvovet.model.AtendimentoClinico;
import br.com.fiap.clyvovet.model.CuidadoDaEspecie;
import br.com.fiap.clyvovet.model.Gravidade;
import br.com.fiap.clyvovet.model.TipoPagamento;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public class ProntuarioRepository {

    private final JdbcTemplate jdbc;

    public ProntuarioRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public List<AtendimentoClinico> listarAtendimentos(Long idPaciente) {
        return jdbc.query("""
                        SELECT c.id_consulta, c.data_consulta, u.nome_usuario, v.crmv, pg.tipo_pagamento,
                               c.observacoes, c.orientacao_consulta,
                               LISTAGG(CASE WHEN pr.id_medicamento <> ? THEN m.nome_medicamento END, ', ')
                                   WITHIN GROUP (ORDER BY m.nome_medicamento) AS medicamentos,
                               LISTAGG(CASE WHEN pr.id_exame <> ? THEN e.nome_exame END, ', ')
                                   WITHIN GROUP (ORDER BY e.nome_exame) AS exames
                        FROM TB_CT_CONSULTA c
                        JOIN TB_CT_VETERINARIO v ON v.id_veterinario = c.id_veterinario
                        JOIN TB_CT_USUARIO u ON u.id_usuario = v.id_usuario
                        JOIN TB_CT_PAGAMENTO pg ON pg.id_pagamento = c.id_pagamento
                        LEFT JOIN TB_CT_PRESCRICAO pr ON pr.id_consulta = c.id_consulta
                        LEFT JOIN TB_CT_MEDICAMENTO m ON m.id_medicamento = pr.id_medicamento
                        LEFT JOIN TB_CT_EXAME e ON e.id_exame = pr.id_exame
                        WHERE c.id_paciente = ?
                        GROUP BY c.id_consulta, c.data_consulta, u.nome_usuario, v.crmv, pg.tipo_pagamento,
                                 c.observacoes, c.orientacao_consulta
                        ORDER BY c.data_consulta DESC""",
                (r, linha) -> new AtendimentoClinico(
                        r.getLong("id_consulta"),
                        r.getTimestamp("data_consulta").toLocalDateTime().toLocalDate(),
                        r.getString("nome_usuario"),
                        r.getString("crmv"),
                        TipoPagamento.valueOf(r.getString("tipo_pagamento")),
                        r.getString("observacoes"),
                        r.getString("orientacao_consulta"),
                        r.getString("medicamentos"),
                        r.getString("exames")),
                CatalogoRepository.NENHUM_MEDICAMENTO, CatalogoRepository.NENHUM_EXAME, idPaciente);
    }

    public List<CuidadoDaEspecie> listarCuidadosDaEspecie(Long idRaca) {
        return jdbc.query("""
                        SELECT 'PREDISPOSICAO' AS tipo, p.nome_predisposicao AS nome,
                               p.orientacao_predisposicao AS orientacao, CAST(NULL AS VARCHAR2(5)) AS gravidade
                        FROM TB_CT_CUIDADO c JOIN TB_CT_PREDISPOSICAO_ESP p ON p.id_predisposicao = c.id_predisposicao
                        WHERE c.id_especie = ?
                        UNION
                        SELECT 'RESTRICAO', r.nome_restricao, r.orientacao_restricao, r.gravidade_restricao
                        FROM TB_CT_CUIDADO c JOIN TB_CT_RESTRICAO_ESP r ON r.id_restricao = c.id_restricao
                        WHERE c.id_especie = ?
                        ORDER BY 1, 2""",
                (r, linha) -> new CuidadoDaEspecie(
                        CuidadoDaEspecie.Tipo.valueOf(r.getString("tipo")),
                        r.getString("nome"),
                        r.getString("orientacao"),
                        r.getString("gravidade") == null ? null : Gravidade.valueOf(r.getString("gravidade"))),
                idRaca, idRaca);
    }

    public List<AlergiaDoPet> listarAlergias(Long idPaciente) {
        return jdbc.query("""
                        SELECT a.id_medicamento, m.nome_medicamento, a.gravidade_alergia
                        FROM TB_CT_ALERGIA a JOIN TB_CT_MEDICAMENTO m ON m.id_medicamento = a.id_medicamento
                        WHERE a.id_paciente = ? ORDER BY m.nome_medicamento""",
                (r, linha) -> new AlergiaDoPet(r.getLong(1), r.getString(2), Gravidade.valueOf(r.getString(3))),
                idPaciente);
    }

    public boolean temConsulta(Long idPaciente) {
        Integer total = jdbc.queryForObject("SELECT COUNT(*) FROM TB_CT_CONSULTA WHERE id_paciente = ?",
                Integer.class, idPaciente);
        return total != null && total > 0;
    }

    public void excluirAlergias(Long idPaciente) {
        jdbc.update("DELETE FROM TB_CT_ALERGIA WHERE id_paciente = ?", idPaciente);
    }
}
