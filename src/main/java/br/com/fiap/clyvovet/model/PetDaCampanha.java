package br.com.fiap.clyvovet.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonAlias;

/** Um item do JSON de PKG_CT_RELATORIOS.FN_CT_MARKETING_PETS: lê os nomes do package e a API devolve em camelCase. */
@JsonIgnoreProperties(ignoreUnknown = true)
public record PetDaCampanha(
        @JsonAlias("id_paciente") Long idPaciente,
        @JsonAlias("nome_pet") String nomePet,
        @JsonAlias("idade") Integer idade,
        @JsonAlias("id_tutor") Long idTutor,
        @JsonAlias("nome_tutor") String nomeTutor,
        @JsonAlias("uf") String uf,
        @JsonAlias("telefone") String telefone,
        @JsonAlias("email") String email) {
}
