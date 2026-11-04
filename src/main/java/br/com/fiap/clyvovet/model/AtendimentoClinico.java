package br.com.fiap.clyvovet.model;

import java.time.LocalDate;

public record AtendimentoClinico(
        Long idConsulta,
        LocalDate data,
        String veterinario,
        String crmv,
        TipoPagamento pagamento,
        String observacoes,
        String orientacao,
        String medicamentos,
        String exames) {
}
