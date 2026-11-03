(() => {
    if (!exigirPerfil('VETERINARIO')) {
        return;
    }

    const lista = document.querySelector('#lista');
    const paginacao = document.querySelector('#paginacao');
    let abaAtual = 'operacoes';
    let paginaAtual = 0;

    const ABAS = {
        operacoes: {
            vazio: 'Nenhuma operação registrada ainda. Cadastre, edite ou exclua um pet para ver a trigger em ação.',
            colunas: ['Data e hora', 'Operação', 'Usuário do banco', 'Antes', 'Depois'],
            linha: registro => `
                <tr>
                    <td>${formatarDataHora(registro.dataHora)}</td>
                    <td><span class="selo selo-${registro.operacao.toLowerCase()}">${registro.operacao}</span></td>
                    <td>${escapar(registro.usuarioBanco)}</td>
                    <td class="texto-tecnico">${escapar(registro.valoresAnteriores) || '—'}</td>
                    <td class="texto-tecnico">${escapar(registro.valoresNovos) || '—'}</td>
                </tr>`
        },
        erros: {
            vazio: 'Nenhum erro registrado pelas procedures.',
            colunas: ['Data e hora', 'Procedure', 'Usuário do banco', 'Mensagem'],
            linha: registro => `
                <tr>
                    <td>${formatarDataHora(registro.data)}</td>
                    <td class="texto-tecnico">${escapar(registro.procedure)}</td>
                    <td>${escapar(registro.usuarioBanco)}</td>
                    <td>${escapar(registro.mensagem)}</td>
                </tr>`
        }
    };

    function exibir(pagina) {
        const aba = ABAS[abaAtual];
        renderizarTabela(lista, pagina.itens, aba.vazio, aba.colunas, aba.linha);
        paginacao.innerHTML = pagina.totalItens === 0 ? '' : `
            <button type="button" class="botao botao-secundario" data-pagina="${pagina.pagina - 1}"
                ${pagina.pagina === 0 ? 'disabled' : ''}>Anterior</button>
            <span>Página ${pagina.pagina + 1} de ${pagina.totalPaginas} · ${pagina.totalItens} registros</span>
            <button type="button" class="botao botao-secundario" data-pagina="${pagina.pagina + 1}"
                ${pagina.pagina + 1 >= pagina.totalPaginas ? 'disabled' : ''}>Próxima</button>`;
    }

    function carregar() {
        carregarNaTela(`auditoria/${abaAtual}?pagina=${paginaAtual}`, exibir);
    }

    document.querySelector('.abas').addEventListener('click', evento => {
        const aba = evento.target.dataset.aba;
        if (!aba) {
            return;
        }
        document.querySelectorAll('.aba').forEach(botao => {
            botao.classList.toggle('ativa', botao.dataset.aba === aba);
            botao.setAttribute('aria-selected', botao.dataset.aba === aba);
        });
        abaAtual = aba;
        paginaAtual = 0;
        carregar();
    });

    paginacao.addEventListener('click', evento => {
        if (evento.target.dataset.pagina !== undefined) {
            paginaAtual = Number(evento.target.dataset.pagina);
            carregar();
        }
    });

    carregar();
})();
