-- ===================================================================================================================
-- REQUISITO: Carga e Povoamento de Dados com Diversidade Estatística
-- DESCRIÇÃO: Script mestre automatizado para carga de dados integrados da clínica CelticsTech.
--            Gera registros dinâmicos de endereços, contatos, usuários, perfis, espécies e consultas médicas.
-- ===================================================================================================================

SET SERVEROUTPUT ON;

DECLARE
    TYPE t_lista IS TABLE OF VARCHAR2(100);

    v_nomes_m     t_lista := t_lista('Gabriel', 'Lucas', 'Marcos', 'Rafael', 'Rodrigo', 'Bruno', 'Thiago', 'Felipe', 'Andre', 'Ricardo', 'Fabio', 'Leonardo', 'Gustavo', 'Guilherme', 'Mateus', 'Joao', 'Victor', 'Jose', 'Renan');
    v_nomes_f     t_lista := t_lista('Ana', 'Julia', 'Fernanda', 'Beatriz', 'Camila', 'Larissa', 'Mariana', 'Leticia', 'Amanda', 'Priscila', 'Carolina', 'Debora', 'Bianca', 'Vanessa', 'Isabela', 'Ercilia', 'Alayde', 'Sabrina');
    v_sobrenomes  t_lista := t_lista('Silva', 'Santos', 'Oliveira', 'Souza', 'Pereira', 'Costa', 'Carvalho', 'Almeida', 'Ferreira', 'Ribeiro', 'Mendes', 'Nascimento', 'Alves', 'Monteiro', 'Cardoso', 'Ambrosio', 'Vendrameto', 'Mariano', 'Estorino', 'Sato', 'Santos');

    v_ufs          t_lista := t_lista('SP', 'RJ', 'MG', 'PR', 'RS', 'BA');
    v_cidades      t_lista := t_lista('São Paulo', 'Rio de Janeiro', 'Belo Horizonte', 'Curitiba', 'Porto Alegre', 'Salvador');
    v_ceps         t_lista := t_lista('01310000', '20040002', '30140001', '80010010', '90010001', '40010000');
    v_ddds         t_lista := t_lista('11', '21', '31', '41', '51', '71');
    v_logradouros t_lista := t_lista('Avenida Paulista', 'Avenida Rio Branco', 'Avenida Afonso Pena', 'Rua XV de Novembro', 'Avenida Ipiranga', 'Avenida Sete de Setembro');

    v_rand_loc        INTEGER;
    v_nome_esc        VARCHAR2(50);
    v_sobrenome_1     VARCHAR2(50);
    v_sobrenome_2     VARCHAR2(50);
    v_nome_completo   VARCHAR2(100);
    v_sexo            CHAR(1);
    v_cpf_fake        CHAR(11);
    v_login           VARCHAR2(10);
    v_idx_contato     INTEGER;
    v_idx_endereco    INTEGER;
    v_idx_usuario     INTEGER;
    v_complemento_fake VARCHAR2(20);

BEGIN
    FOR i IN 1..100 LOOP
        v_rand_loc := TRUNC(DBMS_RANDOM.VALUE(1, 7));

        IF MOD(i, 2) = 0 THEN
            v_sexo := 'F';
            v_nome_esc := v_nomes_f(TRUNC(DBMS_RANDOM.VALUE(1, v_nomes_f.COUNT + 1)));
        ELSE
            v_sexo := 'M';
            v_nome_esc := v_nomes_m(TRUNC(DBMS_RANDOM.VALUE(1, v_nomes_m.COUNT + 1)));
        END IF;

        v_sobrenome_1 := v_sobrenomes(TRUNC(DBMS_RANDOM.VALUE(1, v_sobrenomes.COUNT + 1)));
        v_sobrenome_2 := v_sobrenomes(TRUNC(DBMS_RANDOM.VALUE(1, v_sobrenomes.COUNT + 1)));
        
        IF v_sobrenome_1 = v_sobrenome_2 OR DBMS_RANDOM.VALUE(0, 1) > 0.5 THEN
            v_nome_completo := v_nome_esc || ' ' || v_sobrenome_1 || ' ' || v_sobrenome_2;
        ELSE
            v_nome_completo := v_nome_esc || ' ' || v_sobrenome_1;
        END IF;

        v_cpf_fake := LPAD(i, 3, '0') || LPAD(TRUNC(DBMS_RANDOM.VALUE(10000000, 99999999)), 8, '0');
        v_login := LOWER(SUBSTR(v_nome_esc, 1, 1) || SUBSTR(v_sobrenome_1, 1, 1)) || LPAD(i, 3, '0');

        IF DBMS_RANDOM.VALUE(0, 1) > 0.3 THEN
            v_complemento_fake := 'Apto ' || TRUNC(DBMS_RANDOM.VALUE(1, 151));
        ELSE
            v_complemento_fake := NULL;
        END IF;

        
        INSERT INTO TB_CT_ENDERECO (id_endereco, logradouro, numero, complemento, cidade, uf_endereco, cep)
        VALUES (NULL, v_logradouros(v_rand_loc), TRUNC(DBMS_RANDOM.VALUE(1, 5000)), v_complemento_fake, v_cidades(v_rand_loc), v_ufs(v_rand_loc), v_ceps(v_rand_loc))
        RETURNING id_endereco INTO v_idx_endereco;

        INSERT INTO TB_CT_CONTATO (id_contato, telefone, email)
        VALUES (NULL, v_ddds(v_rand_loc) || '9' || LPAD(TRUNC(DBMS_RANDOM.VALUE(10000000, 99999999)), 8, '0'), LOWER(v_nome_esc) || i || '@gmail.com')
        RETURNING id_contato INTO v_idx_contato;

        INSERT INTO TB_CT_USUARIO (id_usuario, login, senha, cpf, nome_usuario, sexo_usuario)
        VALUES (NULL, v_login, TO_CHAR(TRUNC(DBMS_RANDOM.VALUE(100000, 999999))), v_cpf_fake, v_nome_completo, v_sexo)
        RETURNING id_usuario INTO v_idx_usuario;

        INSERT INTO TB_CT_DADOS_PESSOAIS (id_contato, id_endereco, id_usuario)
        VALUES (v_idx_contato, v_idx_endereco, v_idx_usuario);
    END LOOP;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Carga inicializada com alta diversidade de nomes!');
END;
/


INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Vira lata SDR', 'Canis', 'SPD');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Shih Tzu', 'Canis', 'PEQUENO');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Spitz Alemao', 'Canis', 'PEQUENO');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Pinscher', 'Canis', 'PEQUENO');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Golden Retriever', 'Canis', 'GRANDE');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Lhasa Apso', 'Canis', 'PEQUENO');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Bulldog Frances', 'Canis', 'MEDIO');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Pug', 'Canis', 'PEQUENO');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Dachshund', 'Canis', 'PEQUENO');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Poodle', 'Canis', 'MEDIO');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Maltes', 'Canis', 'PEQUENO');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Schnauzer Miniatura', 'Canis', 'PEQUENO');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Chihuahua', 'Canis', 'PEQUENO');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Cavalier King Charles Spaniel', 'Canis', 'PEQUENO');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Bichon Frise', 'Canis', 'PEQUENO');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Boston Terrier', 'Canis', 'PEQUENO');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Pequines', 'Canis', 'PEQUENO');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Jack Russell Terrier', 'Canis', 'PEQUENO');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('West Highland White Terrier', 'Canis', 'PEQUENO');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Fox Paulistano', 'Canis', 'PEQUENO');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Cocker Spaniel Ingles', 'Canis', 'MEDIO');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Beagle', 'Canis', 'MEDIO');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Buldogue Ingles', 'Canis', 'MEDIO');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Italian Greyhound', 'Canis', 'PEQUENO');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Pit Bull', 'Canis', 'MEDIO');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Pastor Alemao', 'Canis', 'GRANDE');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Labrador Retriever', 'Canis', 'GRANDE');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Rottweiler', 'Canis', 'GRANDE');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Border Collie', 'Canis', 'MEDIO');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('American Bully', 'Canis', 'MEDIO');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Fila Brasileiro', 'Canis', 'GRANDE');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Samoieda', 'Canis', 'GRANDE');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Husky Siberiano', 'Canis', 'GRANDE');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Dobermann', 'Canis', 'GRANDE');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Pastor Belga Malinois', 'Canis', 'GRANDE');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Boxer', 'Canis', 'GRANDE');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Dogue Alemao', 'Canis', 'GRANDE');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Bernese Mountain Dog', 'Canis', 'GRANDE');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Dalmata', 'Canis', 'GRANDE');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Cane Corso', 'Canis', 'GRANDE');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Chow Chow', 'Canis', 'MEDIO');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Akita Inu', 'Canis', 'GRANDE');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Shiba Inu', 'Canis', 'MEDIO');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Staffordshire', 'Canis', 'MEDIO');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Border Terrier', 'Canis', 'PEQUENO');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Sao Bernardo', 'Canis', 'GRANDE');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Pastor Australiano', 'Canis', 'MEDIO');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Weimaraner', 'Canis', 'GRANDE');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Basenji', 'Canis', 'MEDIO');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Bull Terrier', 'Canis', 'MEDIO');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Siamês', 'Felis', 'PEQUENO');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Persa', 'Felis', 'MEDIO');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Maine Coon', 'Felis', 'GRANDE');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Angora', 'Felis', 'MEDIO');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Ragdoll', 'Felis', 'GRANDE');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('British Shorthair', 'Felis', 'MEDIO');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Sphynx', 'Felis', 'PEQUENO');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Bengal', 'Felis', 'MEDIO');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Azul Russo', 'Felis', 'MEDIO');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Vira lata SRD', 'Felis', 'SPD');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Jiboia', 'Reptil', 'GRANDE');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Iguana Verde', 'Reptil', 'MEDIO');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Teiu', 'Reptil', 'GRANDE');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Jabuti Piranga', 'Reptil', 'MEDIO');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Cagado Tigre Dagua', 'Reptil', 'MEDIO');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Camaleao do Yemen', 'Reptil', 'PEQUENO');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Gecko Leopardo', 'Reptil', 'PEQUENO');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Arara Caninde', 'Ave', 'GRANDE');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Arara Vermelha', 'Ave', 'GRANDE');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Papagaio Verdadeiro', 'Ave', 'MEDIO');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Calopsita', 'Ave', 'PEQUENO');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Coruja Suindara', 'Ave', 'MEDIO');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Tucano Toco', 'Ave', 'MEDIO');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Sapo Cururu', 'Anfibio', 'MEDIO');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Perereca Verde', 'Anfibio', 'PEQUENO');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Axolote', 'Anfibio', 'PEQUENO');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Pirarucu', 'Peixe', 'GRANDE');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Arowana Prata', 'Peixe', 'GRANDE');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Oscar', 'Peixe', 'MEDIO');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Tucunare', 'Peixe', 'GRANDE');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Betta', 'Peixe', 'PEQUENO');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Acara Bandeira', 'Peixe', 'MEDIO');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Mico Leao Dourado', 'Primata', 'PEQUENO');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Macaco Prego', 'Primata', 'MEDIO');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Sagui', 'Primata', 'PEQUENO');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Bugio', 'Primata', 'GRANDE');
INSERT INTO TB_CT_ESPECIE (NOME_ESPECIE, GENERO, PORTE) VALUES ('Macaco Aranha', 'Primata', 'GRANDE');

INSERT INTO TB_CT_PREDISPOSICAO_ESP (NOME_PREDISPOSICAO, ORIENTACAO_PREDISPOSICAO) VALUES ('Displasia Coxofemoral', 'Monitorar articulacoes e evitar excesso de impacto durante crescimento.');
INSERT INTO TB_CT_PREDISPOSICAO_ESP (NOME_PREDISPOSICAO, ORIENTACAO_PREDISPOSICAO) VALUES ('Problemas Respiratorios', 'Evitar calor excessivo e exercicios intensos em dias quentes.');
INSERT INTO TB_CT_PREDISPOSICAO_ESP (NOME_PREDISPOSICAO, ORIENTACAO_PREDISPOSICAO) VALUES ('Dermatite em Dobras', 'Secar regularmente as dobras da pele para evitar fungos e infeccoes.');
INSERT INTO TB_CT_PREDISPOSICAO_ESP (NOME_PREDISPOSICAO, ORIENTACAO_PREDISPOSICAO) VALUES ('Obesidade', 'Controlar alimentacao e manter rotina frequente de exercicios.');
INSERT INTO TB_CT_PREDISPOSICAO_ESP (NOME_PREDISPOSICAO, ORIENTACAO_PREDISPOSICAO) VALUES ('Ansiedade por Separacao', 'Estimular enriquecimento ambiental e evitar longos periodos sozinho.');
INSERT INTO TB_CT_PREDISPOSICAO_ESP (NOME_PREDISPOSICAO, ORIENTACAO_PREDISPOSICAO) VALUES ('Sensibilidade ao Calor', 'Manter ambiente ventilado e hidratacao constante.');
INSERT INTO TB_CT_PREDISPOSICAO_ESP (NOME_PREDISPOSICAO, ORIENTACAO_PREDISPOSICAO) VALUES ('Sensibilidade ao Frio', 'Evitar exposicao prolongada a baixas temperaturas.');
INSERT INTO TB_CT_PREDISPOSICAO_ESP (NOME_PREDISPOSICAO, ORIENTACAO_PREDISPOSICAO) VALUES ('Problemas Renais', 'Estimular hidratacao e realizar acompanhamento veterinario.');
INSERT INTO TB_CT_PREDISPOSICAO_ESP (NOME_PREDISPOSICAO, ORIENTACAO_PREDISPOSICAO) VALUES ('Bola de Pelos', 'Escovar regularmente e fornecer suporte digestivo adequado.');
INSERT INTO TB_CT_PREDISPOSICAO_ESP (NOME_PREDISPOSICAO, ORIENTACAO_PREDISPOSICAO) VALUES ('Estresse Territorial', 'Evitar mudancas bruscas no ambiente e conflitos entre animais.');
INSERT INTO TB_CT_PREDISPOSICAO_ESP (NOME_PREDISPOSICAO, ORIENTACAO_PREDISPOSICAO) VALUES ('Troca de Pele Incompleta', 'Manter umidade adequada no terrario.');
INSERT INTO TB_CT_PREDISPOSICAO_ESP (NOME_PREDISPOSICAO, ORIENTACAO_PREDISPOSICAO) VALUES ('Deficiencia de Calcio', 'Garantir suplementacao UVB e dieta balanceada.');
INSERT INTO TB_CT_PREDISPOSICAO_ESP (NOME_PREDISPOSICAO, ORIENTACAO_PREDISPOSICAO) VALUES ('Estresse por Manejo Excessivo', 'Reduzir manipulacao frequente e manter ambiente seguro.');
INSERT INTO TB_CT_PREDISPOSICAO_ESP (NOME_PREDISPOSICAO, ORIENTACAO_PREDISPOSICAO) VALUES ('Intoxicacao por Metais', 'Evitar contato com produtos contendo cobre ou metals pesados.');
INSERT INTO TB_CT_PREDISPOSICAO_ESP (NOME_PREDISPOSICAO, ORIENTACAO_PREDISPOSICAO) VALUES ('Baixa Oxigenacao da Agua', 'Manter filtragem e oxigenacao adequadas no aquario.');
INSERT INTO TB_CT_PREDISPOSICAO_ESP (NOME_PREDISPOSICAO, ORIENTACAO_PREDISPOSICAO) VALUES ('Estresse por Solidao', 'Avaliar necessidade de convivencia com outros individuos da especie.');
INSERT INTO TB_CT_PREDISPOSICAO_ESP (NOME_PREDISPOSICAO, ORIENTACAO_PREDISPOSICAO) VALUES ('Otite Cronica', 'Realizar limpeza periodica das orelhas e monitorar umidade.');
INSERT INTO TB_CT_PREDISPOSICAO_ESP (NOME_PREDISPOSICAO, ORIENTACAO_PREDISPOSICAO) VALUES ('Problemas Cardiacos', 'Acompanhar exames cardiacos preventivos regularmente.');
INSERT INTO TB_CT_PREDISPOSICAO_ESP (NOME_PREDISPOSICAO, ORIENTACAO_PREDISPOSICAO) VALUES ('Agressividade Territorial', 'Socializar desde filhote e evitar ambientes estressantes.');
INSERT INTO TB_CT_PREDISPOSICAO_ESP (NOME_PREDISPOSICAO, ORIENTACAO_PREDISPOSICAO) VALUES ('Queda Excessiva de Pelos', 'Escovar frequentemente e avaliar suplementacao nutricional.');
INSERT INTO TB_CT_PREDISPOSICAO_ESP (NOME_PREDISPOSICAO, ORIENTACAO_PREDISPOSICAO) VALUES ('Problemas Oculares', 'Realizar higienizacao ocular e consultas preventivas.');
INSERT INTO TB_CT_PREDISPOSICAO_ESP (NOME_PREDISPOSICAO, ORIENTACAO_PREDISPOSICAO) VALUES ('Sensibilidade Digestiva', 'Introduzir novos alimentos gradualmente.');
INSERT INTO TB_CT_PREDISPOSICAO_ESP (NOME_PREDISPOSICAO, ORIENTACAO_PREDISPOSICAO) VALUES ('Torcao Gastrica', 'Evitar exercicios apos refeicoes.');
INSERT INTO TB_CT_PREDISPOSICAO_ESP (NOME_PREDISPOSICAO, ORIENTACAO_PREDISPOSICAO) VALUES ('Problemas Hepaticos', 'Monitorar dieta e evitar alimentos toxicos.');
INSERT INTO TB_CT_PREDISPOSICAO_ESP (NOME_PREDISPOSICAO, ORIENTACAO_PREDISPOSICAO) VALUES ('Sensibilidade a Medicamentos', 'Consultar dosagem especifica antes de administrar medicamentos.');
INSERT INTO TB_CT_PREDISPOSICAO_ESP (NOME_PREDISPOSICAO, ORIENTACAO_PREDISPOSICAO) VALUES ('Desidratacao Rapida', 'Garantir acesso constante a agua limpa.');
INSERT INTO TB_CT_PREDISPOSICAO_ESP (NOME_PREDISPOSICAO, ORIENTACAO_PREDISPOSICAO) VALUES ('Comportamento Destrutivo', 'Fornecer brinquedos e enriquecimento ambiental.');
INSERT INTO TB_CT_PREDISPOSICAO_ESP (NOME_PREDISPOSICAO, ORIENTACAO_PREDISPOSICAO) VALUES ('Alergia Alimentar', 'Evitar ingredientes que provoquem reacoes alergicas.');
INSERT INTO TB_CT_PREDISPOSICAO_ESP (NOME_PREDISPOSICAO, ORIENTACAO_PREDISPOSICAO) VALUES ('Parasitismo Frequente', 'Manter protocolo regular de vermifugacao.');
INSERT INTO TB_CT_PREDISPOSICAO_ESP (NOME_PREDISPOSICAO, ORIENTACAO_PREDISPOSICAO) VALUES ('Problemas Dentarios', 'Escovar os dentes regularmente e oferecer suporte odontologico.');
INSERT INTO TB_CT_PREDISPOSICAO_ESP (NOME_PREDISPOSICAO, ORIENTACAO_PREDISPOSICAO) VALUES ('Necessidade de Alta Atividade', 'Garantir rotina diaria de exercicios fisicos.');


INSERT INTO TB_CT_RESTRICAO_ESP (NOME_RESTRICAO, ORIENTACAO_RESTRICAO, GRAVIDADE_RESTRICAO) VALUES ('Medicacao com Cobre', 'Nao administrar medicamentos com cobre em peixes sensiveis.', 'GRAVE');
INSERT INTO TB_CT_RESTRICAO_ESP (NOME_RESTRICAO, ORIENTACAO_RESTRICAO, GRAVIDADE_RESTRICAO) VALUES ('Exposicao ao Calor', 'Evitar exposicao prolongada ao calor intenso.', 'GRAVE');
INSERT INTO TB_CT_RESTRICAO_ESP (NOME_RESTRICAO, ORIENTACAO_RESTRICAO, GRAVIDADE_RESTRICAO) VALUES ('Exercicio Excessivo', 'Limitar exercicios intensos em animais braquicefalicos.', 'MEDIA');
INSERT INTO TB_CT_RESTRICAO_ESP (NOME_RESTRICAO, ORIENTACAO_RESTRICAO, GRAVIDADE_RESTRICAO) VALUES ('Alimentos Gordurosos', 'Evitar dieta rica em gordura e excesso de petiscos.', 'MEDIA');
INSERT INTO TB_CT_RESTRICAO_ESP (NOME_RESTRICAO, ORIENTACAO_RESTRICAO, GRAVIDADE_RESTRICAO) VALUES ('Ambiente Umido', 'Evitar excesso de umidade em dobras cutaneas e recintos.', 'MEDIA');
INSERT INTO TB_CT_RESTRICAO_ESP (NOME_RESTRICAO, ORIENTACAO_RESTRICAO, GRAVIDADE_RESTRICAO) VALUES ('Falta de UVB', 'Nao manter repteis sem iluminacao UVB adequada.', 'GRAVE');
INSERT INTO TB_CT_RESTRICAO_ESP (NOME_RESTRICAO, ORIENTACAO_RESTRICAO, GRAVIDADE_RESTRICAO) VALUES ('Agua sem Filtragem', 'Nao manter peixes em agua sem controle de qualidade.', 'GRAVE');
INSERT INTO TB_CT_RESTRICAO_ESP (NOME_RESTRICAO, ORIENTACAO_RESTRICAO, GRAVIDADE_RESTRICAO) VALUES ('Manejo Excessivo', 'Evitar manipulacao frequente de animais exoticos.', 'LEVE');
INSERT INTO TB_CT_RESTRICAO_ESP (NOME_RESTRICAO, ORIENTACAO_RESTRICAO, GRAVIDADE_RESTRICAO) VALUES ('Convivencia com Presas', 'Nao manter especies predadoras junto de animais menores.', 'GRAVE');
INSERT INTO TB_CT_RESTRICAO_ESP (NOME_RESTRICAO, ORIENTACAO_RESTRICAO, GRAVIDADE_RESTRICAO) VALUES ('Mudancas Bruscas de Temperatura', 'Evitar variacoes abruptas de temperatura.', 'GRAVE');
INSERT INTO TB_CT_RESTRICAO_ESP (NOME_RESTRICAO, ORIENTACAO_RESTRICAO, GRAVIDADE_RESTRICAO) VALUES ('Baixa Umidade', 'Nao manter anfibios em ambiente seco.', 'GRAVE');
INSERT INTO TB_CT_RESTRICAO_ESP (NOME_RESTRICAO, ORIENTACAO_RESTRICAO, GRAVIDADE_RESTRICAO) VALUES ('Falta de Enriquecimento Ambiental', 'Evitar ambientes sem estimulos fisicos e mentais.', 'MEDIA');
INSERT INTO TB_CT_RESTRICAO_ESP (NOME_RESTRICAO, ORIENTACAO_RESTRICAO, GRAVIDADE_RESTRICAO) VALUES ('Contato com Produtos Quimicos', 'Evitar contato com desinfetantes e produtos toxicos.', 'GRAVE');
INSERT INTO TB_CT_RESTRICAO_ESP (NOME_RESTRICAO, ORIENTACAO_RESTRICAO, GRAVIDADE_RESTRICAO) VALUES ('Ruido Excessivo', 'Evitar ambientes com barulho constante.', 'MEDIA');
INSERT INTO TB_CT_RESTRICAO_ESP (NOME_RESTRICAO, ORIENTACAO_RESTRICAO, GRAVIDADE_RESTRICAO) VALUES ('Superlotacao', 'Nao manter muitos animais no mesmo recinto.', 'GRAVE');
INSERT INTO TB_CT_RESTRICAO_ESP (NOME_RESTRICAO, ORIENTACAO_RESTRICAO, GRAVIDADE_RESTRICAO) VALUES ('Privacao de Luz Natural', 'Garantir ciclo adequado de iluminacao.', 'MEDIA');
INSERT INTO TB_CT_RESTRICAO_ESP (NOME_RESTRICAO, ORIENTACAO_RESTRICAO, GRAVIDADE_RESTRICAO) VALUES ('Alimentacao Irregular', 'Manter rotina alimentar consistente.', 'MEDIA');
INSERT INTO TB_CT_RESTRICAO_ESP (NOME_RESTRICAO, ORIENTACAO_RESTRICAO, GRAVIDADE_RESTRICAO) VALUES ('Falta de Socializacao', 'Nao isolar animais sociaveis por longos periodos.', 'MEDIA');
INSERT INTO TB_CT_RESTRICAO_ESP (NOME_RESTRICAO, ORIENTACAO_RESTRICAO, GRAVIDADE_RESTRICAO) VALUES ('Pisos Escorregadios', 'Evitar superficies lisas para animais idosos.', 'LEVE');
INSERT INTO TB_CT_RESTRICAO_ESP (NOME_RESTRICAO, ORIENTACAO_RESTRICAO, GRAVIDADE_RESTRICAO) VALUES ('Excesso de Carboidratos', 'Controlar dieta rica em carboidratos.', 'MEDIA');
INSERT INTO TB_CT_RESTRICAO_ESP (NOME_RESTRICAO, ORIENTACAO_RESTRICAO, GRAVIDADE_RESTRICAO) VALUES ('Contato com Predadores', 'Nao expor pequenos animais a especies predadoras.', 'GRAVE');
INSERT INTO TB_CT_RESTRICAO_ESP (NOME_RESTRICAO, ORIENTACAO_RESTRICAO, GRAVIDADE_RESTRICAO) VALUES ('Baixa Hidratacao', 'Garantir hidratacao frequente e adequada.', 'GRAVE');
INSERT INTO TB_CT_RESTRICAO_ESP (NOME_RESTRICAO, ORIENTACAO_RESTRICAO, GRAVIDADE_RESTRICAO) VALUES ('Excesso de Sol', 'Evitar exposicao prolongada ao sol forte.', 'MEDIA');
INSERT INTO TB_CT_RESTRICAO_ESP (NOME_RESTRICAO, ORIENTACAO_RESTRICAO, GRAVIDADE_RESTRICAO) VALUES ('Correntes de Ar', 'Nao manter animais sensiveis em locais com vento constante.', 'LEVE');
INSERT INTO TB_CT_RESTRICAO_ESP (NOME_RESTRICAO, ORIENTACAO_RESTRICAO, GRAVIDADE_RESTRICAO) VALUES ('Falta de Exercicios', 'Evitar sedentarismo prolongado.', 'MEDIA');
INSERT INTO TB_CT_RESTRICAO_ESP (NOME_RESTRICAO, ORIENTACAO_RESTRICAO, GRAVIDADE_RESTRICAO) VALUES ('Uso Indevido de Antibioticos', 'Administrar antibioticos apenas com orientacao veterinaria.', 'GRAVE');
INSERT INTO TB_CT_RESTRICAO_ESP (NOME_RESTRICAO, ORIENTACAO_RESTRICAO, GRAVIDADE_RESTRICAO) VALUES ('Convivencia com Agua Suja', 'Manter limpeza frequente do habitat aquatico.', 'GRAVE');
INSERT INTO TB_CT_RESTRICAO_ESP (NOME_RESTRICAO, ORIENTACAO_RESTRICAO, GRAVIDADE_RESTRICAO) VALUES ('Temperatura Baixa', 'Evitar ambientes frios para especies tropicais.', 'MEDIA');
INSERT INTO TB_CT_RESTRICAO_ESP (NOME_RESTRICAO, ORIENTACAO_RESTRICAO, GRAVIDADE_RESTRICAO) VALUES ('Falta de Esconderijos', 'Garantir locais seguros para descanso e refugio.', 'LEVE');
INSERT INTO TB_CT_RESTRICAO_ESP (NOME_RESTRICAO, ORIENTACAO_RESTRICAO, GRAVIDADE_RESTRICAO) VALUES ('Contato Excessivo com Humans', 'Respeitar limites comportamentais de especies exoticas.', 'MEDIA');


DECLARE
    v_r1 INTEGER; v_r2 INTEGER; v_r3 INTEGER; v_r4 INTEGER; v_r5 INTEGER;
    v_r6 INTEGER; v_r7 INTEGER; v_r8 INTEGER; v_r9 INTEGER; v_r10 INTEGER;
    v_r11 INTEGER; v_r12 INTEGER; v_r13 INTEGER; v_r14 INTEGER; v_r15 INTEGER;
    v_r16 INTEGER; v_r17 INTEGER; v_r18 INTEGER; v_r19 INTEGER; v_r20 INTEGER;
    v_r21 INTEGER; v_r22 INTEGER; v_r23 INTEGER; v_r24 INTEGER; v_r25 INTEGER;
    v_r26 INTEGER; v_r27 INTEGER; v_r28 INTEGER; v_r29 INTEGER; v_r30 INTEGER;

    v_p_resp      INTEGER; v_p_displasia INTEGER; v_p_dobras    INTEGER; 
    v_p_pelos     INTEGER; v_p_pele      INTEGER; v_p_estresse  INTEGER; 
    v_p_oxigenio  INTEGER; v_p_cardiaco  INTEGER; v_p_dentario  INTEGER;
    v_p_obesidade INTEGER; v_p_otite     INTEGER; v_p_renal     INTEGER;
BEGIN
    v_r1 := 1; v_r2 := 2; v_r3 := 3; v_r4 := 4; v_r5 := 5;
    v_r6 := 6; v_r7 := 7; v_r8 := 8; v_r9 := 9; v_r10 := 10;
    v_r11 := 11; v_r12 := 12; v_r13 := 13; v_r14 := 14; v_r15 := 15;
    v_r16 := 16; v_r17 := 17; v_r18 := 18; v_r19 := 19; v_r20 := 20;
    v_r21 := 21; v_r22 := 22; v_r23 := 23; v_r24 := 24; v_r25 := 25;
    v_r26 := 26; v_r27 := 27; v_r28 := 28; v_r29 := 29; v_r30 := 30;

    SELECT id_predisposicao INTO v_p_resp      FROM TB_CT_PREDISPOSICAO_ESP WHERE nome_predisposicao = 'Problemas Respiratorios' AND ROWNUM = 1;
    SELECT id_predisposicao INTO v_p_displasia FROM TB_CT_PREDISPOSICAO_ESP WHERE nome_predisposicao = 'Displasia Coxofemoral' AND ROWNUM = 1;
    SELECT id_predisposicao INTO v_p_dobras    FROM TB_CT_PREDISPOSICAO_ESP WHERE nome_predisposicao = 'Dermatite em Dobras' AND ROWNUM = 1;
    SELECT id_predisposicao INTO v_p_pelos     FROM TB_CT_PREDISPOSICAO_ESP WHERE nome_predisposicao = 'Bola de Pelos' AND ROWNUM = 1;
    SELECT id_predisposicao INTO v_p_pele      FROM TB_CT_PREDISPOSICAO_ESP WHERE nome_predisposicao = 'Troca de Pele Incompleta' AND ROWNUM = 1;
    SELECT id_predisposicao INTO v_p_estresse  FROM TB_CT_PREDISPOSICAO_ESP WHERE nome_predisposicao = 'Estresse por Manejo Excessivo' AND ROWNUM = 1;
    SELECT id_predisposicao INTO v_p_oxigenio  FROM TB_CT_PREDISPOSICAO_ESP WHERE nome_predisposicao = 'Baixa Oxigenacao da Agua' AND ROWNUM = 1;
    SELECT id_predisposicao INTO v_p_cardiaco  FROM TB_CT_PREDISPOSICAO_ESP WHERE nome_predisposicao = 'Problemas Cardiacos' AND ROWNUM = 1;
    SELECT id_predisposicao INTO v_p_dentario  FROM TB_CT_PREDISPOSICAO_ESP WHERE nome_predisposicao = 'Problemas Dentarios' AND ROWNUM = 1;
    SELECT id_predisposicao INTO v_p_obesidade FROM TB_CT_PREDISPOSICAO_ESP WHERE nome_predisposicao = 'Obesidade' AND ROWNUM = 1;
    SELECT id_predisposicao INTO v_p_otite     FROM TB_CT_PREDISPOSICAO_ESP WHERE nome_predisposicao = 'Otite Cronica' AND ROWNUM = 1;
    SELECT id_predisposicao INTO v_p_renal     FROM TB_CT_PREDISPOSICAO_ESP WHERE nome_predisposicao = 'Problemas Renais' AND ROWNUM = 1;

    
    DELETE FROM TB_CT_CUIDADO;

    FOR r IN (SELECT id_especie FROM TB_CT_ESPECIE WHERE nome_especie IN ('Pug', 'Bulldog Frances', 'Buldogue Ingles', 'Boston Terrier', 'Pequines', 'Shih Tzu', 'Lhasa Apso')) LOOP
        INSERT INTO TB_CT_CUIDADO (id_especie, id_restricao, id_predisposicao) VALUES (r.id_especie, v_r3, v_p_resp);
        INSERT INTO TB_CT_CUIDADO (id_especie, id_restricao, id_predisposicao) VALUES (r.id_especie, v_r2, v_p_resp);
        INSERT INTO TB_CT_CUIDADO (id_especie, id_restricao, id_predisposicao) VALUES (r.id_especie, v_r5, v_p_dobras);
        INSERT INTO TB_CT_CUIDADO (id_especie, id_restricao, id_predisposicao) VALUES (r.id_especie, v_r14, v_p_estresse);
    END LOOP;

    FOR r IN (SELECT id_especie FROM TB_CT_ESPECIE WHERE porte = 'GRANDE' AND genero = 'Canis') LOOP
        INSERT INTO TB_CT_CUIDADO (id_especie, id_restricao, id_predisposicao) VALUES (r.id_especie, v_r23, v_p_displasia);
        INSERT INTO TB_CT_CUIDADO (id_especie, id_restricao, id_predisposicao) VALUES (r.id_especie, v_r19, v_p_displasia);
        INSERT INTO TB_CT_CUIDADO (id_especie, id_restricao, id_predisposicao) VALUES (r.id_especie, v_r25, v_p_obesidade);
    END LOOP;

    FOR r IN (SELECT id_especie FROM TB_CT_ESPECIE WHERE nome_especie IN ('Cocker Spaniel Ingles', 'Beagle', 'Dachshund')) LOOP
        INSERT INTO TB_CT_CUIDADO (id_especie, id_restricao, id_predisposicao) VALUES (r.id_especie, v_r5, v_p_otite);
    END LOOP;

    FOR r IN (SELECT id_especie FROM TB_CT_ESPECIE WHERE porte = 'PEQUENO' AND genero = 'Canis' AND nome_especie NOT IN ('Pug','Pequines','Shih Tzu','Lhasa Apso','Boston Terrier','Spitz Alemao','Pinscher','Chihuahua','Maltes','Bichon Frise')) LOOP
        INSERT INTO TB_CT_CUIDADO (id_especie, id_restricao, id_predisposicao) VALUES (r.id_especie, v_r24, v_p_cardiaco);
        INSERT INTO TB_CT_CUIDADO (id_especie, id_restricao, id_predisposicao) VALUES (r.id_especie, v_r20, v_p_dentario);
    END LOOP;

    FOR r IN (SELECT id_especie FROM TB_CT_ESPECIE WHERE genero = 'Felis') LOOP
        INSERT INTO TB_CT_CUIDADO (id_especie, id_restricao, id_predisposicao) VALUES (r.id_especie, v_r4, v_p_pelos);
        INSERT INTO TB_CT_CUIDADO (id_especie, id_restricao, id_predisposicao) VALUES (r.id_especie, v_r17, v_p_obesidade);
        INSERT INTO TB_CT_CUIDADO (id_especie, id_restricao, id_predisposicao) VALUES (r.id_especie, v_r22, v_p_renal);
        INSERT INTO TB_CT_CUIDADO (id_especie, id_restricao, id_predisposicao) VALUES (r.id_especie, v_r26, v_p_renal);
    END LOOP;

    FOR r IN (SELECT id_especie FROM TB_CT_ESPECIE WHERE genero = 'Reptil') LOOP
        INSERT INTO TB_CT_CUIDADO (id_especie, id_restricao, id_predisposicao) VALUES (r.id_especie, v_r6, v_p_pele);
        INSERT INTO TB_CT_CUIDADO (id_especie, id_restricao, id_predisposicao) VALUES (r.id_especie, v_r16, v_p_pele);
        INSERT INTO TB_CT_CUIDADO (id_especie, id_restricao, id_predisposicao) VALUES (r.id_especie, v_r28, v_p_estresse);
        INSERT INTO TB_CT_CUIDADO (id_especie, id_restricao, id_predisposicao) VALUES (r.id_especie, v_r29, v_p_estresse);
    END LOOP;

    FOR r IN (SELECT id_especie FROM TB_CT_ESPECIE WHERE genero = 'Peixe') LOOP
        INSERT INTO TB_CT_CUIDADO (id_especie, id_restricao, id_predisposicao) VALUES (r.id_especie, v_r1, v_p_oxigenio);
        INSERT INTO TB_CT_CUIDADO (id_especie, id_restricao, id_predisposicao) VALUES (r.id_especie, v_r7, v_p_oxigenio);
        INSERT INTO TB_CT_CUIDADO (id_especie, id_restricao, id_predisposicao) VALUES (r.id_especie, v_r27, v_p_oxigenio);
        INSERT INTO TB_CT_CUIDADO (id_especie, id_restricao, id_predisposicao) VALUES (r.id_especie, v_r15, v_p_estresse);
    END LOOP;

    FOR r IN (SELECT id_especie FROM TB_CT_ESPECIE WHERE genero = 'Anfibio') LOOP
        INSERT INTO TB_CT_CUIDADO (id_especie, id_restricao, id_predisposicao) VALUES (r.id_especie, v_r11, v_p_pele);
        INSERT INTO TB_CT_CUIDADO (id_especie, id_restricao, id_predisposicao) VALUES (r.id_especie, v_r13, v_p_estresse);
    END LOOP;

    FOR r IN (SELECT id_especie FROM TB_CT_ESPECIE WHERE genero IN ('Primata', 'Ave')) LOOP
        INSERT INTO TB_CT_CUIDADO (id_especie, id_restricao, id_predisposicao) VALUES (r.id_especie, v_r8, v_p_estresse);
        INSERT INTO TB_CT_CUIDADO (id_especie, id_restricao, id_predisposicao) VALUES (r.id_especie, v_r12, v_p_estresse);
        INSERT INTO TB_CT_CUIDADO (id_especie, id_restricao, id_predisposicao) VALUES (r.id_especie, v_r18, v_p_estresse);
        INSERT INTO TB_CT_CUIDADO (id_especie, id_restricao, id_predisposicao) VALUES (r.id_especie, v_r30, v_p_estresse);
    END LOOP;

    FOR r IN (SELECT id_especie FROM TB_CT_ESPECIE WHERE nome_especie IN ('Calopsita', 'Betta', 'Sagui', 'Mico Leao Dourado', 'Perereca Verde')) LOOP
        INSERT INTO TB_CT_CUIDADO (id_especie, id_restricao, id_predisposicao) VALUES (r.id_especie, v_r9, v_p_estresse);
        INSERT INTO TB_CT_CUIDADO (id_especie, id_restricao, id_predisposicao) VALUES (r.id_especie, v_r21, v_p_estresse);
    END LOOP;

    COMMIT;
END;
/


DECLARE
    TYPE t_lista IS TABLE OF VARCHAR2(50);
    
    v_caes_m   t_lista := t_lista('Thor', 'Luke', 'Bob', 'Rex', 'Teo', 'Freud', 'Banzai', 'Brutus', 'Apollo', 'Pingo');
    v_gatos_m  t_lista := t_lista('Garfield', 'Oliver', 'Simba', 'Tom', 'Mingau', 'Félix', 'Frajola', 'Zeca');
    v_exot_m   t_lista := t_lista('Nemo', 'Snape', 'Draco', 'Kaa', 'Fred', 'Zazu', 'Yoshi');

    v_caes_f   t_lista := t_lista('Mel', 'Luna', 'Maggie', 'Amora', 'Nina', 'Cacau', 'Pipoca', 'Belinha', 'Maia', 'Cloe');
    v_gatos_f  t_lista := t_lista('Mia', 'Luna', 'Fiona', 'Pipoca', 'Frida', 'Pretinha', 'Pandora', 'Cleo');
    v_exot_f   t_lista := t_lista('Bubbles', 'Hedwig', 'Glub', 'Dory', 'Jade', 'Fiona', 'Flora');

    v_id_especie   INTEGER;
    v_id_maine_coon INTEGER;
    v_nome_pac    VARCHAR2(50);
    v_porte       VARCHAR2(25);
    v_sexo        CHAR(1);
    v_idade       INTEGER;
    v_random      NUMBER;
BEGIN
    BEGIN
        SELECT id_especie INTO v_id_maine_coon FROM TB_CT_ESPECIE WHERE nome_especie = 'Maine Coon' AND ROWNUM = 1;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN v_id_maine_coon := -1;
    END;

    FOR i IN 1..60 LOOP
        v_random := DBMS_RANDOM.VALUE(0, 1);
        v_sexo   := CASE WHEN DBMS_RANDOM.VALUE(0, 1) > 0.5 THEN 'M' ELSE 'F' END;
        v_idade  := TRUNC(DBMS_RANDOM.VALUE(1, 14)); 

        IF v_random <= 0.45 THEN
            IF v_sexo = 'M' THEN
                v_nome_pac := v_caes_m(TRUNC(DBMS_RANDOM.VALUE(1, v_caes_m.COUNT + 1)));
            ELSE
                v_nome_pac := v_caes_f(TRUNC(DBMS_RANDOM.VALUE(1, v_caes_f.COUNT + 1)));
            END IF;
            
            SELECT id_especie, porte INTO v_id_especie, v_porte 
            FROM (
                SELECT id_especie, porte FROM TB_CT_ESPECIE 
                WHERE nome_especie IN ('Vira lata SDR', 'Shih Tzu', 'Spitz Alemao', 'Golden Retriever', 'Pug', 'Poodle', 'Pastor Alemao', 'Labrador Retriever', 'Bulldog Frances', 'Rottweiler')
                ORDER BY DBMS_RANDOM.VALUE
            ) WHERE ROWNUM = 1;

        ELSIF v_random > 0.45 AND v_random <= 0.80 THEN
            IF v_sexo = 'M' THEN
                v_nome_pac := v_gatos_m(TRUNC(DBMS_RANDOM.VALUE(1, v_gatos_m.COUNT + 1)));
            ELSE
                v_nome_pac := v_gatos_f(TRUNC(DBMS_RANDOM.VALUE(1, v_gatos_f.COUNT + 1)));
            END IF;
            
            v_porte    := 'MEDIO'; 
            
            SELECT id_especie INTO v_id_especie 
            FROM (
                SELECT id_especie FROM TB_CT_ESPECIE 
                WHERE genero = 'Felis'
                ORDER BY DBMS_RANDOM.VALUE
            ) WHERE ROWNUM = 1;
            
            IF v_id_especie = v_id_maine_coon THEN
                v_porte := 'GRANDE';
            END IF;

        ELSIF v_random > 0.80 AND v_random <= 0.90 THEN
            IF v_sexo = 'M' THEN
                v_nome_pac := v_exot_m(TRUNC(DBMS_RANDOM.VALUE(1, v_exot_m.COUNT + 1)));
            ELSE
                v_nome_pac := v_exot_f(TRUNC(DBMS_RANDOM.VALUE(1, v_exot_f.COUNT + 1)));
            END IF;
            
            v_idade    := TRUNC(DBMS_RANDOM.VALUE(1, 5)); 
            
            SELECT id_especie, porte INTO v_id_especie, v_porte 
            FROM (
                SELECT id_especie, porte FROM TB_CT_ESPECIE 
                WHERE genero = 'Reptil'
                ORDER BY DBMS_RANDOM.VALUE
            ) WHERE ROWNUM = 1;

        ELSE
            IF v_sexo = 'M' THEN
                v_nome_pac := v_exot_m(TRUNC(DBMS_RANDOM.VALUE(1, v_exot_m.COUNT + 1)));
            ELSE
                v_nome_pac := v_exot_f(TRUNC(DBMS_RANDOM.VALUE(1, v_exot_f.COUNT + 1)));
            END IF;
            
            v_idade    := TRUNC(DBMS_RANDOM.VALUE(1, 3));
            
            SELECT id_especie, porte INTO v_id_especie, v_porte 
            FROM (
                SELECT id_especie, porte FROM TB_CT_ESPECIE 
                WHERE genero IN ('Peixe', 'Ave')
                ORDER BY DBMS_RANDOM.VALUE
            ) WHERE ROWNUM = 1;
        END IF;

        IF MOD(i, 5) = 0 THEN
            v_nome_pac := v_nome_pac || CASE WHEN v_sexo = 'M' THEN ' Filho' ELSE ' Filha' END;
        END IF;

        INSERT INTO TB_CT_PACIENTE (id_paciente, id_especie, idade_paciente, nome_paciente, sexo_paciente, porte_paciente)
        VALUES (NULL, v_id_especie, v_idade, v_nome_pac, v_sexo, v_porte);

    END LOOP;

    COMMIT;
END;
/


DECLARE
    v_contador_crmv INTEGER := 1001; 
BEGIN
  
    DELETE FROM TB_CT_VETERINARIO;
    DELETE FROM TB_CT_TUTOR;

    FOR r_vet IN (
        SELECT 
            u.id_usuario,
            e.uf_endereco
        FROM 
            TB_CT_USUARIO u
        INNER JOIN 
            TB_CT_DADOS_PESSOAIS dp ON u.id_usuario = dp.id_usuario
        INNER JOIN 
            TB_CT_ENDERECO e ON dp.id_endereco = e.id_endereco 
        WHERE 
            u.id_usuario <= 10
    ) LOOP
        INSERT INTO TB_CT_VETERINARIO (id_usuario, crmv, uf_crmv)
        VALUES (r_vet.id_usuario, TO_CHAR(v_contador_crmv), r_vet.uf_endereco);
        
        v_contador_crmv := v_contador_crmv + 1;
    END LOOP;

    FOR r_tutor IN (SELECT id_usuario FROM TB_CT_USUARIO WHERE id_usuario > 10) LOOP
        INSERT INTO TB_CT_TUTOR (id_usuario)
        VALUES (r_tutor.id_usuario);
    END LOOP;

    COMMIT;
END;
/


DECLARE
    TYPE t_ids IS TABLE OF INTEGER;
    v_lista_tutores   t_ids;
    v_lista_pacientes t_ids;
    
    v_idx_paciente    INTEGER := 1;
    v_total_pacientes INTEGER;
BEGIN
    DELETE FROM TB_CT_PET;

    SELECT id_tutor BULK COLLECT INTO v_lista_tutores FROM TB_CT_TUTOR ORDER BY id_tutor;
    SELECT id_paciente BULK COLLECT INTO v_lista_pacientes FROM TB_CT_PACIENTE ORDER BY id_paciente;
    
    v_total_pacientes := v_lista_pacientes.COUNT;

    
    FOR i IN 1..5 LOOP
        IF v_lista_tutores.EXISTS(i) THEN
            EXIT WHEN v_idx_paciente > v_total_pacientes;
            INSERT INTO TB_CT_PET (id_tutor, id_paciente) VALUES (v_lista_tutores(i), v_lista_pacientes(v_idx_paciente));
            v_idx_paciente := v_idx_paciente + 1;
            
            EXIT WHEN v_idx_paciente > v_total_pacientes;
            INSERT INTO TB_CT_PET (id_tutor, id_paciente) VALUES (v_lista_tutores(i), v_lista_pacientes(v_idx_paciente));
            v_idx_paciente := v_idx_paciente + 1;
            
            EXIT WHEN v_idx_paciente > v_total_pacientes;
            INSERT INTO TB_CT_PET (id_tutor, id_paciente) VALUES (v_lista_tutores(i), v_lista_pacientes(v_idx_paciente));
            v_idx_paciente := v_idx_paciente + 1;
        END IF;
    END LOOP;

    FOR i IN 6..15 LOOP
        IF v_lista_tutores.EXISTS(i) THEN
            EXIT WHEN v_idx_paciente > v_total_pacientes;
            INSERT INTO TB_CT_PET (id_tutor, id_paciente) VALUES (v_lista_tutores(i), v_lista_pacientes(v_idx_paciente));
            v_idx_paciente := v_idx_paciente + 1;
            
            EXIT WHEN v_idx_paciente > v_total_pacientes;
            INSERT INTO TB_CT_PET (id_tutor, id_paciente) VALUES (v_lista_tutores(i), v_lista_pacientes(v_idx_paciente));
            v_idx_paciente := v_idx_paciente + 1;
        END IF;
    END LOOP;

    FOR i IN 16..v_lista_tutores.COUNT LOOP
        IF v_lista_tutores.EXISTS(i) THEN
            EXIT WHEN v_idx_paciente > v_total_pacientes;
            INSERT INTO TB_CT_PET (id_tutor, id_paciente) VALUES (v_lista_tutores(i), v_lista_pacientes(v_idx_paciente));
            v_idx_paciente := v_idx_paciente + 1;
        END IF;
    END LOOP;

    COMMIT;
END;
/


BEGIN
    
    DELETE FROM TB_CT_PRESCRICAO;
    DELETE FROM TB_CT_CONSULTA;
    DELETE FROM TB_CT_MEDICAMENTO;
    DELETE FROM TB_CT_EXAME;
    
    INSERT INTO TB_CT_MEDICAMENTO (nome_medicamento, bula_medicamento, tipo_medicamento)
    VALUES ('Nenhum Medicamento Prescrito', 'Sem recomendacao de farmaco para esta consulta.', 'analgesico');
    
    INSERT INTO TB_CT_MEDICAMENTO (nome_medicamento, bula_medicamento, tipo_medicamento) 
    VALUES ('Enrofloxacina 50mg', 'Antibiotico amplo espectro para infeccoes bacterianas.', 'antibiotico');
    
    INSERT INTO TB_CT_MEDICAMENTO (nome_medicamento, bula_medicamento, tipo_medicamento) 
    VALUES ('Amoxicilina + Clav 250mg', 'Indicado para infeccoes de pele, urinarias e respiratorias.', 'antibiotico');
    
    INSERT INTO TB_CT_MEDICAMENTO (nome_medicamento, bula_medicamento, tipo_medicamento) 
    VALUES ('Meloxicam 1mg', 'Anti-inflamatorio e analgesico para dores agudas.', 'anti inflamatorio nao esteroide');
    
    INSERT INTO TB_CT_MEDICAMENTO (nome_medicamento, bula_medicamento, tipo_medicamento) 
    VALUES ('Dipirona Gotas', 'Analgesico e antipiretico potente para controle de febre.', 'analgesico');
    
    INSERT INTO TB_CT_MEDICAMENTO (nome_medicamento, bula_medicamento, tipo_medicamento) 
    VALUES ('Tramadol 50mg', 'Analgesico opioide indicado para dores moderadas a graves.', 'analgesico');
    
    INSERT INTO TB_CT_MEDICAMENTO (nome_medicamento, bula_medicamento, tipo_medicamento) 
    VALUES ('Prednisolona 20mg', 'Corticoide com potente acao anti-inflamatoria.', 'anti inflamatorio esteroide');
    
    INSERT INTO TB_CT_MEDICAMENTO (nome_medicamento, bula_medicamento, tipo_medicamento) 
    VALUES ('Simparic (Sarolaner)', 'Prevencao e tratamento contra pulgas, carrapatos e sarnas.', 'antiparasitario');
    
    INSERT INTO TB_CT_MEDICAMENTO (nome_medicamento, bula_medicamento, tipo_medicamento) 
    VALUES ('Drontal Plus', 'Vermifugo oral de amplo espectro para caes.', 'antiparasitario');
    
    INSERT INTO TB_CT_MEDICAMENTO (nome_medicamento, bula_medicamento, tipo_medicamento) 
    VALUES ('Omeprazol 10mg', 'Protetor gastrico, reduz a acidez do estomago.', 'protetor gastrico');
    
    INSERT INTO TB_CT_MEDICAMENTO (nome_medicamento, bula_medicamento, tipo_medicamento) 
    VALUES ('Maropitant (Cenia)', 'Antiemetico potente para controle de vomitos e enjoos.', 'anti emetico');

    INSERT INTO TB_CT_EXAME (nome_exame, orientacoes_exame)
    VALUES ('Nenhum Exame Solicitado', 'Apenas avaliacao clinica.');
    
    INSERT INTO TB_CT_EXAME (nome_exame, orientacoes_exame) 
    VALUES ('Hemograma Completo', 'Jejum de 8 horas');
    
    INSERT INTO TB_CT_EXAME (nome_exame, orientacoes_exame) 
    VALUES ('Bioquimico Renal', 'Jejum de 8 horas');
    
    INSERT INTO TB_CT_EXAME (nome_exame, orientacoes_exame) 
    VALUES ('Bioquimico Hepatico', 'Jejum de 8 horas');
    
    INSERT INTO TB_CT_EXAME (nome_exame, orientacoes_exame) 
    VALUES ('Urinalise Tipo 1', 'Coleta esteril');
    
    INSERT INTO TB_CT_EXAME (nome_exame, orientacoes_exame) 
    VALUES ('Exame de Fezes', 'Coleta recente');
    
    INSERT INTO TB_CT_EXAME (nome_exame, orientacoes_exame) 
    VALUES ('Ultrassom Abdominal', 'Jejum e bexiga cheia');
    
    INSERT INTO TB_CT_EXAME (nome_exame, orientacoes_exame) 
    VALUES ('Raio-X de Torax', 'Nao requer jejum');
    
    INSERT INTO TB_CT_EXAME (nome_exame, orientacoes_exame) 
    VALUES ('Raio-X Coxofemoral', 'Pode requerer sedacao');
    
    INSERT INTO TB_CT_EXAME (nome_exame, orientacoes_exame) 
    VALUES ('Ecocardiograma', 'Nao requer jejum');
    
    INSERT INTO TB_CT_EXAME (nome_exame, orientacoes_exame) 
    VALUES ('Teste Rapido FIV/FeLV', 'Nao requer jejum');

    COMMIT;
END;
/


DECLARE
    v_id_amoxicilina   INTEGER;
    v_id_meloxicam     INTEGER;
    v_id_enrofloxacina INTEGER;
    v_id_dipirona      INTEGER;
    
    TYPE t_ids IS TABLE OF INTEGER;
    v_lista_pacientes  t_ids;
BEGIN
    DELETE FROM TB_CT_ALERGIA;

    SELECT id_medicamento INTO v_id_amoxicilina   FROM TB_CT_MEDICAMENTO WHERE nome_medicamento LIKE 'Amoxicilina%' AND id_medicamento <> 1 AND ROWNUM = 1;
    SELECT id_medicamento INTO v_id_meloxicam     FROM TB_CT_MEDICAMENTO WHERE nome_medicamento LIKE 'Meloxicam%' AND id_medicamento <> 1 AND ROWNUM = 1;
    SELECT id_medicamento INTO v_id_enrofloxacina FROM TB_CT_MEDICAMENTO WHERE nome_medicamento LIKE 'Enrofloxacina%' AND id_medicamento <> 1 AND ROWNUM = 1;
    SELECT id_medicamento INTO v_id_dipirona      FROM TB_CT_MEDICAMENTO WHERE nome_medicamento LIKE 'Dipirona%' AND id_medicamento <> 1 AND ROWNUM = 1;

    SELECT id_paciente BULK COLLECT INTO v_lista_pacientes FROM TB_CT_PACIENTE ORDER BY id_paciente;

    IF v_lista_pacientes.COUNT >= 10 THEN
        INSERT INTO TB_CT_ALERGIA (id_paciente, id_medicamento, gravidade_alergia)
        VALUES (v_lista_pacientes(1), v_id_amoxicilina, 'GRAVE');
        
        INSERT INTO TB_CT_ALERGIA (id_paciente, id_medicamento, gravidade_alergia)
        VALUES (v_lista_pacientes(3), v_id_dipirona, 'LEVE');
        
        INSERT INTO TB_CT_ALERGIA (id_paciente, id_medicamento, gravidade_alergia)
        VALUES (v_lista_pacientes(5), v_id_meloxicam, 'MEDIA');
        
        INSERT INTO TB_CT_ALERGIA (id_paciente, id_medicamento, gravidade_alergia)
        VALUES (v_lista_pacientes(8), v_id_amoxicilina, 'GRAVE');
        
        INSERT INTO TB_CT_ALERGIA (id_paciente, id_medicamento, gravidade_alergia)
        VALUES (v_lista_pacientes(10), v_id_enrofloxacina, 'MEDIA');
    END IF;

    COMMIT;
END;
/


DECLARE
    TYPE t_ids IS TABLE OF INTEGER;
    v_vets            t_ids;
    
    v_id_pagto        INTEGER;
    v_id_consulta     INTEGER;
    v_id_vet          INTEGER;
    v_id_med_proposto INTEGER;
    v_id_exame_prop   INTEGER;
    v_tipo_pagto      VARCHAR2(20);
    v_total_vets      INTEGER;
    v_contador        INTEGER := 1;
    
    v_eh_alergico     INTEGER;
    v_id_med_min      INTEGER;
    v_id_med_max      INTEGER;
    v_id_exame_min    INTEGER;
    v_id_exame_max    INTEGER;
   
    v_porcentagem_sem_med INTEGER := 20; 
BEGIN
    DELETE FROM TB_CT_PRESCRICAO;
    DELETE FROM TB_CT_CONSULTA;
    DELETE FROM TB_CT_PAGAMENTO;

    SELECT id_veterinario BULK COLLECT INTO v_vets FROM TB_CT_VETERINARIO ORDER BY id_veterinario;
    v_total_vets := v_vets.COUNT;
    
    SELECT MIN(id_medicamento), MAX(id_medicamento) INTO v_id_med_min, v_id_med_max 
    FROM TB_CT_MEDICAMENTO 
    WHERE id_medicamento <> 1;
    
    SELECT MIN(id_exame), MAX(id_exame) INTO v_id_exame_min, v_id_exame_max 
    FROM TB_CT_EXAME 
    WHERE id_exame <> 1;

    FOR r_pet IN (
        SELECT id_tutor, id_paciente 
        FROM TB_CT_PET 
        WHERE ROWNUM <= 30
    ) LOOP
        
        CASE TRUNC(DBMS_RANDOM.VALUE(0, 4))
            WHEN 0 THEN v_tipo_pagto := 'PIX';
            WHEN 1 THEN v_tipo_pagto := 'CREDITO';
            WHEN 2 THEN v_tipo_pagto := 'DEBITO';
            ELSE v_tipo_pagto := 'SALDO';
        END CASE;
        
        INSERT INTO TB_CT_PAGAMENTO (tipo_pagamento)
        VALUES (v_tipo_pagto)
        RETURNING id_pagamento INTO v_id_pagto;
        
        
        v_id_vet := v_vets(TRUNC(DBMS_RANDOM.VALUE(1, v_total_vets + 1)));
        
       
        INSERT INTO TB_CT_CONSULTA (id_pagamento, id_veterinario, id_tutor, id_paciente, observacoes, orientacao_consulta, data_consulta)
        VALUES (v_id_pagto, v_id_vet, r_pet.id_tutor, r_pet.id_paciente, 
                'Atendimento clínico ' || CASE WHEN MOD(v_contador, 2) = 0 THEN 'preventivo.' ELSE 'de urgência.' END, 
                'Retorno agendado para avaliacao.', SYSDATE - v_contador)
        RETURNING id_consulta INTO v_id_consulta;
        
        IF DBMS_RANDOM.VALUE(1, 100) <= v_porcentagem_sem_med THEN
            v_id_med_proposto := 1;
            v_id_exame_prop   := 1;
        ELSE
            v_id_med_proposto := v_id_med_min + MOD(v_contador, (v_id_med_max - v_id_med_min + 1));
            v_id_exame_prop   := v_id_exame_min + MOD(v_contador, (v_id_exame_max - v_id_exame_min + 1));
            
            LOOP
                SELECT COUNT(*) INTO v_eh_alergico 
                FROM TB_CT_ALERGIA 
                WHERE id_paciente = r_pet.id_paciente AND id_medicamento = v_id_med_proposto;
                
                IF v_eh_alergico = 0 THEN
                    EXIT; 
                ELSE
                    v_id_med_proposto := v_id_med_proposto + 1;
                    IF v_id_med_proposto > v_id_med_max THEN
                        v_id_med_proposto := v_id_med_min;
                    END IF;
                END IF;
            END LOOP;
        END IF;
        
        INSERT INTO TB_CT_PRESCRICAO (id_medicamento, id_exame, id_consulta)
        VALUES (v_id_med_proposto, v_id_exame_prop, v_id_consulta);
        
        v_contador := v_contador + 1;
    END LOOP;

    COMMIT;
END;
/