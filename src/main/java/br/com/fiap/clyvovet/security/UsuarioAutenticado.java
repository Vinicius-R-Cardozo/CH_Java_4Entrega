package br.com.fiap.clyvovet.security;

import br.com.fiap.clyvovet.model.Perfil;
import br.com.fiap.clyvovet.model.Usuario;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;

import java.util.Collection;
import java.util.List;

/**
 * Usuário logado. Além do id de TB_CT_USUARIO, guarda o id do perfil (id_tutor ou id_veterinario),
 * que é o que as outras tabelas do grupo referenciam.
 */
public class UsuarioAutenticado implements UserDetails {

    private final Long id;
    private final String nome;
    private final String email;
    private final String senha;
    private final Perfil perfil;
    private final Long idDoPerfil;

    public UsuarioAutenticado(Usuario usuario, String email, Perfil perfil, Long idDoPerfil) {
        this.id = usuario.getId();
        this.nome = usuario.getNome();
        this.email = email;
        this.senha = usuario.getSenha();
        this.perfil = perfil;
        this.idDoPerfil = idDoPerfil;
    }

    public Long getId() {
        return id;
    }

    public String getNome() {
        return nome;
    }

    public Perfil getPerfil() {
        return perfil;
    }

    /** id em TB_CT_TUTOR; só existe para o perfil TUTOR. */
    public Long getIdTutor() {
        return perfil == Perfil.TUTOR ? idDoPerfil : null;
    }

    /** id em TB_CT_VETERINARIO; só existe para o perfil VETERINARIO. */
    public Long getIdVeterinario() {
        return perfil == Perfil.VETERINARIO ? idDoPerfil : null;
    }

    @Override
    public Collection<? extends GrantedAuthority> getAuthorities() {
        return List.of(new SimpleGrantedAuthority("ROLE_" + perfil.name()));
    }

    @Override
    public String getPassword() {
        return senha;
    }

    @Override
    public String getUsername() {
        return email;
    }
}
