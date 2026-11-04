package br.com.fiap.clyvovet.model;

import java.util.List;

public record CarteiraPet(
        Pet pet,
        List<ProximoCuidado> proximosCuidados,
        List<Agendamento> historico,
        List<AtendimentoClinico> atendimentos,
        List<CuidadoDaEspecie> cuidadosDaEspecie,
        List<AlergiaDoPet> alergias) {
}
