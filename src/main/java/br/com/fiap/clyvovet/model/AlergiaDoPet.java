package br.com.fiap.clyvovet.model;

/** Uma linha de TB_CT_ALERGIA com o nome do medicamento. */
public record AlergiaDoPet(Long idMedicamento, String medicamento, Gravidade gravidade) {
}
