-- CelticsTech | Sprint 4 | Oracle PL/SQL
-- Script consolidado: cada especificacao (PACKAGE) vem imediatamente antes
-- do seu corpo (PACKAGE BODY). Execute depois do SCRIPT DE CRIACAO DO BANCO.sql.
-- Execute o arquivo inteiro no Oracle SQL Developer com Run Script (F5).
-- O gatilho permanece independente, conforme exigido pelo Oracle, e delega
-- a regra de auditoria ao package PKG_CT_AUDITORIA.

CREATE OR REPLACE PACKAGE PKG_CT_AUDITORIA AS
PROCEDURE PRC_REGISTRAR_LOG (
    p_nome_proc VARCHAR2,
    p_cod_erro  NUMBER,
    p_msg_erro  VARCHAR2
);
PROCEDURE PRC_AUDITAR_PACIENTE (p_tipo_operacao IN VARCHAR2, p_valores_anteriores IN VARCHAR2, p_valores_novos IN VARCHAR2);
END PKG_CT_AUDITORIA;
/

CREATE OR REPLACE PACKAGE BODY PKG_CT_AUDITORIA AS
PROCEDURE PRC_REGISTRAR_LOG (
    p_nome_proc VARCHAR2,
    p_cod_erro  NUMBER,
    p_msg_erro  VARCHAR2
)
IS
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    INSERT INTO TB_CT_LOG_ERRO (id_log, nome_procedure, usuario_banco, data_ocorrencia, mensagem_erro)
    VALUES (NULL, p_nome_proc, USER, SYSDATE, 'Cod: ' || p_cod_erro || ' - ' || SUBSTR(p_msg_erro, 1, 250));
    COMMIT;
END;

PROCEDURE PRC_AUDITAR_PACIENTE (p_tipo_operacao IN VARCHAR2, p_valores_anteriores IN VARCHAR2, p_valores_novos IN VARCHAR2) IS
    BEGIN
        INSERT INTO TB_CT_AUDITORIA_DML (NOME_TABELA, USUARIO_BANCO, TIPO_OPERACAO, DATA_HORA, VALORES_ANTERIORES, VALORES_NOVOS)
        VALUES ('TB_CT_PACIENTE', SYS_CONTEXT('USERENV','SESSION_USER'), p_tipo_operacao, SYSDATE, p_valores_anteriores, p_valores_novos);
    EXCEPTION WHEN OTHERS THEN
        PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG('PKG_CT_AUDITORIA.PRC_AUDITAR_PACIENTE', SQLCODE, SQLERRM); RAISE;
    END PRC_AUDITAR_PACIENTE;
END PKG_CT_AUDITORIA;
/

CREATE OR REPLACE PACKAGE PKG_CT_JSON AS
FUNCTION FN_CT_RELACIONAL_JSON (
    p_campo1_nome  IN VARCHAR2,
    p_campo1_valor IN VARCHAR2,
    p_campo2_nome  IN VARCHAR2,
    p_campo2_valor IN VARCHAR2,
    p_campo3_nome  IN VARCHAR2,
    p_campo3_valor IN VARCHAR2,
    p_campo4_nome  IN VARCHAR2 DEFAULT NULL,
    p_campo4_valor IN VARCHAR2 DEFAULT NULL,
    p_campo5_nome  IN VARCHAR2 DEFAULT NULL,
    p_campo5_valor IN VARCHAR2 DEFAULT NULL,
    p_campo6_nome  IN VARCHAR2 DEFAULT NULL,
    p_campo6_valor IN VARCHAR2 DEFAULT NULL,
    p_campo7_nome  IN VARCHAR2 DEFAULT NULL,
    p_campo7_valor IN VARCHAR2 DEFAULT NULL,
    p_campo8_nome  IN VARCHAR2 DEFAULT NULL,
    p_campo8_valor IN VARCHAR2 DEFAULT NULL,
    p_campo9_nome  IN VARCHAR2 DEFAULT NULL,
    p_campo9_valor IN VARCHAR2 DEFAULT NULL,
    p_campo10_nome IN VARCHAR2 DEFAULT NULL,
    p_campo10_valor IN VARCHAR2 DEFAULT NULL
) RETURN VARCHAR2;
END PKG_CT_JSON;
/

CREATE OR REPLACE PACKAGE BODY PKG_CT_JSON AS
FUNCTION FN_CT_RELACIONAL_JSON (
    p_campo1_nome  IN VARCHAR2,
    p_campo1_valor IN VARCHAR2,
    p_campo2_nome  IN VARCHAR2,
    p_campo2_valor IN VARCHAR2,
    p_campo3_nome  IN VARCHAR2,
    p_campo3_valor IN VARCHAR2,
    p_campo4_nome  IN VARCHAR2,
    p_campo4_valor IN VARCHAR2,
    p_campo5_nome  IN VARCHAR2,
    p_campo5_valor IN VARCHAR2,
    p_campo6_nome  IN VARCHAR2,
    p_campo6_valor IN VARCHAR2,
    p_campo7_nome  IN VARCHAR2,
    p_campo7_valor IN VARCHAR2,
    p_campo8_nome  IN VARCHAR2,
    p_campo8_valor IN VARCHAR2,
    p_campo9_nome  IN VARCHAR2,
    p_campo9_valor IN VARCHAR2,
    p_campo10_nome IN VARCHAR2,
    p_campo10_valor IN VARCHAR2
) RETURN VARCHAR2
IS
    v_json VARCHAR2(32767);

    ex_nome_nulo EXCEPTION;
    ex_valor_nulo EXCEPTION;
    ex_nome_invalido EXCEPTION;

BEGIN

    IF p_campo1_nome IS NULL
       OR p_campo2_nome IS NULL
       OR p_campo3_nome IS NULL THEN
        RAISE ex_nome_nulo;
    END IF;

    IF p_campo1_valor IS NULL
       OR p_campo2_valor IS NULL
       OR p_campo3_valor IS NULL THEN
        RAISE ex_valor_nulo;
    END IF;

    IF INSTR(p_campo1_nome, '"') > 0
       OR INSTR(p_campo2_nome, '"') > 0
       OR INSTR(p_campo3_nome, '"') > 0
       OR INSTR(p_campo4_nome, '"') > 0
       OR INSTR(p_campo5_nome, '"') > 0
       OR INSTR(p_campo6_nome, '"') > 0
       OR INSTR(p_campo7_nome, '"') > 0
       OR INSTR(p_campo8_nome, '"') > 0
       OR INSTR(p_campo9_nome, '"') > 0
       OR INSTR(p_campo10_nome, '"') > 0 THEN
        RAISE ex_nome_invalido;
    END IF;

    v_json := '{' ||
              '"' || p_campo1_nome || '":"' ||
              REPLACE(p_campo1_valor, '"', '\"') || '",' ||
              '"' || p_campo2_nome || '":"' ||
              REPLACE(p_campo2_valor, '"', '\"') || '",' ||
              '"' || p_campo3_nome || '":"' ||
              REPLACE(p_campo3_valor, '"', '\"') || '"';

    IF p_campo4_nome IS NOT NULL THEN
        IF p_campo4_valor IS NULL THEN
            RAISE ex_valor_nulo;
        END IF;

        v_json := v_json ||
                  ',"' || p_campo4_nome ||
                  '":"' || REPLACE(p_campo4_valor, '"', '\"') || '"';
    END IF;

    IF p_campo5_nome IS NOT NULL THEN
        IF p_campo5_valor IS NULL THEN
            RAISE ex_valor_nulo;
        END IF;

        v_json := v_json ||
                  ',"' || p_campo5_nome ||
                  '":"' || REPLACE(p_campo5_valor, '"', '\"') || '"';
    END IF;

    IF p_campo6_nome IS NOT NULL THEN
        IF p_campo6_valor IS NULL THEN
            RAISE ex_valor_nulo;
        END IF;

        v_json := v_json ||
                  ',"' || p_campo6_nome ||
                  '":"' || REPLACE(p_campo6_valor, '"', '\"') || '"';
    END IF;

    IF p_campo7_nome IS NOT NULL THEN
        IF p_campo7_valor IS NULL THEN
            RAISE ex_valor_nulo;
        END IF;

        v_json := v_json ||
                  ',"' || p_campo7_nome ||
                  '":"' || REPLACE(p_campo7_valor, '"', '\"') || '"';
    END IF;

    IF p_campo8_nome IS NOT NULL THEN
        IF p_campo8_valor IS NULL THEN
            RAISE ex_valor_nulo;
        END IF;

        v_json := v_json ||
                  ',"' || p_campo8_nome ||
                  '":"' || REPLACE(p_campo8_valor, '"', '\"') || '"';
    END IF;

    IF p_campo9_nome IS NOT NULL THEN
        IF p_campo9_valor IS NULL THEN
            RAISE ex_valor_nulo;
        END IF;

        v_json := v_json ||
                  ',"' || p_campo9_nome ||
                  '":"' || REPLACE(p_campo9_valor, '"', '\"') || '"';
    END IF;

    IF p_campo10_nome IS NOT NULL THEN
        IF p_campo10_valor IS NULL THEN
            RAISE ex_valor_nulo;
        END IF;

        v_json := v_json ||
                  ',"' || p_campo10_nome ||
                  '":"' || REPLACE(p_campo10_valor, '"', '\"') || '"';
    END IF;

    v_json := v_json || '}';

    RETURN v_json;

EXCEPTION

    WHEN ex_nome_nulo THEN
        PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG(
            'PKG_CT_JSON.FN_CT_RELACIONAL_JSON',
            -20001,
            'Nome de campo obrigatorio nao pode ser nulo'
        );

        RETURN '{"erro":"Nome de campo obrigatorio nao pode ser nulo"}';

    WHEN ex_valor_nulo THEN
        PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG(
            'PKG_CT_JSON.FN_CT_RELACIONAL_JSON',
            -20002,
            'Valor de campo obrigatorio nao pode ser nulo'
        );

        RETURN '{"erro":"Valor de campo obrigatorio nao pode ser nulo"}';

    WHEN ex_nome_invalido THEN
        PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG(
            'PKG_CT_JSON.FN_CT_RELACIONAL_JSON',
            -20003,
            'Nome de campo possui caractere invalido para JSON'
        );

        RETURN '{"erro":"Nome de campo possui caractere invalido para JSON"}';

    WHEN OTHERS THEN
        PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG(
            'PKG_CT_JSON.FN_CT_RELACIONAL_JSON',
            SQLCODE,
            SQLERRM
        );

        RETURN '{"erro":"Erro inesperado na conversao para JSON"}';

END FN_CT_RELACIONAL_JSON;
END PKG_CT_JSON;
/

CREATE OR REPLACE PACKAGE PKG_CT_RELATORIOS AS
FUNCTION FN_CT_MARKETING_PETS (
    p_faixa_etaria IN VARCHAR2 DEFAULT NULL,
    p_uf           IN VARCHAR2 DEFAULT NULL
) RETURN CLOB;
PROCEDURE PRC_CT_BUSCA_PETS_POR_TUTOR (
    p_id_tutor IN NUMBER
);
    PROCEDURE PRC_CT_RESUMO_IDADE_PORTE (
    p_faixa_etaria IN VARCHAR2 DEFAULT NULL,
    p_porte        IN VARCHAR2 DEFAULT NULL
);
END PKG_CT_RELATORIOS;
/

CREATE OR REPLACE PACKAGE BODY PKG_CT_RELATORIOS AS
FUNCTION FN_CT_MARKETING_PETS (
    p_faixa_etaria IN VARCHAR2,
    p_uf           IN VARCHAR2
) RETURN CLOB
IS
    v_json       CLOB;
    v_objeto     VARCHAR2(32767);
    v_qtd        NUMBER := 0;
    v_qtd_uf     NUMBER := 0;
    v_faixa      VARCHAR2(10);
    v_uf         VARCHAR2(2);

    ex_faixa_invalida EXCEPTION;
    ex_uf_invalida    EXCEPTION;
    ex_nenhum_retorno EXCEPTION;

BEGIN

    DBMS_LOB.CREATETEMPORARY(v_json, TRUE);

    DBMS_LOB.APPEND(v_json, '[' || CHR(10));

    v_faixa := UPPER(TRIM(p_faixa_etaria));
    v_uf := UPPER(TRIM(p_uf));

    IF v_faixa IS NOT NULL
       AND v_faixa NOT IN ('JOVEM', 'ADULTO', 'IDOSO') THEN
        RAISE ex_faixa_invalida;
    END IF;

    IF v_uf IS NOT NULL THEN

        IF v_uf NOT IN (
            'AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF',
            'ES', 'GO', 'MA', 'MT', 'MS', 'MG', 'PA',
            'PB', 'PR', 'PE', 'PI', 'RJ', 'RN', 'RS',
            'RO', 'RR', 'SC', 'SE', 'SP', 'TO'
        ) THEN
            RAISE ex_uf_invalida;
        END IF;

        SELECT COUNT(*)
        INTO v_qtd_uf
        FROM TB_CT_ENDERECO
        WHERE uf_endereco = v_uf;

        IF v_qtd_uf = 0 THEN
            RAISE ex_uf_invalida;
        END IF;

    END IF;

    FOR r IN (
        SELECT
            p.id_paciente,
            p.nome_paciente AS nome_pet,
            p.idade_paciente AS idade,
            t.id_tutor,
            u.nome_usuario AS nome_tutor,
            en.uf_endereco AS uf,
            c.telefone,
            c.email
        FROM TB_CT_PET pt
        JOIN TB_CT_PACIENTE p
            ON pt.id_paciente = p.id_paciente
        JOIN TB_CT_TUTOR t
            ON pt.id_tutor = t.id_tutor
        JOIN TB_CT_USUARIO u
            ON t.id_usuario = u.id_usuario
        LEFT JOIN TB_CT_DADOS_PESSOAIS dp
            ON u.id_usuario = dp.id_usuario
        LEFT JOIN TB_CT_CONTATO c
            ON dp.id_contato = c.id_contato
        LEFT JOIN TB_CT_ENDERECO en
            ON dp.id_endereco = en.id_endereco
        WHERE
            (
                v_faixa IS NULL
                OR (
                    v_faixa = 'JOVEM'
                    AND p.idade_paciente BETWEEN 1 AND 2
                )
                OR (
                    v_faixa = 'ADULTO'
                    AND p.idade_paciente BETWEEN 3 AND 8
                )
                OR (
                    v_faixa = 'IDOSO'
                    AND p.idade_paciente >= 9
                )
            )
            AND (
                v_uf IS NULL
                OR en.uf_endereco = v_uf
            )
        ORDER BY
            en.uf_endereco,
            p.idade_paciente,
            p.nome_paciente
    ) LOOP

        v_qtd := v_qtd + 1;

        v_objeto := PKG_CT_JSON.FN_CT_RELACIONAL_JSON(
            'id_paciente',
            r.id_paciente,
            'nome_pet',
            r.nome_pet,
            'idade',
            r.idade,
            'id_tutor',
            r.id_tutor,
            'nome_tutor',
            r.nome_tutor,
            'uf',
            r.uf,
            'telefone',
            r.telefone,
            'email',
            r.email
        );

        IF v_qtd > 1 THEN
            DBMS_LOB.APPEND(v_json, ',' || CHR(10));
        END IF;

        DBMS_LOB.APPEND(
            v_json,
            '  ' || v_objeto
        );

    END LOOP;

    IF v_qtd = 0 THEN
        RAISE ex_nenhum_retorno;
    END IF;

    DBMS_LOB.APPEND(
        v_json,
        CHR(10) || ']'
    );

    RETURN v_json;

EXCEPTION

    WHEN ex_faixa_invalida THEN

        PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG(
            'FN_CT_MARKETING_PETS',
            -20001,
            'Faixa etaria invalida. Utilize JOVEM, ADULTO ou IDOSO.'
        );

        RETURN '{"erro":"Faixa etaria invalida. Utilize JOVEM, ADULTO ou IDOSO."}';

    WHEN ex_uf_invalida THEN

        PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG(
            'FN_CT_MARKETING_PETS',
            -20002,
            'UF invalida ou sem registros na base.'
        );

        RETURN '{"erro":"UF invalida ou sem registros na base."}';

    WHEN ex_nenhum_retorno THEN

        PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG(
            'FN_CT_MARKETING_PETS',
            -20003,
            'Nenhum pet encontrado para os filtros informados.'
        );

        RETURN '{"erro":"Nenhum pet encontrado para os filtros informados."}';

    WHEN OTHERS THEN

        PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG(
            'FN_CT_MARKETING_PETS',
            SQLCODE,
            SQLERRM
        );

        RETURN '{"erro":"Erro inesperado na segmentacao de marketing."}';

END FN_CT_MARKETING_PETS;

PROCEDURE PRC_CT_BUSCA_PETS_POR_TUTOR (
    p_id_tutor IN NUMBER
)
IS
    v_qtd_pets NUMBER := 0;
    v_tutor_existe NUMBER := 0;

    ex_tutor_nulo EXCEPTION;
    ex_tutor_inexistente EXCEPTION;
    ex_sem_pets EXCEPTION;

BEGIN

    IF p_id_tutor IS NULL THEN
        RAISE ex_tutor_nulo;
    END IF;

    SELECT COUNT(*)
    INTO v_tutor_existe
    FROM TB_CT_TUTOR
    WHERE id_tutor = p_id_tutor;

    IF v_tutor_existe = 0 THEN
        RAISE ex_tutor_inexistente;
    END IF;

    FOR r IN (
        SELECT
            p.id_paciente,
            p.nome_paciente,
            e.nome_especie,
            p.idade_paciente,
            p.porte_paciente
        FROM TB_CT_PET pt
        JOIN TB_CT_PACIENTE p
            ON pt.id_paciente = p.id_paciente
        JOIN TB_CT_ESPECIE e
            ON p.id_especie = e.id_especie
        WHERE pt.id_tutor = p_id_tutor
    ) LOOP

        v_qtd_pets := v_qtd_pets + 1;

        DBMS_OUTPUT.PUT_LINE(
            PKG_CT_JSON.FN_CT_RELACIONAL_JSON(
                'id_paciente',
                r.id_paciente,
                'nome_paciente',
                r.nome_paciente,
                'especie',
                r.nome_especie,
                'idade',
                r.idade_paciente,
                'porte',
                r.porte_paciente
            )
        );

    END LOOP;

    IF v_qtd_pets = 0 THEN
        RAISE ex_sem_pets;
    END IF;

EXCEPTION

    WHEN ex_tutor_nulo THEN
        PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG(
            'PRC_CT_BUSCA_PETS_POR_TUTOR',
            -20001,
            'ID do tutor nao informado'
        );

        DBMS_OUTPUT.PUT_LINE(
            'Erro: ID do tutor nao informado'
        );

    WHEN ex_tutor_inexistente THEN
        PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG(
            'PRC_CT_BUSCA_PETS_POR_TUTOR',
            -20002,
            'Tutor informado nao existe'
        );

        DBMS_OUTPUT.PUT_LINE(
            'Erro: tutor informado nao existe'
        );

    WHEN ex_sem_pets THEN
        PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG(
            'PRC_CT_BUSCA_PETS_POR_TUTOR',
            -20003,
            'Nenhum pet encontrado para o tutor informado'
        );

        DBMS_OUTPUT.PUT_LINE(
            'Erro: nenhum pet encontrado para o tutor informado'
        );

    WHEN OTHERS THEN
        PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG(
            'PRC_CT_BUSCA_PETS_POR_TUTOR',
            SQLCODE,
            SQLERRM
        );

        DBMS_OUTPUT.PUT_LINE(
            'Erro inesperado: ' || SQLERRM
        );

END PRC_CT_BUSCA_PETS_POR_TUTOR;

PROCEDURE PRC_CT_RESUMO_IDADE_PORTE (
    p_faixa_etaria IN VARCHAR2,
    p_porte        IN VARCHAR2
)
IS

    CURSOR c_pacientes IS
        SELECT
            nome_paciente,
            idade_paciente,
            porte_paciente
        FROM TB_CT_PACIENTE
        WHERE idade_paciente IS NOT NULL
          AND (
                p_faixa_etaria IS NULL
                OR (
                    UPPER(TRIM(p_faixa_etaria)) = 'FILHOTE/JOVEM'
                    AND idade_paciente <= 2
                )
                OR (
                    UPPER(TRIM(p_faixa_etaria)) = 'ADULTO'
                    AND idade_paciente > 2
                    AND idade_paciente <= 8
                )
                OR (
                    UPPER(TRIM(p_faixa_etaria)) = 'IDOSO'
                    AND idade_paciente > 8
                )
          )
          AND (
                p_porte IS NULL
                OR UPPER(TRIM(porte_paciente)) = UPPER(TRIM(p_porte))
          )
        ORDER BY
            CASE
                WHEN idade_paciente <= 2 THEN 1
                WHEN idade_paciente <= 8 THEN 2
                ELSE 3
            END,
            porte_paciente,
            nome_paciente;

    v_nome            TB_CT_PACIENTE.NOME_PACIENTE%TYPE;
    v_idade           TB_CT_PACIENTE.IDADE_PACIENTE%TYPE;
    v_porte           TB_CT_PACIENTE.PORTE_PACIENTE%TYPE;

    v_faixa_atual     VARCHAR2(20);
    v_faixa_anterior  VARCHAR2(20);

    v_porte_atual     VARCHAR2(30);
    v_porte_anterior  VARCHAR2(30);

    v_soma_combinacao NUMBER := 0;
    v_subtotal_faixa  NUMBER := 0;
    v_total_geral     NUMBER := 0;

    v_qtd_registros   NUMBER := 0;

    v_faixa_filtro    VARCHAR2(20);
    v_porte_filtro    VARCHAR2(30);

    ex_faixa_invalida EXCEPTION;
    ex_porte_invalido EXCEPTION;
    ex_sem_resultados EXCEPTION;

BEGIN

    v_faixa_filtro := UPPER(TRIM(p_faixa_etaria));
    v_porte_filtro := UPPER(TRIM(p_porte));

    IF v_faixa_filtro IS NOT NULL
       AND v_faixa_filtro NOT IN (
           'FILHOTE/JOVEM',
           'ADULTO',
           'IDOSO'
       ) THEN
        RAISE ex_faixa_invalida;
    END IF;

    IF v_porte_filtro IS NOT NULL
       AND v_porte_filtro NOT IN (
           'GRANDE',
           'MEDIO',
           'PEQUENO',
           'SPD'
       ) THEN
        RAISE ex_porte_invalido;
    END IF;

    DBMS_OUTPUT.PUT_LINE('======================================================================');
    DBMS_OUTPUT.PUT_LINE('========== RELATORIO: SOMA DE IDADES POR FAIXA E PORTE ==========');
    DBMS_OUTPUT.PUT_LINE('======================================================================');

    DBMS_OUTPUT.PUT_LINE(
        RPAD('FAIXA ETARIA', 20) || ' | ' ||
        RPAD('PORTE', 15) || ' | ' ||
        'SOMA DAS IDADES'
    );

    DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------------------');

    OPEN c_pacientes;

    LOOP

        FETCH c_pacientes
        INTO v_nome, v_idade, v_porte;

        EXIT WHEN c_pacientes%NOTFOUND;

        v_qtd_registros := v_qtd_registros + 1;

        IF v_idade < 0 THEN
            RAISE ex_faixa_invalida;
        END IF;

        IF v_porte IS NULL THEN
            RAISE ex_porte_invalido;
        END IF;

        IF v_idade <= 2 THEN
            v_faixa_atual := 'Filhote/Jovem';

        ELSIF v_idade <= 8 THEN
            v_faixa_atual := 'Adulto';

        ELSE
            v_faixa_atual := 'Idoso';

        END IF;

        v_porte_atual := v_porte;

        IF v_faixa_anterior IS NULL THEN

            v_faixa_anterior := v_faixa_atual;
            v_porte_anterior := v_porte_atual;

            v_soma_combinacao := v_idade;
            v_subtotal_faixa := v_idade;
            v_total_geral := v_idade;

        ELSIF v_faixa_atual <> v_faixa_anterior THEN

            DBMS_OUTPUT.PUT_LINE(
                RPAD(v_faixa_anterior, 20) || ' | ' ||
                RPAD(v_porte_anterior, 15) || ' | ' ||
                TO_CHAR(v_soma_combinacao, '999G990D00')
            );

            DBMS_OUTPUT.PUT_LINE(
                RPAD(v_faixa_anterior, 20) || ' | ' ||
                RPAD('NULL', 15) || ' | ' ||
                TO_CHAR(v_subtotal_faixa, '999G990D00')
            );

            DBMS_OUTPUT.PUT_LINE('----------------------------------------------------------------------');

            v_faixa_anterior := v_faixa_atual;
            v_porte_anterior := v_porte_atual;

            v_soma_combinacao := v_idade;
            v_subtotal_faixa := v_idade;
            v_total_geral := v_total_geral + v_idade;

        ELSIF v_porte_atual <> v_porte_anterior THEN

            DBMS_OUTPUT.PUT_LINE(
                RPAD(v_faixa_anterior, 20) || ' | ' ||
                RPAD(v_porte_anterior, 15) || ' | ' ||
                TO_CHAR(v_soma_combinacao, '999G990D00')
            );

            v_porte_anterior := v_porte_atual;

            v_soma_combinacao := v_idade;
            v_subtotal_faixa := v_subtotal_faixa + v_idade;
            v_total_geral := v_total_geral + v_idade;

        ELSE

            v_soma_combinacao := v_soma_combinacao + v_idade;
            v_subtotal_faixa := v_subtotal_faixa + v_idade;
            v_total_geral := v_total_geral + v_idade;

        END IF;

    END LOOP;

    CLOSE c_pacientes;

    IF v_qtd_registros = 0 THEN
        RAISE ex_sem_resultados;
    END IF;

    DBMS_OUTPUT.PUT_LINE(
        RPAD(v_faixa_anterior, 20) || ' | ' ||
        RPAD(v_porte_anterior, 15) || ' | ' ||
        TO_CHAR(v_soma_combinacao, '999G990D00')
    );

    DBMS_OUTPUT.PUT_LINE(
        RPAD(v_faixa_anterior, 20) || ' | ' ||
        RPAD('NULL', 15) || ' | ' ||
        TO_CHAR(v_subtotal_faixa, '999G990D00')
    );

    DBMS_OUTPUT.PUT_LINE('======================================================================');

    DBMS_OUTPUT.PUT_LINE(
        RPAD('NULL', 20) || ' | ' ||
        RPAD('NULL', 15) || ' | ' ||
        TO_CHAR(v_total_geral, '999G990D00')
    );

    DBMS_OUTPUT.PUT_LINE('======================================================================');

EXCEPTION

    WHEN ex_faixa_invalida THEN

        PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG(
            'PRC_CT_RESUMO_IDADE_PORTE',
            -20001,
            'Faixa etaria invalida. Utilize FILHOTE/JOVEM, ADULTO ou IDOSO.'
        );

        DBMS_OUTPUT.PUT_LINE(
            'Erro: faixa etaria invalida. Utilize FILHOTE/JOVEM, ADULTO ou IDOSO.'
        );

    WHEN ex_porte_invalido THEN

        PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG(
            'PRC_CT_RESUMO_IDADE_PORTE',
            -20002,
            'Porte invalido. Utilize GRANDE, MEDIO, PEQUENO ou SPD.'
        );

        DBMS_OUTPUT.PUT_LINE(
            'Erro: porte invalido. Utilize GRANDE, MEDIO, PEQUENO ou SPD.'
        );

    WHEN ex_sem_resultados THEN

        PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG(
            'PRC_CT_RESUMO_IDADE_PORTE',
            -20003,
            'Nenhum paciente encontrado para os filtros informados.'
        );

        DBMS_OUTPUT.PUT_LINE(
            'Nenhum paciente foi encontrado para os filtros informados.'
        );

    WHEN OTHERS THEN

        PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG(
            'PRC_CT_RESUMO_IDADE_PORTE',
            SQLCODE,
            SQLERRM
        );

        DBMS_OUTPUT.PUT_LINE(
            'Ocorreu um erro inesperado durante a execucao da procedure.'
        );

        DBMS_OUTPUT.PUT_LINE(
            'Codigo do erro Oracle: ' || SQLCODE
        );

        DBMS_OUTPUT.PUT_LINE(
            'Mensagem: ' || SUBSTR(SQLERRM, 1, 150)
        );

END PRC_CT_RESUMO_IDADE_PORTE;
END PKG_CT_RELATORIOS;
/

CREATE OR REPLACE PACKAGE PKG_CT_CADASTRO AS
PROCEDURE PRC_INS_ENDERECO (
    p_logradouro  IN VARCHAR2,
    p_numero      IN INTEGER,
    p_complemento IN VARCHAR2,
    p_cidade      IN VARCHAR2,
    p_uf          IN CHAR,
    p_cep         IN CHAR,
    p_id_gerado   OUT INTEGER
);
    PROCEDURE PRC_INS_CONTATO (
    p_telefone  IN CHAR,
    p_email     IN VARCHAR2,
    p_id_gerado OUT INTEGER
);
    PROCEDURE PRC_INS_USUARIO (
    p_login     IN VARCHAR2,
    p_senha     IN VARCHAR2,
    p_cpf       IN CHAR,
    p_nome      IN VARCHAR2,
    p_sexo      IN CHAR,
    p_id_gerado OUT INTEGER
);
    PROCEDURE PRC_INS_DADOS_PESSOAIS (
    p_contato  IN INTEGER,
    p_endereco IN INTEGER,
    p_usuario  IN INTEGER
);
    PROCEDURE PRC_INS_ESPECIE (
    p_nome_especie IN VARCHAR2,
    p_genero       IN VARCHAR2,
    p_porte        IN VARCHAR2
);
    PROCEDURE PRC_INS_PREDISPOSICAO (
    p_nome_pred      IN VARCHAR2,
    p_orientao_pred  IN VARCHAR2
);
    PROCEDURE PRC_INS_RESTRICAO (
    p_nome_rest      IN VARCHAR2,
    p_orientacao_rest IN VARCHAR2,
    p_gravidade_rest  IN VARCHAR2
);
    PROCEDURE PRC_INS_CUIDADO (
    p_id_especie      IN INTEGER,
    p_id_restricao    IN INTEGER,
    p_id_predisposicao IN INTEGER
);
    PROCEDURE PRC_INS_PACIENTE (
    p_id_especie   IN INTEGER,
    p_idade        IN INTEGER,
    p_nome         IN VARCHAR2,
    p_sexo         IN CHAR,
    p_porte        IN VARCHAR2
);
    PROCEDURE PRC_INS_VETERINARIO (
    p_id_usuario IN INTEGER,
    p_crmv       IN VARCHAR2,
    p_uf_crmv    IN CHAR
);
    PROCEDURE PRC_INS_TUTOR (
    p_id_usuario IN INTEGER
);
    PROCEDURE PRC_INS_PET (
    p_id_tutor    IN INTEGER,
    p_id_paciente IN INTEGER
);
    PROCEDURE PRC_INS_MEDICAMENTO (
    p_nome_medicamento IN VARCHAR2,
    p_bula_medicamento IN VARCHAR2,
    p_tipo_medicamento IN VARCHAR2
);
    PROCEDURE PRC_INS_EXAME (
    p_nome_exame       IN VARCHAR2,
    p_orientacoes_exame IN VARCHAR2
);
    PROCEDURE PRC_INS_ALERGIA (
    p_id_paciente     IN INTEGER,
    p_id_medicamento  IN INTEGER,
    p_gravidade       IN VARCHAR2
);
    PROCEDURE PRC_INS_PAGAMENTO (
    p_tipo_pagamento IN VARCHAR2,
    p_id_gerado      OUT INTEGER
);
    PROCEDURE PRC_INS_CONSULTA (
    p_id_pagamento   IN INTEGER,
    p_id_veterinario IN INTEGER,
    p_id_tutor       IN INTEGER,
    p_id_paciente    IN INTEGER,
    p_observacoes    IN VARCHAR2,
    p_orientacao     IN VARCHAR2,
    p_data_consulta  IN DATE,
    p_id_gerado      OUT INTEGER
);
    PROCEDURE PRC_INS_PRESCRICAO (
    p_id_medicamento IN INTEGER,
    p_id_exame       IN INTEGER,
    p_id_consulta    IN INTEGER
);
END PKG_CT_CADASTRO;
/

CREATE OR REPLACE PACKAGE BODY PKG_CT_CADASTRO AS
PROCEDURE PRC_INS_ENDERECO (
    p_logradouro  IN VARCHAR2,
    p_numero      IN INTEGER,
    p_complemento IN VARCHAR2,
    p_cidade      IN VARCHAR2,
    p_uf          IN CHAR,
    p_cep         IN CHAR,
    p_id_gerado   OUT INTEGER
)
IS
    EX_VALOR_NULO EXCEPTION; PRAGMA EXCEPTION_INIT(EX_VALOR_NULO, -1400);
    EX_CHECK_UF EXCEPTION; PRAGMA EXCEPTION_INIT(EX_CHECK_UF, -2290);
BEGIN
    INSERT INTO TB_CT_ENDERECO (id_endereco, logradouro, numero, complemento, cidade, uf_endereco, cep)
    VALUES (NULL, p_logradouro, p_numero, p_complemento, p_cidade, p_uf, p_cep)
    RETURNING id_endereco INTO p_id_gerado;
EXCEPTION
    WHEN EX_VALOR_NULO THEN PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG('PRC_INS_ENDERECO', SQLCODE, 'Erro: Nulos em campos mandatorios de endereco.');
    WHEN EX_CHECK_UF THEN PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG('PRC_INS_ENDERECO', SQLCODE, 'Erro: UF informada invalida para a regra CHECK.');
    WHEN OTHERS THEN PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG('PRC_INS_ENDERECO', SQLCODE, SQLERRM);
END;

PROCEDURE PRC_INS_CONTATO (
    p_telefone  IN CHAR,
    p_email     IN VARCHAR2,
    p_id_gerado OUT INTEGER
)
IS
    EX_VALOR_NULO EXCEPTION; PRAGMA EXCEPTION_INIT(EX_VALOR_NULO, -1400);
    EX_FORMATO_DADO EXCEPTION; PRAGMA EXCEPTION_INIT(EX_FORMATO_DADO, -12899);
BEGIN
    INSERT INTO TB_CT_CONTATO (id_contato, telefone, email)
    VALUES (NULL, p_telefone, p_email)
    RETURNING id_contato INTO p_id_gerado;
EXCEPTION
    WHEN EX_VALOR_NULO THEN PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG('PRC_INS_CONTATO', SQLCODE, 'Erro: Colunas vazias em contato.');
    WHEN EX_FORMATO_DADO THEN PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG('PRC_INS_CONTATO', SQLCODE, 'Erro: Estouro de tamanho de string em telefone/email.');
    WHEN OTHERS THEN PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG('PRC_INS_CONTATO', SQLCODE, SQLERRM);
END;

PROCEDURE PRC_INS_USUARIO (
    p_login     IN VARCHAR2,
    p_senha     IN VARCHAR2,
    p_cpf       IN CHAR,
    p_nome      IN VARCHAR2,
    p_sexo      IN CHAR,
    p_id_gerado OUT INTEGER
)
IS
    EX_VALOR_NULO EXCEPTION; PRAGMA EXCEPTION_INIT(EX_VALOR_NULO, -1400);
    EX_CPF_DUPLICADO EXCEPTION; PRAGMA EXCEPTION_INIT(EX_CPF_DUPLICADO, -0001);
BEGIN
    INSERT INTO TB_CT_USUARIO (id_usuario, login, senha, cpf, nome_usuario, sexo_usuario)
    VALUES (NULL, p_login, p_senha, p_cpf, p_nome, p_sexo)
    RETURNING id_usuario INTO p_id_gerado;
EXCEPTION
    WHEN EX_VALOR_NULO THEN PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG('PRC_INS_USUARIO', SQLCODE, 'Erro: Identificadores obrigatorios do usuario vazios.');
    WHEN EX_CPF_DUPLICADO THEN PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG('PRC_INS_USUARIO', SQLCODE, 'Erro: CPF ja existente no sistema (UK).');
    WHEN OTHERS THEN PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG('PRC_INS_USUARIO', SQLCODE, SQLERRM);
END;

PROCEDURE PRC_INS_DADOS_PESSOAIS (
    p_contato  IN INTEGER,
    p_endereco IN INTEGER,
    p_usuario  IN INTEGER
)
IS
    EX_VALOR_NULO EXCEPTION; PRAGMA EXCEPTION_INIT(EX_VALOR_NULO, -1400);
    EX_FK_VIOLADA EXCEPTION; PRAGMA EXCEPTION_INIT(EX_FK_VIOLADA, -2291);
BEGIN
    INSERT INTO TB_CT_DADOS_PESSOAIS (id_contato, id_endereco, id_usuario)
    VALUES (p_contato, p_endereco, p_usuario);
EXCEPTION
    WHEN EX_VALOR_NULO THEN PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG('PRC_INS_DADOS_PESSOAIS', SQLCODE, 'Erro: Chaves obrigatorias nulas.');
    WHEN EX_FK_VIOLADA THEN PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG('PRC_INS_DADOS_PESSOAIS', SQLCODE, 'Erro: Uma das chaves nao existe no banco.');
    WHEN OTHERS THEN PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG('PRC_INS_DADOS_PESSOAIS', SQLCODE, SQLERRM);
END;

PROCEDURE PRC_INS_ESPECIE (
    p_nome_especie IN VARCHAR2,
    p_genero       IN VARCHAR2,
    p_porte        IN VARCHAR2
)
IS
    
    EX_VALOR_NULO EXCEPTION;     PRAGMA EXCEPTION_INIT(EX_VALOR_NULO, -1400);
    EX_REGRA_CHECK EXCEPTION;    PRAGMA EXCEPTION_INIT(EX_REGRA_CHECK, -2290);
BEGIN
    INSERT INTO TB_CT_ESPECIE (id_especie, nome_especie, genero, porte)
    VALUES (NULL, p_nome_especie, p_genero, p_porte);
EXCEPTION
    WHEN EX_VALOR_NULO THEN 
        PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG('PRC_INS_ESPECIE', SQLCODE, 'Erro: Tentativa de inserir valor nulo em campo obrigatorio.');
    WHEN EX_REGRA_CHECK THEN 
        PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG('PRC_INS_ESPECIE', SQLCODE, 'Erro: Porte inserido nao corresponde as regras aceitas (CHECK).');
    WHEN OTHERS THEN 
        PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG('PRC_INS_ESPECIE', SQLCODE, SQLERRM);
END;

PROCEDURE PRC_INS_PREDISPOSICAO (
    p_nome_pred      IN VARCHAR2,
    p_orientao_pred  IN VARCHAR2
)
IS
    EX_VALOR_NULO EXCEPTION;       PRAGMA EXCEPTION_INIT(EX_VALOR_NULO, -1400);
    EX_TAMANHO_DADO EXCEPTION;     PRAGMA EXCEPTION_INIT(EX_TAMANHO_DADO, -12899);
BEGIN
    INSERT INTO TB_CT_PREDISPOSICAO_ESP (id_predisposicao, nome_predisposicao, orientacao_predisposicao)
    VALUES (NULL, p_nome_pred, p_orientao_pred);
EXCEPTION
    WHEN EX_VALOR_NULO THEN 
        PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG('PRC_INS_PREDISPOSICAO', SQLCODE, 'Erro: Tentativa de deixar campos mandatorios nulos.');
    WHEN EX_TAMANHO_DADO THEN 
        PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG('PRC_INS_PREDISPOSICAO', SQLCODE, 'Erro: Texto de nome ou orientacao excede os limites da tabela.');
    WHEN OTHERS THEN 
        PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG('PRC_INS_PREDISPOSICAO', SQLCODE, SQLERRM);
END;

PROCEDURE PRC_INS_RESTRICAO (
    p_nome_rest      IN VARCHAR2,
    p_orientacao_rest IN VARCHAR2,
    p_gravidade_rest  IN VARCHAR2
)
IS
    EX_VALOR_NULO EXCEPTION;       PRAGMA EXCEPTION_INIT(EX_VALOR_NULO, -1400);
    EX_REGRA_CHECK EXCEPTION;      PRAGMA EXCEPTION_INIT(EX_REGRA_CHECK, -2290);
    EX_TAMANHO_DADO EXCEPTION;     PRAGMA EXCEPTION_INIT(EX_TAMANHO_DADO, -12899);
BEGIN
    INSERT INTO TB_CT_RESTRICAO_ESP (id_restricao, nome_restricao, orientacao_restricao, gravidade_restricao)
    VALUES (NULL, p_nome_rest, p_orientacao_rest, p_gravidade_rest);
EXCEPTION
    WHEN EX_VALOR_NULO THEN 
        PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG('PRC_INS_RESTRICAO', SQLCODE, 'Erro: Tentativa de inserir valores nulos em campos mandatorios.');
    WHEN EX_REGRA_CHECK THEN 
        PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG('PRC_INS_RESTRICAO', SQLCODE, 'Erro: Gravidade da restricao invalida para as regras CHECK.');
    WHEN EX_TAMANHO_DADO THEN 
        PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG('PRC_INS_RESTRICAO', SQLCODE, 'Erro: Dados inseridos excedem o tamanho maximo das colunas.');
    WHEN OTHERS THEN 
        PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG('PRC_INS_RESTRICAO', SQLCODE, SQLERRM);
END;

PROCEDURE PRC_INS_CUIDADO (
    p_id_especie      IN INTEGER,
    p_id_restricao    IN INTEGER,
    p_id_predisposicao IN INTEGER
)
IS
    EX_VALOR_NULO EXCEPTION;       PRAGMA EXCEPTION_INIT(EX_VALOR_NULO, -1400);
    EX_FK_INEXISTENTE EXCEPTION;   PRAGMA EXCEPTION_INIT(EX_FK_INEXISTENTE, -2291); -- Captura se ID de espécie, restrição ou predisposição não existir
BEGIN
    INSERT INTO TB_CT_CUIDADO (id_especie, id_restricao, id_predisposicao) 
    VALUES (p_id_especie, p_id_restricao, p_id_predisposicao);
EXCEPTION
    WHEN EX_VALOR_NULO THEN 
        PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG('PRC_INS_CUIDADO', SQLCODE, 'Erro: Nao e permitido associar vinculos vazios em cuidados.');
    WHEN EX_FK_INEXISTENTE THEN 
        PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG('PRC_INS_CUIDADO', SQLCODE, 'Erro: Tentativa de vincular ID inexistente de Especie, Restricao ou Predisposicao.');
    WHEN OTHERS THEN 
        PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG('PRC_INS_CUIDADO', SQLCODE, SQLERRM);
END;

PROCEDURE PRC_INS_PACIENTE (
    p_id_especie   IN INTEGER,
    p_idade        IN INTEGER,
    p_nome         IN VARCHAR2,
    p_sexo         IN CHAR,
    p_porte        IN VARCHAR2
)
IS
    EX_VALOR_NULO EXCEPTION;       PRAGMA EXCEPTION_INIT(EX_VALOR_NULO, -1400);
    EX_REGRA_CHECK EXCEPTION;      PRAGMA EXCEPTION_INIT(EX_REGRA_CHECK, -2290);
    EX_FK_INEXISTENTE EXCEPTION;   PRAGMA EXCEPTION_INIT(EX_FK_INEXISTENTE, -2291);
BEGIN
    INSERT INTO TB_CT_PACIENTE (id_paciente, id_especie, idade_paciente, nome_paciente, sexo_paciente, porte_paciente)
    VALUES (NULL, p_id_especie, p_idade, p_nome, p_sexo, p_porte);
EXCEPTION
    WHEN EX_VALOR_NULO THEN 
        PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG('PRC_INS_PACIENTE', SQLCODE, 'Erro: Dados mandatorios do paciente ausentes.');
    WHEN EX_REGRA_CHECK THEN 
        PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG('PRC_INS_PACIENTE', SQLCODE, 'Erro: Sexo ou Porte informado viola a regra CHECK da clinica.');
    WHEN EX_FK_INEXISTENTE THEN 
        PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG('PRC_INS_PACIENTE', SQLCODE, 'Erro: A especie informada nao existe na tabela mae.');
    WHEN OTHERS THEN 
        PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG('PRC_INS_PACIENTE', SQLCODE, SQLERRM);
END;

PROCEDURE PRC_INS_VETERINARIO (
    p_id_usuario IN INTEGER,
    p_crmv       IN VARCHAR2,
    p_uf_crmv    IN CHAR
)
IS
    EX_VALOR_NULO EXCEPTION;       PRAGMA EXCEPTION_INIT(EX_VALOR_NULO, -1400);
    EX_CRMV_DUPLICADO EXCEPTION;   PRAGMA EXCEPTION_INIT(EX_CRMV_DUPLICADO, -0001);
    EX_FK_INEXISTENTE EXCEPTION;   PRAGMA EXCEPTION_INIT(EX_FK_INEXISTENTE, -2291);
BEGIN
    INSERT INTO TB_CT_VETERINARIO (id_veterinario, id_usuario, crmv, uf_crmv)
    VALUES (NULL, p_id_usuario, p_crmv, p_uf_crmv);
EXCEPTION
    WHEN EX_VALOR_NULO THEN 
        PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG('PRC_INS_VETERINARIO', SQLCODE, 'Erro: Campos obrigatorios do veterinario ausentes.');
    WHEN EX_CRMV_DUPLICADO THEN 
        PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG('PRC_INS_VETERINARIO', SQLCODE, 'Erro: Este numero de CRMV ja esta cadastrado no sistema.');
    WHEN EX_FK_INEXISTENTE THEN 
        PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG('PRC_INS_VETERINARIO', SQLCODE, 'Erro: O ID de usuario informado nao existe.');
    WHEN OTHERS THEN 
        PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG('PRC_INS_VETERINARIO', SQLCODE, SQLERRM);
END;

PROCEDURE PRC_INS_TUTOR (
    p_id_usuario IN INTEGER
)
IS
    EX_VALOR_NULO EXCEPTION;       PRAGMA EXCEPTION_INIT(EX_VALOR_NULO, -1400);
    EX_FK_INEXISTENTE EXCEPTION;   PRAGMA EXCEPTION_INIT(EX_FK_INEXISTENTE, -2291);
BEGIN
    INSERT INTO TB_CT_TUTOR (id_tutor, id_usuario)
    VALUES (NULL, p_id_usuario);
EXCEPTION
    WHEN EX_VALOR_NULO THEN 
        PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG('PRC_INS_TUTOR', SQLCODE, 'Erro: ID de usuario obrigatorio nao informado para o tutor.');
    WHEN EX_FK_INEXISTENTE THEN 
        PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG('PRC_INS_TUTOR', SQLCODE, 'Erro: O ID de usuario informado para o tutor nao existe.');
    WHEN OTHERS THEN 
        PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG('PRC_INS_TUTOR', SQLCODE, SQLERRM);
END;

PROCEDURE PRC_INS_PET (
    p_id_tutor    IN INTEGER,
    p_id_paciente IN INTEGER
)
IS
    EX_VALOR_NULO EXCEPTION;       PRAGMA EXCEPTION_INIT(EX_VALOR_NULO, -1400);
    EX_FK_INEXISTENTE EXCEPTION;   PRAGMA EXCEPTION_INIT(EX_FK_INEXISTENTE, -2291);
BEGIN
    INSERT INTO TB_CT_PET (id_tutor, id_paciente) 
    VALUES (p_id_tutor, p_id_paciente);
EXCEPTION
    WHEN EX_VALOR_NULO THEN 
        PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG('PRC_INS_PET', SQLCODE, 'Erro: Nao e permitido criar vinculos vazios de tutor e pet.');
    WHEN EX_FK_INEXISTENTE THEN 
        PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG('PRC_INS_PET', SQLCODE, 'Erro: O ID de tutor ou de paciente fornecido nao existe na base.');
    WHEN OTHERS THEN 
        PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG('PRC_INS_PET', SQLCODE, SQLERRM);
END;

PROCEDURE PRC_INS_MEDICAMENTO (
    p_nome_medicamento IN VARCHAR2,
    p_bula_medicamento IN VARCHAR2,
    p_tipo_medicamento IN VARCHAR2
)
IS
    EX_VALOR_NULO EXCEPTION;       PRAGMA EXCEPTION_INIT(EX_VALOR_NULO, -1400);
    EX_REGRA_CHECK EXCEPTION;      PRAGMA EXCEPTION_INIT(EX_REGRA_CHECK, -2290); -- Captura se o tipo violar a lista da constraint CHECK
    EX_TAMANHO_DADO EXCEPTION;     PRAGMA EXCEPTION_INIT(EX_TAMANHO_DADO, -12899);
BEGIN
    INSERT INTO TB_CT_MEDICAMENTO (id_medicamento, nome_medicamento, bula_medicamento, tipo_medicamento)
    VALUES (NULL, p_nome_medicamento, p_bula_medicamento, p_tipo_medicamento);
EXCEPTION
    WHEN EX_VALOR_NULO THEN 
        PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG('PRC_INS_MEDICAMENTO', SQLCODE, 'Erro: Campos obrigatorios de medicamento ausentes.');
    WHEN EX_REGRA_CHECK THEN 
        PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG('PRC_INS_MEDICAMENTO', SQLCODE, 'Erro: O tipo de medicamento fornecido nao consta na lista permitida (CHECK).');
    WHEN EX_TAMANHO_DADO THEN 
        PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG('PRC_INS_MEDICAMENTO', SQLCODE, 'Erro: Nome, Bula ou Tipo ultrapassou o limite de caracteres da tabela.');
    WHEN OTHERS THEN 
        PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG('PRC_INS_MEDICAMENTO', SQLCODE, SQLERRM);
END;

PROCEDURE PRC_INS_EXAME (
    p_nome_exame       IN VARCHAR2,
    p_orientacoes_exame IN VARCHAR2
)
IS
    EX_VALOR_NULO EXCEPTION;       PRAGMA EXCEPTION_INIT(EX_VALOR_NULO, -1400);
    EX_TAMANHO_DADO EXCEPTION;     PRAGMA EXCEPTION_INIT(EX_TAMANHO_DADO, -12899);
BEGIN
    INSERT INTO TB_CT_EXAME (id_exame, nome_exame, orientacoes_exame)
    VALUES (NULL, p_nome_exame, p_orientacoes_exame);
EXCEPTION
    WHEN EX_VALOR_NULO THEN 
        PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG('PRC_INS_EXAME', SQLCODE, 'Erro: Nome ou orientacao do exame obrigatoria ausente.');
    WHEN EX_TAMANHO_DADO THEN 
        PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG('PRC_INS_EXAME', SQLCODE, 'Erro: Texto de nome ou orientacao de exame longo demais.');
    WHEN OTHERS THEN 
        PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG('PRC_INS_EXAME', SQLCODE, SQLERRM);
END;

PROCEDURE PRC_INS_ALERGIA (
    p_id_paciente     IN INTEGER,
    p_id_medicamento  IN INTEGER,
    p_gravidade       IN VARCHAR2
)
IS
    EX_VALOR_NULO EXCEPTION;       PRAGMA EXCEPTION_INIT(EX_VALOR_NULO, -1400);
    EX_REGRA_CHECK EXCEPTION;      PRAGMA EXCEPTION_INIT(EX_REGRA_CHECK, -2290); 
    EX_FK_INEXISTENTE EXCEPTION;   PRAGMA EXCEPTION_INIT(EX_FK_INEXISTENTE, -2291); 
BEGIN
    INSERT INTO TB_CT_ALERGIA (id_paciente, id_medicamento, gravidade_alergia)
    VALUES (p_id_paciente, p_id_medicamento, p_gravidade);
EXCEPTION
    WHEN EX_VALOR_NULO THEN 
        PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG('PRC_INS_ALERGIA', SQLCODE, 'Erro: Tentativa de inserir valores nulos em chaves de alergia.');
    WHEN EX_REGRA_CHECK THEN 
        PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG('PRC_INS_ALERGIA', SQLCODE, 'Erro: Gravidade de alergia invalida. Use GRAVE, MEDIA ou LEVE.');
    WHEN EX_FK_INEXISTENTE THEN 
        PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG('PRC_INS_ALERGIA', SQLCODE, 'Erro: O paciente ou medicamento informado nao existe na base.');
    WHEN OTHERS THEN 
        PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG('PRC_INS_ALERGIA', SQLCODE, SQLERRM);
END;

PROCEDURE PRC_INS_PAGAMENTO (
    p_tipo_pagamento IN VARCHAR2,
    p_id_gerado      OUT INTEGER
)
IS
    EX_VALOR_NULO EXCEPTION;       PRAGMA EXCEPTION_INIT(EX_VALOR_NULO, -1400);
    EX_REGRA_CHECK EXCEPTION;      PRAGMA EXCEPTION_INIT(EX_REGRA_CHECK, -2290); -- Valida formas de pagamento (PIX, CREDITO, DEBITO)
BEGIN
    INSERT INTO TB_CT_PAGAMENTO (id_pagamento, tipo_pagamento)
    VALUES (NULL, p_tipo_pagamento)
    RETURNING id_pagamento INTO p_id_gerado;
EXCEPTION
    WHEN EX_VALOR_NULO THEN PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG('PRC_INS_PAGAMENTO', SQLCODE, 'Erro: Tipo de pagamento obrigatorio vazio.');
    WHEN EX_REGRA_CHECK THEN PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG('PRC_INS_PAGAMENTO', SQLCODE, 'Erro: Forma de pagamento invalida na regra CHECK.');
    WHEN OTHERS THEN PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG('PRC_INS_PAGAMENTO', SQLCODE, SQLERRM);
END;

PROCEDURE PRC_INS_CONSULTA (
    p_id_pagamento   IN INTEGER,
    p_id_veterinario IN INTEGER,
    p_id_tutor       IN INTEGER,
    p_id_paciente    IN INTEGER,
    p_observacoes    IN VARCHAR2,
    p_orientacao     IN VARCHAR2,
    p_data_consulta  IN DATE,
    p_id_gerado      OUT INTEGER
)
IS
    EX_VALOR_NULO EXCEPTION;       PRAGMA EXCEPTION_INIT(EX_VALOR_NULO, -1400);
    EX_FK_INEXISTENTE EXCEPTION;   PRAGMA EXCEPTION_INIT(EX_FK_INEXISTENTE, -2291);
BEGIN
    INSERT INTO TB_CT_CONSULTA (id_consulta, id_pagamento, id_veterinario, id_tutor, id_paciente, observacoes, orientacao_consulta, data_consulta)
    VALUES (NULL, p_id_pagamento, p_id_veterinario, p_id_tutor, p_id_paciente, p_observacoes, p_orientacao, p_data_consulta)
    RETURNING id_consulta INTO p_id_gerado;
EXCEPTION
    WHEN EX_VALOR_NULO THEN PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG('PRC_INS_CONSULTA', SQLCODE, 'Erro: Identificadores mandatorios da consulta nulos.');
    WHEN EX_FK_INEXISTENTE THEN PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG('PRC_INS_CONSULTA', SQLCODE, 'Erro: Um dos IDs relacionais (Vet/Tutor/Pet/Pagto) nao existe.');
    WHEN OTHERS THEN PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG('PRC_INS_CONSULTA', SQLCODE, SQLERRM);
END;

PROCEDURE PRC_INS_PRESCRICAO (
    p_id_medicamento IN INTEGER,
    p_id_exame       IN INTEGER,
    p_id_consulta    IN INTEGER
)
IS
    EX_VALOR_NULO EXCEPTION;       PRAGMA EXCEPTION_INIT(EX_VALOR_NULO, -1400);
    EX_FK_INEXISTENTE EXCEPTION;   PRAGMA EXCEPTION_INIT(EX_FK_INEXISTENTE, -2291);
BEGIN
    
    INSERT INTO TB_CT_PRESCRICAO (id_medicamento, id_exame, id_consulta)
    VALUES (p_id_medicamento, p_id_exame, p_id_consulta);
EXCEPTION
    WHEN EX_VALOR_NULO THEN 
        PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG('PRC_INS_PRESCRICAO', SQLCODE, 'Erro: Chaves de ligacao vazias na receita.');
    WHEN EX_FK_INEXISTENTE THEN 
        PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG('PRC_INS_PRESCRICAO', SQLCODE, 'Erro: ID de Medicamento, Exame ou Consulta invalido ou inexistente.');
    WHEN OTHERS THEN 
        PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG('PRC_INS_PRESCRICAO', SQLCODE, SQLERRM);
END;
END PKG_CT_CADASTRO;
/

-- Gatilho independente que delega a regra ao package de auditoria.
CREATE OR REPLACE TRIGGER TRG_CT_AUDITORIA_PACIENTE
AFTER INSERT OR UPDATE OR DELETE ON TB_CT_PACIENTE FOR EACH ROW
DECLARE
 v_tipo VARCHAR2(10); v_old VARCHAR2(4000); v_new VARCHAR2(4000);
BEGIN
 IF INSERTING THEN v_tipo := 'INSERT'; v_new := 'ID_PACIENTE='||:NEW.ID_PACIENTE||'; ID_ESPECIE='||:NEW.ID_ESPECIE||'; IDADE_PACIENTE='||:NEW.IDADE_PACIENTE||'; NOME_PACIENTE='||:NEW.NOME_PACIENTE||'; SEXO_PACIENTE='||:NEW.SEXO_PACIENTE||'; PORTE_PACIENTE='||:NEW.PORTE_PACIENTE;
 ELSIF UPDATING THEN v_tipo := 'UPDATE'; v_old := 'ID_PACIENTE='||:OLD.ID_PACIENTE||'; ID_ESPECIE='||:OLD.ID_ESPECIE||'; IDADE_PACIENTE='||:OLD.IDADE_PACIENTE||'; NOME_PACIENTE='||:OLD.NOME_PACIENTE||'; SEXO_PACIENTE='||:OLD.SEXO_PACIENTE||'; PORTE_PACIENTE='||:OLD.PORTE_PACIENTE; v_new := 'ID_PACIENTE='||:NEW.ID_PACIENTE||'; ID_ESPECIE='||:NEW.ID_ESPECIE||'; IDADE_PACIENTE='||:NEW.IDADE_PACIENTE||'; NOME_PACIENTE='||:NEW.NOME_PACIENTE||'; SEXO_PACIENTE='||:NEW.SEXO_PACIENTE||'; PORTE_PACIENTE='||:NEW.PORTE_PACIENTE;
 ELSE v_tipo := 'DELETE'; v_old := 'ID_PACIENTE='||:OLD.ID_PACIENTE||'; ID_ESPECIE='||:OLD.ID_ESPECIE||'; IDADE_PACIENTE='||:OLD.IDADE_PACIENTE||'; NOME_PACIENTE='||:OLD.NOME_PACIENTE||'; SEXO_PACIENTE='||:OLD.SEXO_PACIENTE||'; PORTE_PACIENTE='||:OLD.PORTE_PACIENTE;
 END IF;
 PKG_CT_AUDITORIA.PRC_AUDITAR_PACIENTE(v_tipo,v_old,v_new);
END;
/