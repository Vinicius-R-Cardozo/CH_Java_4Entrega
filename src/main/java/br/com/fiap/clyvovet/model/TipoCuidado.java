package br.com.fiap.clyvovet.model;

public enum TipoCuidado {

    VACINA("Vacinação", 30, 365, 365),
    VERMIFUGO("Vermífugo", 30, 90, 90),
    CHECKUP("Check-up", 90, 365, 180);

    private final String descricao;
    private final int intervaloFilhote;
    private final int intervaloAdulto;
    private final int intervaloSenior;

    TipoCuidado(String descricao, int intervaloFilhote, int intervaloAdulto, int intervaloSenior) {
        this.descricao = descricao;
        this.intervaloFilhote = intervaloFilhote;
        this.intervaloAdulto = intervaloAdulto;
        this.intervaloSenior = intervaloSenior;
    }

    public int intervaloEmDias(FaseVida faseVida) {
        return switch (faseVida) {
            case FILHOTE -> intervaloFilhote;
            case ADULTO -> intervaloAdulto;
            case SENIOR -> intervaloSenior;
        };
    }

    public String getDescricao() {
        return descricao;
    }

    /** Cães e gatos seguem os três cuidados; as demais espécies, só o check-up. */
    public boolean aplicaA(Especie especie) {
        return this == CHECKUP || especie.temProtocoloDeVacina();
    }
}
