package br.com.fiap.clyvovet.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonAlias;

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
