package br.com.fiap.clyvovet.controller;

import br.com.fiap.clyvovet.model.CarteiraPet;
import br.com.fiap.clyvovet.model.Gravidade;
import br.com.fiap.clyvovet.model.Pet;
import br.com.fiap.clyvovet.service.AlergiaService;
import br.com.fiap.clyvovet.service.CarteiraService;
import br.com.fiap.clyvovet.service.PetService;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import org.springframework.http.HttpStatus;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("pacientes")
public class PacienteController {

    private final PetService petService;
    private final CarteiraService carteiraService;
    private final AlergiaService alergiaService;

    public PacienteController(PetService petService, CarteiraService carteiraService, AlergiaService alergiaService) {
        this.petService = petService;
        this.carteiraService = carteiraService;
        this.alergiaService = alergiaService;
    }

    record AlergiaRequest(
            @NotNull(message = "Selecione o medicamento.")
            Long idMedicamento,
            @NotNull(message = "Selecione a gravidade.")
            Gravidade gravidade) {}

    @GetMapping
    List<Pet> listar() {
        return petService.listarTodos();
    }

    @GetMapping("{id}/carteira")
    CarteiraPet carteira(@PathVariable Long id) {
        return carteiraService.montar(petService.buscar(id));
    }

    @PostMapping("{id}/alergias")
    @ResponseStatus(HttpStatus.CREATED)
    CarteiraPet registrarAlergia(@PathVariable Long id, @RequestBody @Valid AlergiaRequest alergia) {
        Pet pet = petService.buscar(id);
        alergiaService.registrar(pet, alergia.idMedicamento(), alergia.gravidade());
        return carteiraService.montar(pet);
    }
}
