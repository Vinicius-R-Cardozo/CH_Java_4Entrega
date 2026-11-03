package br.com.fiap.clyvovet.exception;

import org.springframework.http.HttpStatus;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.List;

@RestControllerAdvice
public class TratadorDeErros {

    record ErroCampo(String campo, String mensagem) {}
    record Erro(String mensagem) {}
    record PedidoDeConfirmacao(String mensagem, boolean precisaConfirmar) {}

    @ExceptionHandler(MethodArgumentNotValidException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    List<ErroCampo> dadosInvalidos(MethodArgumentNotValidException excecao) {
        return excecao.getBindingResult().getFieldErrors().stream()
                .map(erro -> new ErroCampo(erro.getField(), erro.getDefaultMessage()))
                .toList();
    }

    /** Corpo que não dá para ler, por exemplo um valor fora das opções de um enum. */
    @ExceptionHandler(HttpMessageNotReadableException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    Erro corpoInvalido(HttpMessageNotReadableException excecao) {
        return new Erro("Confira os dados enviados: algum campo tem um valor que não é aceito.");
    }

    @ExceptionHandler(RegraDeNegocioException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    Erro regraDeNegocio(RegraDeNegocioException excecao) {
        return new Erro(excecao.getMessage());
    }

    @ExceptionHandler(AlergiaPrecisaDeConfirmacaoException.class)
    @ResponseStatus(HttpStatus.CONFLICT)
    PedidoDeConfirmacao alergiaPrecisaDeConfirmacao(AlergiaPrecisaDeConfirmacaoException excecao) {
        return new PedidoDeConfirmacao(excecao.getMessage(), true);
    }

    @ExceptionHandler(RecursoNaoEncontradoException.class)
    @ResponseStatus(HttpStatus.NOT_FOUND)
    Erro naoEncontrado(RecursoNaoEncontradoException excecao) {
        return new Erro(excecao.getMessage());
    }
}
