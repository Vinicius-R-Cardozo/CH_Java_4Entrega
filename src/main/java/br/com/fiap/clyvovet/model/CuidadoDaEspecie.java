package br.com.fiap.clyvovet.model;

/**
 * Predisposição ou restrição ligada à espécie do pet em TB_CT_CUIDADO.
 * A gravidade só existe para restrições (TB_CT_RESTRICAO_ESP.gravidade_restricao).
 */
public record CuidadoDaEspecie(Tipo tipo, String nome, String orientacao, Gravidade gravidade) {

    public enum Tipo {
        PREDISPOSICAO,
        RESTRICAO
    }
}
