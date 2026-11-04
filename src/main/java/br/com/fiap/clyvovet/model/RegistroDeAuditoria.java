package br.com.fiap.clyvovet.model;

import java.time.LocalDateTime;

public record RegistroDeAuditoria(
        Long id,
        String tabela,
        String usuarioBanco,
        String operacao,
        LocalDateTime dataHora,
        String valoresAnteriores,
        String valoresNovos) {
}
