package br.com.fiap.clyvovet.model;

import java.time.LocalDateTime;

public record RegistroDeErro(Long id, String procedure, String usuarioBanco, LocalDateTime data, String mensagem) {
}
