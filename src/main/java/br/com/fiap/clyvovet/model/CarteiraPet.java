package br.com.fiap.clyvovet.model;

import java.util.List;

/**
 * Visão longitudinal do pet: próximos cuidados calculados, histórico de cuidados preventivos,
 * consultas registradas na clínica, cuidados recomendados para a espécie e alergias.
 */
public record CarteiraPet(
        Pet pet,
        List<ProximoCuidado> proximosCuidados,
        List<Agendamento> historico,
        List<AtendimentoClinico> atendimentos,
        List<CuidadoDaEspecie> cuidadosDaEspecie,
        List<AlergiaDoPet> alergias) {
}
