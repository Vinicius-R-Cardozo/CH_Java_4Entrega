-- Packages do grupo (docs/database/PACKAGES_CELTICSTECH.sql) registrados no H2.
-- O H2 não executa PL/SQL: cada package vira um schema com o mesmo nome e cada procedure/função
-- vira um ALIAS para o método Java que reproduz o corpo original, com os mesmos parâmetros.
-- Assim a aplicação chama exatamente PKG_CT_CADASTRO.PRC_INS_USUARIO(...), como no Oracle.
-- Diferenças: parâmetros OUT (p_id_gerado) viram o retorno da função, e as procedures que
-- usam DBMS_OUTPUT devolvem as linhas impressas como um conjunto de resultados (coluna LINHA).

CREATE SCHEMA PKG_CT_AUDITORIA;
CREATE ALIAS PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG FOR 'br.com.fiap.clyvovet.database.packages.PkgCtAuditoria.prcRegistrarLog';
CREATE ALIAS PKG_CT_AUDITORIA.PRC_AUDITAR_PACIENTE FOR 'br.com.fiap.clyvovet.database.packages.PkgCtAuditoria.prcAuditarPaciente';

CREATE SCHEMA PKG_CT_JSON;
CREATE ALIAS PKG_CT_JSON.FN_CT_RELACIONAL_JSON FOR 'br.com.fiap.clyvovet.database.packages.PkgCtJson.fnCtRelacionalJson';

CREATE SCHEMA PKG_CT_RELATORIOS;
CREATE ALIAS PKG_CT_RELATORIOS.FN_CT_MARKETING_PETS FOR 'br.com.fiap.clyvovet.database.packages.PkgCtRelatorios.fnCtMarketingPets';
CREATE ALIAS PKG_CT_RELATORIOS.PRC_CT_BUSCA_PETS_POR_TUTOR FOR 'br.com.fiap.clyvovet.database.packages.PkgCtRelatorios.prcCtBuscaPetsPorTutor';
CREATE ALIAS PKG_CT_RELATORIOS.PRC_CT_RESUMO_IDADE_PORTE FOR 'br.com.fiap.clyvovet.database.packages.PkgCtRelatorios.prcCtResumoIdadePorte';

CREATE SCHEMA PKG_CT_CADASTRO;
CREATE ALIAS PKG_CT_CADASTRO.PRC_INS_ENDERECO FOR 'br.com.fiap.clyvovet.database.packages.PkgCtCadastro.prcInsEndereco';
CREATE ALIAS PKG_CT_CADASTRO.PRC_INS_CONTATO FOR 'br.com.fiap.clyvovet.database.packages.PkgCtCadastro.prcInsContato';
CREATE ALIAS PKG_CT_CADASTRO.PRC_INS_USUARIO FOR 'br.com.fiap.clyvovet.database.packages.PkgCtCadastro.prcInsUsuario';
CREATE ALIAS PKG_CT_CADASTRO.PRC_INS_DADOS_PESSOAIS FOR 'br.com.fiap.clyvovet.database.packages.PkgCtCadastro.prcInsDadosPessoais';
CREATE ALIAS PKG_CT_CADASTRO.PRC_INS_ESPECIE FOR 'br.com.fiap.clyvovet.database.packages.PkgCtCadastro.prcInsEspecie';
CREATE ALIAS PKG_CT_CADASTRO.PRC_INS_PREDISPOSICAO FOR 'br.com.fiap.clyvovet.database.packages.PkgCtCadastro.prcInsPredisposicao';
CREATE ALIAS PKG_CT_CADASTRO.PRC_INS_RESTRICAO FOR 'br.com.fiap.clyvovet.database.packages.PkgCtCadastro.prcInsRestricao';
CREATE ALIAS PKG_CT_CADASTRO.PRC_INS_CUIDADO FOR 'br.com.fiap.clyvovet.database.packages.PkgCtCadastro.prcInsCuidado';
CREATE ALIAS PKG_CT_CADASTRO.PRC_INS_PACIENTE FOR 'br.com.fiap.clyvovet.database.packages.PkgCtCadastro.prcInsPaciente';
CREATE ALIAS PKG_CT_CADASTRO.PRC_INS_VETERINARIO FOR 'br.com.fiap.clyvovet.database.packages.PkgCtCadastro.prcInsVeterinario';
CREATE ALIAS PKG_CT_CADASTRO.PRC_INS_TUTOR FOR 'br.com.fiap.clyvovet.database.packages.PkgCtCadastro.prcInsTutor';
CREATE ALIAS PKG_CT_CADASTRO.PRC_INS_PET FOR 'br.com.fiap.clyvovet.database.packages.PkgCtCadastro.prcInsPet';
CREATE ALIAS PKG_CT_CADASTRO.PRC_INS_MEDICAMENTO FOR 'br.com.fiap.clyvovet.database.packages.PkgCtCadastro.prcInsMedicamento';
CREATE ALIAS PKG_CT_CADASTRO.PRC_INS_EXAME FOR 'br.com.fiap.clyvovet.database.packages.PkgCtCadastro.prcInsExame';
CREATE ALIAS PKG_CT_CADASTRO.PRC_INS_ALERGIA FOR 'br.com.fiap.clyvovet.database.packages.PkgCtCadastro.prcInsAlergia';
CREATE ALIAS PKG_CT_CADASTRO.PRC_INS_PAGAMENTO FOR 'br.com.fiap.clyvovet.database.packages.PkgCtCadastro.prcInsPagamento';
CREATE ALIAS PKG_CT_CADASTRO.PRC_INS_CONSULTA FOR 'br.com.fiap.clyvovet.database.packages.PkgCtCadastro.prcInsConsulta';
CREATE ALIAS PKG_CT_CADASTRO.PRC_INS_PRESCRICAO FOR 'br.com.fiap.clyvovet.database.packages.PkgCtCadastro.prcInsPrescricao';
