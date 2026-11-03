package br.com.fiap.clyvovet.model;

import java.util.List;

public record Pagina<T>(List<T> itens, int pagina, int totalPaginas, long totalItens) {

    public static <T> Pagina<T> de(List<T> itens, int pagina, int tamanho, long totalItens) {
        int totalPaginas = (int) Math.max(1, (totalItens + tamanho - 1) / tamanho);
        return new Pagina<>(itens, pagina, totalPaginas, totalItens);
    }
}
