package br.com.fiap.clyvovet.repository;

import br.com.fiap.clyvovet.model.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.Optional;

public interface UsuarioRepository extends JpaRepository<Usuario, Long> {

    String POR_EMAIL = """
            FROM TB_CT_USUARIO u
            JOIN TB_CT_DADOS_PESSOAIS dp ON dp.id_usuario = u.id_usuario
            JOIN TB_CT_CONTATO c ON c.id_contato = dp.id_contato
            WHERE LOWER(c.email) = LOWER(:email)""";

    // O e-mail fica em TB_CT_CONTATO, ligado ao usuário pela tabela TB_CT_DADOS_PESSOAIS.
    @Query(value = "SELECT u.* " + POR_EMAIL, nativeQuery = true)
    Optional<Usuario> findByEmail(String email);

    @Query(value = "SELECT COUNT(*) " + POR_EMAIL, nativeQuery = true)
    long contarPorEmail(String email);
}
