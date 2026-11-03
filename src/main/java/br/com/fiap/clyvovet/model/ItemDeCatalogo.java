package br.com.fiap.clyvovet.model;

/** Medicamento ou exame para os selects do atendimento (TB_CT_MEDICAMENTO / TB_CT_EXAME). */
public record ItemDeCatalogo(Long id, String nome, String detalhe) {
}
