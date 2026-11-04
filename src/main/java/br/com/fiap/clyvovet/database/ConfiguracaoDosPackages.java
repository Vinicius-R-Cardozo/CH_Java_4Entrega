package br.com.fiap.clyvovet.database;

import br.com.fiap.clyvovet.database.packages.ConexaoAutonoma;
import org.springframework.context.annotation.Configuration;

import javax.sql.DataSource;

@Configuration
public class ConfiguracaoDosPackages {

    public ConfiguracaoDosPackages(DataSource dataSource) {
        ConexaoAutonoma.configurar(dataSource);
    }
}
