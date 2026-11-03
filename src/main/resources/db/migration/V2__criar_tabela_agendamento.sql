-- Única tabela nova do app: os pedidos de cuidado preventivo feitos pelo tutor (fluxo da Sprint 3).
-- Não existe no modelo do grupo e não altera nenhuma tabela dele. Quando o atendimento é registrado,
-- a consulta oficial vai para TB_CT_CONSULTA pelas procedures e fica ligada aqui em id_consulta.
CREATE SEQUENCE TB_CT_AGENDAMENTO_ID_SEQ START WITH 1 NOCACHE ORDER;

CREATE TABLE TB_CT_AGENDAMENTO
(
    id_agendamento INTEGER DEFAULT TB_CT_AGENDAMENTO_ID_SEQ.NEXTVAL DEFAULT ON NULL NOT NULL,
    id_paciente    INTEGER NOT NULL,
    tipo_cuidado   VARCHAR2 (20 CHAR) NOT NULL,
    data_agendada  DATE NOT NULL,
    status         VARCHAR2 (20 CHAR) NOT NULL,
    observacao     VARCHAR2 (100 CHAR),
    id_consulta    INTEGER
);
ALTER TABLE TB_CT_AGENDAMENTO ADD CONSTRAINT tb_ct_agendamento_pk PRIMARY KEY (id_agendamento);
ALTER TABLE TB_CT_AGENDAMENTO ADD CONSTRAINT tb_ct_agendamento_tipo_ck
    CHECK (tipo_cuidado IN ('VACINA', 'VERMIFUGO', 'CHECKUP'));
ALTER TABLE TB_CT_AGENDAMENTO ADD CONSTRAINT tb_ct_agendamento_status_ck
    CHECK (status IN ('SOLICITADO', 'CONFIRMADO', 'RECUSADO', 'REALIZADO'));
ALTER TABLE TB_CT_AGENDAMENTO ADD CONSTRAINT tb_ct_agendamento_id_pac_fk
    FOREIGN KEY (id_paciente) REFERENCES TB_CT_PACIENTE (id_paciente);
ALTER TABLE TB_CT_AGENDAMENTO ADD CONSTRAINT tb_ct_agendamento_id_cons_fk
    FOREIGN KEY (id_consulta) REFERENCES TB_CT_CONSULTA (id_consulta);
