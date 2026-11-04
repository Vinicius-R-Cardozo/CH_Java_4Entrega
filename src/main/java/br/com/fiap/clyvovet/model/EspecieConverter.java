package br.com.fiap.clyvovet.model;

import jakarta.persistence.AttributeConverter;
import jakarta.persistence.Converter;

@Converter
public class EspecieConverter implements AttributeConverter<Especie, String> {

    @Override
    public String convertToDatabaseColumn(Especie especie) {
        return especie == null ? null : especie.getGenero();
    }

    @Override
    public Especie convertToEntityAttribute(String genero) {
        return genero == null ? null : Especie.doGenero(genero);
    }
}
