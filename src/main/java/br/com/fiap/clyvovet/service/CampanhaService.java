package br.com.fiap.clyvovet.service;

import br.com.fiap.clyvovet.database.RelatoriosProcedures;
import br.com.fiap.clyvovet.exception.RegraDeNegocioException;
import br.com.fiap.clyvovet.model.PetDaCampanha;
import org.springframework.stereotype.Service;
import tools.jackson.databind.ObjectMapper;

import java.util.Arrays;
import java.util.List;
import java.util.Map;
import java.util.Objects;

@Service
public class CampanhaService {

    private static final String SEM_RESULTADO = "Nenhum pet encontrado para os filtros informados.";

    private final RelatoriosProcedures relatoriosProcedures;
    private final ObjectMapper objectMapper;

    public CampanhaService(RelatoriosProcedures relatoriosProcedures, ObjectMapper objectMapper) {
        this.relatoriosProcedures = relatoriosProcedures;
        this.objectMapper = objectMapper;
    }

    public List<PetDaCampanha> segmentar(String faixaEtaria, String uf) {
        String json = relatoriosProcedures.marketingPets(faixaEtaria, uf);
        if (ehErro(json)) {
            String erro = String.valueOf(objectMapper.readValue(json, Map.class).get("erro"));
            if (SEM_RESULTADO.equals(erro)) {
                return List.of();
            }
            throw new RegraDeNegocioException(erro);
        }
        // Uma linha com dado faltando volta como {"erro": ...} dentro do array; essa linha é descartada.
        return Arrays.stream(objectMapper.readValue(json, PetDaCampanha[].class))
                .filter(pet -> Objects.nonNull(pet.idPaciente()))
                .toList();
    }

    /** O texto exatamente como a função devolve, para download. */
    public String exportar(String faixaEtaria, String uf) {
        String json = relatoriosProcedures.marketingPets(faixaEtaria, uf);
        if (ehErro(json)) {
            throw new RegraDeNegocioException(String.valueOf(objectMapper.readValue(json, Map.class).get("erro")));
        }
        return json;
    }

    private static boolean ehErro(String json) {
        return json == null || json.strip().startsWith("{");
    }
}
