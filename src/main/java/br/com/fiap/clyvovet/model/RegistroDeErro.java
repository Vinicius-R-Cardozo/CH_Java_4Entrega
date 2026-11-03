package br.com.fiap.clyvovet.model;

import java.time.LocalDateTime;

/** Uma linha de TB_CT_LOG_ERRO, gravada por PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG. */
public record RegistroDeErro(Long id, String procedure, String usuarioBanco, LocalDateTime data, String mensagem) {
}
