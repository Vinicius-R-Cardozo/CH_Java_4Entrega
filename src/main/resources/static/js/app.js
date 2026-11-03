const ROTULOS = {
    CAO: 'Cão',
    GATO: 'Gato',
    FILHOTE: 'Filhote',
    ADULTO: 'Adulto',
    SENIOR: 'Sênior',
    VACINA: 'Vacinação',
    VERMIFUGO: 'Vermífugo',
    CHECKUP: 'Check-up',
    SOLICITADO: 'Solicitado',
    CONFIRMADO: 'Confirmado',
    RECUSADO: 'Recusado',
    REALIZADO: 'Realizado',
    SEM_REGISTRO: 'Sem registro',
    ATRASADO: 'Atrasado',
    PROXIMO: 'Próximo',
    EM_DIA: 'Em dia',
    AVE: 'Ave',
    REPTIL: 'Réptil',
    PEIXE: 'Peixe',
    ANFIBIO: 'Anfíbio',
    PRIMATA: 'Primata',
    PEQUENO: 'Pequeno',
    MEDIO: 'Médio',
    GRANDE: 'Grande',
    SPD: 'Sem porte definido',
    F: 'Fêmea',
    M: 'Macho',
    PIX: 'Pix',
    CREDITO: 'Crédito',
    DEBITO: 'Débito',
    SALDO: 'Saldo',
    GRAVE: 'Grave',
    MEDIA: 'Média',
    LEVE: 'Leve',
    PREDISPOSICAO: 'Predisposição',
    RESTRICAO: 'Restrição',
    JOVEM: 'Jovem (1 a 2 anos)',
    IDOSO: 'Idoso (9 anos ou mais)',
    'FILHOTE/JOVEM': 'Filhote/Jovem (até 2 anos)'
};

const UFS = ['AC', 'AL', 'AP', 'AM', 'BA', 'CE', 'DF', 'ES', 'GO', 'MA', 'MT', 'MS', 'MG', 'PA', 'PB', 'PR', 'PE',
    'PI', 'RJ', 'RN', 'RS', 'RO', 'RR', 'SC', 'SP', 'SE', 'TO'];

const MENU = {
    TUTOR: [
        { pagina: 'pets.html', texto: 'Meus pets' },
        { pagina: 'agendamentos.html', texto: 'Agendamentos' }
    ],
    VETERINARIO: [
        { pagina: 'agenda.html', texto: 'Agenda' },
        { pagina: 'pacientes.html', texto: 'Pacientes' },
        { pagina: 'campanhas.html', texto: 'Campanhas' },
        { pagina: 'relatorios.html', texto: 'Relatórios' },
        { pagina: 'auditoria.html', texto: 'Auditoria' }
    ]
};

class ErroApi extends Error {
    constructor(status, dados) {
        super(dados?.mensagem ?? 'Não foi possível concluir a operação.');
        this.status = status;
        this.dados = dados;
    }
}

function lerSessao() {
    return JSON.parse(sessionStorage.getItem('sessao'));
}

function paginaInicial(perfil) {
    return MENU[perfil][0].pagina;
}

function codificarCredenciais(email, senha) {
    const bytes = new TextEncoder().encode(`${email}:${senha}`);
    return btoa(String.fromCharCode(...bytes));
}

function sair() {
    sessionStorage.removeItem('sessao');
    location.href = 'index.html';
}

async function chamarApi(metodo, caminho, corpo, credenciais = lerSessao()?.credenciais) {
    const cabecalhos = { 'Accept': 'application/json', 'Content-Type': 'application/json' };
    if (credenciais) {
        cabecalhos.Authorization = `Basic ${credenciais}`;
    }
    const resposta = await fetch(caminho, {
        method: metodo,
        headers: cabecalhos,
        body: corpo === undefined ? undefined : JSON.stringify(corpo)
    });

    if (resposta.status === 401 && lerSessao()) {
        sair();
    }

    const texto = await resposta.text();
    const dados = texto ? JSON.parse(texto) : null;
    if (!resposta.ok) {
        throw new ErroApi(resposta.status, dados);
    }
    return dados;
}

function carregarNaTela(caminho, exibir) {
    return chamarApi('GET', caminho)
        .then(exibir)
        .catch(erro => mostrarAviso(erro.message, 'erro'));
}

function escapar(texto) {
    const elemento = document.createElement('span');
    elemento.textContent = texto ?? '';
    return elemento.innerHTML;
}

function formatarData(dataIso) {
    if (!dataIso) {
        return '—';
    }
    const [ano, mes, dia] = dataIso.split('-');
    return `${dia}/${mes}/${ano}`;
}

function formatarDataHora(dataHoraIso) {
    if (!dataHoraIso) {
        return '—';
    }
    const [data, hora] = dataHoraIso.split('T');
    return `${formatarData(data)} ${hora.slice(0, 5)}`;
}

function hojeIso() {
    const agora = new Date();
    agora.setMinutes(agora.getMinutes() - agora.getTimezoneOffset());
    return agora.toISOString().slice(0, 10);
}

function parametro(nome) {
    return new URLSearchParams(location.search).get(nome);
}

function selo(valor) {
    return `<span class="selo selo-${valor.toLowerCase()}">${ROTULOS[valor]}</span>`;
}

function mostrarAviso(texto, tipo = 'sucesso') {
    document.querySelector('#avisos').innerHTML = `<p class="aviso aviso-${tipo}">${escapar(texto)}</p>`;
}

function avisarNaProximaPagina(texto) {
    sessionStorage.setItem('aviso', texto);
}

function mostrarAvisoPendente() {
    const aviso = sessionStorage.getItem('aviso');
    if (aviso) {
        sessionStorage.removeItem('aviso');
        mostrarAviso(aviso);
    }
}

function montarMenu(sessao) {
    const paginaAtual = location.pathname.split('/').pop();
    const links = MENU[sessao.perfil]
        .map(item => `<a href="${item.pagina}"${item.pagina === paginaAtual ? ' class="ativo" aria-current="page"' : ''}>${item.texto}</a>`)
        .join('');

    document.querySelector('.topo').innerHTML = `
        <a class="marca" href="${paginaInicial(sessao.perfil)}">Clyvo Vet</a>
        <nav>${links}</nav>
        <div class="sair">
            <span>${escapar(sessao.nome)}</span>
            <button type="button" class="botao botao-contorno-claro">Sair</button>
        </div>`;
    document.querySelector('.sair button').addEventListener('click', sair);
}

function exigirPerfil(...perfis) {
    const sessao = lerSessao();
    if (!sessao) {
        location.href = 'index.html';
        return null;
    }

    montarMenu(sessao);
    if (!perfis.includes(sessao.perfil)) {
        document.querySelector('main').innerHTML = `
            <h1>Acesso negado</h1>
            <p class="subtitulo">Seu perfil não tem permissão para acessar esta página.</p>
            <p><a class="botao" href="${paginaInicial(sessao.perfil)}">Voltar ao início</a></p>`;
        return null;
    }

    mostrarAvisoPendente();
    return sessao;
}

function renderizarTabela(elemento, itens, mensagemVazia, colunas, montarLinha) {
    if (itens.length === 0) {
        elemento.innerHTML = `<p class="vazio">${mensagemVazia}</p>`;
        return;
    }
    elemento.innerHTML = `
        <div class="tabela">
            <table>
                <thead><tr>${colunas.map(coluna => `<th>${coluna}</th>`).join('')}</tr></thead>
                <tbody>${itens.map(montarLinha).join('')}</tbody>
            </table>
        </div>`;
}

/** Monta as opções de um select a partir de uma lista (ex.: raças, medicamentos). */
function preencherSelect(select, itens, valor, texto, primeiraOpcao = 'Selecione') {
    const opcoes = itens
        .map(item => `<option value="${escapar(String(valor(item)))}">${escapar(texto(item))}</option>`)
        .join('');
    select.innerHTML = `<option value="">${primeiraOpcao}</option>${opcoes}`;
}

/** Desabilita o botão e mostra "Aguarde..." enquanto a ação roda. */
async function comCarregamento(botao, acao) {
    const textoOriginal = botao.textContent;
    botao.disabled = true;
    botao.textContent = 'Aguarde...';
    try {
        return await acao();
    } finally {
        botao.disabled = false;
        botao.textContent = textoOriginal;
    }
}

function rotuloDaIdade(idade) {
    if (idade === 0) {
        return 'menos de 1 ano';
    }
    return idade === 1 ? '1 ano' : `${idade} anos`;
}

function preencherOpcoes(formulario) {
    formulario.querySelectorAll('select[data-opcoes]').forEach(select => {
        const opcoes = select.dataset.opcoes
            .split(',')
            .map(valor => `<option value="${valor}">${ROTULOS[valor]}</option>`)
            .join('');
        select.innerHTML = `<option value="">Selecione</option>${opcoes}`;
    });
}

function lerFormulario(formulario) {
    const dados = Object.fromEntries(new FormData(formulario));
    Object.keys(dados).forEach(campo => {
        if (dados[campo] === '') {
            dados[campo] = null;
        }
    });
    return dados;
}

function limparErros(formulario) {
    document.querySelector('#avisos').innerHTML = '';
    formulario.querySelectorAll('[data-erro]').forEach(elemento => elemento.textContent = '');
    formulario.querySelectorAll('.campo-invalido').forEach(campo => campo.classList.remove('campo-invalido'));
}

function mostrarErros(formulario, erro) {
    limparErros(formulario);
    if (!Array.isArray(erro.dados)) {
        mostrarAviso(erro.message, 'erro');
        return;
    }
    erro.dados.forEach(({ campo, mensagem }) => {
        const destino = formulario.querySelector(`[data-erro="${campo}"]`);
        if (!destino) {
            mostrarAviso(mensagem, 'erro');
            return;
        }
        destino.textContent = mensagem;
        formulario.elements[campo]?.classList.add('campo-invalido');
    });
}
