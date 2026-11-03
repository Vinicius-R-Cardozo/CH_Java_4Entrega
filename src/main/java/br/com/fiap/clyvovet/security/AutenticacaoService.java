package br.com.fiap.clyvovet.security;

import br.com.fiap.clyvovet.model.Perfil;
import br.com.fiap.clyvovet.model.Usuario;
import br.com.fiap.clyvovet.repository.TutorRepository;
import br.com.fiap.clyvovet.repository.UsuarioRepository;
import br.com.fiap.clyvovet.repository.VeterinarioRepository;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
public class AutenticacaoService implements UserDetailsService {

    private final UsuarioRepository usuarioRepository;
    private final VeterinarioRepository veterinarioRepository;
    private final TutorRepository tutorRepository;

    public AutenticacaoService(UsuarioRepository usuarioRepository, VeterinarioRepository veterinarioRepository,
                               TutorRepository tutorRepository) {
        this.usuarioRepository = usuarioRepository;
        this.veterinarioRepository = veterinarioRepository;
        this.tutorRepository = tutorRepository;
    }

    /** O perfil não é uma coluna: quem está em TB_CT_VETERINARIO é veterinário, quem está em TB_CT_TUTOR é tutor. */
    @Override
    public UserDetails loadUserByUsername(String email) {
        Usuario usuario = usuarioRepository.findByEmail(email)
                .orElseThrow(() -> new UsernameNotFoundException("Usuário não encontrado: " + email));

        return veterinarioRepository.findByUsuarioId(usuario.getId())
                .map(veterinario -> new UsuarioAutenticado(usuario, email, Perfil.VETERINARIO, veterinario.getId()))
                .or(() -> tutorRepository.findByUsuarioId(usuario.getId())
                        .map(tutor -> new UsuarioAutenticado(usuario, email, Perfil.TUTOR, tutor.getId())))
                .orElseThrow(() -> new UsernameNotFoundException("Usuário sem perfil de tutor ou veterinário: " + email));
    }
}
