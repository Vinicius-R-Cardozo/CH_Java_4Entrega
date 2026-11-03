package br.com.fiap.clyvovet.service;

import br.com.fiap.clyvovet.database.CadastroProcedures;
import br.com.fiap.clyvovet.exception.AlergiaPrecisaDeConfirmacaoException;
import br.com.fiap.clyvovet.exception.RegraDeNegocioException;
import br.com.fiap.clyvovet.model.AlergiaDoPet;
import br.com.fiap.clyvovet.model.Gravidade;
import br.com.fiap.clyvovet.model.Pet;
import br.com.fiap.clyvovet.repository.CatalogoRepository;
import br.com.fiap.clyvovet.repository.ProntuarioRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Service
public class AlergiaService {

    private final ProntuarioRepository prontuarioRepository;
    private final CatalogoRepository catalogoRepository;
    private final CadastroProcedures cadastroProcedures;

    public AlergiaService(ProntuarioRepository prontuarioRepository, CatalogoRepository catalogoRepository,
                          CadastroProcedures cadastroProcedures) {
        this.prontuarioRepository = prontuarioRepository;
        this.catalogoRepository = catalogoRepository;
        this.cadastroProcedures = cadastroProcedures;
    }

    /**
     * Alergia GRAVE bloqueia a prescrição. MEDIA ou LEVE só passa se o veterinário confirmar na tela.
     * É a mesma preocupação do script de carga do grupo, que pula o medicamento quando o pet é alérgico.
     */
    public void verificarPrescricao(Pet pet, Long medicamentoId, boolean confirmado) {
        if (CatalogoRepository.NENHUM_MEDICAMENTO == medicamentoId) {
            return;
        }
        String medicamento = catalogoRepository.nomeDoMedicamento(medicamentoId)
                .orElseThrow(() -> new RegraDeNegocioException("Selecione um medicamento da lista."));

        Optional<AlergiaDoPet> alergia = prontuarioRepository.listarAlergias(pet.getId()).stream()
                .filter(registro -> registro.idMedicamento().equals(medicamentoId))
                .findFirst();
        if (alergia.isEmpty()) {
            return;
        }
        if (alergia.get().gravidade() == Gravidade.GRAVE) {
            throw new RegraDeNegocioException("%s tem alergia grave a %s. Escolha outro medicamento."
                    .formatted(pet.getNome(), medicamento));
        }
        if (!confirmado) {
            throw new AlergiaPrecisaDeConfirmacaoException(
                    "%s tem alergia %s a %s. Deseja prescrever mesmo assim?"
                            .formatted(pet.getNome(), alergia.get().gravidade() == Gravidade.MEDIA ? "média" : "leve",
                                    medicamento));
        }
    }

    @Transactional
    public void registrar(Pet pet, Long medicamentoId, Gravidade gravidade) {
        String medicamento = catalogoRepository.nomeDoMedicamento(medicamentoId)
                .filter(nome -> CatalogoRepository.NENHUM_MEDICAMENTO != medicamentoId)
                .orElseThrow(() -> new RegraDeNegocioException("Selecione um medicamento da lista."));
        boolean jaRegistrada = prontuarioRepository.listarAlergias(pet.getId()).stream()
                .anyMatch(registro -> registro.idMedicamento().equals(medicamentoId));
        if (jaRegistrada) {
            throw new RegraDeNegocioException("A alergia de %s a %s já está registrada.".formatted(pet.getNome(), medicamento));
        }
        cadastroProcedures.inserirAlergia(pet.getId(), medicamentoId, gravidade.name());
    }
}
