package br.com.fiap.clyvovet.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonAlias;

@JsonIgnoreProperties(ignoreUnknown = true)
public record PetDoTutor(
        @JsonAlias("id_paciente") Long idPaciente,
        @JsonAlias("nome_paciente") String nome,
        @JsonAlias("especie") String raca,
        @JsonAlias("idade") Integer idade,
        @JsonAlias("porte") String porte) {
}
