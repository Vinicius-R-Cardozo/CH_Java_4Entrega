package br.com.fiap.clyvovet.database.packages;

import org.h2.api.Trigger;

import java.sql.Connection;
import java.sql.SQLException;

public class TrgCtAuditoriaPaciente implements Trigger {

    private static final int ID_PACIENTE = 0;
    private static final int ID_ESPECIE = 1;
    private static final int IDADE_PACIENTE = 2;
    private static final int NOME_PACIENTE = 3;
    private static final int SEXO_PACIENTE = 4;
    private static final int PORTE_PACIENTE = 5;

    @Override
    public void fire(Connection conexao, Object[] linhaAntiga, Object[] linhaNova) throws SQLException {
        String tipo;
        if (linhaAntiga == null) {
            tipo = "INSERT";
        } else if (linhaNova == null) {
            tipo = "DELETE";
        } else {
            tipo = "UPDATE";
        }
        PkgCtAuditoria.prcAuditarPaciente(conexao, tipo, descrever(linhaAntiga), descrever(linhaNova));
    }

    private static String descrever(Object[] linha) {
        if (linha == null) {
            return null;
        }
        return "ID_PACIENTE=" + linha[ID_PACIENTE]
                + "; ID_ESPECIE=" + linha[ID_ESPECIE]
                + "; IDADE_PACIENTE=" + linha[IDADE_PACIENTE]
                + "; NOME_PACIENTE=" + linha[NOME_PACIENTE]
                + "; SEXO_PACIENTE=" + linha[SEXO_PACIENTE]
                + "; PORTE_PACIENTE=" + linha[PORTE_PACIENTE];
    }
}
