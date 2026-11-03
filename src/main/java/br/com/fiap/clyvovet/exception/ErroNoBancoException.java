package br.com.fiap.clyvovet.exception;

/**
 * Erro registrado por uma procedure do grupo em TB_CT_LOG_ERRO. A mensagem do log vem no formato
 * "Cod: -1 - Erro: CPF ja existente no sistema (UK)."; para a tela mostramos só a parte do texto.
 */
public class ErroNoBancoException extends RegraDeNegocioException {

    private final String procedure;

    public ErroNoBancoException(String procedure, String mensagemDoLog) {
        super("Não foi possível salvar: " + textoDoErro(mensagemDoLog));
        this.procedure = procedure;
    }

    public String getProcedure() {
        return procedure;
    }

    private static String textoDoErro(String mensagemDoLog) {
        return mensagemDoLog
                .replaceFirst("^Cod: -?\\d+ - ", "")
                .replaceFirst("^Erro: ", "");
    }
}
