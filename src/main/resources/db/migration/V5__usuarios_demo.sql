-- Usuários de demonstração: troca o e-mail e a senha de três usuários da carga do grupo
-- (o resto dos dados deles continua igual). Senhas: vet123 e tutor123, com hash BCrypt.
--   veterinário: usuário 1               -> vet@clyvo.com
--   tutor:       usuário 11 (tutor 1, 3 pets) -> tutor@clyvo.com
--   tutora:      usuário 16 (tutor 6, 2 pets) -> tutora@clyvo.com
UPDATE TB_CT_USUARIO SET senha = '$2a$10$OPwQGJHtUm/ws9fq97OGcekAfNVUcr854ZtAEK.4LwFtu6FjD3OY.' WHERE id_usuario = 1;
UPDATE TB_CT_USUARIO SET senha = '$2a$10$EfyVv10/utoC8w3fcD/D4uyE9lGiPqiD2jDpad9f6aJFjims1Uo3e' WHERE id_usuario = 11;
UPDATE TB_CT_USUARIO SET senha = '$2a$10$C0QmpR6FUd0VznBoE.GH5.hSeG8ZBf94lxU90yMVoxoCLdm/TjDTa' WHERE id_usuario = 16;

UPDATE TB_CT_CONTATO SET email = 'vet@clyvo.com'
WHERE id_contato = (SELECT id_contato FROM TB_CT_DADOS_PESSOAIS WHERE id_usuario = 1);
UPDATE TB_CT_CONTATO SET email = 'tutor@clyvo.com'
WHERE id_contato = (SELECT id_contato FROM TB_CT_DADOS_PESSOAIS WHERE id_usuario = 11);
UPDATE TB_CT_CONTATO SET email = 'tutora@clyvo.com'
WHERE id_contato = (SELECT id_contato FROM TB_CT_DADOS_PESSOAIS WHERE id_usuario = 16);

-- Histórico de cuidados preventivos dos pets desses tutores, para a carteira não começar vazia.
-- Vacina e vermífugo só entram para cães e gatos (gênero Canis ou Felis).
CREATE VIEW VW_PETS_DEMO AS
SELECT pt.id_tutor, p.id_paciente,
       ROW_NUMBER() OVER (PARTITION BY pt.id_tutor ORDER BY p.id_paciente) AS ordem,
       CASE WHEN e.genero IN ('Canis', 'Felis') THEN 1 ELSE 0 END AS cao_ou_gato
FROM TB_CT_PET pt
JOIN TB_CT_PACIENTE p ON p.id_paciente = pt.id_paciente
JOIN TB_CT_ESPECIE e ON e.id_especie = p.id_especie
WHERE pt.id_tutor IN (1, 6);

INSERT INTO TB_CT_AGENDAMENTO (id_paciente, tipo_cuidado, data_agendada, status, observacao)
SELECT id_paciente, 'VACINA', TRUNC(SYSDATE) - 400, 'REALIZADO', 'Vacina anual aplicada, sem reações.'
FROM VW_PETS_DEMO WHERE id_tutor = 1 AND ordem = 1 AND cao_ou_gato = 1;
INSERT INTO TB_CT_AGENDAMENTO (id_paciente, tipo_cuidado, data_agendada, status, observacao)
SELECT id_paciente, 'VERMIFUGO', TRUNC(SYSDATE) - 70, 'REALIZADO', 'Vermífugo oral na dose do peso.'
FROM VW_PETS_DEMO WHERE id_tutor = 1 AND ordem = 1 AND cao_ou_gato = 1;
INSERT INTO TB_CT_AGENDAMENTO (id_paciente, tipo_cuidado, data_agendada, status, observacao)
SELECT id_paciente, 'CHECKUP', TRUNC(SYSDATE) - 100, 'REALIZADO', 'Exames de sangue normais para a idade.'
FROM VW_PETS_DEMO WHERE id_tutor = 1 AND ordem = 1;
INSERT INTO TB_CT_AGENDAMENTO (id_paciente, tipo_cuidado, data_agendada, status)
SELECT id_paciente, 'CHECKUP', TRUNC(SYSDATE), 'CONFIRMADO'
FROM VW_PETS_DEMO WHERE id_tutor = 1 AND ordem = 1;

INSERT INTO TB_CT_AGENDAMENTO (id_paciente, tipo_cuidado, data_agendada, status, observacao)
SELECT id_paciente, 'VACINA', TRUNC(SYSDATE) - 200, 'REALIZADO', 'Vacina aplicada.'
FROM VW_PETS_DEMO WHERE id_tutor = 1 AND ordem = 2 AND cao_ou_gato = 1;
INSERT INTO TB_CT_AGENDAMENTO (id_paciente, tipo_cuidado, data_agendada, status)
SELECT id_paciente, 'CHECKUP', TRUNC(SYSDATE) + 3, 'SOLICITADO'
FROM VW_PETS_DEMO WHERE id_tutor = 1 AND ordem = 2;

INSERT INTO TB_CT_AGENDAMENTO (id_paciente, tipo_cuidado, data_agendada, status, observacao)
SELECT id_paciente, 'CHECKUP', TRUNC(SYSDATE) - 20, 'REALIZADO', 'Primeira avaliação na clínica.'
FROM VW_PETS_DEMO WHERE id_tutor = 6 AND ordem = 1;
INSERT INTO TB_CT_AGENDAMENTO (id_paciente, tipo_cuidado, data_agendada, status)
SELECT id_paciente, 'CHECKUP', TRUNC(SYSDATE) + 7, 'SOLICITADO'
FROM VW_PETS_DEMO WHERE id_tutor = 6 AND ordem = 2;

DROP VIEW VW_PETS_DEMO;
