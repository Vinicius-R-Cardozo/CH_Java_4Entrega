(() => {
    if (!exigirPerfil('TUTOR')) {
        return;
    }

    const formulario = document.querySelector('#formulario');
    preencherOpcoes(formulario);

    const ESPECIES_COM_VACINA = ['CAO', 'GATO'];
    let petsDoTutor = [];

    // Vacinação e vermífugo só se aplicam a cães e gatos; para as outras espécies sobra o check-up.
    function ajustarTiposAoPet() {
        const pet = petsDoTutor.find(item => String(item.id) === formulario.elements.petId.value);
        const soCheckup = pet && !ESPECIES_COM_VACINA.includes(pet.especie);
        [...formulario.elements.tipo.options].forEach(opcao => {
            opcao.disabled = soCheckup && opcao.value !== '' && opcao.value !== 'CHECKUP';
        });
        if (formulario.elements.tipo.selectedOptions[0]?.disabled) {
            formulario.elements.tipo.value = 'CHECKUP';
        }
    }

    carregarNaTela('pets', pets => {
        if (pets.length === 0) {
            document.querySelector('#sem-pets').hidden = false;
            return;
        }
        petsDoTutor = pets;
        preencherSelect(formulario.elements.petId, pets, pet => pet.id, pet => pet.nome);
        formulario.elements.petId.value = parametro('pet') ?? '';
        formulario.elements.tipo.value = parametro('tipo') ?? '';
        formulario.elements.data.value = hojeIso();
        ajustarTiposAoPet();
        formulario.hidden = false;
    });

    formulario.elements.petId.addEventListener('change', ajustarTiposAoPet);

    formulario.addEventListener('submit', async evento => {
        evento.preventDefault();
        try {
            await chamarApi('POST', 'agendamentos', lerFormulario(formulario));
            avisarNaProximaPagina('Solicitação enviada! Assim que a clínica confirmar, a situação muda aqui.');
            location.href = 'agendamentos.html';
        } catch (erro) {
            mostrarErros(formulario, erro);
        }
    });
})();
