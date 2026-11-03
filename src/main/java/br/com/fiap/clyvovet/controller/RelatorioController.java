package br.com.fiap.clyvovet.controller;

import br.com.fiap.clyvovet.model.PetDoTutor;
import br.com.fiap.clyvovet.service.RelatorioService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("relatorios")
public class RelatorioController {

    private final RelatorioService relatorioService;

    public RelatorioController(RelatorioService relatorioService) {
        this.relatorioService = relatorioService;
    }

    @GetMapping("pets-do-tutor/{idTutor}")
    List<PetDoTutor> petsDoTutor(@PathVariable Long idTutor) {
        return relatorioService.petsDoTutor(idTutor);
    }

    @GetMapping("resumo-idade-porte")
    List<String> resumoIdadePorte(@RequestParam(required = false) String faixa,
                                  @RequestParam(required = false) String porte) {
        return relatorioService.resumoIdadePorte(faixa, porte);
    }
}
