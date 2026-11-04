package br.com.fiap.clyvovet.model;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;

public record CadastroDeTutor(
        @NotBlank(message = "Informe seu nome.")
        @Size(max = 50, message = "O nome deve ter no máximo 50 caracteres.")
        String nome,

        @NotBlank(message = "Informe o CPF.")
        @Pattern(regexp = "\\d{11}", message = "Digite os 11 números do CPF, sem pontos ou traço.")
        String cpf,

        @NotNull(message = "Selecione o sexo.")
        Sexo sexo,

        @NotBlank(message = "Escolha um login.")
        @Size(max = 10, message = "O login deve ter no máximo 10 caracteres.")
        String login,

        @NotBlank(message = "Informe o e-mail.")
        @Email(message = "Informe um e-mail válido.")
        @Size(max = 50, message = "O e-mail deve ter no máximo 50 caracteres.")
        String email,

        @NotBlank(message = "Informe o celular.")
        @Pattern(regexp = "\\d{11}", message = "Digite DDD + número, só os 11 números.")
        String telefone,

        @NotBlank(message = "Crie uma senha.")
        @Size(min = 6, max = 40, message = "A senha deve ter entre 6 e 40 caracteres.")
        String senha,

        @NotBlank(message = "Informe o CEP.")
        @Pattern(regexp = "\\d{8}", message = "Digite os 8 números do CEP.")
        String cep,

        @NotBlank(message = "Informe a rua.")
        @Size(max = 100, message = "A rua deve ter no máximo 100 caracteres.")
        String logradouro,

        @NotNull(message = "Informe o número.")
        @Min(value = 1, message = "Informe o número.")
        @Max(value = 999999, message = "Confira o número.")
        Integer numero,

        @Size(max = 50, message = "O complemento deve ter no máximo 50 caracteres.")
        String complemento,

        @NotBlank(message = "Informe a cidade.")
        @Size(max = 60, message = "A cidade deve ter no máximo 60 caracteres.")
        String cidade,

        @NotBlank(message = "Selecione a UF.")
        @Pattern(regexp = "[A-Z]{2}", message = "Selecione a UF.")
        String uf) {
}
