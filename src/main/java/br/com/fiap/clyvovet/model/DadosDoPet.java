package br.com.fiap.clyvovet.model;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

/** Cadastro e edição de pet. Os limites seguem as colunas de TB_CT_PACIENTE. */
public record DadosDoPet(
        @NotBlank(message = "Informe o nome do pet.")
        @Size(max = 50, message = "O nome deve ter no máximo 50 caracteres.")
        String nome,

        @NotNull(message = "Selecione a raça.")
        Long idRaca,

        @NotNull(message = "Informe a idade em anos (0 se tiver menos de 1 ano).")
        @Min(value = 0, message = "A idade não pode ser negativa.")
        @Max(value = 40, message = "Confira a idade informada.")
        Integer idade,

        @NotNull(message = "Selecione o sexo.")
        Sexo sexo,

        @NotNull(message = "Selecione o porte.")
        Porte porte) {
}
