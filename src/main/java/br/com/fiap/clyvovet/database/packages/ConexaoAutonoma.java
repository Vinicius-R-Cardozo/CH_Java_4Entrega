package br.com.fiap.clyvovet.database.packages;

import javax.sql.DataSource;

/**
 * Guarda o DataSource da aplicação para o PRC_REGISTRAR_LOG abrir uma conexão própria,
 * reproduzindo o PRAGMA AUTONOMOUS_TRANSACTION do Oracle. O H2 chama os métodos dos packages
 * de forma estática, por isso o DataSource fica num campo estático preenchido na subida do Spring.
 */
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
