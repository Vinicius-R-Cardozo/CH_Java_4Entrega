package br.com.fiap.clyvovet.model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.JoinTable;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.Table;
import lombok.Data;

@Data
@Entity
@Table(name = "TB_CT_PACIENTE")
public class Pet {

    @Id
    @Column(name = "id_paciente")
    private Long id;

    @Column(name = "nome_paciente")
    private String nome;

    @ManyToOne(optional = false)
    @JoinColumn(name = "id_especie")
    private Raca raca;

    @Column(name = "idade_paciente")
    private Integer idade;

    @Enumerated(EnumType.STRING)
    @Column(name = "sexo_paciente")
    private Sexo sexo;

    @Enumerated(EnumType.STRING)
    @Column(name = "porte_paciente")
    private Porte porte;

    @ManyToOne
    @JoinTable(name = "TB_CT_PET",
            joinColumns = @JoinColumn(name = "id_paciente"),
            inverseJoinColumns = @JoinColumn(name = "id_tutor"))
    private Tutor tutor;

    public Especie getEspecie() {
        return raca.getEspecie();
    }

    public FaseVida getFaseVida() {
        return FaseVida.de(getEspecie(), idade);
    }
}
