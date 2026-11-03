(() => {
    if (!exigirPerfil('VETERINARIO')) {
        return;
    }

    const formulario = document.querySelector('#formulario');
    const id = parametro('id');
    preencherOpcoes(formulario);

    Promise.all([chamarApi('GET', 'medicamentos'), chamarApi('GET', 'exames')])
        .then(([medicamentos, exames]) => {
            preencherSelect(formulario.elements.idMedicamento, medicamentos, item => item.id, item => item.nome,
                'Nenhum medicamento');
            preencherSelect(formulario.elements.idExame, exames, item => item.id, item => `${item.nome} (${item.detalhe})`,
                'Nenhum exame');
        })
        .catch(erro => mostrarAviso(erro.message, 'erro'));

    carregarNaTela(`agendamentos/${id}`, agendamento => {
        document.querySelector('#resumo').textContent =
            `${ROTULOS[agendamento.tipo]} de ${agendamento.pet.nome} · ${formatarData(agendamento.data)}`;
        return chamarApi('GET', `pacientes/${agendamento.pet.id}/carteira`).then(carteira => {
            if (carteira.alergias.length > 0) {
                document.querySelector('#alergias-do-pet').innerHTML = `<p class="aviso aviso-alerta">
                    <strong>Alergias registradas:</strong> ${carteira.alergias
                        .map(alergia => `${escapar(alergia.medicamento)} (${ROTULOS[alergia.gravidade].toLowerCase()})`)
                        .join(', ')}.</p>`;
            }
        });
    });

    async function registrar(confirmarAlergia) {
        const dados = { ...lerFormulario(formulario), confirmarAlergia };
        return chamarApi('PATCH', `agendamentos/${id}/concluir`, dados);
    }

    formulario.addEventListener('submit', async evento => {
        evento.preventDefault();
        const botao = formulario.querySelector('button[type="submit"]');
        try {
            let agendamento;
            try {
                agendamento = await comCarregamento(botao, () => registrar(false));
            } catch (erro) {
                // 409: alergia média ou leve ao medicamento escolhido; o veterinário decide.
                if (erro.status !== 409 || !confirm(erro.message)) {
                    throw erro;
                }
                agendamento = await comCarregamento(botao, () => registrar(true));
            }
            avisarNaProximaPagina('Atendimento registrado. A carteira de cuidados foi atualizada.');
            location.href = `carteira.html?pet=${agendamento.pet.id}`;
        } catch (erro) {
            if (erro.status === 409) {
                mostrarAviso('Prescrição cancelada. Escolha outro medicamento.', 'erro');
                return;
            }
            mostrarErros(formulario, erro);
        }
    });
})();
