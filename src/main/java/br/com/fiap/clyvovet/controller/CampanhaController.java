package br.com.fiap.clyvovet.controller;

import br.com.fiap.clyvovet.model.PetDaCampanha;
import br.com.fiap.clyvovet.service.CampanhaService;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("campanhas")
public class CampanhaController {

    private final CampanhaService campanhaService;

    public CampanhaController(CampanhaService campanhaService) {
        this.campanhaService = campanhaService;
    }

    @GetMapping
    List<PetDaCampanha> segmentar(@RequestParam(required = false) String faixa,
                                  @RequestParam(required = false) String uf) {
        return campanhaService.segmentar(faixa, uf);
    }

    /** Baixa o JSON gerado pela FN_CT_MARKETING_PETS (o arquivo que o grupo importa no MongoDB). */
    @GetMapping("exportar")
    ResponseEntity<String> exportar(@RequestParam(required = false) String faixa,
                                    @RequestParam(required = false) String uf) {
        return ResponseEntity.ok()
                .contentType(MediaType.APPLICATION_JSON)
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"campanha-marketing.json\"")
                .body(campanhaService.exportar(faixa, uf));
    }
}
