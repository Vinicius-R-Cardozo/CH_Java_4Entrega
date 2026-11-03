# Roteiro de gravação

Dois vídeos: o da **Java Advanced** (até 15 minutos, todos os integrantes aparecem e falam) e o trecho de **Database** em que as procedures são usadas pela aplicação (o colega de banco edita esse trecho no vídeo dele).

Antes de gravar: apague a pasta `data/` (ou faça um deploy novo) para começar com a carga limpa, deixe o app aberto em uma aba e o console H2 em outra (entre como `vet@clyvo.com` / `vet123`; JDBC URL `jdbc:h2:file:./data/clyvovet;MODE=Oracle`, usuário `sa`, senha em branco), e o código aberto na IDE.

## Trecho de Database: procedures chamadas pelo backend

Em cada passo, mostre primeiro o código da chamada e depois o resultado no console H2.

1. **Cadastro de tutor**
   - Código: [`CadastroTutorService.cadastrar`](../src/main/java/br/com/fiap/clyvovet/service/CadastroTutorService.java) e [`CadastroProcedures`](../src/main/java/br/com/fiap/clyvovet/database/CadastroProcedures.java) (`PKG_CT_CADASTRO.PRC_INS_ENDERECO`, `PRC_INS_CONTATO`, `PRC_INS_USUARIO`, `PRC_INS_DADOS_PESSOAIS`, `PRC_INS_TUTOR`).
   - App: tela inicial → **Crie sua conta de tutor** → preencha e salve.
   - Console:
     ```sql
     SELECT u.id_usuario, u.nome_usuario, u.cpf, c.email, c.telefone, e.logradouro, e.cidade, e.uf_endereco, t.id_tutor
     FROM TB_CT_USUARIO u
     JOIN TB_CT_DADOS_PESSOAIS dp ON dp.id_usuario = u.id_usuario
     JOIN TB_CT_CONTATO c ON c.id_contato = dp.id_contato
     JOIN TB_CT_ENDERECO e ON e.id_endereco = dp.id_endereco
     JOIN TB_CT_TUTOR t ON t.id_usuario = u.id_usuario
     ORDER BY u.id_usuario DESC FETCH FIRST 1 ROWS ONLY;
     ```

2. **Erro tratado pela procedure (CPF repetido)**
   - App: crie outra conta com o **mesmo CPF** e outro e-mail. A tela mostra "CPF ja existente no sistema (UK)".
   - Console:
     ```sql
     SELECT * FROM TB_CT_LOG_ERRO ORDER BY id_log DESC;
     SELECT COUNT(*) FROM TB_CT_CONTATO WHERE email = '<o e-mail usado na segunda tentativa>';  -- 0: a transação foi desfeita
     ```
   - Explique: a procedure gravou o log e não relançou o erro (como no PL/SQL); o app leu o log, mostrou a mensagem e desfez o endereço e o contato. O log ficou porque `PRC_REGISTRAR_LOG` é autônoma.

3. **Cadastro de pet + trigger**
   - Código: [`PetService.cadastrar`](../src/main/java/br/com/fiap/clyvovet/service/PetService.java) (`PRC_INS_PACIENTE` → `CURRVAL` → `PRC_INS_PET`).
   - App: entre com a conta criada (ou `tutor@clyvo.com` / `tutor123`) → **Cadastrar pet**.
   - Console:
     ```sql
     SELECT * FROM TB_CT_PACIENTE ORDER BY id_paciente DESC FETCH FIRST 1 ROWS ONLY;
     SELECT * FROM TB_CT_PET ORDER BY id_paciente DESC FETCH FIRST 1 ROWS ONLY;
     SELECT * FROM TB_CT_AUDITORIA_DML ORDER BY id_auditoria DESC;
     ```

4. **Atendimento: pagamento, consulta e prescrição**
   - Código: [`AgendamentoService.concluir`](../src/main/java/br/com/fiap/clyvovet/service/AgendamentoService.java) (`PRC_INS_PAGAMENTO` → `PRC_INS_CONSULTA` → `PRC_INS_PRESCRICAO`).
   - App: entre como `vet@clyvo.com` → **Agenda** → **Registrar atendimento** no check-up do Brutus. Escolha primeiro a Amoxicilina (o Brutus tem alergia grave: a tela bloqueia), depois o Meloxicam, um exame e a forma de pagamento.
   - Console:
     ```sql
     SELECT c.*, pg.tipo_pagamento FROM TB_CT_CONSULTA c JOIN TB_CT_PAGAMENTO pg ON pg.id_pagamento = c.id_pagamento
     ORDER BY c.id_consulta DESC FETCH FIRST 1 ROWS ONLY;
     SELECT * FROM TB_CT_PRESCRICAO ORDER BY id_consulta DESC FETCH FIRST 1 ROWS ONLY;
     ```

5. **Função de marketing e JSON**
   - Código: [`CampanhaService`](../src/main/java/br/com/fiap/clyvovet/service/CampanhaService.java) e [`RelatoriosProcedures`](../src/main/java/br/com/fiap/clyvovet/database/RelatoriosProcedures.java) (`PKG_CT_RELATORIOS.FN_CT_MARKETING_PETS`).
   - App: **Campanhas** → faixa **Idoso**, estado **SP** → **Buscar público** → **Exportar JSON** (esse arquivo é o que vai para o MongoDB).
   - Console: `CALL PKG_CT_RELATORIOS.FN_CT_MARKETING_PETS('IDOSO', 'SP');`

6. **Relatórios (DBMS_OUTPUT)**
   - App: **Relatórios** → pets de um tutor e soma de idades por faixa e porte.
   - Console: `CALL PKG_CT_RELATORIOS.PRC_CT_BUSCA_PETS_POR_TUTOR(1);` e `CALL PKG_CT_RELATORIOS.PRC_CT_RESUMO_IDADE_PORTE(NULL, NULL);`

7. **UPDATE e DELETE auditados**
   - App: como tutor, **Editar** o pet criado no passo 3 (mude a idade) e depois **Excluir**.
   - App: **Auditoria** (como veterinário) mostra INSERT, UPDATE e DELETE.
   - Console: `SELECT * FROM TB_CT_AUDITORIA_DML ORDER BY id_auditoria DESC;`

## Vídeo de Java Advanced (até 15 minutos)

Sugestão de divisão; todos os integrantes precisam falar.

| Tempo | Quem | O quê |
|-------|------|-------|
| 0:00–1:30 | Integrante 1 | Problema da CLYVO e a proposta (carteira de cuidados contínua, histórico da clínica, campanhas preventivas) |
| 1:30–3:00 | Integrante 2 | Arquitetura e decisões: Spring Boot, Security com dois perfis, Flyway, H2 em modo Oracle com o banco do grupo, deploy no Render |
| 3:00–7:00 | Integrante 3 | Demonstração do tutor no app online: criar conta, cadastrar pet, carteira (próximos cuidados, cuidados da raça, alergias), pedir agendamento |
| 7:00–11:00 | Integrante 4 | Demonstração do veterinário: agenda, registrar atendimento com bloqueio de alergia, campanha e exportação do JSON, relatórios, auditoria |
| 11:00–13:30 | Integrante 5 | Integração com as disciplinas: packages e trigger do grupo chamados pelo Java (mostrar `CadastroProcedures` e o console H2), JSON para o MongoDB, outras disciplinas |
| 13:30–15:00 | Todos | Testes automáticos (`./mvnw test`), o que aprenderam e próximos passos |
