package br.com.fiap.clyvovet.model;

import jakarta.persistence.Column;
import jakarta.persistence.Convert;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Data;

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
