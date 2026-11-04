package br.com.fiap.clyvovet.model;

public enum FaseVida {

    FILHOTE,
    ADULTO,
    SENIOR;

    private static final int IDADE_MAXIMA_FILHOTE = 1;

    public static FaseVida de(Especie especie, int idade) {
        if (idade <= IDADE_MAXIMA_FILHOTE) {
            return FILHOTE;
        }
        return idade >= especie.getIdadeInicioSenior() ? SENIOR : ADULTO;
    }
}
