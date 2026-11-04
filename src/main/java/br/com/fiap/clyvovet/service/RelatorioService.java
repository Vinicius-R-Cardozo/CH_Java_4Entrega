package br.com.fiap.clyvovet.service;

import br.com.fiap.clyvovet.database.RelatoriosProcedures;
import br.com.fiap.clyvovet.exception.RegraDeNegocioException;
import br.com.fiap.clyvovet.model.PetDoTutor;
import org.springframework.stereotype.Service;
import tools.jackson.databind.ObjectMapper;

import java.util.List;

@Service
public class RelatorioService {

    private static final String PREFIXO_DE_ERRO = "Erro";

    private final RelatoriosProcedures relatoriosProcedures;
    private final ObjectMapper objectMapper;

    public RelatorioService(RelatoriosProcedures relatoriosProcedures, ObjectMapper objectMapper) {
        this.relatoriosProcedures = relatoriosProcedures;
        this.objectMapper = objectMapper;
    }

    public List<PetDoTutor> petsDoTutor(Long tutorId) {
        List<String> linhas = relatoriosProcedures.buscaPetsPorTutor(tutorId);
        linhas.stream()
                .filter(linha -> linha.startsWith(PREFIXO_DE_ERRO))
                .findFirst()
                .ifPresent(erro -> {
                    throw new RegraDeNegocioException(erro.replaceFirst("^Erro: ", ""));
                });
        return linhas.stream()
                .map(linha -> objectMapper.readValue(linha, PetDoTutor.class))
                .toList();
    }

    public List<String> resumoIdadePorte(String faixaEtaria, String porte) {
        List<String> linhas = relatoriosProcedures.resumoIdadePorte(faixaEtaria, porte);
        if (linhas.size() == 1 && linhas.get(0).startsWith(PREFIXO_DE_ERRO)) {
            throw new RegraDeNegocioException(linhas.get(0).replaceFirst("^Erro: ", ""));
        }
        return linhas;
    }
}
