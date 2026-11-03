(() => {
    const sessao = exigirPerfil('VETERINARIO');
    if (!sessao) {
        return;
    }

    const filtros = document.querySelector('#filtros');
    preencherSelect(filtros.elements.uf, UFS, uf => uf, uf => uf, 'Todos');

    function parametrosDaBusca() {
        const { faixa, uf } = lerFormulario(filtros);
        const parametros = new URLSearchParams();
        if (faixa) parametros.set('faixa', faixa);
        if (uf) parametros.set('uf', uf);
        return parametros.toString();
    }

    function formatarTelefone(telefone) {
        return telefone ? `(${telefone.slice(0, 2)}) ${telefone.slice(2, 7)}-${telefone.slice(7)}` : '—';
    }

    function exibir(pets) {
        const tutores = new Set(pets.map(pet => pet.idTutor)).size;
        document.querySelector('#resumo').textContent = pets.length === 0 ? ''
            : `${pets.length} pets de ${tutores} tutores neste público.`;
        renderizarTabela(document.querySelector('#lista'), pets, 'Nenhum pet encontrado para esse público.',
            ['Pet', 'Idade', 'Tutor', 'UF', 'Celular', 'E-mail'], pet => `
            <tr>
                <td><a href="carteira.html?pet=${pet.idPaciente}">${escapar(pet.nomePet)}</a></td>
                <td>${rotuloDaIdade(pet.idade)}</td>
                <td>${escapar(pet.nomeTutor)}</td>
                <td>${escapar(pet.uf)}</td>
                <td>${formatarTelefone(pet.telefone)}</td>
                <td><a href="mailto:${escapar(pet.email)}">${escapar(pet.email)}</a></td>
            </tr>`);
    }

    filtros.addEventListener('submit', async evento => {
        evento.preventDefault();
        const botao = filtros.querySelector('button[type="submit"]');
        try {
            exibir(await comCarregamento(botao, () => chamarApi('GET', `campanhas?${parametrosDaBusca()}`)));
        } catch (erro) {
            mostrarAviso(erro.message, 'erro');
        }
    });

    // Baixa o JSON exatamente como a função do banco devolve (é o arquivo importado no MongoDB).
    document.querySelector('#exportar').addEventListener('click', async evento => {
        try {
            await comCarregamento(evento.target, async () => {
                const resposta = await fetch(`campanhas/exportar?${parametrosDaBusca()}`,
                    { headers: { Authorization: `Basic ${sessao.credenciais}` } });
                if (!resposta.ok) {
                    throw new ErroApi(resposta.status, await resposta.json());
                }
                const link = document.createElement('a');
                link.href = URL.createObjectURL(await resposta.blob());
                link.download = 'campanha-marketing.json';
                link.click();
                URL.revokeObjectURL(link.href);
            });
        } catch (erro) {
            mostrarAviso(erro.message, 'erro');
        }
    });

    filtros.requestSubmit();
})();
