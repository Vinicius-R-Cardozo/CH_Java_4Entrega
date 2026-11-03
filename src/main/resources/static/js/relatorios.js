(() => {
    if (!exigirPerfil('VETERINARIO')) {
        return;
    }

    const formTutor = document.querySelector('#form-tutor');
    const formResumo = document.querySelector('#form-resumo');
    const saidaResumo = document.querySelector('#resumo');

    chamarApi('GET', 'tutores')
        .then(tutores => preencherSelect(formTutor.elements.idTutor, tutores, tutor => tutor.id,
            tutor => `${tutor.nome} (tutor ${tutor.id})`))
        .catch(erro => mostrarAviso(erro.message, 'erro'));

    formTutor.addEventListener('submit', async evento => {
        evento.preventDefault();
        const { idTutor } = lerFormulario(formTutor);
        const destino = document.querySelector('#pets-do-tutor');
        if (!idTutor) {
            mostrarAviso('Selecione um tutor.', 'erro');
            return;
        }
        try {
            const pets = await comCarregamento(formTutor.querySelector('button'),
                () => chamarApi('GET', `relatorios/pets-do-tutor/${idTutor}`));
            renderizarTabela(destino, pets, 'Este tutor não tem pets.', ['Pet', 'Raça', 'Idade', 'Porte'], pet => `
                <tr>
                    <td><a href="carteira.html?pet=${pet.idPaciente}">${escapar(pet.nome)}</a></td>
                    <td>${escapar(pet.raca)}</td>
                    <td>${rotuloDaIdade(pet.idade)}</td>
                    <td>${ROTULOS[pet.porte] ?? escapar(pet.porte)}</td>
                </tr>`);
        } catch (erro) {
            destino.innerHTML = `<p class="vazio">${escapar(erro.message)}</p>`;
        }
    });

    formResumo.addEventListener('submit', async evento => {
        evento.preventDefault();
        const { faixa, porte } = lerFormulario(formResumo);
        const parametros = new URLSearchParams();
        if (faixa) parametros.set('faixa', faixa);
        if (porte) parametros.set('porte', porte);
        try {
            const linhas = await comCarregamento(formResumo.querySelector('button'),
                () => chamarApi('GET', `relatorios/resumo-idade-porte?${parametros}`));
            saidaResumo.textContent = linhas.join('\n');
            saidaResumo.hidden = false;
        } catch (erro) {
            saidaResumo.hidden = true;
            mostrarAviso(erro.message, 'erro');
        }
    });
})();
