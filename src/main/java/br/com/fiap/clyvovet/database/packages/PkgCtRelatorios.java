package br.com.fiap.clyvovet.database.packages;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.DecimalFormat;
import java.text.DecimalFormatSymbols;
import java.util.ArrayList;
import java.util.List;
import java.util.Locale;
import java.util.Set;

/** Porte do PKG_CT_RELATORIOS (docs/database/PACKAGES_CELTICSTECH.sql). */
public final class PkgCtRelatorios {

    private static final Set<String> UFS = Set.of("AC", "AL", "AP", "AM", "BA", "CE", "DF", "ES", "GO", "MA", "MT",
            "MS", "MG", "PA", "PB", "PR", "PE", "PI", "RJ", "RN", "RS", "RO", "RR", "SC", "SE", "SP", "TO");
    private static final Set<String> FAIXAS_MARKETING = Set.of("JOVEM", "ADULTO", "IDOSO");
    private static final Set<String> FAIXAS_RESUMO = Set.of("FILHOTE/JOVEM", "ADULTO", "IDOSO");
    private static final Set<String> PORTES = Set.of("GRANDE", "MEDIO", "PEQUENO", "SPD");

    private static final String SEPARADOR_DUPLO = "======================================================================";
    private static final String SEPARADOR_SIMPLES = "----------------------------------------------------------------------";
    private static final int LARGURA_FAIXA = 20;
    private static final int LARGURA_PORTE = 15;

    private PkgCtRelatorios() {
    }

    /** Equivale aos RAISE de exceções nomeadas do PL/SQL: código e mensagem para o log. */
    private static final class ErroDeRegra extends Exception {
        private final int codigo;
        private final String linhaDeSaida;

        private ErroDeRegra(int codigo, String mensagem) {
            this(codigo, mensagem, null);
        }

        /** linhaDeSaida: o texto que o PL/SQL imprime com DBMS_OUTPUT nesse erro. */
        private ErroDeRegra(int codigo, String mensagem, String linhaDeSaida) {
            super(mensagem);
            this.codigo = codigo;
            this.linhaDeSaida = linhaDeSaida;
        }
    }

    // FUNCTION FN_CT_MARKETING_PETS (p_faixa_etaria, p_uf) RETURN CLOB
    public static String fnCtMarketingPets(Connection conexao, String pFaixaEtaria, String pUf) throws SQLException {
        String faixa = normalizar(pFaixaEtaria);
        String uf = normalizar(pUf);
        try {
            if (faixa != null && !FAIXAS_MARKETING.contains(faixa)) {
                throw new ErroDeRegra(-20001, "Faixa etaria invalida. Utilize JOVEM, ADULTO ou IDOSO.");
            }
            if (uf != null && (!UFS.contains(uf) || contarEnderecosNaUf(conexao, uf) == 0)) {
                throw new ErroDeRegra(-20002, "UF invalida ou sem registros na base.");
            }

            List<String> objetos = new ArrayList<>();
            String sql = """
                    SELECT p.id_paciente, p.nome_paciente AS nome_pet, p.idade_paciente AS idade, t.id_tutor,
                           u.nome_usuario AS nome_tutor, en.uf_endereco AS uf, c.telefone, c.email
                    FROM TB_CT_PET pt
                    JOIN TB_CT_PACIENTE p ON pt.id_paciente = p.id_paciente
                    JOIN TB_CT_TUTOR t ON pt.id_tutor = t.id_tutor
                    JOIN TB_CT_USUARIO u ON t.id_usuario = u.id_usuario
                    LEFT JOIN TB_CT_DADOS_PESSOAIS dp ON u.id_usuario = dp.id_usuario
                    LEFT JOIN TB_CT_CONTATO c ON dp.id_contato = c.id_contato
                    LEFT JOIN TB_CT_ENDERECO en ON dp.id_endereco = en.id_endereco
                    WHERE (CAST(? AS VARCHAR2(10)) IS NULL
                           OR (? = 'JOVEM' AND p.idade_paciente BETWEEN 1 AND 2)
                           OR (? = 'ADULTO' AND p.idade_paciente BETWEEN 3 AND 8)
                           OR (? = 'IDOSO' AND p.idade_paciente >= 9))
                      AND (CAST(? AS VARCHAR2(2)) IS NULL OR en.uf_endereco = ?)
                    ORDER BY en.uf_endereco, p.idade_paciente, p.nome_paciente""";
            try (PreparedStatement consulta = conexao.prepareStatement(sql)) {
                for (int i = 1; i <= 4; i++) {
                    consulta.setString(i, faixa);
                }
                consulta.setString(5, uf);
                consulta.setString(6, uf);
                try (ResultSet r = consulta.executeQuery()) {
                    while (r.next()) {
                        objetos.add("  " + PkgCtJson.fnCtRelacionalJson(conexao,
                                "id_paciente", r.getString("id_paciente"),
                                "nome_pet", r.getString("nome_pet"),
                                "idade", r.getString("idade"),
                                "id_tutor", r.getString("id_tutor"),
                                "nome_tutor", r.getString("nome_tutor"),
                                "uf", r.getString("uf"),
                                "telefone", r.getString("telefone"),
                                "email", r.getString("email")));
                    }
                }
            }
            if (objetos.isEmpty()) {
                throw new ErroDeRegra(-20003, "Nenhum pet encontrado para os filtros informados.");
            }
            return "[\n" + String.join(",\n", objetos) + "\n]";
        } catch (ErroDeRegra erro) {
            PkgCtAuditoria.prcRegistrarLog(conexao, "FN_CT_MARKETING_PETS", erro.codigo, erro.getMessage());
            return "{\"erro\":\"" + erro.getMessage() + "\"}";
        } catch (SQLException excecao) {
            PkgCtAuditoria.prcRegistrarLog(conexao, "FN_CT_MARKETING_PETS",
                    ErroOracle.sqlcode(excecao), excecao.getMessage());
            return "{\"erro\":\"Erro inesperado na segmentacao de marketing.\"}";
        }
    }

    // PROCEDURE PRC_CT_BUSCA_PETS_POR_TUTOR (p_id_tutor) — resultado via DBMS_OUTPUT, aqui como ResultSet.
    public static ResultSet prcCtBuscaPetsPorTutor(Connection conexao, Integer pIdTutor) throws SQLException {
        if (SaidaDbmsOutput.apenasDescobrindoColunas(conexao)) {
            return SaidaDbmsOutput.estrutura();
        }
        SaidaDbmsOutput saida = new SaidaDbmsOutput();
        try {
            if (pIdTutor == null) {
                throw new ErroDeRegra(-20001, "ID do tutor nao informado", "Erro: ID do tutor nao informado");
            }
            if (contar(conexao, "SELECT COUNT(*) FROM TB_CT_TUTOR WHERE id_tutor = ?", pIdTutor) == 0) {
                throw new ErroDeRegra(-20002, "Tutor informado nao existe", "Erro: tutor informado nao existe");
            }
            int quantidadeDePets = 0;
            String sql = """
                    SELECT p.id_paciente, p.nome_paciente, e.nome_especie, p.idade_paciente, p.porte_paciente
                    FROM TB_CT_PET pt
                    JOIN TB_CT_PACIENTE p ON pt.id_paciente = p.id_paciente
                    JOIN TB_CT_ESPECIE e ON p.id_especie = e.id_especie
                    WHERE pt.id_tutor = ?""";
            try (PreparedStatement consulta = conexao.prepareStatement(sql)) {
                consulta.setInt(1, pIdTutor);
                try (ResultSet r = consulta.executeQuery()) {
                    while (r.next()) {
                        quantidadeDePets++;
                        saida.putLine(PkgCtJson.fnCtRelacionalJson(conexao,
                                "id_paciente", r.getString("id_paciente"),
                                "nome_paciente", r.getString("nome_paciente"),
                                "especie", r.getString("nome_especie"),
                                "idade", r.getString("idade_paciente"),
                                "porte", r.getString("porte_paciente")));
                    }
                }
            }
            if (quantidadeDePets == 0) {
                throw new ErroDeRegra(-20003, "Nenhum pet encontrado para o tutor informado",
                        "Erro: nenhum pet encontrado para o tutor informado");
            }
        } catch (ErroDeRegra erro) {
            PkgCtAuditoria.prcRegistrarLog(conexao, "PRC_CT_BUSCA_PETS_POR_TUTOR", erro.codigo, erro.getMessage());
            saida.putLine(erro.linhaDeSaida);
        } catch (SQLException excecao) {
            PkgCtAuditoria.prcRegistrarLog(conexao, "PRC_CT_BUSCA_PETS_POR_TUTOR",
                    ErroOracle.sqlcode(excecao), excecao.getMessage());
            saida.putLine("Erro inesperado: " + excecao.getMessage());
        }
        return saida.comoResultSet();
    }

    // PROCEDURE PRC_CT_RESUMO_IDADE_PORTE (p_faixa_etaria, p_porte) — soma das idades por faixa e porte.
    public static ResultSet prcCtResumoIdadePorte(Connection conexao, String pFaixaEtaria, String pPorte)
            throws SQLException {
        if (SaidaDbmsOutput.apenasDescobrindoColunas(conexao)) {
            return SaidaDbmsOutput.estrutura();
        }
        SaidaDbmsOutput saida = new SaidaDbmsOutput();
        String faixaFiltro = normalizar(pFaixaEtaria);
        String porteFiltro = normalizar(pPorte);
        try {
            if (faixaFiltro != null && !FAIXAS_RESUMO.contains(faixaFiltro)) {
                throw erroFaixaDoResumo();
            }
            if (porteFiltro != null && !PORTES.contains(porteFiltro)) {
                throw erroPorteDoResumo();
            }

            saida.putLine(SEPARADOR_DUPLO);
            saida.putLine("========== RELATORIO: SOMA DE IDADES POR FAIXA E PORTE ==========");
            saida.putLine(SEPARADOR_DUPLO);
            saida.putLine(rpad("FAIXA ETARIA", LARGURA_FAIXA) + " | " + rpad("PORTE", LARGURA_PORTE) + " | SOMA DAS IDADES");
            saida.putLine(SEPARADOR_SIMPLES);

            String sql = """
                    SELECT nome_paciente, idade_paciente, porte_paciente
                    FROM TB_CT_PACIENTE
                    WHERE idade_paciente IS NOT NULL
                      AND (CAST(? AS VARCHAR2(20)) IS NULL
                           OR (? = 'FILHOTE/JOVEM' AND idade_paciente <= 2)
                           OR (? = 'ADULTO' AND idade_paciente > 2 AND idade_paciente <= 8)
                           OR (? = 'IDOSO' AND idade_paciente > 8))
                      AND (CAST(? AS VARCHAR2(30)) IS NULL OR UPPER(TRIM(porte_paciente)) = ?)
                    ORDER BY CASE WHEN idade_paciente <= 2 THEN 1 WHEN idade_paciente <= 8 THEN 2 ELSE 3 END,
                             porte_paciente, nome_paciente""";

            int quantidade = 0;
            String faixaAnterior = null;
            String porteAnterior = null;
            int somaCombinacao = 0;
            int subtotalFaixa = 0;
            int totalGeral = 0;

            try (PreparedStatement consulta = conexao.prepareStatement(sql)) {
                for (int i = 1; i <= 4; i++) {
                    consulta.setString(i, faixaFiltro);
                }
                consulta.setString(5, porteFiltro);
                consulta.setString(6, porteFiltro);
                try (ResultSet r = consulta.executeQuery()) {
                    while (r.next()) {
                        quantidade++;
                        int idade = r.getInt("idade_paciente");
                        String porte = r.getString("porte_paciente");
                        if (idade < 0) {
                            throw erroFaixaDoResumo();
                        }
                        if (porte == null) {
                            throw erroPorteDoResumo();
                        }
                        String faixa = idade <= 2 ? "Filhote/Jovem" : idade <= 8 ? "Adulto" : "Idoso";

                        if (faixaAnterior == null) {
                            faixaAnterior = faixa;
                            porteAnterior = porte;
                            somaCombinacao = idade;
                            subtotalFaixa = idade;
                            totalGeral = idade;
                        } else if (!faixa.equals(faixaAnterior)) {
                            saida.putLine(linhaResumo(faixaAnterior, porteAnterior, somaCombinacao));
                            saida.putLine(linhaResumo(faixaAnterior, "NULL", subtotalFaixa));
                            saida.putLine(SEPARADOR_SIMPLES);
                            faixaAnterior = faixa;
                            porteAnterior = porte;
                            somaCombinacao = idade;
                            subtotalFaixa = idade;
                            totalGeral += idade;
                        } else if (!porte.equals(porteAnterior)) {
                            saida.putLine(linhaResumo(faixaAnterior, porteAnterior, somaCombinacao));
                            porteAnterior = porte;
                            somaCombinacao = idade;
                            subtotalFaixa += idade;
                            totalGeral += idade;
                        } else {
                            somaCombinacao += idade;
                            subtotalFaixa += idade;
                            totalGeral += idade;
                        }
                    }
                }
            }
            if (quantidade == 0) {
                throw new ErroDeRegra(-20003, "Nenhum paciente encontrado para os filtros informados.",
                        "Nenhum paciente foi encontrado para os filtros informados.");
            }
            saida.putLine(linhaResumo(faixaAnterior, porteAnterior, somaCombinacao));
            saida.putLine(linhaResumo(faixaAnterior, "NULL", subtotalFaixa));
            saida.putLine(SEPARADOR_DUPLO);
            saida.putLine(linhaResumo("NULL", "NULL", totalGeral));
            saida.putLine(SEPARADOR_DUPLO);
        } catch (ErroDeRegra erro) {
            PkgCtAuditoria.prcRegistrarLog(conexao, "PRC_CT_RESUMO_IDADE_PORTE", erro.codigo, erro.getMessage());
            saida.putLine(erro.linhaDeSaida);
        } catch (SQLException excecao) {
            PkgCtAuditoria.prcRegistrarLog(conexao, "PRC_CT_RESUMO_IDADE_PORTE",
                    ErroOracle.sqlcode(excecao), excecao.getMessage());
            saida.putLine("Ocorreu um erro inesperado durante a execucao da procedure.");
            saida.putLine("Codigo do erro Oracle: " + ErroOracle.sqlcode(excecao));
            saida.putLine("Mensagem: " + primeiros(excecao.getMessage(), 150));
        }
        return saida.comoResultSet();
    }

    private static ErroDeRegra erroFaixaDoResumo() {
        return new ErroDeRegra(-20001, "Faixa etaria invalida. Utilize FILHOTE/JOVEM, ADULTO ou IDOSO.",
                "Erro: faixa etaria invalida. Utilize FILHOTE/JOVEM, ADULTO ou IDOSO.");
    }

    private static ErroDeRegra erroPorteDoResumo() {
        return new ErroDeRegra(-20002, "Porte invalido. Utilize GRANDE, MEDIO, PEQUENO ou SPD.",
                "Erro: porte invalido. Utilize GRANDE, MEDIO, PEQUENO ou SPD.");
    }

    /** RPAD(faixa, 20) || ' | ' || RPAD(porte, 15) || ' | ' || TO_CHAR(valor, '999G990D00'). */
    private static String linhaResumo(String faixa, String porte, int valor) {
        DecimalFormat formato = new DecimalFormat("#,##0.00", DecimalFormatSymbols.getInstance(new Locale("pt", "BR")));
        return rpad(faixa, LARGURA_FAIXA) + " | " + rpad(porte, LARGURA_PORTE) + " | "
                + String.format("%11s", formato.format(valor));
    }

    private static String rpad(String texto, int largura) {
        return texto.length() >= largura ? texto.substring(0, largura) : String.format("%-" + largura + "s", texto);
    }

    /** UPPER(TRIM(valor)), tratando texto vazio como NULL, como o Oracle faz. */
    private static String normalizar(String valor) {
        if (valor == null || valor.isBlank()) {
            return null;
        }
        return valor.trim().toUpperCase(Locale.ROOT);
    }

    private static String primeiros(String texto, int tamanho) {
        return texto == null || texto.length() <= tamanho ? texto : texto.substring(0, tamanho);
    }

    private static int contarEnderecosNaUf(Connection conexao, String uf) throws SQLException {
        return contar(conexao, "SELECT COUNT(*) FROM TB_CT_ENDERECO WHERE uf_endereco = ?", uf);
    }

    private static int contar(Connection conexao, String sql, Object parametro) throws SQLException {
        try (PreparedStatement consulta = conexao.prepareStatement(sql)) {
            consulta.setObject(1, parametro);
            try (ResultSet r = consulta.executeQuery()) {
                r.next();
                return r.getInt(1);
            }
        }
    }
}
