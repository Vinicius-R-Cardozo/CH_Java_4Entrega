package br.com.fiap.clyvovet.database;

import org.springframework.stereotype.Component;

import java.util.List;

/** Chamadas ao PKG_CT_RELATORIOS do banco do grupo. */
@Component
public class RelatoriosProcedures {

    private final ChamadorDePackages chamador;

    public RelatoriosProcedures(ChamadorDePackages chamador) {
        this.chamador = chamador;
    }

    /** Array JSON com os pets da segmentação, ou {"erro": "..."} quando o filtro é inválido ou não há resultado. */
    public String marketingPets(String faixaEtaria, String uf) {
        return chamador.chamarFuncao("{? = call PKG_CT_RELATORIOS.FN_CT_MARKETING_PETS(?, ?)}", faixaEtaria, uf);
    }

    /** Uma linha JSON por pet, ou a linha "Erro: ..." que a procedure imprimiria no DBMS_OUTPUT. */
    public List<String> buscaPetsPorTutor(Long idTutor) {
        return chamador.chamarComSaida("CALL PKG_CT_RELATORIOS.PRC_CT_BUSCA_PETS_POR_TUTOR(?)", idTutor);
    }

    /** Relatório em texto (o mesmo que sairia no DBMS_OUTPUT). */
    public List<String> resumoIdadePorte(String faixaEtaria, String porte) {
        return chamador.chamarComSaida("CALL PKG_CT_RELATORIOS.PRC_CT_RESUMO_IDADE_PORTE(?, ?)", faixaEtaria, porte);
    }
}
