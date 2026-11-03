package br.com.fiap.clyvovet.controller;

import br.com.fiap.clyvovet.model.Agendamento;
import br.com.fiap.clyvovet.model.DadosDoAtendimento;
import br.com.fiap.clyvovet.model.TipoCuidado;
import br.com.fiap.clyvovet.security.UsuarioAutenticado;
import br.com.fiap.clyvovet.service.AgendamentoService;
import jakarta.validation.Valid;
import jakarta.validation.constraints.FutureOrPresent;
import jakarta.validation.constraints.NotNull;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("agendamentos")
public class AgendamentoController {

    private final AgendamentoService agendamentoService;

    public AgendamentoController(AgendamentoService agendamentoService) {
        this.agendamentoService = agendamentoService;
    }

    record SolicitacaoRequest(
            @NotNull(message = "Selecione o pet.")
            Long petId,

            @NotNull(message = "Selecione o tipo de cuidado.")
            TipoCuidado tipo,

            @NotNull(message = "Informe a data desejada.")
            @FutureOrPresent(message = "A data desejada não pode estar no passado.")
            LocalDate data) {}

    @GetMapping
    List<Agendamento> listarDoTutor(@AuthenticationPrincipal UsuarioAutenticado usuario) {
        return agendamentoService.listarDoTutor(usuario.getIdTutor());
    }

    @PostMapping
    @ResponseStatus(HttpStatus.CREATED)
    Agendamento solicitar(@AuthenticationPrincipal UsuarioAutenticado usuario,
                          @RequestBody @Valid SolicitacaoRequest solicitacao) {
        return agendamentoService.solicitar(usuario.getIdTutor(), solicitacao.petId(), solicitacao.tipo(), solicitacao.data());
    }

    @GetMapping("abertos")
    List<Agendamento> listarEmAberto() {
        return agendamentoService.listarEmAberto();
    }

    @GetMapping("{id}")
    Agendamento buscar(@PathVariable Long id) {
        return agendamentoService.buscar(id);
    }

    @PatchMapping("{id}/confirmar")
    Agendamento confirmar(@PathVariable Long id) {
        return agendamentoService.confirmar(id);
    }

    @PatchMapping("{id}/recusar")
    Agendamento recusar(@PathVariable Long id) {
        return agendamentoService.recusar(id);
    }

    @PatchMapping("{id}/concluir")
    Agendamento concluir(@AuthenticationPrincipal UsuarioAutenticado usuario, @PathVariable Long id,
                         @RequestBody @Valid DadosDoAtendimento atendimento) {
        return agendamentoService.concluir(id, usuario.getIdVeterinario(), atendimento);
    }
}
