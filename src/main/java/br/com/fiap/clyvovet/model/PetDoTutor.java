package br.com.fiap.clyvovet.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;

/** Uma linha impressa por PKG_CT_RELATORIOS.PRC_CT_BUSCA_PETS_POR_TUTOR. */
@JsonIgnoreProperties(ignoreUnknown = true)
public record PetDoTutor(
        @JsonProperty("id_paciente") Long idPaciente,
        @JsonProperty("nome_paciente") String nome,
        @JsonProperty("especie") String raca,
        @JsonProperty("idade") Integer idade,
        @JsonProperty("porte") String porte) {
}
