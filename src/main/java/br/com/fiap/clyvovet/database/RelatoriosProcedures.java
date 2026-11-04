package br.com.fiap.clyvovet.database;

import org.springframework.stereotype.Component;

import java.util.List;

@Component
public class RelatoriosProcedures {

    private final ChamadorDePackages chamador;

    public RelatoriosProcedures(ChamadorDePackages chamador) {
        this.chamador = chamador;
    }

    public String marketingPets(String faixaEtaria, String uf) {
        return chamador.chamarFuncao("{? = call PKG_CT_RELATORIOS.FN_CT_MARKETING_PETS(?, ?)}", faixaEtaria, uf);
    }

    public List<String> buscaPetsPorTutor(Long idTutor) {
        return chamador.chamarComSaida("CALL PKG_CT_RELATORIOS.PRC_CT_BUSCA_PETS_POR_TUTOR(?)", idTutor);
    }

    public List<String> resumoIdadePorte(String faixaEtaria, String porte) {
        return chamador.chamarComSaida("CALL PKG_CT_RELATORIOS.PRC_CT_RESUMO_IDADE_PORTE(?, ?)", faixaEtaria, porte);
    }
}
