package br.com.fiap.clyvovet.database.packages;

import org.h2.api.ErrorCode;

import java.sql.SQLException;
import java.util.Arrays;
import java.util.Optional;

/**
 * Exceções que os packages do grupo tratam com PRAGMA EXCEPTION_INIT, com o código Oracle original
 * e o código equivalente que o H2 devolve na SQLException.
 */
public enum ErroOracle {

    VALOR_NULO(-1400, ErrorCode.NULL_NOT_ALLOWED),
    REGRA_CHECK(-2290, ErrorCode.CHECK_CONSTRAINT_VIOLATED_1),
    CHAVE_DUPLICADA(-1, ErrorCode.DUPLICATE_KEY_1),
    CHAVE_INEXISTENTE(-2291, ErrorCode.REFERENTIAL_INTEGRITY_VIOLATED_PARENT_MISSING_1),
    TAMANHO_EXCEDIDO(-12899, ErrorCode.VALUE_TOO_LONG_2);

    private final int codigoOracle;
    private final int codigoH2;

    ErroOracle(int codigoOracle, int codigoH2) {
        this.codigoOracle = codigoOracle;
        this.codigoH2 = codigoH2;
    }

    public int getCodigoOracle() {
        return codigoOracle;
    }

    public static Optional<ErroOracle> de(SQLException excecao) {
        return Arrays.stream(values())
                .filter(erro -> erro.codigoH2 == excecao.getErrorCode())
                .findFirst();
    }

    /** Equivalente ao SQLCODE do PL/SQL: o código Oracle quando conhecido, senão o código do H2 negativo. */
    public static int sqlcode(SQLException excecao) {
        return de(excecao).map(ErroOracle::getCodigoOracle).orElse(-excecao.getErrorCode());
    }
}
