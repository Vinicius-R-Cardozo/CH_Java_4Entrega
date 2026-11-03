package br.com.fiap.clyvovet.model;

import java.time.LocalDate;

/** Uma linha de TB_CT_CONSULTA com veterinário, pagamento e o que foi prescrito (TB_CT_PRESCRICAO). */
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
