package br.com.fiap.clyvovet.controller;

import br.com.fiap.clyvovet.model.Pagina;
import br.com.fiap.clyvovet.model.RegistroDeAuditoria;
import br.com.fiap.clyvovet.model.RegistroDeErro;
import br.com.fiap.clyvovet.repository.AuditoriaRepository;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("auditoria")
public class AuditoriaController {

    private static final int ITENS_POR_PAGINA = 15;

    private final AuditoriaRepository auditoriaRepository;

    public AuditoriaController(AuditoriaRepository auditoriaRepository) {
        this.auditoriaRepository = auditoriaRepository;
    }

    @GetMapping("operacoes")
    Pagina<RegistroDeAuditoria> operacoes(@RequestParam(defaultValue = "0") int pagina) {
        return auditoriaRepository.listarOperacoes(Math.max(pagina, 0), ITENS_POR_PAGINA);
    }

    @GetMapping("erros")
    Pagina<RegistroDeErro> erros(@RequestParam(defaultValue = "0") int pagina) {
        return auditoriaRepository.listarErros(Math.max(pagina, 0), ITENS_POR_PAGINA);
    }
}
