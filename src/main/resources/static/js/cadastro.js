(() => {
    const formulario = document.querySelector('#formulario');
    preencherOpcoes(formulario);
    preencherSelect(formulario.elements.uf, UFS, uf => uf, uf => uf);

    formulario.addEventListener('submit', async evento => {
        evento.preventDefault();
        const botao = formulario.querySelector('button[type="submit"]');
        try {
            // Rota pública: vai sem credenciais. As procedures do grupo gravam endereço, contato,
            // usuário, dados pessoais e tutor numa transação só.
            const resposta = await comCarregamento(botao,
                () => chamarApi('POST', 'cadastro', lerFormulario(formulario), null));
            avisarNaProximaPagina(resposta.mensagem);
            location.href = 'index.html';
        } catch (erro) {
            mostrarErros(formulario, erro);
        }
    });
})();
