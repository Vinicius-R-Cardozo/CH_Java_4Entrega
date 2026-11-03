package br.com.fiap.clyvovet.exception;

/** Prescrição de um medicamento ao qual o pet tem alergia MEDIA ou LEVE: a tela pede confirmação do veterinário. */
public class AlergiaPrecisaDeConfirmacaoException extends RuntimeException {

    public AlergiaPrecisaDeConfirmacaoException(String mensagem) {
        super(mensagem);
    }
}
