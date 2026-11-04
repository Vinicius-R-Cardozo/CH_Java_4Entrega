package br.com.fiap.clyvovet.database.packages;

import org.h2.tools.SimpleResultSet;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;

final class SaidaDbmsOutput {

    private static final String URL_DE_COLUNAS = "jdbc:columnlist:connection";

    private final List<String> linhas = new ArrayList<>();

    void putLine(String linha) {
        linhas.add(linha);
    }

    ResultSet comoResultSet() {
        SimpleResultSet resultado = estrutura();
        linhas.forEach(linha -> resultado.addRow(linha));
        return resultado;
    }

    static boolean apenasDescobrindoColunas(Connection conexao) throws SQLException {
        return URL_DE_COLUNAS.equals(conexao.getMetaData().getURL());
    }

    static SimpleResultSet estrutura() {
        SimpleResultSet resultado = new SimpleResultSet();
        resultado.addColumn("LINHA", Types.VARCHAR, 4000, 0);
        return resultado;
    }
}
