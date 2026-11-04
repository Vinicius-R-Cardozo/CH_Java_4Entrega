package br.com.fiap.clyvovet.exception;
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
