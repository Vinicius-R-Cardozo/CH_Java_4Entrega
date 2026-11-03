-- ===================================================================================================================
-- Trigger de auditoria das operações realizadas na tabela TB_CT_PACIENTE.
-- Registra automaticamente as operações de INSERT, UPDATE e DELETE realizadas sobre os pacientes,
-- armazenando o usuario do banco, a data e hora da operação, o tipo da operação e os valores
-- anteriores e novos dos registros na tabela TB_CT_AUDITORIA_DML.
-- A trigger utiliza os valores :OLD e :NEW para identificar as alterações realizadas nos dados,
-- permitindo manter um histórico das modificações efetuadas na tabela de pacientes.

--COMENTADA COMO FOI SOLICITADO EM DOCUMENTO DE ENTREGA

-- ===================================================================================================================




CREATE OR REPLACE TRIGGER TRG_CT_AUDITORIA_PACIENTE
AFTER INSERT OR UPDATE OR DELETE ON TB_CT_PACIENTE
FOR EACH ROW

BEGIN

    -- Verifica se a operação realizada foi um INSERT.
    -- Nesse caso, não existem valores antigos, então o campo
    -- VALORES_ANTERIORES fica como NULL.
    IF INSERTING THEN

        -- Insere na tabela de auditoria os dados do novo paciente.
        INSERT INTO TB_CT_AUDITORIA_DML
        (
            NOME_TABELA,
            USUARIO_BANCO,
            TIPO_OPERACAO,
            DATA_HORA,
            VALORES_ANTERIORES,
            VALORES_NOVOS
        )
        VALUES
        (
            'TB_CT_PACIENTE',
            USER,
            'INSERT',
            SYSDATE,
            NULL,

            -- Junta os valores do novo registro em uma única string
            -- para facilitar a visualização no histórico.
            'ID_PACIENTE=' || :NEW.ID_PACIENTE ||
            '; ID_ESPECIE=' || :NEW.ID_ESPECIE ||
            '; IDADE_PACIENTE=' || :NEW.IDADE_PACIENTE ||
            '; NOME_PACIENTE=' || :NEW.NOME_PACIENTE ||
            '; SEXO_PACIENTE=' || :NEW.SEXO_PACIENTE ||
            '; PORTE_PACIENTE=' || :NEW.PORTE_PACIENTE
        );


    -- Verifica se a operação realizada foi um UPDATE.
    -- Nesse caso, precisamos guardar tanto os valores antigos
    -- quanto os valores novos para saber o que foi alterado.
    ELSIF UPDATING THEN

        INSERT INTO TB_CT_AUDITORIA_DML
        (
            NOME_TABELA,
            USUARIO_BANCO,
            TIPO_OPERACAO,
            DATA_HORA,
            VALORES_ANTERIORES,
            VALORES_NOVOS
        )
        VALUES
        (
            'TB_CT_PACIENTE',
            USER,
            'UPDATE',
            SYSDATE,

            -- :OLD representa os valores que estavam no paciente
            -- antes da alteração.
            'ID_PACIENTE=' || :OLD.ID_PACIENTE ||
            '; ID_ESPECIE=' || :OLD.ID_ESPECIE ||
            '; IDADE_PACIENTE=' || :OLD.IDADE_PACIENTE ||
            '; NOME_PACIENTE=' || :OLD.NOME_PACIENTE ||
            '; SEXO_PACIENTE=' || :OLD.SEXO_PACIENTE ||
            '; PORTE_PACIENTE=' || :OLD.PORTE_PACIENTE,

            -- :NEW representa os valores que ficaram no paciente
            -- depois da alteração.
            'ID_PACIENTE=' || :NEW.ID_PACIENTE ||
            '; ID_ESPECIE=' || :NEW.ID_ESPECIE ||
            '; IDADE_PACIENTE=' || :NEW.IDADE_PACIENTE ||
            '; NOME_PACIENTE=' || :NEW.NOME_PACIENTE ||
            '; SEXO_PACIENTE=' || :NEW.SEXO_PACIENTE ||
            '; PORTE_PACIENTE=' || :NEW.PORTE_PACIENTE
        );


    -- Verifica se a operação realizada foi um DELETE.
    -- Como o registro será removido, guardamos apenas os
    -- valores que existiam antes da exclusão.
    ELSIF DELETING THEN

        INSERT INTO TB_CT_AUDITORIA_DML
        (
            NOME_TABELA,
            USUARIO_BANCO,
            TIPO_OPERACAO,
            DATA_HORA,
            VALORES_ANTERIORES,
            VALORES_NOVOS
        )
        VALUES
        (
            'TB_CT_PACIENTE',
            USER,
            'DELETE',
            SYSDATE,

            -- Guarda os dados do paciente antes de ele ser excluído.
            'ID_PACIENTE=' || :OLD.ID_PACIENTE ||
            '; ID_ESPECIE=' || :OLD.ID_ESPECIE ||
            '; IDADE_PACIENTE=' || :OLD.IDADE_PACIENTE ||
            '; NOME_PACIENTE=' || :OLD.NOME_PACIENTE ||
            '; SEXO_PACIENTE=' || :OLD.SEXO_PACIENTE ||
            '; PORTE_PACIENTE=' || :OLD.PORTE_PACIENTE,

            -- Como o registro foi excluído, não existem valores novos.
            NULL
        );

    END IF;

END;
/