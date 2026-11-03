package br.com.fiap.clyvovet.controller;

import br.com.fiap.clyvovet.model.ItemDeCatalogo;
import br.com.fiap.clyvovet.model.Raca;
import br.com.fiap.clyvovet.model.Tutor;
import br.com.fiap.clyvovet.repository.CatalogoRepository;
import br.com.fiap.clyvovet.repository.RacaRepository;
import br.com.fiap.clyvovet.repository.TutorRepository;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/** Listas de apoio para os formulários (raças, medicamentos, exames e tutores). */
@RestController
public class CatalogoController {

    private final RacaRepository racaRepository;
    private final CatalogoRepository catalogoRepository;
    private final TutorRepository tutorRepository;

    public CatalogoController(RacaRepository racaRepository, CatalogoRepository catalogoRepository,
                              TutorRepository tutorRepository) {
        this.racaRepository = racaRepository;
        this.catalogoRepository = catalogoRepository;
        this.tutorRepository = tutorRepository;
    }

    @GetMapping("racas")
    List<Raca> racas() {
        return racaRepository.findAllByOrderByNome();
    }

    @GetMapping("medicamentos")
    List<ItemDeCatalogo> medicamentos() {
        return catalogoRepository.listarMedicamentos();
    }

    @GetMapping("exames")
    List<ItemDeCatalogo> exames() {
        return catalogoRepository.listarExames();
    }

    @GetMapping("tutores")
    List<Tutor> tutores() {
        return tutorRepository.findAllByOrderByUsuarioNome();
    }
}
