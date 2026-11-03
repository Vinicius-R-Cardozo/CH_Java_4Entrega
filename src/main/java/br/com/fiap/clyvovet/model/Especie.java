package br.com.fiap.clyvovet.model;

import java.util.Arrays;

/** Grupo da espécie, guardado na coluna TB_CT_ESPECIE.genero do banco do grupo. */
public enum Especie {

    CAO("Canis", 7),
    GATO("Felis", 10),
    AVE("Ave", 8),
    REPTIL("Reptil", 8),
    PEIXE("Peixe", 8),
    ANFIBIO("Anfibio", 8),
    PRIMATA("Primata", 8);

    private final String genero;
    private final int idadeInicioSenior;

    Especie(String genero, int idadeInicioSenior) {
        this.genero = genero;
        this.idadeInicioSenior = idadeInicioSenior;
    }

    public String getGenero() {
        return genero;
    }

    public int getIdadeInicioSenior() {
        return idadeInicioSenior;
    }

    /** Vacinação e vermífugo têm protocolo na clínica só para cães e gatos; os demais seguem com check-up. */
    public boolean temProtocoloDeVacina() {
        return this == CAO || this == GATO;
    }

    public static Especie doGenero(String genero) {
        return Arrays.stream(values())
                .filter(especie -> especie.genero.equalsIgnoreCase(genero))
                .findFirst()
                .orElseThrow(() -> new IllegalArgumentException("Gênero de espécie desconhecido: " + genero));
    }
}
