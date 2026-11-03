package br.com.fiap.clyvovet.database;

import br.com.fiap.clyvovet.database.packages.ConexaoAutonoma;
import org.springframework.context.annotation.Configuration;

import javax.sql.DataSource;

/** Entrega o DataSource ao porte do PRC_REGISTRAR_LOG, para o log ser gravado numa transação autônoma. */
@Configuration
public class ConfiguracaoDosPackages {

    public ConfiguracaoDosPackages(DataSource dataSource) {
        ConexaoAutonoma.configurar(dataSource);
    }
}
