package br.com.fiap.clyvovet.model;

import jakarta.persistence.Column;
import jakarta.persistence.Convert;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Data;

/**
 * TB_CT_ESPECIE do banco do grupo. Cada linha é uma raça (nome_especie, ex.: "Golden Retriever"),
 * com o grupo da espécie em genero ("Canis", "Felis"...) e o porte típico.
 */
@Data
@Entity
@Table(name = "TB_CT_ESPECIE")
public class Raca {

    @Id
    @Column(name = "id_especie")
    private Long id;

    @Column(name = "nome_especie")
    private String nome;

    @Convert(converter = EspecieConverter.class)
    @Column(name = "genero")
    private Especie especie;

    @Enumerated(EnumType.STRING)
    private Porte porte;
}
