# Clyvo Vet — Jornada contínua de cuidados do pet

Aplicação web em Spring Boot desenvolvida para a disciplina **Java Advanced** (Sprint 4) do Challenge FIAP 2026, proposto pela **CLYVO VET**, pelo grupo **CelticsTech**.

- **Aplicação online:** _(link do Render)_
- **Vídeo da apresentação:** _(link do YouTube)_

## Integrantes

| Nome | RM | Turma |
|------|----|-------|
|      |    |       |
|      |    |       |
|      |    |       |

## O problema

O tutor costuma procurar a clínica só em urgências ou em gatilhos óbvios, como a vacinação. Vermífugos, check-ups e retornos acabam esquecidos, e a clínica perde o acompanhamento do animal ao longo da vida, sem um histórico estruturado.

## A solução

O Clyvo Vet organiza a vida clínica do pet numa **carteira de cuidados** e liga o tutor à clínica:

- a próxima data de cada cuidado (vacinação, vermífugo e check-up) é calculada pela **espécie** e pela **fase de vida** do animal, e o tutor vê o que está **em dia**, **próximo** ou **atrasado** e já pede o agendamento;
- a carteira mostra o **histórico longitudinal**: consultas registradas, o que foi prescrito, **alergias** e os **cuidados recomendados para a raça** (predisposições e restrições);
- a clínica confirma as solicitações e registra o atendimento, com **bloqueio de prescrição** quando o pet tem alergia grave ao medicamento;
- a clínica monta **campanhas preventivas** por faixa etária e estado (por exemplo, pets idosos em SP para check-up geriátrico) e exporta o público em JSON;
- relatórios e **auditoria** das operações, gerados pelo banco do grupo.

## Tecnologias e decisões

| Tecnologia | Por quê |
|------------|---------|
| Java 17 e Spring Boot 4.0.6 (Spring MVC, Data JPA, Validation, JDBC) | Base da disciplina; JPA para as entidades e `JdbcTemplate` para chamar os packages e ler tabelas de ligação sem chave primária |
| Spring Security (HTTP Basic, BCrypt) | Dois perfis, `TUTOR` e `VETERINARIO`, com rotas protegidas; o perfil vem das tabelas do grupo |
| Flyway | Versiona a estrutura, a carga, os packages e a trigger do banco do grupo |
| H2 em modo Oracle | O mesmo banco da Sprint 3 e o usado pelo professor nos projetos da disciplina. O modo Oracle aceita o DDL do grupo sem mudanças (VARCHAR2, sequences, DUAL, CURRVAL) |
| HTML, CSS e JavaScript | Páginas estáticas que consomem a API com `fetch` |
| Docker e Render | Deploy online a partir do repositório |
| Maven Wrapper | Ninguém precisa instalar o Maven |

## Integração com as disciplinas

### Mastering Relational and Non-Relational Database

O app usa **o banco do grupo** — as mesmas tabelas `TB_CT_*`, constraints, sequences, packages, procedures, funções e trigger — e **chama as procedures pela aplicação**. Os scripts originais estão em [`docs/database/`](docs/database).

Como o banco roda em H2 (que não executa PL/SQL), o PL/SQL foi **portado para Java com os mesmos nomes e parâmetros**:

- cada package virou um schema do H2 com o mesmo nome (`PKG_CT_CADASTRO`, `PKG_CT_RELATORIOS`, `PKG_CT_AUDITORIA`, `PKG_CT_JSON`) e cada procedure ou função virou um `CREATE ALIAS` para um método Java que reproduz o corpo original ([`V6__packages.sql`](src/main/resources/db/migration/V6__packages.sql) e [`database/packages`](src/main/java/br/com/fiap/clyvovet/database/packages));
- a aplicação chama exatamente `PKG_CT_CADASTRO.PRC_INS_USUARIO(...)`, como faria no Oracle ([`CadastroProcedures`](src/main/java/br/com/fiap/clyvovet/database/CadastroProcedures.java));
- **mesmo tratamento de exceção**: os erros de nulo, CHECK, chave duplicada, chave estrangeira e tamanho gravam em `TB_CT_LOG_ERRO` com as mesmas mensagens e não são relançados, como no PL/SQL. O app percebe o log novo, mostra a mensagem na tela e desfaz a transação;
- `PRC_REGISTRAR_LOG` é `PRAGMA AUTONOMOUS_TRANSACTION` no original; aqui o log é gravado numa conexão separada, então continua lá mesmo depois do rollback;
- os parâmetros `OUT p_id_gerado` viram o **retorno** da chamada (`{? = call ...}`), porque o H2 não tem parâmetro OUT;
- as procedures que imprimem com `DBMS_OUTPUT` devolvem as mesmas linhas como resultado da chamada;
- a trigger `TRG_CT_AUDITORIA_PACIENTE` virou uma trigger Java no H2 que grava o mesmo texto em `TB_CT_AUDITORIA_DML` ([`V7__trigger_auditoria_paciente.sql`](src/main/resources/db/migration/V7__trigger_auditoria_paciente.sql)).

Onde cada objeto do banco é usado:

| Tela / rota | Objeto do banco |
|-------------|-----------------|
| Criar conta (`POST /cadastro`) | `PKG_CT_CADASTRO.PRC_INS_ENDERECO` → `PRC_INS_CONTATO` → `PRC_INS_USUARIO` → `PRC_INS_DADOS_PESSOAIS` → `PRC_INS_TUTOR` |
| Cadastrar pet (`POST /pets`) | `PKG_CT_CADASTRO.PRC_INS_PACIENTE` → `PRC_INS_PET` (e a trigger audita o INSERT) |
| Editar e excluir pet (`PUT`/`DELETE /pets/{id}`) | `TB_CT_PACIENTE` pelo JPA; a trigger audita UPDATE e DELETE |
| Registrar atendimento (`PATCH /agendamentos/{id}/concluir`) | `PKG_CT_CADASTRO.PRC_INS_PAGAMENTO` → `PRC_INS_CONSULTA` → `PRC_INS_PRESCRICAO` |
| Registrar alergia (`POST /pacientes/{id}/alergias`) | `PKG_CT_CADASTRO.PRC_INS_ALERGIA` |
| Campanhas (`GET /campanhas`, `/campanhas/exportar`) | `PKG_CT_RELATORIOS.FN_CT_MARKETING_PETS` (que usa `PKG_CT_JSON.FN_CT_RELACIONAL_JSON`) |
| Relatórios (`GET /relatorios/...`) | `PKG_CT_RELATORIOS.PRC_CT_BUSCA_PETS_POR_TUTOR` e `PRC_CT_RESUMO_IDADE_PORTE` |
| Auditoria (`GET /auditoria/...`) | `TB_CT_AUDITORIA_DML` (trigger) e `TB_CT_LOG_ERRO` (`PKG_CT_AUDITORIA.PRC_REGISTRAR_LOG`) |

O JSON exportado na tela de campanhas é o mesmo que o grupo importa no **MongoDB**.

Diferenças em relação aos scripts do grupo, todas por limitação do H2 ou do BCrypt:

- `TB_CT_USUARIO.senha` passou de 20 para 100 caracteres, porque o hash BCrypt tem 60;
- as triggers que geram os ids viraram `DEFAULT <sequence>.NEXTVAL DEFAULT ON NULL` (mesmo efeito: inserir com id `NULL` usa a mesma sequence);
- a carga com `DBMS_RANDOM` foi portada para uma migration Java com as mesmas listas e regras e uma semente fixa, para os dados serem sempre os mesmos;
- única tabela nova: `TB_CT_AGENDAMENTO`, para o fluxo de solicitação e confirmação de cuidados (não existe no modelo do grupo e não altera nenhuma tabela dele).

### Outras disciplinas

_(Mobile, .NET, DevOps e IoT: preencher como cada uma foi aplicada na solução.)_

## Como executar

### Pré-requisito

- JDK 17 ou superior, com a variável `JAVA_HOME` apontando para ele. Não precisa instalar o Maven (o projeto usa o Maven Wrapper).

### Passos

```bash
git clone <url-do-repositorio>
cd clyvo-vet-sprint4
```

Windows:

```bash
.\mvnw.cmd spring-boot:run
```

Linux ou macOS:

```bash
./mvnw spring-boot:run
```

Acesse **http://localhost:8080**. Na primeira execução o Flyway cria o banco do grupo, roda a carga e registra os packages e a trigger. O banco fica na pasta `data/`; para recomeçar do zero, pare a aplicação e apague essa pasta.

### Variáveis de ambiente

| Variável | Padrão | Uso |
|----------|--------|-----|
| `PORT` | `8080` | Porta HTTP (o Render define sozinho) |
| `DB_PATH` | `./data/clyvovet` | Arquivo do banco H2 |

### Testes

```bash
./mvnw test
```

- `PackagesCelticsTechTest`: roda as migrations e chama cada package pelo SQL (carga, log de erro, trigger, função de marketing e relatórios);
- `FluxosDaClinicaTest`: fluxos pela API com login real (perfis, cadastro de tutor com rollback, CRUD de pet auditado, atendimento com bloqueio de alergia, campanha e relatórios).

## Deploy (Render)

1. No [Render](https://render.com), escolha **New → Blueprint** e selecione este repositório. O arquivo [`render.yaml`](render.yaml) cria um Web Service com o [`Dockerfile`](Dockerfile).
2. Aguarde o build e abra a URL gerada.

No plano gratuito o disco não é persistente: a cada deploy ou reinício o Flyway recria o banco com a mesma carga do grupo, e os usuários de demonstração voltam iguais.

## Usuários de demonstração

| Perfil      | E-mail           | Senha    |
|-------------|------------------|----------|
| Veterinário | vet@clyvo.com    | vet123   |
| Tutor       | tutor@clyvo.com  | tutor123 |
| Tutora      | tutora@clyvo.com | tutor123 |

São usuários da carga do grupo (usuário 1, veterinário; usuários 11 e 16, tutores com pets) com e-mail e senha conhecidos ([`V5__usuarios_demo.sql`](src/main/resources/db/migration/V5__usuarios_demo.sql)). Também é possível criar uma conta de tutor pela tela de cadastro.

## Console do banco (H2)

Para conferir os dados com SELECT (inclusive no app online), entre como veterinário e abra **Auditoria → Abrir console do banco** (ou `/h2-console`). O navegador pede login: use o do veterinário. No console:

- **JDBC URL:** `jdbc:h2:file:./data/clyvovet;MODE=Oracle` (no Render: `jdbc:h2:file:/app/data/clyvovet;MODE=Oracle`)
- **User Name:** `sa` e **Password** em branco

## Perfis e segurança

| Perfil        | Pode acessar |
|---------------|--------------|
| `TUTOR`       | os próprios pets (`/pets/**`), a carteira de cada um e os próprios agendamentos |
| `VETERINARIO` | agenda (`/agendamentos/**`), pacientes, alergias, campanhas, relatórios, auditoria e console do banco |

- Sem login a API responde **401**; com o perfil errado, **403**.
- O tutor só enxerga os próprios pets: pedir o pet de outro tutor retorna **404**.
- O perfil não é uma coluna: quem está em `TB_CT_VETERINARIO` é veterinário e quem está em `TB_CT_TUTOR` é tutor.

## Fluxos principais

1. **Cadastro de tutor:** a pessoa cria a conta e as procedures gravam endereço, contato, usuário, dados pessoais e tutor numa transação. CPF repetido é recusado pela procedure (com log) e nada fica gravado.
2. **Cadastro de pet:** o tutor escolhe a raça (do banco do grupo), idade, sexo e porte; o pet entra pela procedure e a trigger registra a operação.
3. **Solicitação e confirmação de cuidado:** o tutor pede vacinação, vermífugo ou check-up (vacinação e vermífugo só para cães e gatos); o veterinário confirma ou recusa.
4. **Registro do atendimento:** o veterinário descreve o atendimento, a orientação ao tutor, o medicamento, o exame e a forma de pagamento. Alergia **grave** ao medicamento bloqueia a prescrição; alergia **média ou leve** pede confirmação. A consulta entra no histórico e a carteira recalcula o próximo cuidado.
5. **Campanha preventiva:** o veterinário segmenta por faixa etária e UF, vê os tutores e pets do público e exporta o JSON.

Fases de vida e intervalos dos cuidados, em dias:

| Cuidado   | Filhote | Adulto | Sênior |
|-----------|---------|--------|--------|
| Vacinação | 30      | 365    | 365    |
| Vermífugo | 30      | 90     | 90     |
| Check-up  | 90      | 365    | 180    |

O banco guarda a idade em anos inteiros: o pet é filhote até 1 ano; cães ficam sêniores aos 7, gatos aos 10 e as demais espécies aos 8. Um cuidado fica **Próximo** quando a data prevista cai nos próximos 30 dias.

## Rotas da API

| Método | Rota                             | Perfil      | O que faz                                        |
|--------|----------------------------------|-------------|--------------------------------------------------|
| POST   | `/cadastro`                      | público     | cria a conta de tutor (procedures)               |
| POST   | `/login`                         | todos       | confere o login e devolve nome e perfil          |
| GET    | `/racas`                         | todos       | raças e espécies do banco do grupo               |
| GET    | `/pets`                          | tutor       | lista os pets do tutor                           |
| GET    | `/pets/{id}`                     | tutor       | busca um pet                                     |
| POST   | `/pets`                          | tutor       | cadastra um pet (procedures)                     |
| PUT    | `/pets/{id}`                     | tutor       | atualiza um pet                                  |
| DELETE | `/pets/{id}`                     | tutor       | exclui um pet sem consultas                      |
| GET    | `/pets/{id}/carteira`            | tutor       | carteira do pet                                  |
| GET    | `/agendamentos`                  | tutor       | agendamentos do tutor                            |
| POST   | `/agendamentos`                  | tutor       | solicita um cuidado                              |
| GET    | `/agendamentos/abertos`          | veterinário | solicitações e confirmados                       |
| GET    | `/agendamentos/{id}`             | veterinário | busca um agendamento                             |
| PATCH  | `/agendamentos/{id}/confirmar`   | veterinário | confirma                                         |
| PATCH  | `/agendamentos/{id}/recusar`     | veterinário | recusa                                           |
| PATCH  | `/agendamentos/{id}/concluir`    | veterinário | registra o atendimento (procedures)              |
| GET    | `/pacientes`                     | veterinário | todos os pets                                    |
| GET    | `/pacientes/{id}/carteira`       | veterinário | carteira de qualquer pet                         |
| POST   | `/pacientes/{id}/alergias`       | veterinário | registra uma alergia (procedure)                 |
| GET    | `/medicamentos`, `/exames`, `/tutores` | veterinário | listas para os formulários                 |
| GET    | `/campanhas?faixa=&uf=`          | veterinário | público da campanha (função do banco)            |
| GET    | `/campanhas/exportar?faixa=&uf=` | veterinário | baixa o JSON da campanha                         |
| GET    | `/relatorios/pets-do-tutor/{id}` | veterinário | pets de um tutor (procedure)                     |
| GET    | `/relatorios/resumo-idade-porte?faixa=&porte=` | veterinário | soma de idades por faixa e porte (procedure) |
| GET    | `/auditoria/operacoes?pagina=`   | veterinário | registros da trigger                             |
| GET    | `/auditoria/erros?pagina=`       | veterinário | erros registrados pelas procedures               |

Erros de validação voltam com **400** e a lista de campos (`[{ "campo": "nome", "mensagem": "..." }]`); regras de negócio e erros das procedures, com **400** e `{ "mensagem": "..." }`; alergia média ou leve, com **409** e `{ "mensagem": "...", "precisaConfirmar": true }`.

## Migrations Flyway

| Versão | Arquivo | O que faz |
|--------|---------|-----------|
| V1 | `V1__estrutura_celticstech.sql` | estrutura do banco do grupo (20 tabelas, sequences e constraints) |
| V2 | `V2__criar_tabela_agendamento.sql` | `TB_CT_AGENDAMENTO` |
| V3 | `V3__carga_fixa.sql` | espécies, predisposições, restrições, medicamentos e exames do script do grupo |
| V4 | `V4__CargaInicial.java` | porte dos blocos PL/SQL da carga (usuários, pacientes, vínculos, cuidados, alergias e consultas) |
| V5 | `V5__usuarios_demo.sql` | usuários de demonstração e histórico de cuidados |
| V6 | `V6__packages.sql` | packages do grupo |
| V7 | `V7__trigger_auditoria_paciente.sql` | trigger de auditoria |

## Estrutura do projeto

```text
src/main/java
├── br/com/fiap/clyvovet
│   ├── controller          endpoints REST
│   ├── database            chamadas aos packages (CadastroProcedures, RelatoriosProcedures)
│   │   └── packages        porte do PL/SQL do grupo para o H2
│   ├── exception           exceções e tratamento dos erros da API
│   ├── model               entidades JPA das tabelas TB_CT_*, enums e records
│   ├── repository          Spring Data JPA e consultas com JdbcTemplate
│   ├── security            Spring Security e usuário autenticado
│   └── service             regras de negócio
└── db/migration            carga inicial em Java (V4)

src/main/resources
├── db/migration            migrations SQL
└── static                  páginas HTML, CSS e JavaScript

docs
├── database                scripts originais do grupo
└── ROTEIRO_VIDEO.md        roteiro de gravação
```

## Divisão do trabalho

| Integrante | O que fez |
|------------|-----------|
|            |           |
|            |           |
|            |           |
