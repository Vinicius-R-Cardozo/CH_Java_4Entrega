package db.migration;

import org.flywaydb.core.api.migration.BaseJavaMigration;
import org.flywaydb.core.api.migration.Context;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;

public class V4__CargaInicial extends BaseJavaMigration {

    private static final long SEMENTE = 2026L;
    private static final int TOTAL_USUARIOS = 100;
    private static final int TOTAL_PACIENTES = 60;
    private static final int ULTIMO_ID_VETERINARIO = 10;
    private static final int PRIMEIRO_CRMV = 1001;
    private static final int CONSULTAS_DA_CARGA = 30;
    private static final int PORCENTAGEM_SEM_MEDICAMENTO = 20;
    private static final int ID_NENHUM = 1;

    private static final String[] NOMES_M = {"Gabriel", "Lucas", "Marcos", "Rafael", "Rodrigo", "Bruno", "Thiago",
            "Felipe", "Andre", "Ricardo", "Fabio", "Leonardo", "Gustavo", "Guilherme", "Mateus", "Joao", "Victor",
            "Jose", "Renan"};
    private static final String[] NOMES_F = {"Ana", "Julia", "Fernanda", "Beatriz", "Camila", "Larissa", "Mariana",
            "Leticia", "Amanda", "Priscila", "Carolina", "Debora", "Bianca", "Vanessa", "Isabela", "Ercilia", "Alayde",
            "Sabrina"};
    private static final String[] SOBRENOMES = {"Silva", "Santos", "Oliveira", "Souza", "Pereira", "Costa",
            "Carvalho", "Almeida", "Ferreira", "Ribeiro", "Mendes", "Nascimento", "Alves", "Monteiro", "Cardoso",
            "Ambrosio", "Vendrameto", "Mariano", "Estorino", "Sato", "Santos"};
    private static final String[] UFS = {"SP", "RJ", "MG", "PR", "RS", "BA"};
    private static final String[] CIDADES = {"São Paulo", "Rio de Janeiro", "Belo Horizonte", "Curitiba",
            "Porto Alegre", "Salvador"};
    private static final String[] CEPS = {"01310000", "20040002", "30140001", "80010010", "90010001", "40010000"};
    private static final String[] DDDS = {"11", "21", "31", "41", "51", "71"};
    private static final String[] LOGRADOUROS = {"Avenida Paulista", "Avenida Rio Branco", "Avenida Afonso Pena",
            "Rua XV de Novembro", "Avenida Ipiranga", "Avenida Sete de Setembro"};

    private static final String[] CAES_M = {"Thor", "Luke", "Bob", "Rex", "Teo", "Freud", "Banzai", "Brutus",
            "Apollo", "Pingo"};
    private static final String[] GATOS_M = {"Garfield", "Oliver", "Simba", "Tom", "Mingau", "Félix", "Frajola", "Zeca"};
    private static final String[] EXOT_M = {"Nemo", "Snape", "Draco", "Kaa", "Fred", "Zazu", "Yoshi"};
    private static final String[] CAES_F = {"Mel", "Luna", "Maggie", "Amora", "Nina", "Cacau", "Pipoca", "Belinha",
            "Maia", "Cloe"};
    private static final String[] GATOS_F = {"Mia", "Luna", "Fiona", "Pipoca", "Frida", "Pretinha", "Pandora", "Cleo"};
    private static final String[] EXOT_F = {"Bubbles", "Hedwig", "Glub", "Dory", "Jade", "Fiona", "Flora"};
    private static final String RACAS_DE_CAES = "'Vira lata SDR', 'Shih Tzu', 'Spitz Alemao', 'Golden Retriever', "
            + "'Pug', 'Poodle', 'Pastor Alemao', 'Labrador Retriever', 'Bulldog Frances', 'Rottweiler'";

    private final Random aleatorio = new Random(SEMENTE);
    // Custo baixo só para a carga não demorar: são 100 senhas aleatórias que ninguém usa para entrar.
    private final BCryptPasswordEncoder codificador = new BCryptPasswordEncoder(4);

    @Override
    public void migrate(Context context) throws Exception {
        Connection conexao = context.getConnection();
        inserirUsuarios(conexao);
        inserirCuidados(conexao);
        inserirPacientes(conexao);
        separarVeterinariosETutores(conexao);
        vincularPetsAosTutores(conexao);
        inserirAlergias(conexao);
        inserirConsultas(conexao);
    }

    /** DBMS_RANDOM.VALUE(minimo, maximo). */
    private double valor(double minimo, double maximo) {
        return minimo + aleatorio.nextDouble() * (maximo - minimo);
    }

    /** TRUNC(DBMS_RANDOM.VALUE(minimo, maximo)). */
    private int inteiro(int minimo, int maximo) {
        return (int) Math.floor(valor(minimo, maximo));
    }

    /** lista(TRUNC(DBMS_RANDOM.VALUE(1, lista.COUNT + 1))). */
    private String sortear(String[] lista) {
        return lista[inteiro(1, lista.length + 1) - 1];
    }

    private static String lpad(long numero, int tamanho) {
        return String.format("%0" + tamanho + "d", numero);
    }

    // Bloco 1: 100 usuários com endereço, contato e dados pessoais.
    private void inserirUsuarios(Connection conexao) throws SQLException {
        for (int i = 1; i <= TOTAL_USUARIOS; i++) {
            int local = inteiro(1, 7) - 1;
            String sexo = i % 2 == 0 ? "F" : "M";
            String nome = sexo.equals("F") ? sortear(NOMES_F) : sortear(NOMES_M);
            String sobrenome1 = sortear(SOBRENOMES);
            String sobrenome2 = sortear(SOBRENOMES);
            String nomeCompleto = sobrenome1.equals(sobrenome2) || valor(0, 1) > 0.5
                    ? nome + " " + sobrenome1 + " " + sobrenome2
                    : nome + " " + sobrenome1;
            String cpf = lpad(i, 3) + lpad(inteiro(10000000, 99999999), 8);
            String login = (nome.substring(0, 1) + sobrenome1.substring(0, 1)).toLowerCase() + lpad(i, 3);
            String complemento = valor(0, 1) > 0.3 ? "Apto " + inteiro(1, 151) : null;

            long idEndereco = inserirComId(conexao, "ID_ENDERECO", """
                            INSERT INTO TB_CT_ENDERECO (id_endereco, logradouro, numero, complemento, cidade, uf_endereco, cep)
                            VALUES (NULL, ?, ?, ?, ?, ?, ?)""",
                    LOGRADOUROS[local], inteiro(1, 5000), complemento, CIDADES[local], UFS[local], CEPS[local]);
            long idContato = inserirComId(conexao, "ID_CONTATO",
                    "INSERT INTO TB_CT_CONTATO (id_contato, telefone, email) VALUES (NULL, ?, ?)",
                    DDDS[local] + "9" + lpad(inteiro(10000000, 99999999), 8), nome.toLowerCase() + i + "@gmail.com");
            String senha = codificador.encode(String.valueOf(inteiro(100000, 999999)));
            long idUsuario = inserirComId(conexao, "ID_USUARIO", """
                            INSERT INTO TB_CT_USUARIO (id_usuario, login, senha, cpf, nome_usuario, sexo_usuario)
                            VALUES (NULL, ?, ?, ?, ?, ?)""",
                    login, senha, cpf, nomeCompleto, sexo);
            executar(conexao, "INSERT INTO TB_CT_DADOS_PESSOAIS (id_contato, id_endereco, id_usuario) VALUES (?, ?, ?)",
                    idContato, idEndereco, idUsuario);
        }
    }

    // Bloco 2: cuidados por espécie (restrições 1 a 30 e predisposições pelo nome, como no original).
    private void inserirCuidados(Connection conexao) throws SQLException {
        vincularCuidados(conexao, "nome_especie IN ('Pug', 'Bulldog Frances', 'Buldogue Ingles', 'Boston Terrier', "
                        + "'Pequines', 'Shih Tzu', 'Lhasa Apso')",
                3, "Problemas Respiratorios", 2, "Problemas Respiratorios", 5, "Dermatite em Dobras",
                14, "Estresse por Manejo Excessivo");
        vincularCuidados(conexao, "porte = 'GRANDE' AND genero = 'Canis'",
                23, "Displasia Coxofemoral", 19, "Displasia Coxofemoral", 25, "Obesidade");
        vincularCuidados(conexao, "nome_especie IN ('Cocker Spaniel Ingles', 'Beagle', 'Dachshund')",
                5, "Otite Cronica");
        vincularCuidados(conexao, "porte = 'PEQUENO' AND genero = 'Canis' AND nome_especie NOT IN ('Pug','Pequines',"
                        + "'Shih Tzu','Lhasa Apso','Boston Terrier','Spitz Alemao','Pinscher','Chihuahua','Maltes','Bichon Frise')",
                24, "Problemas Cardiacos", 20, "Problemas Dentarios");
        vincularCuidados(conexao, "genero = 'Felis'",
                4, "Bola de Pelos", 17, "Obesidade", 22, "Problemas Renais", 26, "Problemas Renais");
        vincularCuidados(conexao, "genero = 'Reptil'",
                6, "Troca de Pele Incompleta", 16, "Troca de Pele Incompleta", 28, "Estresse por Manejo Excessivo",
                29, "Estresse por Manejo Excessivo");
        vincularCuidados(conexao, "genero = 'Peixe'",
                1, "Baixa Oxigenacao da Agua", 7, "Baixa Oxigenacao da Agua", 27, "Baixa Oxigenacao da Agua",
                15, "Estresse por Manejo Excessivo");
        vincularCuidados(conexao, "genero = 'Anfibio'",
                11, "Troca de Pele Incompleta", 13, "Estresse por Manejo Excessivo");
        vincularCuidados(conexao, "genero IN ('Primata', 'Ave')",
                8, "Estresse por Manejo Excessivo", 12, "Estresse por Manejo Excessivo",
                18, "Estresse por Manejo Excessivo", 30, "Estresse por Manejo Excessivo");
        vincularCuidados(conexao, "nome_especie IN ('Calopsita', 'Betta', 'Sagui', 'Mico Leao Dourado', 'Perereca Verde')",
                9, "Estresse por Manejo Excessivo", 21, "Estresse por Manejo Excessivo");
    }

    /** FOR r IN (SELECT id_especie ... WHERE filtro) LOOP INSERT INTO TB_CT_CUIDADO ... para cada par. */
    private void vincularCuidados(Connection conexao, String filtroDeEspecies, Object... restricoesEPredisposicoes)
            throws SQLException {
        for (int i = 0; i < restricoesEPredisposicoes.length; i += 2) {
            executar(conexao, """
                            INSERT INTO TB_CT_CUIDADO (id_especie, id_restricao, id_predisposicao)
                            SELECT e.id_especie, ?, (SELECT MIN(id_predisposicao) FROM TB_CT_PREDISPOSICAO_ESP
                                                     WHERE nome_predisposicao = ?)
                            FROM TB_CT_ESPECIE e WHERE %s ORDER BY e.id_especie""".formatted(filtroDeEspecies),
                    restricoesEPredisposicoes[i], restricoesEPredisposicoes[i + 1]);
        }
    }

    // Bloco 3: 60 pacientes (45% cães, 35% gatos, 10% répteis, 10% peixes e aves).
    private void inserirPacientes(Connection conexao) throws SQLException {
        Integer idMaineCoon = buscarInteiro(conexao,
                "SELECT MIN(id_especie) FROM TB_CT_ESPECIE WHERE nome_especie = 'Maine Coon'");
        for (int i = 1; i <= TOTAL_PACIENTES; i++) {
            double sorteio = valor(0, 1);
            String sexo = valor(0, 1) > 0.5 ? "M" : "F";
            boolean macho = sexo.equals("M");
            int idade = inteiro(1, 14);
            String nome;
            Object[] especie;
            if (sorteio <= 0.45) {
                nome = sortear(macho ? CAES_M : CAES_F);
                especie = sortearEspecie(conexao, "nome_especie IN (" + RACAS_DE_CAES + ")");
            } else if (sorteio <= 0.80) {
                nome = sortear(macho ? GATOS_M : GATOS_F);
                especie = sortearEspecie(conexao, "genero = 'Felis'");
                especie[1] = especie[0].equals(idMaineCoon) ? "GRANDE" : "MEDIO";
            } else if (sorteio <= 0.90) {
                nome = sortear(macho ? EXOT_M : EXOT_F);
                idade = inteiro(1, 5);
                especie = sortearEspecie(conexao, "genero = 'Reptil'");
            } else {
                nome = sortear(macho ? EXOT_M : EXOT_F);
                idade = inteiro(1, 3);
                especie = sortearEspecie(conexao, "genero IN ('Peixe', 'Ave')");
            }
            if (i % 5 == 0) {
                nome = nome + (macho ? " Filho" : " Filha");
            }
            executar(conexao, """
                            INSERT INTO TB_CT_PACIENTE (id_paciente, id_especie, idade_paciente, nome_paciente, sexo_paciente, porte_paciente)
                            VALUES (NULL, ?, ?, ?, ?, ?)""",
                    especie[0], idade, nome, sexo, especie[1]);
        }
    }

    /** SELECT id_especie, porte FROM (... ORDER BY DBMS_RANDOM.VALUE) WHERE ROWNUM = 1. */
    private Object[] sortearEspecie(Connection conexao, String filtro) throws SQLException {
        List<Object[]> especies = new ArrayList<>();
        try (PreparedStatement consulta = conexao.prepareStatement(
                "SELECT id_especie, porte FROM TB_CT_ESPECIE WHERE " + filtro + " ORDER BY id_especie");
             ResultSet r = consulta.executeQuery()) {
            while (r.next()) {
                especies.add(new Object[]{r.getInt(1), r.getString(2)});
            }
        }
        return especies.get(aleatorio.nextInt(especies.size())).clone();
    }

    // Bloco 4: usuários 1 a 10 viram veterinários (CRMV a partir de 1001, UF do endereço); os demais, tutores.
    private void separarVeterinariosETutores(Connection conexao) throws SQLException {
        int crmv = PRIMEIRO_CRMV;
        try (PreparedStatement consulta = conexao.prepareStatement("""
                SELECT u.id_usuario, e.uf_endereco
                FROM TB_CT_USUARIO u
                JOIN TB_CT_DADOS_PESSOAIS dp ON u.id_usuario = dp.id_usuario
                JOIN TB_CT_ENDERECO e ON dp.id_endereco = e.id_endereco
                WHERE u.id_usuario <= ? ORDER BY u.id_usuario""")) {
            consulta.setInt(1, ULTIMO_ID_VETERINARIO);
            try (ResultSet r = consulta.executeQuery()) {
                while (r.next()) {
                    executar(conexao, "INSERT INTO TB_CT_VETERINARIO (id_usuario, crmv, uf_crmv) VALUES (?, ?, ?)",
                            r.getInt(1), String.valueOf(crmv++), r.getString(2));
                }
            }
        }
        executar(conexao, """
                INSERT INTO TB_CT_TUTOR (id_usuario)
                SELECT id_usuario FROM TB_CT_USUARIO WHERE id_usuario > ? ORDER BY id_usuario""",
                ULTIMO_ID_VETERINARIO);
    }

    // Bloco 5: tutores 1 a 5 com 3 pets, 6 a 15 com 2 pets e os seguintes com 1, até acabarem os pacientes.
    private void vincularPetsAosTutores(Connection conexao) throws SQLException {
        List<Integer> tutores = listarInteiros(conexao, "SELECT id_tutor FROM TB_CT_TUTOR ORDER BY id_tutor");
        List<Integer> pacientes = listarInteiros(conexao, "SELECT id_paciente FROM TB_CT_PACIENTE ORDER BY id_paciente");
        int proximoPaciente = 0;
        for (int posicao = 1; posicao <= tutores.size() && proximoPaciente < pacientes.size(); posicao++) {
            int petsDoTutor = posicao <= 5 ? 3 : posicao <= 15 ? 2 : 1;
            for (int j = 0; j < petsDoTutor && proximoPaciente < pacientes.size(); j++) {
                executar(conexao, "INSERT INTO TB_CT_PET (id_tutor, id_paciente) VALUES (?, ?)",
                        tutores.get(posicao - 1), pacientes.get(proximoPaciente++));
            }
        }
    }

    // Bloco 6: alergias dos pacientes 1, 3, 5, 8 e 10.
    private void inserirAlergias(Connection conexao) throws SQLException {
        List<Integer> pacientes = listarInteiros(conexao, "SELECT id_paciente FROM TB_CT_PACIENTE ORDER BY id_paciente");
        Object[][] alergias = {
                {0, "Amoxicilina%", "GRAVE"}, {2, "Dipirona%", "LEVE"}, {4, "Meloxicam%", "MEDIA"},
                {7, "Amoxicilina%", "GRAVE"}, {9, "Enrofloxacina%", "MEDIA"}};
        for (Object[] alergia : alergias) {
            Integer medicamento = buscarInteiro(conexao, """
                    SELECT MIN(id_medicamento) FROM TB_CT_MEDICAMENTO
                    WHERE nome_medicamento LIKE '%s' AND id_medicamento <> %d""".formatted(alergia[1], ID_NENHUM));
            executar(conexao, "INSERT INTO TB_CT_ALERGIA (id_paciente, id_medicamento, gravidade_alergia) VALUES (?, ?, ?)",
                    pacientes.get((Integer) alergia[0]), medicamento, alergia[2]);
        }
    }

    // Bloco 7: 30 consultas com pagamento e prescrição, evitando medicamento ao qual o pet é alérgico.
    private void inserirConsultas(Connection conexao) throws SQLException {
        List<Integer> veterinarios = listarInteiros(conexao, "SELECT id_veterinario FROM TB_CT_VETERINARIO ORDER BY id_veterinario");
        int medicamentoMinimo = buscarInteiro(conexao, "SELECT MIN(id_medicamento) FROM TB_CT_MEDICAMENTO WHERE id_medicamento <> 1");
        int medicamentoMaximo = buscarInteiro(conexao, "SELECT MAX(id_medicamento) FROM TB_CT_MEDICAMENTO WHERE id_medicamento <> 1");
        int exameMinimo = buscarInteiro(conexao, "SELECT MIN(id_exame) FROM TB_CT_EXAME WHERE id_exame <> 1");
        int exameMaximo = buscarInteiro(conexao, "SELECT MAX(id_exame) FROM TB_CT_EXAME WHERE id_exame <> 1");
        String[] formasDePagamento = {"PIX", "CREDITO", "DEBITO", "SALDO"};

        List<int[]> pets = new ArrayList<>();
        try (PreparedStatement consulta = conexao.prepareStatement(
                "SELECT id_tutor, id_paciente FROM TB_CT_PET WHERE ROWNUM <= " + CONSULTAS_DA_CARGA);
             ResultSet r = consulta.executeQuery()) {
            while (r.next()) {
                pets.add(new int[]{r.getInt(1), r.getInt(2)});
            }
        }

        int contador = 1;
        for (int[] pet : pets) {
            long idPagamento = inserirComId(conexao, "ID_PAGAMENTO",
                    "INSERT INTO TB_CT_PAGAMENTO (tipo_pagamento) VALUES (?)", formasDePagamento[inteiro(0, 4)]);
            int veterinario = veterinarios.get(inteiro(1, veterinarios.size() + 1) - 1);
            long idConsulta = inserirComId(conexao, "ID_CONSULTA", """
                            INSERT INTO TB_CT_CONSULTA (id_pagamento, id_veterinario, id_tutor, id_paciente,
                                                        observacoes, orientacao_consulta, data_consulta)
                            VALUES (?, ?, ?, ?, ?, 'Retorno agendado para avaliacao.', SYSDATE - CAST(? AS INTEGER))""",
                    idPagamento, veterinario, pet[0], pet[1],
                    "Atendimento clínico " + (contador % 2 == 0 ? "preventivo." : "de urgência."), contador);

            int medicamento = ID_NENHUM;
            int exame = ID_NENHUM;
            if (valor(1, 100) > PORCENTAGEM_SEM_MEDICAMENTO) {
                medicamento = medicamentoMinimo + contador % (medicamentoMaximo - medicamentoMinimo + 1);
                exame = exameMinimo + contador % (exameMaximo - exameMinimo + 1);
                while (buscarInteiro(conexao, "SELECT COUNT(*) FROM TB_CT_ALERGIA WHERE id_paciente = "
                        + pet[1] + " AND id_medicamento = " + medicamento) > 0) {
                    medicamento = medicamento + 1 > medicamentoMaximo ? medicamentoMinimo : medicamento + 1;
                }
            }
            executar(conexao, "INSERT INTO TB_CT_PRESCRICAO (id_medicamento, id_exame, id_consulta) VALUES (?, ?, ?)",
                    medicamento, exame, idConsulta);
            contador++;
        }
    }

    private static void executar(Connection conexao, String sql, Object... valores) throws SQLException {
        try (PreparedStatement comando = conexao.prepareStatement(sql)) {
            preencher(comando, valores);
            comando.executeUpdate();
        }
    }

    /** INSERT ... RETURNING coluna INTO variavel. */
    private static long inserirComId(Connection conexao, String coluna, String sql, Object... valores)
            throws SQLException {
        try (PreparedStatement comando = conexao.prepareStatement(sql, new String[]{coluna})) {
            preencher(comando, valores);
            comando.executeUpdate();
            try (ResultSet chaves = comando.getGeneratedKeys()) {
                chaves.next();
                return chaves.getLong(1);
            }
        }
    }

    private static void preencher(PreparedStatement comando, Object... valores) throws SQLException {
        for (int i = 0; i < valores.length; i++) {
            comando.setObject(i + 1, valores[i]);
        }
    }

    private static Integer buscarInteiro(Connection conexao, String sql) throws SQLException {
        try (PreparedStatement consulta = conexao.prepareStatement(sql); ResultSet r = consulta.executeQuery()) {
            r.next();
            int valor = r.getInt(1);
            return r.wasNull() ? null : valor;
        }
    }

    private static List<Integer> listarInteiros(Connection conexao, String sql) throws SQLException {
        List<Integer> valores = new ArrayList<>();
        try (PreparedStatement consulta = conexao.prepareStatement(sql); ResultSet r = consulta.executeQuery()) {
            while (r.next()) {
                valores.add(r.getInt(1));
            }
        }
        return valores;
    }
}
