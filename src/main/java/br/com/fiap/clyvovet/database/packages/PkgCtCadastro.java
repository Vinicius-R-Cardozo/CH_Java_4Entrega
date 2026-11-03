package br.com.fiap.clyvovet.database.packages;

import java.sql.Connection;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.Map;

import static br.com.fiap.clyvovet.database.packages.ErroOracle.CHAVE_DUPLICADA;
import static br.com.fiap.clyvovet.database.packages.ErroOracle.CHAVE_INEXISTENTE;
import static br.com.fiap.clyvovet.database.packages.ErroOracle.REGRA_CHECK;
import static br.com.fiap.clyvovet.database.packages.ErroOracle.TAMANHO_EXCEDIDO;
import static br.com.fiap.clyvovet.database.packages.ErroOracle.VALOR_NULO;

/**
 * Porte do PKG_CT_CADASTRO (docs/database/PACKAGES_CELTICSTECH.sql), procedure por procedure:
 * mesmo nome, mesmos parâmetros na mesma ordem, mesmo INSERT e mesmas mensagens de erro.
 * Cada método é registrado no H2 com CREATE ALIAS PKG_CT_CADASTRO.PRC_... (V6__packages.sql).
 * O primeiro parâmetro (Connection) é injetado pelo H2 e não aparece na chamada SQL.
 */
public final class PkgCtCadastro {

    private PkgCtCadastro() {
    }

    // PROCEDURE PRC_INS_ENDERECO (p_logradouro, p_numero, p_complemento, p_cidade, p_uf, p_cep, p_id_gerado OUT)
    public static Long prcInsEndereco(Connection conexao, String pLogradouro, Integer pNumero, String pComplemento,
                                      String pCidade, String pUf, String pCep) throws SQLException {
        return InsercaoComLog.executar(conexao, "PRC_INS_ENDERECO", Map.of(
                        VALOR_NULO, "Erro: Nulos em campos mandatorios de endereco.",
                        REGRA_CHECK, "Erro: UF informada invalida para a regra CHECK."),
                "ID_ENDERECO", """
                        INSERT INTO TB_CT_ENDERECO (id_endereco, logradouro, numero, complemento, cidade, uf_endereco, cep)
                        VALUES (NULL, ?, ?, ?, ?, ?, ?)""",
                pLogradouro, pNumero, pComplemento, pCidade, pUf, pCep);
    }

    // PROCEDURE PRC_INS_CONTATO (p_telefone, p_email, p_id_gerado OUT)
    public static Long prcInsContato(Connection conexao, String pTelefone, String pEmail) throws SQLException {
        return InsercaoComLog.executar(conexao, "PRC_INS_CONTATO", Map.of(
                        VALOR_NULO, "Erro: Colunas vazias em contato.",
                        TAMANHO_EXCEDIDO, "Erro: Estouro de tamanho de string em telefone/email."),
                "ID_CONTATO", "INSERT INTO TB_CT_CONTATO (id_contato, telefone, email) VALUES (NULL, ?, ?)",
                pTelefone, pEmail);
    }

    // PROCEDURE PRC_INS_USUARIO (p_login, p_senha, p_cpf, p_nome, p_sexo, p_id_gerado OUT)
    public static Long prcInsUsuario(Connection conexao, String pLogin, String pSenha, String pCpf, String pNome,
                                     String pSexo) throws SQLException {
        return InsercaoComLog.executar(conexao, "PRC_INS_USUARIO", Map.of(
                        VALOR_NULO, "Erro: Identificadores obrigatorios do usuario vazios.",
                        CHAVE_DUPLICADA, "Erro: CPF ja existente no sistema (UK)."),
                "ID_USUARIO", """
                        INSERT INTO TB_CT_USUARIO (id_usuario, login, senha, cpf, nome_usuario, sexo_usuario)
                        VALUES (NULL, ?, ?, ?, ?, ?)""",
                pLogin, pSenha, pCpf, pNome, pSexo);
    }

    // PROCEDURE PRC_INS_DADOS_PESSOAIS (p_contato, p_endereco, p_usuario)
    public static void prcInsDadosPessoais(Connection conexao, Integer pContato, Integer pEndereco, Integer pUsuario)
            throws SQLException {
        InsercaoComLog.executar(conexao, "PRC_INS_DADOS_PESSOAIS", Map.of(
                        VALOR_NULO, "Erro: Chaves obrigatorias nulas.",
                        CHAVE_INEXISTENTE, "Erro: Uma das chaves nao existe no banco."),
                "INSERT INTO TB_CT_DADOS_PESSOAIS (id_contato, id_endereco, id_usuario) VALUES (?, ?, ?)",
                pContato, pEndereco, pUsuario);
    }

    // PROCEDURE PRC_INS_ESPECIE (p_nome_especie, p_genero, p_porte)
    public static void prcInsEspecie(Connection conexao, String pNomeEspecie, String pGenero, String pPorte)
            throws SQLException {
        InsercaoComLog.executar(conexao, "PRC_INS_ESPECIE", Map.of(
                        VALOR_NULO, "Erro: Tentativa de inserir valor nulo em campo obrigatorio.",
                        REGRA_CHECK, "Erro: Porte inserido nao corresponde as regras aceitas (CHECK)."),
                "INSERT INTO TB_CT_ESPECIE (id_especie, nome_especie, genero, porte) VALUES (NULL, ?, ?, ?)",
                pNomeEspecie, pGenero, pPorte);
    }

    // PROCEDURE PRC_INS_PREDISPOSICAO (p_nome_pred, p_orientao_pred) — o nome do parâmetro é o do original.
    public static void prcInsPredisposicao(Connection conexao, String pNomePred, String pOrientaoPred)
            throws SQLException {
        InsercaoComLog.executar(conexao, "PRC_INS_PREDISPOSICAO", Map.of(
                        VALOR_NULO, "Erro: Tentativa de deixar campos mandatorios nulos.",
                        TAMANHO_EXCEDIDO, "Erro: Texto de nome ou orientacao excede os limites da tabela."),
                """
                        INSERT INTO TB_CT_PREDISPOSICAO_ESP (id_predisposicao, nome_predisposicao, orientacao_predisposicao)
                        VALUES (NULL, ?, ?)""",
                pNomePred, pOrientaoPred);
    }

    // PROCEDURE PRC_INS_RESTRICAO (p_nome_rest, p_orientacao_rest, p_gravidade_rest)
    public static void prcInsRestricao(Connection conexao, String pNomeRest, String pOrientacaoRest,
                                       String pGravidadeRest) throws SQLException {
        InsercaoComLog.executar(conexao, "PRC_INS_RESTRICAO", Map.of(
                        VALOR_NULO, "Erro: Tentativa de inserir valores nulos em campos mandatorios.",
                        REGRA_CHECK, "Erro: Gravidade da restricao invalida para as regras CHECK.",
                        TAMANHO_EXCEDIDO, "Erro: Dados inseridos excedem o tamanho maximo das colunas."),
                """
                        INSERT INTO TB_CT_RESTRICAO_ESP (id_restricao, nome_restricao, orientacao_restricao, gravidade_restricao)
                        VALUES (NULL, ?, ?, ?)""",
                pNomeRest, pOrientacaoRest, pGravidadeRest);
    }

    // PROCEDURE PRC_INS_CUIDADO (p_id_especie, p_id_restricao, p_id_predisposicao)
    public static void prcInsCuidado(Connection conexao, Integer pIdEspecie, Integer pIdRestricao,
                                     Integer pIdPredisposicao) throws SQLException {
        InsercaoComLog.executar(conexao, "PRC_INS_CUIDADO", Map.of(
                        VALOR_NULO, "Erro: Nao e permitido associar vinculos vazios em cuidados.",
                        CHAVE_INEXISTENTE, "Erro: Tentativa de vincular ID inexistente de Especie, Restricao ou Predisposicao."),
                "INSERT INTO TB_CT_CUIDADO (id_especie, id_restricao, id_predisposicao) VALUES (?, ?, ?)",
                pIdEspecie, pIdRestricao, pIdPredisposicao);
    }

    // PROCEDURE PRC_INS_PACIENTE (p_id_especie, p_idade, p_nome, p_sexo, p_porte)
    public static void prcInsPaciente(Connection conexao, Integer pIdEspecie, Integer pIdade, String pNome,
                                      String pSexo, String pPorte) throws SQLException {
        InsercaoComLog.executar(conexao, "PRC_INS_PACIENTE", Map.of(
                        VALOR_NULO, "Erro: Dados mandatorios do paciente ausentes.",
                        REGRA_CHECK, "Erro: Sexo ou Porte informado viola a regra CHECK da clinica.",
                        CHAVE_INEXISTENTE, "Erro: A especie informada nao existe na tabela mae."),
                """
                        INSERT INTO TB_CT_PACIENTE (id_paciente, id_especie, idade_paciente, nome_paciente, sexo_paciente, porte_paciente)
                        VALUES (NULL, ?, ?, ?, ?, ?)""",
                pIdEspecie, pIdade, pNome, pSexo, pPorte);
    }

    // PROCEDURE PRC_INS_VETERINARIO (p_id_usuario, p_crmv, p_uf_crmv)
    public static void prcInsVeterinario(Connection conexao, Integer pIdUsuario, String pCrmv, String pUfCrmv)
            throws SQLException {
        InsercaoComLog.executar(conexao, "PRC_INS_VETERINARIO", Map.of(
                        VALOR_NULO, "Erro: Campos obrigatorios do veterinario ausentes.",
                        CHAVE_DUPLICADA, "Erro: Este numero de CRMV ja esta cadastrado no sistema.",
                        CHAVE_INEXISTENTE, "Erro: O ID de usuario informado nao existe."),
                "INSERT INTO TB_CT_VETERINARIO (id_veterinario, id_usuario, crmv, uf_crmv) VALUES (NULL, ?, ?, ?)",
                pIdUsuario, pCrmv, pUfCrmv);
    }

    // PROCEDURE PRC_INS_TUTOR (p_id_usuario)
    public static void prcInsTutor(Connection conexao, Integer pIdUsuario) throws SQLException {
        InsercaoComLog.executar(conexao, "PRC_INS_TUTOR", Map.of(
                        VALOR_NULO, "Erro: ID de usuario obrigatorio nao informado para o tutor.",
                        CHAVE_INEXISTENTE, "Erro: O ID de usuario informado para o tutor nao existe."),
                "INSERT INTO TB_CT_TUTOR (id_tutor, id_usuario) VALUES (NULL, ?)",
                pIdUsuario);
    }

    // PROCEDURE PRC_INS_PET (p_id_tutor, p_id_paciente)
    public static void prcInsPet(Connection conexao, Integer pIdTutor, Integer pIdPaciente) throws SQLException {
        InsercaoComLog.executar(conexao, "PRC_INS_PET", Map.of(
                        VALOR_NULO, "Erro: Nao e permitido criar vinculos vazios de tutor e pet.",
                        CHAVE_INEXISTENTE, "Erro: O ID de tutor ou de paciente fornecido nao existe na base."),
                "INSERT INTO TB_CT_PET (id_tutor, id_paciente) VALUES (?, ?)",
                pIdTutor, pIdPaciente);
    }

    // PROCEDURE PRC_INS_MEDICAMENTO (p_nome_medicamento, p_bula_medicamento, p_tipo_medicamento)
    public static void prcInsMedicamento(Connection conexao, String pNomeMedicamento, String pBulaMedicamento,
                                         String pTipoMedicamento) throws SQLException {
        InsercaoComLog.executar(conexao, "PRC_INS_MEDICAMENTO", Map.of(
                        VALOR_NULO, "Erro: Campos obrigatorios de medicamento ausentes.",
                        REGRA_CHECK, "Erro: O tipo de medicamento fornecido nao consta na lista permitida (CHECK).",
                        TAMANHO_EXCEDIDO, "Erro: Nome, Bula ou Tipo ultrapassou o limite de caracteres da tabela."),
                """
                        INSERT INTO TB_CT_MEDICAMENTO (id_medicamento, nome_medicamento, bula_medicamento, tipo_medicamento)
                        VALUES (NULL, ?, ?, ?)""",
                pNomeMedicamento, pBulaMedicamento, pTipoMedicamento);
    }

    // PROCEDURE PRC_INS_EXAME (p_nome_exame, p_orientacoes_exame)
    public static void prcInsExame(Connection conexao, String pNomeExame, String pOrientacoesExame)
            throws SQLException {
        InsercaoComLog.executar(conexao, "PRC_INS_EXAME", Map.of(
                        VALOR_NULO, "Erro: Nome ou orientacao do exame obrigatoria ausente.",
                        TAMANHO_EXCEDIDO, "Erro: Texto de nome ou orientacao de exame longo demais."),
                "INSERT INTO TB_CT_EXAME (id_exame, nome_exame, orientacoes_exame) VALUES (NULL, ?, ?)",
                pNomeExame, pOrientacoesExame);
    }

    // PROCEDURE PRC_INS_ALERGIA (p_id_paciente, p_id_medicamento, p_gravidade)
    public static void prcInsAlergia(Connection conexao, Integer pIdPaciente, Integer pIdMedicamento,
                                     String pGravidade) throws SQLException {
        InsercaoComLog.executar(conexao, "PRC_INS_ALERGIA", Map.of(
                        VALOR_NULO, "Erro: Tentativa de inserir valores nulos em chaves de alergia.",
                        REGRA_CHECK, "Erro: Gravidade de alergia invalida. Use GRAVE, MEDIA ou LEVE.",
                        CHAVE_INEXISTENTE, "Erro: O paciente ou medicamento informado nao existe na base."),
                "INSERT INTO TB_CT_ALERGIA (id_paciente, id_medicamento, gravidade_alergia) VALUES (?, ?, ?)",
                pIdPaciente, pIdMedicamento, pGravidade);
    }

    // PROCEDURE PRC_INS_PAGAMENTO (p_tipo_pagamento, p_id_gerado OUT)
    public static Long prcInsPagamento(Connection conexao, String pTipoPagamento) throws SQLException {
        return InsercaoComLog.executar(conexao, "PRC_INS_PAGAMENTO", Map.of(
                        VALOR_NULO, "Erro: Tipo de pagamento obrigatorio vazio.",
                        REGRA_CHECK, "Erro: Forma de pagamento invalida na regra CHECK."),
                "ID_PAGAMENTO", "INSERT INTO TB_CT_PAGAMENTO (id_pagamento, tipo_pagamento) VALUES (NULL, ?)",
                pTipoPagamento);
    }

    // PROCEDURE PRC_INS_CONSULTA (p_id_pagamento, p_id_veterinario, p_id_tutor, p_id_paciente,
    //                             p_observacoes, p_orientacao, p_data_consulta, p_id_gerado OUT)
    public static Long prcInsConsulta(Connection conexao, Integer pIdPagamento, Integer pIdVeterinario,
                                      Integer pIdTutor, Integer pIdPaciente, String pObservacoes,
                                      String pOrientacao, LocalDateTime pDataConsulta) throws SQLException {
        return InsercaoComLog.executar(conexao, "PRC_INS_CONSULTA", Map.of(
                        VALOR_NULO, "Erro: Identificadores mandatorios da consulta nulos.",
                        CHAVE_INEXISTENTE, "Erro: Um dos IDs relacionais (Vet/Tutor/Pet/Pagto) nao existe."),
                "ID_CONSULTA", """
                        INSERT INTO TB_CT_CONSULTA (id_consulta, id_pagamento, id_veterinario, id_tutor, id_paciente,
                                                    observacoes, orientacao_consulta, data_consulta)
                        VALUES (NULL, ?, ?, ?, ?, ?, ?, ?)""",
                pIdPagamento, pIdVeterinario, pIdTutor, pIdPaciente, pObservacoes, pOrientacao, pDataConsulta);
    }

    // PROCEDURE PRC_INS_PRESCRICAO (p_id_medicamento, p_id_exame, p_id_consulta)
    public static void prcInsPrescricao(Connection conexao, Integer pIdMedicamento, Integer pIdExame,
                                        Integer pIdConsulta) throws SQLException {
        InsercaoComLog.executar(conexao, "PRC_INS_PRESCRICAO", Map.of(
                        VALOR_NULO, "Erro: Chaves de ligacao vazias na receita.",
                        CHAVE_INEXISTENTE, "Erro: ID de Medicamento, Exame ou Consulta invalido ou inexistente."),
                "INSERT INTO TB_CT_PRESCRICAO (id_medicamento, id_exame, id_consulta) VALUES (?, ?, ?)",
                pIdMedicamento, pIdExame, pIdConsulta);
    }
}
