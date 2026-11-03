(() => {
    if (!exigirPerfil('TUTOR')) {
        return;
    }

    const lista = document.querySelector('#lista');

    function exibir(pets) {
        renderizarTabela(lista, pets, 'Você ainda não cadastrou nenhum pet.',
            ['Nome', 'Espécie', 'Raça', 'Idade', 'Fase de vida', ''], pet => `
            <tr>
                <td><a href="carteira.html?pet=${pet.id}">${escapar(pet.nome)}</a></td>
                <td>${ROTULOS[pet.especie]}</td>
                <td>${escapar(pet.raca.nome)}</td>
                <td>${rotuloDaIdade(pet.idade)}</td>
                <td>${ROTULOS[pet.faseVida]}</td>
                <td class="acoes">
                    <a class="botao" href="carteira.html?pet=${pet.id}">Carteira</a>
                    <a class="botao botao-secundario" href="pet-form.html?id=${pet.id}">Editar</a>
                    <button type="button" class="botao botao-perigo" data-excluir="${pet.id}">Excluir</button>
                </td>
            </tr>`);
    }

    lista.addEventListener('click', async evento => {
        const id = evento.target.dataset.excluir;
        if (!id || !confirm('Excluir este pet e todo o histórico dele?')) {
            return;
        }
        try {
            await chamarApi('DELETE', `pets/${id}`);
            mostrarAviso('Pet removido.');
            await carregarNaTela('pets', exibir);
        } catch (erro) {
            mostrarAviso(erro.message, 'erro');
        }
    });

    carregarNaTela('pets', exibir);
})();
