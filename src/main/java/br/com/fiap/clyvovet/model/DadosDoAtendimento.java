package br.com.fiap.clyvovet.model;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

/**
 * Registro do atendimento pelo veterinário. Vira pagamento, consulta e prescrição no banco do grupo;
 * os limites seguem TB_CT_CONSULTA (observacoes 100, orientacao_consulta 200).
 */
public record DadosDoAtendimento(
        @NotNull(message = "Selecione a forma de pagamento.")
        TipoPagamento pagamento,

        @NotBlank(message = "Descreva o que foi realizado no atendimento.")
        @Size(max = 100, message = "A observação deve ter no máximo 100 caracteres.")
        String observacao,

        @NotBlank(message = "Escreva a orientação para o tutor.")
        @Size(max = 200, message = "A orientação deve ter no máximo 200 caracteres.")
        String orientacao,

        Long idMedicamento,

        Long idExame,

        /** true quando o veterinário confirma a prescrição apesar de uma alergia MEDIA ou LEVE. */
        Boolean confirmarAlergia) {

    public boolean alergiaConfirmada() {
        return Boolean.TRUE.equals(confirmarAlergia);
    }
}
