package br.com.fiap.clyvovet.model;

import java.time.LocalDateTime;

/** Uma linha de TB_CT_AUDITORIA_DML, gravada pela trigger TRG_CT_AUDITORIA_PACIENTE. */
public record RegistroDeAuditoria(
        Long id,
        String tabela,
        String usuarioBanco,
        String operacao,
        LocalDateTime dataHora,
        String valoresAnteriores,
        String valoresNovos) {
}
