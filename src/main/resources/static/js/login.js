(() => {
    const sessao = lerSessao();
    if (sessao) {
        location.href = paginaInicial(sessao.perfil);
        return;
    }

    const formulario = document.querySelector('#formulario');
    mostrarAvisoPendente();

    formulario.addEventListener('submit', async evento => {
        evento.preventDefault();
        const { email, senha } = lerFormulario(formulario);
        const credenciais = codificarCredenciais(email ?? '', senha ?? '');
        try {
            const usuario = await chamarApi('POST', 'login', undefined, credenciais);
            sessionStorage.setItem('sessao', JSON.stringify({ credenciais, nome: usuario.nome, perfil: usuario.perfil }));
            location.href = paginaInicial(usuario.perfil);
        } catch (erro) {
            mostrarAviso(erro.status === 401 ? 'E-mail ou senha inválidos.' : erro.message, 'erro');
        }
    });
})();
