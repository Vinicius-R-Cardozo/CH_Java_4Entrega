(() => {
    if (!exigirPerfil('TUTOR')) {
        return;
    }

    const formulario = document.querySelector('#formulario');
    const id = parametro('id');
    preencherOpcoes(formulario);

    const ORDEM_DAS_ESPECIES = ['CAO', 'GATO', 'AVE', 'REPTIL', 'PEIXE', 'ANFIBIO', 'PRIMATA'];

    // As raças vêm de TB_CT_ESPECIE e são agrupadas por espécie (Cão, Gato, Ave...).
    async function carregarRacas() {
        const racas = await chamarApi('GET', 'racas');
        formulario.elements.idRaca.innerHTML = '<option value="">Selecione</option>' + ORDEM_DAS_ESPECIES
            .map(especie => [especie, racas.filter(raca => raca.especie === especie)])
            .filter(([, lista]) => lista.length > 0)
            .map(([especie, lista]) => `<optgroup label="${ROTULOS[especie]}">${lista
                .map(raca => `<option value="${raca.id}" data-porte="${raca.porte}">${escapar(raca.nome)}</option>`)
                .join('')}</optgroup>`)
            .join('');
    }

    formulario.elements.idRaca.addEventListener('change', () => {
        const porte = formulario.elements.idRaca.selectedOptions[0]?.dataset.porte;
        if (porte) {
            formulario.elements.porte.value = porte;
        }
    });

    carregarRacas()
        .then(() => {
            if (!id) {
                return;
            }
            document.querySelector('#titulo').textContent = 'Editar pet';
            document.title = 'Editar pet · Clyvo Vet';
            return chamarApi('GET', `pets/${id}`).then(pet => {
                formulario.elements.nome.value = pet.nome;
                formulario.elements.idRaca.value = pet.raca.id;
                formulario.elements.idade.value = pet.idade;
                formulario.elements.sexo.value = pet.sexo;
                formulario.elements.porte.value = pet.porte;
            });
        })
        .catch(erro => mostrarAviso(erro.message, 'erro'));

    formulario.addEventListener('submit', async evento => {
        evento.preventDefault();
        const botao = formulario.querySelector('button[type="submit"]');
        try {
            await comCarregamento(botao, () => id
                ? chamarApi('PUT', `pets/${id}`, lerFormulario(formulario))
                : chamarApi('POST', 'pets', lerFormulario(formulario)));
            avisarNaProximaPagina(id ? 'Dados do pet atualizados.' : 'Pet cadastrado com sucesso.');
            location.href = 'pets.html';
        } catch (erro) {
            mostrarErros(formulario, erro);
        }
    });
})();
