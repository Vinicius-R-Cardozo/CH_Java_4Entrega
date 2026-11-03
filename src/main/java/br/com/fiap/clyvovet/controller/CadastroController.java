package br.com.fiap.clyvovet.controller;

import br.com.fiap.clyvovet.model.CadastroDeTutor;
import br.com.fiap.clyvovet.service.CadastroTutorService;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("cadastro")
public class CadastroController {

    private final CadastroTutorService cadastroTutorService;

    public CadastroController(CadastroTutorService cadastroTutorService) {
        this.cadastroTutorService = cadastroTutorService;
    }

    record CadastroResponse(String mensagem) {}

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    CadastroResponse cadastrar(@RequestBody @Valid CadastroDeTutor cadastro) {
        cadastroTutorService.cadastrar(cadastro);
        return new CadastroResponse("Conta criada! Entre com seu e-mail e senha.");
    }
}
