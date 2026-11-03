

-- TRIGGERS
DROP TRIGGER TB_CT_LOG_ERRO_ID_LOG_TRG;
DROP TRIGGER TB_CT_CONSULTA_ID_CONSULTA_TRG;
DROP TRIGGER TB_CT_CONTATO_ID_CONTATO_TRG;
DROP TRIGGER TB_CT_ENDERECO_id_endereco_TRG;
DROP TRIGGER TB_CT_ESPECIE_ID_ESPECIE_TRG;
DROP TRIGGER TB_CT_EXAME_ID_EXAME_TRG;
DROP TRIGGER TB_CT_MEDICAMENTO_ID_MEDICAMEN;
DROP TRIGGER TB_CT_PACIENTE_ID_PACIENTE_TRG;
DROP TRIGGER TB_CT_PAGAMENTO_ID_PAGAMENTO;
DROP TRIGGER TB_CT_PREDISPOSICAO_ESP_ID_PRE;
DROP TRIGGER TB_CT_RESTRICAO_ESP_ID_RESTRIC;
DROP TRIGGER TB_CT_TUTOR_ID_TUTOR_TRG;
DROP TRIGGER TB_CT_USUARIO_ID_USUARIO_TRG;
DROP TRIGGER TB_CT_VETERINARIO_ID_VETERINAR;

-- SEQUENCES
DROP SEQUENCE TB_CT_AUDITORIA_DML_ID_AUDITORIA_SEQ;
DROP SEQUENCE TB_CT_LOG_ERRO_ID_LOG_SEQ;
DROP SEQUENCE TB_CT_CONSULTA_ID_CONSULTA_SEQ;
DROP SEQUENCE TB_CT_CONTATO_ID_CONTATO_SEQ;
DROP SEQUENCE TB_CT_ENDERECO_ID_ENDERECO_SEQ;
DROP SEQUENCE TB_CT_ESPECIE_ID_ESPECIE_SEQ;
DROP SEQUENCE TB_CT_EXAME_ID_EXAME_SEQ;
DROP SEQUENCE TB_CT_MEDICAMENTO_ID_MEDICAMEN;
DROP SEQUENCE TB_CT_PACIENTE_ID_PACIENTE_SEQ;
DROP SEQUENCE TB_CT_PAGAMENTO_ID_PAGAMENTO;
DROP SEQUENCE TB_CT_PREDISPOSICAO_ESP_ID_PRE;
DROP SEQUENCE TB_CT_RESTRICAO_ESP_ID_RESTRIC;
DROP SEQUENCE TB_CT_TUTOR_ID_TUTOR_SEQ;
DROP SEQUENCE TB_CT_USUARIO_ID_USUARIO_SEQ;
DROP SEQUENCE TB_CT_VETERINARIO_ID_VETERINAR;

-- Gerado por Oracle SQL Developer Data Modeler 24.3.1.351.0831


DROP TABLE TB_CT_AUDITORIA_DML CASCADE CONSTRAINTS
;

DROP TABLE TB_CT_ALERGIA CASCADE CONSTRAINTS 
;

DROP TABLE TB_CT_CONSULTA CASCADE CONSTRAINTS 
;

DROP TABLE TB_CT_CONTATO CASCADE CONSTRAINTS 
;

DROP TABLE TB_CT_CUIDADO CASCADE CONSTRAINTS 
;

DROP TABLE TB_CT_DADOS_PESSOAIS CASCADE CONSTRAINTS 
;

DROP TABLE TB_CT_ENDERECO CASCADE CONSTRAINTS 
;

DROP TABLE TB_CT_ESPECIE CASCADE CONSTRAINTS 
;

DROP TABLE TB_CT_EXAME CASCADE CONSTRAINTS 
;

DROP TABLE TB_CT_LOG_ERRO CASCADE CONSTRAINTS 
;

DROP TABLE TB_CT_MEDICAMENTO CASCADE CONSTRAINTS 
;

DROP TABLE TB_CT_PACIENTE CASCADE CONSTRAINTS 
;

DROP TABLE TB_CT_PAGAMENTO CASCADE CONSTRAINTS 
;

DROP TABLE TB_CT_PET CASCADE CONSTRAINTS 
;

DROP TABLE TB_CT_PREDISPOSICAO_ESP CASCADE CONSTRAINTS 
;

DROP TABLE TB_CT_PRESCRICAO CASCADE CONSTRAINTS 
;

DROP TABLE TB_CT_RESTRICAO_ESP CASCADE CONSTRAINTS 
;

DROP TABLE TB_CT_TUTOR CASCADE CONSTRAINTS 
;

DROP TABLE TB_CT_USUARIO CASCADE CONSTRAINTS 
;

DROP TABLE TB_CT_VETERINARIO CASCADE CONSTRAINTS 
;

-- predefined type, no DDL - MDSYS.SDO_GEOMETRY

-- predefined type, no DDL - XMLTYPE

CREATE TABLE TB_CT_AUDITORIA_DML
(
    ID_AUDITORIA       INTEGER NOT NULL,
    NOME_TABELA        VARCHAR2 (30 CHAR) NOT NULL,
    USUARIO_BANCO      VARCHAR2 (100 CHAR) NOT NULL,
    TIPO_OPERACAO      VARCHAR2 (10 CHAR) NOT NULL,
    DATA_HORA          DATE NOT NULL,
    VALORES_ANTERIORES VARCHAR2 (4000 CHAR),
    VALORES_NOVOS      VARCHAR2 (4000 CHAR)
);

ALTER TABLE TB_CT_AUDITORIA_DML
    ADD CONSTRAINT TB_CT_AUDITORIA_DML_PK
    PRIMARY KEY (ID_AUDITORIA)
    ;

CREATE TABLE TB_CT_ALERGIA 
    ( 
     id_paciente       INTEGER  NOT NULL , 
     id_medicamento    INTEGER  NOT NULL , 
     gravidade_alergia VARCHAR2 (5 CHAR)  NOT NULL 
    ) 
;

ALTER TABLE TB_CT_ALERGIA 
    ADD CONSTRAINT tb_ct_alergia_gravidade_ck 
    CHECK (gravidade_alergia IN ('GRAVE', 'MEDIA', 'LEVE'))
;

CREATE TABLE TB_CT_CONSULTA 
    ( 
     id_consulta         INTEGER  NOT NULL , 
     id_pagamento        INTEGER  NOT NULL , 
     id_veterinario      INTEGER  NOT NULL , 
     id_tutor            INTEGER  NOT NULL , 
     id_paciente         INTEGER  NOT NULL , 
     observacoes         VARCHAR2 (100 CHAR) , 
     orientacao_consulta VARCHAR2 (200 CHAR)  NOT NULL , 
     data_consulta       DATE  NOT NULL 
    ) 
;

ALTER TABLE TB_CT_CONSULTA 
    ADD CONSTRAINT tb_ct_consulta_pk PRIMARY KEY ( id_consulta ) ;

CREATE TABLE TB_CT_CONTATO 
    ( 
     id_contato INTEGER  NOT NULL , 
     telefone   CHAR (11 CHAR)  NOT NULL , 
     email      VARCHAR2 (50 CHAR)  NOT NULL 
    ) 
;

ALTER TABLE TB_CT_CONTATO 
    ADD CONSTRAINT tb_ct_contato_pk PRIMARY KEY ( id_contato ) ;

CREATE TABLE TB_CT_CUIDADO 
    ( 
     id_especie       INTEGER  NOT NULL , 
     id_restricao     INTEGER  NOT NULL , 
     id_predisposicao INTEGER  NOT NULL 
    ) 
;

CREATE TABLE TB_CT_DADOS_PESSOAIS 
    ( 
     id_contato  INTEGER  NOT NULL , 
     id_endereco INTEGER  NOT NULL , 
     id_usuario  INTEGER  NOT NULL 
    ) 
;

CREATE TABLE TB_CT_ENDERECO 
    ( 
     id_endereco INTEGER  NOT NULL , 
     logradouro  VARCHAR2 (100 CHAR)  NOT NULL , 
     numero      INTEGER  NOT NULL , 
     complemento VARCHAR2 (50 CHAR) , 
     cidade      VARCHAR2 (60)  NOT NULL , 
     uf_endereco CHAR (2)  NOT NULL , 
     cep         CHAR (8 CHAR)  NOT NULL 
    ) 
;

ALTER TABLE TB_CT_ENDERECO 
    ADD CONSTRAINT tb_ct_endereco_uf_ck 
    CHECK (uf_endereco IN ('AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA', 'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN', 'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO'))
;
ALTER TABLE TB_CT_ENDERECO 
    ADD CONSTRAINT tb_cp_endereco_pk PRIMARY KEY ( id_endereco ) ;

CREATE TABLE TB_CT_ESPECIE 
    ( 
     id_especie   INTEGER  NOT NULL , 
     nome_especie VARCHAR2 (50 CHAR)  NOT NULL , 
     genero       VARCHAR2 (25)  NOT NULL , 
     porte        VARCHAR2 (25 CHAR)  NOT NULL 
    ) 
;

ALTER TABLE TB_CT_ESPECIE 
    ADD CONSTRAINT tb_ct_especie_porte_ck 
    CHECK (porte IN ('GRANDE', 'MEDIO', 'PEQUENO', 'SPD'))
;
ALTER TABLE TB_CT_ESPECIE 
    ADD CONSTRAINT tb_ct_especie_pk PRIMARY KEY ( id_especie ) ;

CREATE TABLE TB_CT_EXAME 
    ( 
     id_exame          INTEGER  NOT NULL , 
     nome_exame        VARCHAR2 (50 CHAR)  NOT NULL , 
     orientacoes_exame VARCHAR2 (25 CHAR)  NOT NULL 
    ) 
;

ALTER TABLE TB_CT_EXAME 
    ADD CONSTRAINT tb_ct_exame_id_ex_pk PRIMARY KEY ( id_exame ) ;

CREATE TABLE TB_CT_LOG_ERRO 
    ( 
     id_log          INTEGER  NOT NULL , 
     nome_procedure  VARCHAR2 (35 CHAR)  NOT NULL , 
     usuario_banco   VARCHAR2 (50 CHAR)  NOT NULL , 
     data_ocorrencia DATE  NOT NULL , 
     mensagem_erro   VARCHAR2 (300 CHAR)  NOT NULL 
    ) 
;

ALTER TABLE TB_CT_LOG_ERRO 
    ADD CONSTRAINT tb_ct_log_erro_pk PRIMARY KEY ( id_log ) ;

CREATE TABLE TB_CT_MEDICAMENTO 
    ( 
     id_medicamento   INTEGER  NOT NULL , 
     nome_medicamento VARCHAR2 (50 CHAR)  NOT NULL , 
     bula_medicamento VARCHAR2 (500 CHAR)  NOT NULL , 
     tipo_medicamento VARCHAR2 (40 CHAR)  NOT NULL 
    ) 
;

ALTER TABLE TB_CT_MEDICAMENTO 
    ADD CONSTRAINT tb_ct_medicamento_tipo_med_ck 
    CHECK (tipo_medicamento IN ('NULO','analgesico', 'anti inflamatorio nao esteroide', 'anti inflamatorio esteroide', 'antibiotico', 'antifungico', 'antiparasitario', 'antiviral', 'anti emetico', 'protetor gastrico', 'anticonvulsivante', 'ansiolitico', 'sedativo', 'antipruriginoso', 'suplemento vitaminico', 'probiotico'))
;
ALTER TABLE TB_CT_MEDICAMENTO 
    ADD CONSTRAINT tb_ct_medicamento_id_med_pk PRIMARY KEY ( id_medicamento ) ;

CREATE TABLE TB_CT_PACIENTE 
    ( 
     id_paciente    INTEGER  NOT NULL , 
     id_especie     INTEGER  NOT NULL , 
     idade_paciente INTEGER  NOT NULL , 
     nome_paciente  VARCHAR2 (50 CHAR)  NOT NULL , 
     sexo_paciente  CHAR (1 CHAR)  NOT NULL , 
     porte_paciente VARCHAR2 (25 CHAR)  NOT NULL 
    ) 
;

ALTER TABLE TB_CT_PACIENTE 
    ADD CONSTRAINT tb_ct_paciente_sexo_pac_ck 
    CHECK (sexo_paciente IN  ('F', 'M'))
;


ALTER TABLE TB_CT_PACIENTE 
    ADD CONSTRAINT tb_ct_paciente_porte_pac_ck 
    CHECK (porte_paciente IN ('GRANDE', 'MEDIO', 'PEQUENO', 'SPD'))
;
ALTER TABLE TB_CT_PACIENTE 
    ADD CONSTRAINT tb_ct_paciente_pk PRIMARY KEY ( id_paciente ) ;

CREATE TABLE TB_CT_PAGAMENTO 
    ( 
     id_pagamento   INTEGER  NOT NULL , 
     tipo_pagamento VARCHAR2 (20)  NOT NULL 
    ) 
;

ALTER TABLE TB_CT_PAGAMENTO 
    ADD CONSTRAINT tb_ct_pagamento_tipo_pag_ck 
    CHECK (tipo_pagamento IN ('PIX', 'CREDITO', 'DEBITO', 'SALDO'))
;
ALTER TABLE TB_CT_PAGAMENTO 
    ADD CONSTRAINT tb_ct_pagamento_id_pag_pk PRIMARY KEY ( id_pagamento ) ;

CREATE TABLE TB_CT_PET 
    ( 
     id_tutor    INTEGER  NOT NULL , 
     id_paciente INTEGER  NOT NULL 
    ) 
;

CREATE TABLE TB_CT_PREDISPOSICAO_ESP 
    ( 
     id_predisposicao         INTEGER  NOT NULL , 
     nome_predisposicao       VARCHAR2 (50 CHAR)  NOT NULL , 
     orientacao_predisposicao VARCHAR2 (200 CHAR)  NOT NULL 
    ) 
;

ALTER TABLE TB_CT_PREDISPOSICAO_ESP 
    ADD CONSTRAINT tb_ct_predisposicao_pk PRIMARY KEY ( id_predisposicao ) ;

CREATE TABLE TB_CT_PRESCRICAO 
    ( 
     id_exame       INTEGER  NOT NULL , 
     id_medicamento INTEGER  NOT NULL , 
     id_consulta    INTEGER  NOT NULL 
    ) 
;

CREATE TABLE TB_CT_RESTRICAO_ESP 
    ( 
     id_restricao         INTEGER  NOT NULL , 
     nome_restricao       VARCHAR2 (50 CHAR)  NOT NULL , 
     orientacao_restricao VARCHAR2 (200 CHAR)  NOT NULL , 
     gravidade_restricao  VARCHAR2 (5 CHAR)  NOT NULL 
    ) 
;

ALTER TABLE TB_CT_RESTRICAO_ESP 
    ADD CONSTRAINT tb_ct_gravidade_rest_ck 
    CHECK (gravidade_restricao IN ('GRAVE', 'MEDIA', 'LEVE'))
;
ALTER TABLE TB_CT_RESTRICAO_ESP 
    ADD CONSTRAINT tb_ct_restricao_pk PRIMARY KEY ( id_restricao ) ;

CREATE TABLE TB_CT_TUTOR 
    ( 
     id_tutor   INTEGER  NOT NULL , 
     id_usuario INTEGER  NOT NULL 
    ) 
;

ALTER TABLE TB_CT_TUTOR 
    ADD CONSTRAINT tb_ct_tutor_pk PRIMARY KEY ( id_tutor ) ;

CREATE TABLE TB_CT_USUARIO 
    ( 
     id_usuario   INTEGER  NOT NULL , 
     login        VARCHAR2 (10 CHAR)  NOT NULL , 
     senha        VARCHAR2 (20 CHAR)  NOT NULL , 
     cpf          CHAR (11 CHAR)  NOT NULL , 
     nome_usuario VARCHAR2 (50 CHAR)  NOT NULL , 
     sexo_usuario CHAR (1 CHAR)  NOT NULL 
    ) 
;

ALTER TABLE TB_CT_USUARIO 
    ADD CONSTRAINT TB_CT_USUARIO_CK_1 
    CHECK (sexo_usuario IN ('F', 'M'))
;
ALTER TABLE TB_CT_USUARIO 
    ADD CONSTRAINT tb_ct_usuario_pk PRIMARY KEY ( id_usuario ) ;

ALTER TABLE TB_CT_USUARIO 
    ADD CONSTRAINT tb_usuario_cpf_uc UNIQUE ( cpf ) ;

CREATE TABLE TB_CT_VETERINARIO 
    ( 
     id_veterinario INTEGER  NOT NULL , 
     id_usuario     INTEGER  NOT NULL , 
     crmv           VARCHAR2 (10 CHAR)  NOT NULL , 
     uf_crmv        CHAR (2 CHAR)  NOT NULL 
    ) 
;

ALTER TABLE TB_CT_VETERINARIO 
    ADD CONSTRAINT tb_ct_veterinario_ck 
    CHECK (uf_crmv IN ('AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA', 'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE', 'PI', 'RJ', 'RN', 'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO'))
;
ALTER TABLE TB_CT_VETERINARIO 
    ADD CONSTRAINT tb_ct_veterinario_pk PRIMARY KEY ( id_veterinario ) ;

ALTER TABLE TB_CT_VETERINARIO 
    ADD CONSTRAINT tb_ct_veterninario_crmv_uc UNIQUE ( crmv ) ;

ALTER TABLE TB_CT_CONSULTA 
    ADD CONSTRAINT tb_consulta_id_pac_fk FOREIGN KEY 
    ( 
     id_paciente
    ) 
    REFERENCES TB_CT_PACIENTE 
    ( 
     id_paciente
    ) 
;

ALTER TABLE TB_CT_CONSULTA 
    ADD CONSTRAINT tb_consulta_id_pag_fk FOREIGN KEY 
    ( 
     id_pagamento
    ) 
    REFERENCES TB_CT_PAGAMENTO 
    ( 
     id_pagamento
    ) 
;

ALTER TABLE TB_CT_CONSULTA 
    ADD CONSTRAINT tb_consulta_id_tutor_fk FOREIGN KEY 
    ( 
     id_tutor
    ) 
    REFERENCES TB_CT_TUTOR 
    ( 
     id_tutor
    ) 
;

ALTER TABLE TB_CT_CONSULTA 
    ADD CONSTRAINT tb_consulta_id_vet_fk FOREIGN KEY 
    ( 
     id_veterinario
    ) 
    REFERENCES TB_CT_VETERINARIO 
    ( 
     id_veterinario
    ) 
;

ALTER TABLE TB_CT_ALERGIA 
    ADD CONSTRAINT tb_ct_alergia_id_pac_fk FOREIGN KEY 
    ( 
     id_paciente
    ) 
    REFERENCES TB_CT_PACIENTE 
    ( 
     id_paciente
    ) 
;

ALTER TABLE TB_CT_CUIDADO 
    ADD CONSTRAINT tb_ct_cuidado_id_esp_fk FOREIGN KEY 
    ( 
     id_especie
    ) 
    REFERENCES TB_CT_ESPECIE 
    ( 
     id_especie
    ) 
;

ALTER TABLE TB_CT_CUIDADO 
    ADD CONSTRAINT tb_ct_cuidado_id_pred_fk FOREIGN KEY 
    ( 
     id_predisposicao
    ) 
    REFERENCES TB_CT_PREDISPOSICAO_ESP 
    ( 
     id_predisposicao
    ) 
;

ALTER TABLE TB_CT_CUIDADO 
    ADD CONSTRAINT tb_ct_cuidado_id_rest_fk FOREIGN KEY 
    ( 
     id_restricao
    ) 
    REFERENCES TB_CT_RESTRICAO_ESP 
    ( 
     id_restricao
    ) 
;

ALTER TABLE TB_CT_DADOS_PESSOAIS 
    ADD CONSTRAINT tb_ct_dados_pessoais_id_con_fk FOREIGN KEY 
    ( 
     id_contato
    ) 
    REFERENCES TB_CT_CONTATO 
    ( 
     id_contato
    ) 
;

ALTER TABLE TB_CT_DADOS_PESSOAIS 
    ADD CONSTRAINT tb_ct_dados_pessoais_id_end_fk FOREIGN KEY 
    ( 
     id_endereco
    ) 
    REFERENCES TB_CT_ENDERECO 
    ( 
     id_endereco
    ) 
;

ALTER TABLE TB_CT_DADOS_PESSOAIS 
    ADD CONSTRAINT tb_ct_dados_pessoais_id_usu_fk FOREIGN KEY 
    ( 
     id_usuario
    ) 
    REFERENCES TB_CT_USUARIO 
    ( 
     id_usuario
    ) 
;

ALTER TABLE TB_CT_ALERGIA 
    ADD CONSTRAINT tb_ct_medicamento_id_med_fk FOREIGN KEY 
    ( 
     id_medicamento
    ) 
    REFERENCES TB_CT_MEDICAMENTO 
    ( 
     id_medicamento
    ) 
;

ALTER TABLE TB_CT_PACIENTE 
    ADD CONSTRAINT tb_ct_paciente_id_esp_fk FOREIGN KEY 
    ( 
     id_especie
    ) 
    REFERENCES TB_CT_ESPECIE 
    ( 
     id_especie
    ) 
;

ALTER TABLE TB_CT_PET 
    ADD CONSTRAINT tb_ct_pet_id_paciente_fk FOREIGN KEY 
    ( 
     id_paciente
    ) 
    REFERENCES TB_CT_PACIENTE 
    ( 
     id_paciente
    ) 
;

ALTER TABLE TB_CT_PET 
    ADD CONSTRAINT tb_ct_pet_id_tutor_fk FOREIGN KEY 
    ( 
     id_tutor
    ) 
    REFERENCES TB_CT_TUTOR 
    ( 
     id_tutor
    ) 
;

ALTER TABLE TB_CT_PRESCRICAO 
    ADD CONSTRAINT tb_ct_prescicao_id_ex_fk FOREIGN KEY 
    ( 
     id_exame
    ) 
    REFERENCES TB_CT_EXAME 
    ( 
     id_exame
    ) 
;

ALTER TABLE TB_CT_PRESCRICAO 
    ADD CONSTRAINT tb_ct_prescicao_id_med_fk FOREIGN KEY 
    ( 
     id_medicamento
    ) 
    REFERENCES TB_CT_MEDICAMENTO 
    ( 
     id_medicamento
    ) 
;

ALTER TABLE TB_CT_PRESCRICAO 
    ADD CONSTRAINT tb_ct_prescricao_id_cons_fk FOREIGN KEY 
    ( 
     id_consulta
    ) 
    REFERENCES TB_CT_CONSULTA 
    ( 
     id_consulta
    ) 
;

ALTER TABLE TB_CT_TUTOR 
    ADD CONSTRAINT tb_ct_tutor_id_us_fk FOREIGN KEY 
    ( 
     id_usuario
    ) 
    REFERENCES TB_CT_USUARIO 
    ( 
     id_usuario
    ) 
;

ALTER TABLE TB_CT_VETERINARIO 
    ADD CONSTRAINT tb_ct_veterinario_id_us_fk FOREIGN KEY 
    ( 
     id_usuario
    ) 
    REFERENCES TB_CT_USUARIO 
    ( 
     id_usuario
    ) 
;

CREATE SEQUENCE TB_CT_AUDITORIA_DML_ID_AUDITORIA_SEQ
START WITH 1
    NOCACHE
    ORDER;


CREATE OR REPLACE TRIGGER TB_CT_AUDITORIA_DML_ID_AUDITORIA_TRG
BEFORE INSERT ON TB_CT_AUDITORIA_DML
FOR EACH ROW
WHEN (NEW.ID_AUDITORIA IS NULL)
BEGIN
    :NEW.ID_AUDITORIA := TB_CT_AUDITORIA_DML_ID_AUDITORIA_SEQ.NEXTVAL;
END;
/


CREATE SEQUENCE TB_CT_CONSULTA_id_consulta_SEQ 
START WITH 1 
    NOCACHE 
    ORDER ;

CREATE OR REPLACE TRIGGER TB_CT_CONSULTA_id_consulta_TRG 
BEFORE INSERT ON TB_CT_CONSULTA 
FOR EACH ROW 
WHEN (NEW.id_consulta IS NULL) 
BEGIN 
    :NEW.id_consulta := TB_CT_CONSULTA_id_consulta_SEQ.NEXTVAL; 
END;
/

CREATE SEQUENCE TB_CT_CONTATO_id_contato_SEQ 
START WITH 1 
    NOCACHE 
    ORDER ;

CREATE OR REPLACE TRIGGER TB_CT_CONTATO_id_contato_TRG 
BEFORE INSERT ON TB_CT_CONTATO 
FOR EACH ROW 
WHEN (NEW.id_contato IS NULL) 
BEGIN 
    :NEW.id_contato := TB_CT_CONTATO_id_contato_SEQ.NEXTVAL; 
END;
/

CREATE SEQUENCE TB_CT_ENDERECO_id_endereco_SEQ 
START WITH 1 
    NOCACHE 
    ORDER ;

CREATE OR REPLACE TRIGGER TB_CT_ENDERECO_id_endereco_TRG 
BEFORE INSERT ON TB_CT_ENDERECO 
FOR EACH ROW 
WHEN (NEW.id_endereco IS NULL) 
BEGIN 
    :NEW.id_endereco := TB_CT_ENDERECO_id_endereco_SEQ.NEXTVAL; 
END;
/

CREATE SEQUENCE TB_CT_ESPECIE_id_especie_SEQ 
START WITH 1 
    NOCACHE 
    ORDER ;

CREATE OR REPLACE TRIGGER TB_CT_ESPECIE_id_especie_TRG 
BEFORE INSERT ON TB_CT_ESPECIE 
FOR EACH ROW 
WHEN (NEW.id_especie IS NULL) 
BEGIN 
    :NEW.id_especie := TB_CT_ESPECIE_id_especie_SEQ.NEXTVAL; 
END;
/

CREATE SEQUENCE TB_CT_EXAME_id_exame_SEQ 
START WITH 1 
    NOCACHE 
    ORDER ;

CREATE OR REPLACE TRIGGER TB_CT_EXAME_id_exame_TRG 
BEFORE INSERT ON TB_CT_EXAME 
FOR EACH ROW 
WHEN (NEW.id_exame IS NULL) 
BEGIN 
    :NEW.id_exame := TB_CT_EXAME_id_exame_SEQ.NEXTVAL; 
END;
/

CREATE SEQUENCE TB_CT_LOG_ERRO_id_log_SEQ 
START WITH 1 
    NOCACHE 
    ORDER ;

CREATE OR REPLACE TRIGGER TB_CT_LOG_ERRO_id_log_TRG 
BEFORE INSERT ON TB_CT_LOG_ERRO 
FOR EACH ROW 
WHEN (NEW.id_log IS NULL) 
BEGIN 
    :NEW.id_log := TB_CT_LOG_ERRO_id_log_SEQ.NEXTVAL; 
END;
/

CREATE SEQUENCE TB_CT_MEDICAMENTO_id_medicamen 
START WITH 1 
    NOCACHE 
    ORDER ;

CREATE OR REPLACE TRIGGER TB_CT_MEDICAMENTO_id_medicamen 
BEFORE INSERT ON TB_CT_MEDICAMENTO 
FOR EACH ROW 
WHEN (NEW.id_medicamento IS NULL) 
BEGIN 
    :NEW.id_medicamento := TB_CT_MEDICAMENTO_id_medicamen.NEXTVAL; 
END;
/

CREATE SEQUENCE TB_CT_PACIENTE_id_paciente_SEQ 
START WITH 1 
    NOCACHE 
    ORDER ;

CREATE OR REPLACE TRIGGER TB_CT_PACIENTE_id_paciente_TRG 
BEFORE INSERT ON TB_CT_PACIENTE 
FOR EACH ROW 
WHEN (NEW.id_paciente IS NULL) 
BEGIN 
    :NEW.id_paciente := TB_CT_PACIENTE_id_paciente_SEQ.NEXTVAL; 
END;
/

CREATE SEQUENCE TB_CT_PAGAMENTO_id_pagamento 
START WITH 1 
    NOCACHE 
    ORDER ;

CREATE OR REPLACE TRIGGER TB_CT_PAGAMENTO_id_pagamento 
BEFORE INSERT ON TB_CT_PAGAMENTO 
FOR EACH ROW 
WHEN (NEW.id_pagamento IS NULL) 
BEGIN 
    :NEW.id_pagamento := TB_CT_PAGAMENTO_id_pagamento.NEXTVAL; 
END;
/

CREATE SEQUENCE TB_CT_PREDISPOSICAO_ESP_id_pre 
START WITH 1 
    NOCACHE 
    ORDER ;

CREATE OR REPLACE TRIGGER TB_CT_PREDISPOSICAO_ESP_id_pre 
BEFORE INSERT ON TB_CT_PREDISPOSICAO_ESP 
FOR EACH ROW 
WHEN (NEW.id_predisposicao IS NULL) 
BEGIN 
    :NEW.id_predisposicao := TB_CT_PREDISPOSICAO_ESP_id_pre.NEXTVAL; 
END;
/

CREATE SEQUENCE TB_CT_RESTRICAO_ESP_id_restric 
START WITH 1 
    NOCACHE 
    ORDER ;

CREATE OR REPLACE TRIGGER TB_CT_RESTRICAO_ESP_id_restric 
BEFORE INSERT ON TB_CT_RESTRICAO_ESP 
FOR EACH ROW 
WHEN (NEW.id_restricao IS NULL) 
BEGIN 
    :NEW.id_restricao := TB_CT_RESTRICAO_ESP_id_restric.NEXTVAL; 
END;
/

CREATE SEQUENCE TB_CT_TUTOR_id_tutor_SEQ 
START WITH 1 
    NOCACHE 
    ORDER ;

CREATE OR REPLACE TRIGGER TB_CT_TUTOR_id_tutor_TRG 
BEFORE INSERT ON TB_CT_TUTOR 
FOR EACH ROW 
WHEN (NEW.id_tutor IS NULL) 
BEGIN 
    :NEW.id_tutor := TB_CT_TUTOR_id_tutor_SEQ.NEXTVAL; 
END;
/

CREATE SEQUENCE TB_CT_USUARIO_id_usuario_SEQ 
START WITH 1 
    NOCACHE 
    ORDER ;

CREATE OR REPLACE TRIGGER TB_CT_USUARIO_id_usuario_TRG 
BEFORE INSERT ON TB_CT_USUARIO 
FOR EACH ROW 
WHEN (NEW.id_usuario IS NULL) 
BEGIN 
    :NEW.id_usuario := TB_CT_USUARIO_id_usuario_SEQ.NEXTVAL; 
END;
/

CREATE SEQUENCE TB_CT_VETERINARIO_id_veterinar 
START WITH 1 
    NOCACHE 
    ORDER ;

CREATE OR REPLACE TRIGGER TB_CT_VETERINARIO_id_veterinar 
BEFORE INSERT ON TB_CT_VETERINARIO 
FOR EACH ROW 
WHEN (NEW.id_veterinario IS NULL) 
BEGIN 
    :NEW.id_veterinario := TB_CT_VETERINARIO_id_veterinar.NEXTVAL; 
END;
/



-- Relatório do Resumo do Oracle SQL Developer Data Modeler: 
-- 
-- CREATE TABLE                            20
-- CREATE INDEX                             0
-- ALTER TABLE                             47
-- CREATE VIEW                              0
-- ALTER VIEW                               0
-- CREATE PACKAGE                           0
-- CREATE PACKAGE BODY                      0
-- CREATE PROCEDURE                         0
-- CREATE FUNCTION                          0
-- CREATE TRIGGER                          15
-- ALTER TRIGGER                            0
-- CREATE COLLECTION TYPE                   0
-- CREATE STRUCTURED TYPE                   0
-- CREATE STRUCTURED TYPE BODY              0
-- CREATE CLUSTER                           0
-- CREATE CONTEXT                           0
-- CREATE DATABASE                          0
-- CREATE DIMENSION                         0
-- CREATE DIRECTORY                         0
-- CREATE DISK GROUP                        0
-- CREATE ROLE                              0
-- CREATE ROLLBACK SEGMENT                  0
-- CREATE SEQUENCE                         15
-- CREATE MATERIALIZED VIEW                 0
-- CREATE MATERIALIZED VIEW LOG             0
-- CREATE SYNONYM                           0
-- CREATE TABLESPACE                        0
-- CREATE USER                              0
-- 
-- DROP TABLESPACE                          0
-- DROP DATABASE                            0
-- 
-- REDACTION POLICY                         0
-- 
-- ORDS DROP SCHEMA                         0
-- ORDS ENABLE SCHEMA                       0
-- ORDS ENABLE OBJECT                       0
-- 
-- ERRORS                                   0
-- WARNINGS                                 0
