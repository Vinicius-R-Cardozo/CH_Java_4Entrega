package br.com.fiap.clyvovet.database.packages;

import javax.sql.DataSource;


public final class ConexaoAutonoma {

    private static volatile DataSource dataSource;

    private ConexaoAutonoma() {
    }

    public static void configurar(DataSource dataSourceDaAplicacao) {
        dataSource = dataSourceDaAplicacao;
    }

    static DataSource dataSource() {
        return dataSource;
    }
}
