package br.com.fiap.clyvovet.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.Id;
import jakarta.persistence.Table;
import lombok.Data;

@Data
@Entity
@Table(name = "TB_CT_USUARIO")
public class Usuario {

    @Id
    @Column(name = "id_usuario")
    private Long id;

    private String login;

    @JsonIgnore
    private String senha;

    @JsonIgnore
    private String cpf;

    @Column(name = "nome_usuario")
    private String nome;

    @Enumerated(EnumType.STRING)
    @Column(name = "sexo_usuario")
    private Sexo sexo;
}
