package br.com.fiap.clyvovet.model;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

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

        Boolean confirmarAlergia) {

    public boolean alergiaConfirmada() {
        return Boolean.TRUE.equals(confirmarAlergia);
    }
}
