package br.com.fiap.clyvovet.service;

import br.com.fiap.clyvovet.database.CadastroProcedures;
import br.com.fiap.clyvovet.exception.RegraDeNegocioException;
import br.com.fiap.clyvovet.model.CadastroDeTutor;
import br.com.fiap.clyvovet.repository.UsuarioRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class CadastroTutorService {

    private final CadastroProcedures cadastroProcedures;
    private final UsuarioRepository usuarioRepository;
    private final PasswordEncoder passwordEncoder;

    public CadastroTutorService(CadastroProcedures cadastroProcedures, UsuarioRepository usuarioRepository,
                                PasswordEncoder passwordEncoder) {
        this.cadastroProcedures = cadastroProcedures;
        this.usuarioRepository = usuarioRepository;
        this.passwordEncoder = passwordEncoder;
    }

    /**
     * Cria a conta do tutor pelas procedures do PKG_CT_CADASTRO, na ordem das chaves estrangeiras:
     * endereço → contato → usuário → dados pessoais (liga os três) → tutor.
     * Tudo numa transação: um CPF repetido, por exemplo, é recusado pela PRC_INS_USUARIO (log em
     * TB_CT_LOG_ERRO) e o endereço e o contato já inseridos são desfeitos.
     * O e-mail é o login do app, então é conferido antes (no banco do grupo ele não é único).
     */
    @Transactional
    public void cadastrar(CadastroDeTutor dados) {
        String email = dados.email().strip().toLowerCase();
        if (usuarioRepository.contarPorEmail(email) > 0) {
            throw new RegraDeNegocioException("Já existe uma conta com este e-mail.");
        }

        Long enderecoId = cadastroProcedures.inserirEndereco(dados.logradouro().strip(), dados.numero(),
                vazioComoNulo(dados.complemento()), dados.cidade().strip(), dados.uf(), dados.cep());
        Long contatoId = cadastroProcedures.inserirContato(dados.telefone(), email);
        Long usuarioId = cadastroProcedures.inserirUsuario(dados.login().strip(),
                passwordEncoder.encode(dados.senha()), dados.cpf(), dados.nome().strip(), dados.sexo().name());
        cadastroProcedures.inserirDadosPessoais(contatoId, enderecoId, usuarioId);
        cadastroProcedures.inserirTutor(usuarioId);
    }

    private static String vazioComoNulo(String texto) {
        return texto == null || texto.isBlank() ? null : texto.strip();
    }
}
