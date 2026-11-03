(() => {
    if (!exigirPerfil('VETERINARIO')) {
        return;
    }

    const lista = document.querySelector('#lista');
    const busca = document.createElement('input');
    busca.type = 'search';
    busca.className = 'campo-busca';
    busca.placeholder = 'Buscar por pet, raça ou tutor';
    busca.setAttribute('aria-label', 'Buscar pacientes');
    lista.before(busca);

    let pacientes = [];

    function exibir() {
        const termo = busca.value.trim().toLowerCase();
        const filtrados = pacientes.filter(pet =>
            [pet.nome, pet.raca.nome, pet.tutor?.nome].some(texto => texto?.toLowerCase().includes(termo)));
        renderizarTabela(lista, filtrados, 'Nenhum pet encontrado.',
            ['Nome', 'Espécie', 'Raça', 'Idade', 'Fase de vida', 'Tutor'], pet => `
            <tr>
                <td><a href="carteira.html?pet=${pet.id}">${escapar(pet.nome)}</a></td>
                <td>${ROTULOS[pet.especie]}</td>
                <td>${escapar(pet.raca.nome)}</td>
                <td>${rotuloDaIdade(pet.idade)}</td>
                <td>${ROTULOS[pet.faseVida]}</td>
                <td>${escapar(pet.tutor?.nome ?? '—')}</td>
            </tr>`);
    }

    busca.addEventListener('input', exibir);
    carregarNaTela('pacientes', pets => {
        pacientes = pets;
        exibir();
    });
})();
