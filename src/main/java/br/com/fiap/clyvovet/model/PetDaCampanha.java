package br.com.fiap.clyvovet.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

/** Um item do JSON devolvido por PKG_CT_RELATORIOS.FN_CT_MARKETING_PETS (os nomes de campo são os do package). */
@JsonIgnoreProperties(ignoreUnknown = true)
public record PetDaCampanha(
        @JsonProperty("id_paciente") Long idPaciente,
        @JsonProperty("nome_pet") String nomePet,
        @JsonProperty("idade") Integer idade,
        @JsonProperty("id_tutor") Long idTutor,
        @JsonProperty("nome_tutor") String nomeTutor,
        @JsonProperty("uf") String uf,
        @JsonProperty("telefone") String telefone,
        @JsonProperty("email") String email) {
}
