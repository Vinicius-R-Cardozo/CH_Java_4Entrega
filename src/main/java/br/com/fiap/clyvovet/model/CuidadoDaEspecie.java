package br.com.fiap.clyvovet.model;

public record CuidadoDaEspecie(Tipo tipo, String nome, String orientacao, Gravidade gravidade) {

    public enum Tipo {
        PREDISPOSICAO,
        RESTRICAO
    }
}
