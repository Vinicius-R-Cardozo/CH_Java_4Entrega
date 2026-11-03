-- TRG_CT_AUDITORIA_PACIENTE (docs/database/TRIGGER.sql e PACKAGES_CELTICSTECH.sql).
-- Mesmo nome, mesmo momento (AFTER INSERT/UPDATE/DELETE, FOR EACH ROW) e mesma regra: grava em
-- TB_CT_AUDITORIA_DML pelo PKG_CT_AUDITORIA.PRC_AUDITAR_PACIENTE. O corpo está em Java porque o H2 não roda PL/SQL.
CREATE TRIGGER TRG_CT_AUDITORIA_PACIENTE
    AFTER INSERT, UPDATE, DELETE ON TB_CT_PACIENTE
    FOR EACH ROW
    CALL 'br.com.fiap.clyvovet.database.packages.TrgCtAuditoriaPaciente';
