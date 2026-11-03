(() => {
    const sessao = exigirPerfil('TUTOR', 'VETERINARIO');
    if (!sessao) {
        return;
    }

    const petId = parametro('pet');
    const ehTutor = sessao.perfil === 'TUTOR';
    const caminhoDaCarteira = ehTutor ? `pets/${petId}/carteira` : `pacientes/${petId}/carteira`;
    const formularioAlergia = document.querySelector('#formulario-alergia');

    function acaoDoTutor(cuidado) {
        if (cuidado.agendado) {
            return '<span class="selo selo-confirmado">Agendado</span>';
        }
        return `<a class="botao" href="agendamento-form.html?pet=${petId}&tipo=${cuidado.tipo}">Agendar</a>`;
    }

    function exibirCabecalho(pet) {
        document.title = `${pet.nome} · Clyvo Vet`;
        document.querySelector('#nome-pet').textContent = pet.nome;
        document.querySelector('#detalhes-pet').textContent = [ROTULOS[pet.especie], pet.raca.nome,
            ROTULOS[pet.sexo], rotuloDaIdade(pet.idade), ROTULOS[pet.faseVida], `porte ${ROTULOS[pet.porte].toLowerCase()}`]
            .join(' · ');
        if (!ehTutor) {
            document.querySelector('#tutor-pet').textContent = `Tutor: ${pet.tutor?.nome ?? '—'}`;
        }
    }

    function exibirAlergias(alergias) {
        const graves = alergias.filter(alergia => alergia.gravidade === 'GRAVE');
        document.querySelector('#alerta-alergias').innerHTML = graves.length === 0 ? '' : `
            <p class="aviso aviso-erro"><strong>Atenção:</strong> alergia grave a
            ${graves.map(alergia => escapar(alergia.medicamento)).join(', ')}.</p>`;
        renderizarTabela(document.querySelector('#alergias'), alergias, 'Nenhuma alergia registrada.',
            ['Medicamento', 'Gravidade'], alergia => `
            <tr>
                <td>${escapar(alergia.medicamento)}</td>
                <td><span class="selo selo-gravidade-${alergia.gravidade.toLowerCase()}">${ROTULOS[alergia.gravidade]}</span></td>
            </tr>`);
    }

    function exibirCuidadosDaEspecie(cuidados) {
        const elemento = document.querySelector('#cuidados-especie');
        if (cuidados.length === 0) {
            elemento.innerHTML = '<p class="vazio">Nenhuma orientação específica cadastrada para esta raça.</p>';
            return;
        }
        elemento.innerHTML = `<div class="grade-cartoes">${cuidados.map(cuidado => `
            <article class="cartao cartao-${cuidado.tipo.toLowerCase()}">
                <p class="cartao-rotulo">${ROTULOS[cuidado.tipo]}${cuidado.gravidade
                    ? ` · <span class="selo selo-gravidade-${cuidado.gravidade.toLowerCase()}">${ROTULOS[cuidado.gravidade]}</span>` : ''}</p>
                <h3>${escapar(cuidado.nome)}</h3>
                <p>${escapar(cuidado.orientacao)}</p>
            </article>`).join('')}</div>`;
    }

    function exibir(carteira) {
        exibirCabecalho(carteira.pet);

        const colunas = ['Cuidado', 'Última vez', 'Previsto para', 'Situação'];
        renderizarTabela(document.querySelector('#proximos'), carteira.proximosCuidados, '',
            ehTutor ? [...colunas, ''] : colunas, cuidado => `
            <tr>
                <td>${ROTULOS[cuidado.tipo]}</td>
                <td>${formatarData(cuidado.ultimaRealizacao)}</td>
                <td>${cuidado.dataPrevista ? formatarData(cuidado.dataPrevista) : 'Ainda não realizado'}</td>
                <td>${selo(cuidado.situacao)}</td>
                ${ehTutor ? `<td class="acoes">${acaoDoTutor(cuidado)}</td>` : ''}
            </tr>`);

        exibirCuidadosDaEspecie(carteira.cuidadosDaEspecie);

        renderizarTabela(document.querySelector('#atendimentos'), carteira.atendimentos,
            'Nenhuma consulta registrada na clínica.',
            ['Data', 'Veterinário', 'Orientação', 'Medicamento', 'Exame'], atendimento => `
            <tr>
                <td>${formatarData(atendimento.data)}</td>
                <td>${escapar(atendimento.veterinario)}<br><small>CRMV ${escapar(atendimento.crmv)}</small></td>
                <td>${escapar(atendimento.orientacao)}${atendimento.observacoes
                    ? `<br><small>${escapar(atendimento.observacoes)}</small>` : ''}</td>
                <td>${escapar(atendimento.medicamentos) || '—'}</td>
                <td>${escapar(atendimento.exames) || '—'}</td>
            </tr>`);

        renderizarTabela(document.querySelector('#historico'), carteira.historico,
            'Nenhum cuidado preventivo registrado ainda.',
            ['Data', 'Cuidado', 'Observação da clínica'], atendimento => `
            <tr>
                <td>${formatarData(atendimento.data)}</td>
                <td>${ROTULOS[atendimento.tipo]}</td>
                <td>${escapar(atendimento.observacao)}</td>
            </tr>`);

        exibirAlergias(carteira.alergias);
    }

    // O veterinário registra alergias pela procedure PKG_CT_CADASTRO.PRC_INS_ALERGIA.
    if (!ehTutor) {
        preencherOpcoes(formularioAlergia);
        chamarApi('GET', 'medicamentos').then(medicamentos => {
            preencherSelect(formularioAlergia.elements.idMedicamento, medicamentos, item => item.id, item => item.nome);
            formularioAlergia.hidden = false;
        });
        formularioAlergia.addEventListener('submit', async evento => {
            evento.preventDefault();
            const botao = formularioAlergia.querySelector('button[type="submit"]');
            try {
                const carteira = await comCarregamento(botao,
                    () => chamarApi('POST', `pacientes/${petId}/alergias`, lerFormulario(formularioAlergia)));
                limparErros(formularioAlergia);
                formularioAlergia.reset();
                exibir(carteira);
                mostrarAviso('Alergia registrada.');
            } catch (erro) {
                mostrarErros(formularioAlergia, erro);
            }
        });
    }

    carregarNaTela(caminhoDaCarteira, exibir);
})();
