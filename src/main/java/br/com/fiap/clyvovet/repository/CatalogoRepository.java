package br.com.fiap.clyvovet.repository;

import br.com.fiap.clyvovet.model.ItemDeCatalogo;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

/** Medicamentos e exames do banco do grupo (carga fixa da V3). */
@Repository
public class CatalogoRepository {

    /**
     * Na carga do grupo, o medicamento 1 é "Nenhum Medicamento Prescrito" e o exame 1 é "Nenhum Exame Solicitado".
     * São usados quando o atendimento não prescreve nada, porque TB_CT_PRESCRICAO exige os dois.
     */
    public static final long NENHUM_MEDICAMENTO = 1L;
    public static final long NENHUM_EXAME = 1L;

    private final JdbcTemplate jdbc;

    public CatalogoRepository(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public List<ItemDeCatalogo> listarMedicamentos() {
        return jdbc.query("""
                        SELECT id_medicamento, nome_medicamento, tipo_medicamento FROM TB_CT_MEDICAMENTO
                        WHERE id_medicamento <> ? ORDER BY nome_medicamento""",
                (r, linha) -> new ItemDeCatalogo(r.getLong(1), r.getString(2), r.getString(3)), NENHUM_MEDICAMENTO);
    }

    public List<ItemDeCatalogo> listarExames() {
        return jdbc.query("""
                        SELECT id_exame, nome_exame, orientacoes_exame FROM TB_CT_EXAME
                        WHERE id_exame <> ? ORDER BY nome_exame""",
                (r, linha) -> new ItemDeCatalogo(r.getLong(1), r.getString(2), r.getString(3)), NENHUM_EXAME);
    }

    public Optional<String> nomeDoMedicamento(Long id) {
        return jdbc.query("SELECT nome_medicamento FROM TB_CT_MEDICAMENTO WHERE id_medicamento = ?",
                (r, linha) -> r.getString(1), id).stream().findFirst();
    }

    public boolean existeExame(Long id) {
        Integer total = jdbc.queryForObject("SELECT COUNT(*) FROM TB_CT_EXAME WHERE id_exame = ?", Integer.class, id);
        return total != null && total > 0;
    }
}
