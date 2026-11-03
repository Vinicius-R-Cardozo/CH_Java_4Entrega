package br.com.fiap.clyvovet.database.packages;

import java.sql.Connection;
import java.sql.SQLException;

/** Porte do PKG_CT_JSON (docs/database/PACKAGES_CELTICSTECH.sql). */
public final class PkgCtJson {

    private static final String NOME_FUNCAO = "PKG_CT_JSON.FN_CT_RELACIONAL_JSON";
    private static final int CAMPOS_OBRIGATORIOS = 3;
    private static final int MAXIMO_DE_CAMPOS = 10;

    private PkgCtJson() {
    }

    /**
     * FN_CT_RELACIONAL_JSON(p_campo1_nome, p_campo1_valor, ..., p_campo10_nome, p_campo10_valor).
     * Os 3 primeiros pares são obrigatórios; do 4º ao 10º o PL/SQL usa DEFAULT NULL, aqui são opcionais
     * (varargs). Todos os valores viram texto entre aspas, como no original.
     */
    public static String fnCtRelacionalJson(Connection conexao, String... nomesEValores) throws SQLException {
        String[] campos = new String[MAXIMO_DE_CAMPOS * 2];
        System.arraycopy(nomesEValores, 0, campos, 0, Math.min(nomesEValores.length, campos.length));

        for (int i = 0; i < CAMPOS_OBRIGATORIOS; i++) {
            if (nome(campos, i) == null) {
                return erro(conexao, -20001, "Nome de campo obrigatorio nao pode ser nulo");
            }
        }
        for (int i = 0; i < CAMPOS_OBRIGATORIOS; i++) {
            if (valor(campos, i) == null) {
                return erro(conexao, -20002, "Valor de campo obrigatorio nao pode ser nulo");
            }
        }
        for (int i = 0; i < MAXIMO_DE_CAMPOS; i++) {
            if (nome(campos, i) != null && nome(campos, i).contains("\"")) {
                return erro(conexao, -20003, "Nome de campo possui caractere invalido para JSON");
            }
        }

        StringBuilder json = new StringBuilder("{");
        for (int i = 0; i < MAXIMO_DE_CAMPOS; i++) {
            if (nome(campos, i) == null) {
                continue;
            }
            if (valor(campos, i) == null) {
                return erro(conexao, -20002, "Valor de campo obrigatorio nao pode ser nulo");
            }
            if (json.length() > 1) {
                json.append(',');
            }
            json.append('"').append(nome(campos, i)).append("\":\"")
                    .append(valor(campos, i).replace("\"", "\\\"")).append('"');
        }
        return json.append('}').toString();
    }

    private static String nome(String[] campos, int indice) {
        return campos[indice * 2];
    }

    private static String valor(String[] campos, int indice) {
        return campos[indice * 2 + 1];
    }

    private static String erro(Connection conexao, int codigo, String mensagem) throws SQLException {
        PkgCtAuditoria.prcRegistrarLog(conexao, NOME_FUNCAO, codigo, mensagem);
        return "{\"erro\":\"" + mensagem + "\"}";
    }
}
