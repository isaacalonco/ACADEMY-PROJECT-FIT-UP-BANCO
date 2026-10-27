<<<<<<< HEAD
-- ============================================================================
-- FIT UP — Sistema de Gestão de Academias
-- Script 01: DDL — criação do esquema físico
-- SGBD alvo : PostgreSQL 14 ou superior
-- Execução  : psql -d fitup -v ON_ERROR_STOP=1 -f sql/01_ddl.sql
--             (executável do início ao fim em base limpa; o bloco DROP inicial
--              garante a reexecução sem resíduos)
-- Disciplina: Laboratório de Banco de Dados — UCB — Grupo 6
-- Revisão   : pós-devolutiva da Etapa 1 (ver docs/revisao-pos-devolutiva.md)
--
-- Convenção de nomes das restrições: pk_ (chave primária), uq_ (unicidade),
-- fk_ (chave estrangeira), ck_ (verificação), idx_ (índice).
-- Cada restrição relevante indica, em comentário, a regra de negócio (RN) que
-- implementa. A matriz completa RN -> mecanismo está em docs/relatorio-etapa1.md.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 0. LIMPEZA PREVENTIVA (execução em base limpa / reexecução)
-- ----------------------------------------------------------------------------
DROP VIEW  IF EXISTS vw_relatorio_gerencial_financeiro;
DROP VIEW  IF EXISTS vw_alunos_instrutor;
DROP TABLE IF EXISTS tb_auditoria_sistema   CASCADE;
DROP TABLE IF EXISTS tb_ficha_exercicio     CASCADE;
DROP TABLE IF EXISTS tb_exercicio           CASCADE;
DROP TABLE IF EXISTS tb_ficha_treino        CASCADE;
DROP TABLE IF EXISTS tb_avaliacao_fisica    CASCADE;
DROP TABLE IF EXISTS tb_pagamento           CASCADE;
DROP TABLE IF EXISTS tb_historico_matricula CASCADE;
DROP TABLE IF EXISTS tb_contrato_plano      CASCADE;
DROP TABLE IF EXISTS tb_plano               CASCADE;
DROP TABLE IF EXISTS tb_aluno               CASCADE;
DROP TABLE IF EXISTS tb_instrutor           CASCADE;
DROP TABLE IF EXISTS tb_pessoa              CASCADE;

-- ----------------------------------------------------------------------------
-- 1. SUPERCLASSE: PESSOA
-- RN01: nome com no mínimo 3 caracteres, CPF de 11 dígitos e único, e-mail
--       único e válido, data de nascimento não futura.
-- Tipos: CHAR(11) para CPF (tamanho fixo), VARCHAR para textos de tamanho
--        variável, DATE para datas civis, TIMESTAMPTZ para carimbos de
--        data/hora com fuso (coerente com o dicionário de dados).
-- ----------------------------------------------------------------------------
CREATE TABLE tb_pessoa (
    id_pessoa              SERIAL,
    nome_completo          VARCHAR(120) NOT NULL,
    cpf                    CHAR(11)     NOT NULL,
    email                  VARCHAR(120) NOT NULL,
    telefone               VARCHAR(20)  NULL,                       -- opcional (caso de contorno na carga)
    data_nascimento        DATE         NOT NULL,
    genero                 CHAR(1)      NOT NULL DEFAULT 'N',
    data_cadastro          TIMESTAMPTZ  NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_pessoa             PRIMARY KEY (id_pessoa),
    CONSTRAINT uq_pessoa_cpf         UNIQUE (cpf),                                              -- RN01
    CONSTRAINT uq_pessoa_email       UNIQUE (email),                                            -- RN01
    CONSTRAINT ck_pessoa_nome_tamanho CHECK (char_length(btrim(nome_completo)) >= 3),          -- RN01
    CONSTRAINT ck_pessoa_cpf_digitos CHECK (cpf ~ '^[0-9]{11}$'),                              -- RN01
    CONSTRAINT ck_pessoa_email_formato CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'), -- RN01
    CONSTRAINT ck_pessoa_data_nasc   CHECK (data_nascimento <= CURRENT_DATE),                  -- RN01
    CONSTRAINT ck_pessoa_genero      CHECK (genero IN ('M', 'F', 'O', 'N'))
);

-- ----------------------------------------------------------------------------
-- 2. SUBCLASSE: INSTRUTOR (especialização total e disjunta de PESSOA)
-- RN02: registro CREF único no formato CREF-NNNNNN-G/UF, especialidade
--       obrigatória e salário base > 0.
-- RN03: autorrelacionamento de supervisão técnica (opcional).
-- Mapeamento: uma tabela por subclasse; a PK é também FK para tb_pessoa.
-- ON DELETE CASCADE: remover a pessoa remove o papel de instrutor (dependência
-- existencial da subclasse). ON DELETE SET NULL no supervisor: a saída do
-- coordenador não apaga os supervisionados, apenas desfaz o vínculo (RN03).
-- ----------------------------------------------------------------------------
CREATE TABLE tb_instrutor (
    id_instrutor           INT           NOT NULL,
    registro_cref          VARCHAR(20)   NOT NULL,
    especialidade_primaria VARCHAR(60)   NOT NULL,
    data_admissao          DATE          NOT NULL DEFAULT CURRENT_DATE,
    salario_base           NUMERIC(10,2) NOT NULL,
    id_supervisor          INT           NULL,

    CONSTRAINT pk_instrutor              PRIMARY KEY (id_instrutor),
    CONSTRAINT uq_instrutor_cref         UNIQUE (registro_cref),                                -- RN02
    CONSTRAINT ck_instrutor_cref_formato CHECK (registro_cref ~ '^CREF-[0-9]{6}-G/[A-Z]{2}$'),  -- RN02
    CONSTRAINT ck_instrutor_salario      CHECK (salario_base > 0.00),                           -- RN02
    CONSTRAINT ck_instrutor_nao_autosupervisao CHECK (id_supervisor IS NULL OR id_supervisor <> id_instrutor), -- RN03
    CONSTRAINT fk_instrutor_pessoa FOREIGN KEY (id_instrutor)
        REFERENCES tb_pessoa (id_pessoa)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_instrutor_supervisor FOREIGN KEY (id_supervisor)                              -- RN03
        REFERENCES tb_instrutor (id_instrutor)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- ----------------------------------------------------------------------------
-- 3. SUBCLASSE: ALUNO (especialização total e disjunta de PESSOA)
-- RN04: código de matrícula único e situação cadastral restrita.
-- RN05: autorrelacionamento de indicação (programa de fidelidade, opcional).
-- ----------------------------------------------------------------------------
CREATE TABLE tb_aluno (
    id_aluno               INT          NOT NULL,
    codigo_matricula       VARCHAR(20)  NOT NULL,
    status_cadastral       VARCHAR(20)  NOT NULL DEFAULT 'Ativo',
    id_aluno_indicador     INT          NULL,

    CONSTRAINT pk_aluno            PRIMARY KEY (id_aluno),
    CONSTRAINT uq_aluno_matricula  UNIQUE (codigo_matricula),                                   -- RN04
    CONSTRAINT ck_aluno_status     CHECK (status_cadastral IN ('Ativo', 'Trancado', 'Cancelado', 'Inadimplente')), -- RN04
    CONSTRAINT ck_aluno_nao_autoindicacao CHECK (id_aluno_indicador IS NULL OR id_aluno_indicador <> id_aluno),   -- RN05
    CONSTRAINT fk_aluno_pessoa FOREIGN KEY (id_aluno)
        REFERENCES tb_pessoa (id_pessoa)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_aluno_indicador FOREIGN KEY (id_aluno_indicador)                              -- RN05
        REFERENCES tb_aluno (id_aluno)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- ----------------------------------------------------------------------------
-- 4. ENTIDADE: PLANO (catálogo comercial)
-- RN06: nome único, duração restrita a 1, 3, 6 ou 12 meses, valor > 0.
-- ----------------------------------------------------------------------------
CREATE TABLE tb_plano (
    id_plano               SERIAL,
    nome_plano             VARCHAR(60)   NOT NULL,
    descricao              VARCHAR(255)  NULL,
    duracao_meses          SMALLINT      NOT NULL DEFAULT 1,
    valor_mensal           NUMERIC(10,2) NOT NULL,
    permite_todas_unidades BOOLEAN       NOT NULL DEFAULT FALSE,
    ativo                  BOOLEAN       NOT NULL DEFAULT TRUE,

    CONSTRAINT pk_plano         PRIMARY KEY (id_plano),
    CONSTRAINT uq_plano_nome    UNIQUE (nome_plano),                                            -- RN06
    CONSTRAINT ck_plano_duracao CHECK (duracao_meses IN (1, 3, 6, 12)),                         -- RN06
    CONSTRAINT ck_plano_valor   CHECK (valor_mensal > 0.00)                                     -- RN06
);

-- ----------------------------------------------------------------------------
-- 5. ASSOCIATIVA N:N COM ATRIBUTOS PRÓPRIOS: CONTRATO_PLANO (ALUNO x PLANO)
-- RN07: vigência obrigatória com término posterior ao início e valor > 0.
-- RN08: dia de vencimento entre 1 e 28.
-- Chave substituta id_contrato (justificativa no relatório, A4): simplifica a
-- FK em tb_pagamento e permite que um aluno renove o mesmo plano mais de uma vez.
-- ON DELETE RESTRICT: contrato com histórico financeiro não pode sumir por
-- exclusão acidental de aluno ou plano.
-- ----------------------------------------------------------------------------
CREATE TABLE tb_contrato_plano (
    id_contrato            SERIAL,
    id_aluno               INT           NOT NULL,
    id_plano               INT           NOT NULL,
    data_inicio            DATE          NOT NULL DEFAULT CURRENT_DATE,
    data_termino           DATE          NOT NULL,
    valor_acordado         NUMERIC(10,2) NOT NULL,
    dia_vencimento_mensal  SMALLINT      NOT NULL DEFAULT 10,
    situacao_contrato      VARCHAR(20)   NOT NULL DEFAULT 'Vigente',

    CONSTRAINT pk_contrato_plano      PRIMARY KEY (id_contrato),
    CONSTRAINT ck_contrato_datas      CHECK (data_termino > data_inicio),                       -- RN07
    CONSTRAINT ck_contrato_valor      CHECK (valor_acordado > 0.00),                            -- RN07
    CONSTRAINT ck_contrato_vencimento CHECK (dia_vencimento_mensal BETWEEN 1 AND 28),           -- RN08
    CONSTRAINT ck_contrato_situacao   CHECK (situacao_contrato IN ('Vigente', 'Encerrado', 'Rescindido', 'Suspenso')),
    CONSTRAINT fk_contrato_aluno FOREIGN KEY (id_aluno)
        REFERENCES tb_aluno (id_aluno)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_contrato_plano FOREIGN KEY (id_plano)
        REFERENCES tb_plano (id_plano)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- ----------------------------------------------------------------------------
-- 6. ATRIBUTO TEMPORAL (HISTÓRICO DATADO): HISTORICO_MATRICULA
-- RN09: toda mudança de situação do aluno gera um registro com data, situação
--       anterior, situação nova, motivo e responsável. A situação anterior é
--       nula apenas no evento de matrícula inicial e nunca igual à nova.
-- ON DELETE CASCADE: o histórico só faz sentido enquanto o aluno existir.
-- ----------------------------------------------------------------------------
CREATE TABLE tb_historico_matricula (
    id_historico           SERIAL,
    id_aluno               INT          NOT NULL,
    data_evento            TIMESTAMPTZ  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    situacao_anterior      VARCHAR(20)  NULL,
    situacao_nova          VARCHAR(20)  NOT NULL,
    motivo_alteracao       VARCHAR(200) NOT NULL,
    usuario_responsavel    VARCHAR(60)  NOT NULL DEFAULT 'sistema',

    CONSTRAINT pk_historico_matricula   PRIMARY KEY (id_historico),
    CONSTRAINT ck_hist_situacao_nova     CHECK (situacao_nova IN ('Ativo', 'Trancado', 'Cancelado', 'Inadimplente')),   -- RN09
    CONSTRAINT ck_hist_situacao_anterior CHECK (situacao_anterior IS NULL
                                                OR situacao_anterior IN ('Ativo', 'Trancado', 'Cancelado', 'Inadimplente')), -- RN09
    CONSTRAINT ck_hist_transicao_real    CHECK (situacao_anterior IS DISTINCT FROM situacao_nova),                      -- RN09
    CONSTRAINT fk_hist_aluno FOREIGN KEY (id_aluno)
        REFERENCES tb_aluno (id_aluno)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- ----------------------------------------------------------------------------
-- 7. ENTIDADE FRACA: AVALIACAO_FISICA (identificada por dependência de ALUNO)
-- RN10: chave composta (id_aluno, num_sequencial).
-- RN11: limites biológicos de peso e altura.
-- RN12: toda avaliação é conduzida por um instrutor (FK obrigatória, RESTRICT).
-- ON DELETE CASCADE em id_aluno: entidade fraca não sobrevive ao aluno.
-- ----------------------------------------------------------------------------
CREATE TABLE tb_avaliacao_fisica (
    id_aluno               INT          NOT NULL,
    num_sequencial         INT          NOT NULL,
    id_instrutor_avaliador INT          NOT NULL,
    data_avaliacao         DATE         NOT NULL DEFAULT CURRENT_DATE,
    peso_kg                NUMERIC(5,2) NOT NULL,
    altura_m               NUMERIC(3,2) NOT NULL,
    percentual_gordura     NUMERIC(4,2) NULL,
    circunferencia_cintura NUMERIC(5,2) NULL,
    circunferencia_quadril NUMERIC(5,2) NULL,
    pressao_arterial       VARCHAR(10)  NULL,
    observacoes_clinicas   TEXT         NULL,

    CONSTRAINT pk_avaliacao_fisica  PRIMARY KEY (id_aluno, num_sequencial),                     -- RN10
    CONSTRAINT ck_avaliacao_seq     CHECK (num_sequencial > 0),                                 -- RN10
    CONSTRAINT ck_avaliacao_peso    CHECK (peso_kg  BETWEEN 20.00 AND 350.00),                  -- RN11
    CONSTRAINT ck_avaliacao_altura  CHECK (altura_m BETWEEN 0.80 AND 2.50),                     -- RN11
    CONSTRAINT ck_avaliacao_gordura CHECK (percentual_gordura IS NULL OR percentual_gordura BETWEEN 1.00 AND 60.00),
    CONSTRAINT fk_avaliacao_aluno FOREIGN KEY (id_aluno)
        REFERENCES tb_aluno (id_aluno)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_avaliacao_instrutor FOREIGN KEY (id_instrutor_avaliador)                      -- RN12
        REFERENCES tb_instrutor (id_instrutor)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- ----------------------------------------------------------------------------
-- 8. ENTIDADE: FICHA_TREINO (prescrição e periodização)
-- RN13: validade igual ou posterior à data de prescrição.
-- RN14: nível de dificuldade restrito.
-- ----------------------------------------------------------------------------
CREATE TABLE tb_ficha_treino (
    id_ficha               SERIAL,
    id_aluno               INT          NOT NULL,
    id_instrutor           INT          NOT NULL,
    data_prescricao        DATE         NOT NULL DEFAULT CURRENT_DATE,
    data_validade          DATE         NOT NULL,
    objetivo_treino        VARCHAR(60)  NOT NULL,
    nivel_dificuldade      VARCHAR(20)  NOT NULL DEFAULT 'Iniciante',
    observacoes            VARCHAR(255) NULL,

    CONSTRAINT pk_ficha_treino  PRIMARY KEY (id_ficha),
    CONSTRAINT ck_ficha_validade CHECK (data_validade >= data_prescricao),                      -- RN13
    CONSTRAINT ck_ficha_nivel    CHECK (nivel_dificuldade IN ('Iniciante', 'Intermediário', 'Avançado', 'Atleta')), -- RN14
    CONSTRAINT fk_ficha_aluno FOREIGN KEY (id_aluno)
        REFERENCES tb_aluno (id_aluno)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_ficha_instrutor FOREIGN KEY (id_instrutor)
        REFERENCES tb_instrutor (id_instrutor)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- ----------------------------------------------------------------------------
-- 9. ENTIDADE: EXERCICIO (catálogo de movimentos)
-- RN15: nome único, grupo muscular obrigatório, tipo restrito.
-- ----------------------------------------------------------------------------
CREATE TABLE tb_exercicio (
    id_exercicio           SERIAL,
    nome_exercicio         VARCHAR(100) NOT NULL,
    grupo_muscular         VARCHAR(50)  NOT NULL,
    equipamento_utilizado  VARCHAR(80)  NULL,                       -- opcional (peso corporal)
    tipo_exercicio         VARCHAR(30)  NOT NULL DEFAULT 'Musculação',

    CONSTRAINT pk_exercicio      PRIMARY KEY (id_exercicio),
    CONSTRAINT uq_exercicio_nome UNIQUE (nome_exercicio),                                       -- RN15
    CONSTRAINT ck_exercicio_tipo CHECK (tipo_exercicio IN ('Musculação', 'Cardiovascular', 'Funcional', 'Alongamento')) -- RN15
);

-- ----------------------------------------------------------------------------
-- 10. ASSOCIATIVA N:N COM ATRIBUTOS PRÓPRIOS: FICHA_EXERCICIO (FICHA x EXERCICIO)
-- RN16: ordem de execução > 0, séries > 0, divisão semanal em A, B, C ou D,
--       descanso >= 0.
-- Chave natural composta (id_ficha, id_exercicio): impede o mesmo exercício
-- duas vezes na mesma ficha.
-- ----------------------------------------------------------------------------
CREATE TABLE tb_ficha_exercicio (
    id_ficha               INT          NOT NULL,
    id_exercicio           INT          NOT NULL,
    ordem_execucao         SMALLINT     NOT NULL,
    dia_semana_divisao     CHAR(1)      NOT NULL,
    series                 SMALLINT     NOT NULL DEFAULT 3,
    repeticoes             VARCHAR(20)  NOT NULL DEFAULT '10 a 12',
    carga_sugerida_kg      NUMERIC(5,2) NULL,                       -- opcional (peso corporal / cardio)
    tempo_descanso_seg     SMALLINT     NOT NULL DEFAULT 60,

    CONSTRAINT pk_ficha_exercicio   PRIMARY KEY (id_ficha, id_exercicio),
    CONSTRAINT uq_ficha_ex_ordem    UNIQUE (id_ficha, dia_semana_divisao, ordem_execucao),      -- RN16: ordem única por divisão
    CONSTRAINT ck_ficha_ex_ordem    CHECK (ordem_execucao > 0),                                 -- RN16
    CONSTRAINT ck_ficha_ex_divisao  CHECK (dia_semana_divisao IN ('A', 'B', 'C', 'D')),         -- RN16
    CONSTRAINT ck_ficha_ex_series   CHECK (series > 0),                                         -- RN16
    CONSTRAINT ck_ficha_ex_carga    CHECK (carga_sugerida_kg IS NULL OR carga_sugerida_kg >= 0),
    CONSTRAINT ck_ficha_ex_descanso CHECK (tempo_descanso_seg >= 0),                            -- RN16
    CONSTRAINT fk_ficha_ex_ficha FOREIGN KEY (id_ficha)
        REFERENCES tb_ficha_treino (id_ficha)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_ficha_ex_exercicio FOREIGN KEY (id_exercicio)
        REFERENCES tb_exercicio (id_exercicio)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- ----------------------------------------------------------------------------
-- 11. ENTIDADE DE MAIOR MOVIMENTO: PAGAMENTO (faturas/parcelas)
-- RN17: vinculada a um contrato, valor faturado > 0, status restrito.
-- RN18: ao quitar, valor pago >= 0 e forma de pagamento entre as autorizadas;
--       uma fatura 'Pago' exige data, valor e forma de pagamento preenchidos;
--       faturas 'Pendente'/'Atrasado' não possuem data de pagamento.
-- RN19: inadimplência = vencimento ultrapassado sem quitação (status 'Atrasado').
-- ----------------------------------------------------------------------------
CREATE TABLE tb_pagamento (
    id_pagamento           SERIAL,
    id_contrato            INT           NOT NULL,
    data_vencimento        DATE          NOT NULL,
    data_pagamento         DATE          NULL,
    valor_faturado         NUMERIC(10,2) NOT NULL,
    valor_pago             NUMERIC(10,2) NULL,
    forma_pagamento        VARCHAR(30)   NULL,
    status_pagamento       VARCHAR(20)   NOT NULL DEFAULT 'Pendente',
    codigo_transacao_banco VARCHAR(80)   NULL,

    CONSTRAINT pk_pagamento           PRIMARY KEY (id_pagamento),
    CONSTRAINT uq_pagamento_transacao UNIQUE (codigo_transacao_banco),
    CONSTRAINT ck_pagamento_valor_fat CHECK (valor_faturado > 0.00),                            -- RN17
    CONSTRAINT ck_pagamento_valor_pg  CHECK (valor_pago IS NULL OR valor_pago >= 0.00),         -- RN18
    CONSTRAINT ck_pagamento_status    CHECK (status_pagamento IN ('Pago', 'Pendente', 'Atrasado', 'Cancelado', 'Estornado')), -- RN17
    CONSTRAINT ck_pagamento_forma     CHECK (forma_pagamento IS NULL
                                             OR forma_pagamento IN ('Cartão de Crédito', 'Cartão de Débito', 'Boleto', 'Pix', 'Dinheiro')), -- RN18
    CONSTRAINT ck_pagamento_quitacao  CHECK (status_pagamento <> 'Pago'
                                             OR (data_pagamento IS NOT NULL AND valor_pago IS NOT NULL AND forma_pagamento IS NOT NULL)), -- RN18
    CONSTRAINT ck_pagamento_em_aberto CHECK (status_pagamento NOT IN ('Pendente', 'Atrasado') OR data_pagamento IS NULL),   -- RN19
    CONSTRAINT fk_pagamento_contrato FOREIGN KEY (id_contrato)                                  -- RN17
        REFERENCES tb_contrato_plano (id_contrato)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- ----------------------------------------------------------------------------
-- 12. TABELA TÉCNICA DE AUDITORIA (base para os gatilhos da Etapa 2 — B6)
-- RN20: alterações críticas em contratos e pagamentos registradas com dados
--       anteriores e posteriores, autor e data/hora.
-- Não é entidade do domínio (não aparece no MER); é infraestrutura de auditoria.
-- ----------------------------------------------------------------------------
CREATE TABLE tb_auditoria_sistema (
    id_auditoria           SERIAL,
    tabela_afetada         VARCHAR(50)  NOT NULL,
    operacao               VARCHAR(10)  NOT NULL,
    id_registro_afetado    VARCHAR(50)  NOT NULL,
    dados_anteriores       JSONB        NULL,                       -- nulo em INSERT
    dados_novos            JSONB        NULL,                       -- nulo em DELETE
    usuario_banco          VARCHAR(60)  NOT NULL DEFAULT CURRENT_USER,
    data_hora              TIMESTAMPTZ  NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_auditoria          PRIMARY KEY (id_auditoria),
    CONSTRAINT ck_auditoria_operacao CHECK (operacao IN ('INSERT', 'UPDATE', 'DELETE'))        -- RN20
);

-- ----------------------------------------------------------------------------
-- ÍNDICES COMPLEMENTARES (prefixo idx_)
-- Observação: cpf, email, registro_cref, codigo_matricula e nome_plano já
-- possuem índice único implícito pelas restrições uq_; por isso NÃO se cria
-- índice redundante sobre essas colunas. Os índices abaixo cobrem chaves
-- estrangeiras e filtros frequentes (base para o estudo de desempenho — B4).
-- ----------------------------------------------------------------------------
CREATE INDEX idx_contrato_aluno              ON tb_contrato_plano (id_aluno);
CREATE INDEX idx_contrato_plano              ON tb_contrato_plano (id_plano);
CREATE INDEX idx_pagamento_contrato          ON tb_pagamento (id_contrato);
CREATE INDEX idx_pagamento_status_vencimento ON tb_pagamento (status_pagamento, data_vencimento);
CREATE INDEX idx_avaliacao_aluno_data        ON tb_avaliacao_fisica (id_aluno, data_avaliacao);
CREATE INDEX idx_avaliacao_instrutor         ON tb_avaliacao_fisica (id_instrutor_avaliador);
CREATE INDEX idx_ficha_aluno                 ON tb_ficha_treino (id_aluno);
CREATE INDEX idx_ficha_instrutor             ON tb_ficha_treino (id_instrutor);
CREATE INDEX idx_ficha_ex_exercicio          ON tb_ficha_exercicio (id_exercicio);
CREATE INDEX idx_hist_aluno_data             ON tb_historico_matricula (id_aluno, data_evento);

-- ----------------------------------------------------------------------------
-- VISÕES (citadas no relatório, A5; base da tela de relatório consolidado — B1)
-- ----------------------------------------------------------------------------

-- Receita faturada, recebida e em aberto por plano e competência mensal.
CREATE VIEW vw_relatorio_gerencial_financeiro AS
SELECT
    pl.id_plano,
    pl.nome_plano,
    DATE_TRUNC('month', pg.data_vencimento)::DATE                                   AS competencia,
    COUNT(pg.id_pagamento)                                                           AS qtd_faturas,
    SUM(pg.valor_faturado)                                                           AS total_faturado,
    COALESCE(SUM(pg.valor_pago) FILTER (WHERE pg.status_pagamento = 'Pago'), 0)      AS total_recebido,
    COALESCE(SUM(pg.valor_faturado) FILTER (WHERE pg.status_pagamento IN ('Pendente', 'Atrasado')), 0) AS total_em_aberto,
    COUNT(*) FILTER (WHERE pg.status_pagamento = 'Atrasado')                         AS qtd_atrasadas
FROM tb_pagamento pg
INNER JOIN tb_contrato_plano c  ON c.id_contrato = pg.id_contrato
INNER JOIN tb_plano          pl ON pl.id_plano   = c.id_plano
GROUP BY pl.id_plano, pl.nome_plano, DATE_TRUNC('month', pg.data_vencimento);

-- Cada aluno com o instrutor responsável pela sua ficha de treino mais recente
-- (alunos ainda sem ficha aparecem com instrutor nulo).
CREATE VIEW vw_alunos_instrutor AS
SELECT
    a.id_aluno,
    p.nome_completo          AS aluno,
    a.codigo_matricula,
    a.status_cadastral,
    f.id_ficha,
    f.objetivo_treino,
    f.nivel_dificuldade,
    f.data_validade,
    pi.nome_completo         AS instrutor,
    i.registro_cref,
    i.especialidade_primaria
FROM tb_aluno a
INNER JOIN tb_pessoa p ON p.id_pessoa = a.id_aluno
LEFT JOIN LATERAL (
    SELECT ft.*
    FROM tb_ficha_treino ft
    WHERE ft.id_aluno = a.id_aluno
    ORDER BY ft.data_prescricao DESC, ft.id_ficha DESC
    LIMIT 1
) f ON TRUE
LEFT JOIN tb_instrutor i  ON i.id_instrutor = f.id_instrutor
LEFT JOIN tb_pessoa    pi ON pi.id_pessoa   = i.id_instrutor;

-- Fim do Script DDL
=======
-- Limpeza preventiva de objetos caso já existam (execução limpa)
DROP TABLE IF EXISTS tb_auditoria_sistema CASCADE;
DROP TABLE IF EXISTS tb_ficha_exercicio CASCADE;
DROP TABLE IF EXISTS tb_exercicio CASCADE;
DROP TABLE IF EXISTS tb_ficha_treino CASCADE;
DROP TABLE IF EXISTS tb_avaliacao_fisica CASCADE;
DROP TABLE IF EXISTS tb_pagamento CASCADE;
DROP TABLE IF EXISTS tb_historico_matricula CASCADE;
DROP TABLE IF EXISTS tb_contrato_plano CASCADE;
DROP TABLE IF EXISTS tb_plano CASCADE;
DROP TABLE IF EXISTS tb_aluno CASCADE;
DROP TABLE IF EXISTS tb_instrutor CASCADE;
DROP TABLE IF EXISTS tb_pessoa CASCADE;

-- ----------------------------------------------------------------------------
-- 1. SUPERCLASSE: PESSOA
-- Atende a RN01 (Identificação de indivíduos no domínio acadêmico)
-- ----------------------------------------------------------------------------
CREATE TABLE tb_pessoa (
    id_pessoa              SERIAL,
    nome_completo          VARCHAR(120) NOT NULL,
    cpf                    CHAR(11)     NOT NULL,
    email                  VARCHAR(120) NOT NULL,
    telefone               VARCHAR(20)  NULL,
    data_nascimento        DATE         NOT NULL,
    genero                 CHAR(1)      NOT NULL DEFAULT 'N',
    data_cadastro          TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,

    -- Restrições nomeadas conforme convenção (pk_, uq_, ck_)
    CONSTRAINT pk_pessoa PRIMARY KEY (id_pessoa),
    CONSTRAINT uq_pessoa_cpf UNIQUE (cpf),
    CONSTRAINT uq_pessoa_email UNIQUE (email),
    CONSTRAINT ck_pessoa_cpf_digitos CHECK (cpf ~ '^[0-9]{11}$'),
    CONSTRAINT ck_pessoa_email_formato CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'),
    CONSTRAINT ck_pessoa_data_nasc CHECK (data_nascimento <= CURRENT_DATE),
    CONSTRAINT ck_pessoa_genero CHECK (genero IN ('M', 'F', 'O', 'N'))
);

-- ----------------------------------------------------------------------------
-- 2. SUBCLASSE: INSTRUTOR
-- Atende a RN02, RN03 e Autorrelacionamento de supervisão técnica
-- ----------------------------------------------------------------------------
CREATE TABLE tb_instrutor (
    id_instrutor           INT          NOT NULL,
    registro_cref          VARCHAR(20)  NOT NULL,
    especialidade_primaria VARCHAR(60)  NOT NULL,
    data_admissao          DATE         NOT NULL DEFAULT CURRENT_DATE,
    salario_base           NUMERIC(10,2) NOT NULL,
    id_supervisor          INT          NULL,

    CONSTRAINT pk_instrutor PRIMARY KEY (id_instrutor),
    CONSTRAINT uq_instrutor_cref UNIQUE (registro_cref),
    CONSTRAINT ck_instrutor_salario CHECK (salario_base > 0.00),
    CONSTRAINT fk_instrutor_pessoa FOREIGN KEY (id_instrutor)
        REFERENCES tb_pessoa (id_pessoa)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    -- Autorrelacionamento: Instrutor coordenador/supervisor
    CONSTRAINT fk_instrutor_supervisor FOREIGN KEY (id_supervisor)
        REFERENCES tb_instrutor (id_instrutor)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- ----------------------------------------------------------------------------
-- 3. SUBCLASSE: ALUNO
-- Atende a RN04, RN05 e Autorrelacionamento de indicação de novos membros
-- ----------------------------------------------------------------------------
CREATE TABLE tb_aluno (
    id_aluno               INT          NOT NULL,
    codigo_matricula       VARCHAR(20)  NOT NULL,
    status_cadastral       VARCHAR(20)  NOT NULL DEFAULT 'Ativo',
    id_aluno_indicador     INT          NULL,

    CONSTRAINT pk_aluno PRIMARY KEY (id_aluno),
    CONSTRAINT uq_aluno_matricula UNIQUE (codigo_matricula),
    CONSTRAINT ck_aluno_status CHECK (status_cadastral IN ('Ativo', 'Trancado', 'Cancelado', 'Inadimplente')),
    CONSTRAINT fk_aluno_pessoa FOREIGN KEY (id_aluno)
        REFERENCES tb_pessoa (id_pessoa)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    -- Autorrelacionamento: Aluno que indicou este novo aluno (programa de benefícios)
    CONSTRAINT fk_aluno_indicador FOREIGN KEY (id_aluno_indicador)
        REFERENCES tb_aluno (id_aluno)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

-- ----------------------------------------------------------------------------
-- 4. ENTIDADE: PLANO
-- Atende a RN06 (Catálogo e precificação de planos de acesso)
-- ----------------------------------------------------------------------------
CREATE TABLE tb_plano (
    id_plano               SERIAL,
    nome_plano             VARCHAR(60)  NOT NULL,
    descricao              VARCHAR(255) NULL,
    duracao_meses          SMALLINT     NOT NULL DEFAULT 1,
    valor_mensal           NUMERIC(10,2) NOT NULL,
    permite_todas_unidades BOOLEAN      NOT NULL DEFAULT FALSE,
    ativo                  BOOLEAN      NOT NULL DEFAULT TRUE,

    CONSTRAINT pk_plano PRIMARY KEY (id_plano),
    CONSTRAINT uq_plano_nome UNIQUE (nome_plano),
    CONSTRAINT ck_plano_duracao CHECK (duracao_meses > 0),
    CONSTRAINT ck_plano_valor CHECK (valor_mensal > 0.00)
);

-- ----------------------------------------------------------------------------
-- 5. RELACIONAMENTO N:N COM ATRIBUTOS PRÓPRIOS: CONTRATO_PLANO
-- Associação Aluno x Plano com vigência e regras financeiras (RN07, RN08)
-- ----------------------------------------------------------------------------
CREATE TABLE tb_contrato_plano (
    id_contrato            SERIAL,
    id_aluno               INT          NOT NULL,
    id_plano               INT          NOT NULL,
    data_inicio            DATE         NOT NULL DEFAULT CURRENT_DATE,
    data_termino           DATE         NOT NULL,
    valor_acordado         NUMERIC(10,2) NOT NULL,
    dia_vencimento_mensal  SMALLINT     NOT NULL DEFAULT 10,
    situacao_contrato      VARCHAR(20)  NOT NULL DEFAULT 'Vigente',

    CONSTRAINT pk_contrato_plano PRIMARY KEY (id_contrato),
    CONSTRAINT ck_contrato_datas CHECK (data_termino > data_inicio),
    CONSTRAINT ck_contrato_valor CHECK (valor_acordado > 0.00),
    CONSTRAINT ck_contrato_vencimento CHECK (dia_vencimento_mensal BETWEEN 1 AND 28),
    CONSTRAINT ck_contrato_situacao CHECK (situacao_contrato IN ('Vigente', 'Encerrado', 'Rescindido', 'Suspenso')),
    CONSTRAINT fk_contrato_aluno FOREIGN KEY (id_aluno)
        REFERENCES tb_aluno (id_aluno)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT fk_contrato_plano FOREIGN KEY (id_plano)
        REFERENCES tb_plano (id_plano)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- ----------------------------------------------------------------------------
-- 6. ATRIBUTO TEMPORAL / HISTÓRICO: HISTORICO_MATRICULA
-- Histórico datado de mudanças de situação da matrícula do aluno (RN09)
-- ----------------------------------------------------------------------------
CREATE TABLE tb_historico_matricula (
    id_historico           SERIAL,
    id_aluno               INT          NOT NULL,
    data_evento            TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    situacao_anterior      VARCHAR(20)  NULL,
    situacao_nova          VARCHAR(20)  NOT NULL,
    motivo_alteracao       VARCHAR(200) NOT NULL,
    usuario_responsavel    VARCHAR(60)  NOT NULL DEFAULT 'sistema',

    CONSTRAINT pk_historico_matricula PRIMARY KEY (id_historico),
    CONSTRAINT ck_hist_situacao_nova CHECK (situacao_nova IN ('Ativo', 'Trancado', 'Cancelado', 'Inadimplente')),
    CONSTRAINT fk_hist_aluno FOREIGN KEY (id_aluno)
        REFERENCES tb_aluno (id_aluno)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- ----------------------------------------------------------------------------
-- 7. ENTIDADE FRACA: AVALIACAO_FISICA (Identificação por dependência do Aluno)
-- Atende a RN10, RN11 e RN12 (Série histórica de medidas antropométricas e IMC)
-- Chave Primária Composta pela chave estrangeira do Aluno + número sequencial
-- ----------------------------------------------------------------------------
CREATE TABLE tb_avaliacao_fisica (
    id_aluno               INT          NOT NULL,
    num_sequencial         INT          NOT NULL,
    id_instrutor_avaliador INT          NOT NULL,
    data_avaliacao         DATE         NOT NULL DEFAULT CURRENT_DATE,
    peso_kg                NUMERIC(5,2) NOT NULL,
    altura_m               NUMERIC(3,2) NOT NULL,
    percentual_gordura     NUMERIC(4,2) NULL,
    circunferencia_cintura NUMERIC(5,2) NULL,
    circunferencia_quadril NUMERIC(5,2) NULL,
    pressao_arterial       VARCHAR(10)  NULL,
    observacoes_clinicas   TEXT         NULL,

    -- Chave composta garantindo a identificação fraca
    CONSTRAINT pk_avaliacao_fisica PRIMARY KEY (id_aluno, num_sequencial),
    CONSTRAINT ck_avaliacao_peso CHECK (peso_kg BETWEEN 20.00 AND 350.00),
    CONSTRAINT ck_avaliacao_altura CHECK (altura_m BETWEEN 0.80 AND 2.50),
    CONSTRAINT ck_avaliacao_gordura CHECK (percentual_gordura IS NULL OR (percentual_gordura BETWEEN 1.00 AND 60.00)),
    CONSTRAINT fk_avaliacao_aluno FOREIGN KEY (id_aluno)
        REFERENCES tb_aluno (id_aluno)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_avaliacao_instrutor FOREIGN KEY (id_instrutor_avaliador)
        REFERENCES tb_instrutor (id_instrutor)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- ----------------------------------------------------------------------------
-- 8. ENTIDADE: FICHA_TREINO
-- Atende a RN13, RN14 (Prescrição de rotinas de exercícios)
-- ----------------------------------------------------------------------------
CREATE TABLE tb_ficha_treino (
    id_ficha               SERIAL,
    id_aluno               INT          NOT NULL,
    id_instrutor           INT          NOT NULL,
    data_prescricao        DATE         NOT NULL DEFAULT CURRENT_DATE,
    data_validade          DATE         NOT NULL,
    objetivo_treino        VARCHAR(60)  NOT NULL, -- Ex: Hipertrofia, Emagrecimento, Reabilitação
    nivel_dificuldade      VARCHAR(20)  NOT NULL DEFAULT 'Iniciante',
    observacoes            VARCHAR(255) NULL,

    CONSTRAINT pk_ficha_treino PRIMARY KEY (id_ficha),
    CONSTRAINT ck_ficha_validade CHECK (data_validade >= data_prescricao),
    CONSTRAINT ck_ficha_nivel CHECK (nivel_dificuldade IN ('Iniciante', 'Intermediário', 'Avançado', 'Atleta')),
    CONSTRAINT fk_ficha_aluno FOREIGN KEY (id_aluno)
        REFERENCES tb_aluno (id_aluno)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_ficha_instrutor FOREIGN KEY (id_instrutor)
        REFERENCES tb_instrutor (id_instrutor)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- ----------------------------------------------------------------------------
-- 9. ENTIDADE: EXERCICIO (Catálogo de Exercícios)
-- Atende a RN15 (Classificação de movimentos e grupos musculares)
-- ----------------------------------------------------------------------------
CREATE TABLE tb_exercicio (
    id_exercicio           SERIAL,
    nome_exercicio         VARCHAR(100) NOT NULL,
    grupo_muscular         VARCHAR(50)  NOT NULL, -- Peitoral, Dorsal, Quadríceps, etc.
    equipamento_utilizado  VARCHAR(80)  NULL,
    tipo_exercicio         VARCHAR(30)  NOT NULL DEFAULT 'Musculação',

    CONSTRAINT pk_exercicio PRIMARY KEY (id_exercicio),
    CONSTRAINT uq_exercicio_nome UNIQUE (nome_exercicio),
    CONSTRAINT ck_exercicio_tipo CHECK (tipo_exercicio IN ('Musculação', 'Cardiovascular', 'Funcional', 'Alongamento'))
);

-- ----------------------------------------------------------------------------
-- 10. RELACIONAMENTO N:N COM ATRIBUTOS PRÓPRIOS: FICHA_EXERCICIO
-- Associação Ficha de Treino x Exercício (RN16)
-- ----------------------------------------------------------------------------
CREATE TABLE tb_ficha_exercicio (
    id_ficha               INT          NOT NULL,
    id_exercicio           INT          NOT NULL,
    ordem_execucao         SMALLINT     NOT NULL,
    dia_semana_divisao     CHAR(1)      NOT NULL, -- 'A', 'B', 'C', 'D'
    series                 SMALLINT     NOT NULL DEFAULT 3,
    repeticoes             VARCHAR(20)  NOT NULL DEFAULT '10 a 12',
    carga_sugerida_kg      NUMERIC(5,2) NULL,
    tempo_descanso_seg     SMALLINT     NOT NULL DEFAULT 60,

    CONSTRAINT pk_ficha_exercicio PRIMARY KEY (id_ficha, id_exercicio),
    CONSTRAINT ck_ficha_ex_ordem CHECK (ordem_execucao > 0),
    CONSTRAINT ck_ficha_ex_series CHECK (series > 0),
    CONSTRAINT ck_ficha_ex_descanso CHECK (tempo_descanso_seg >= 0),
    CONSTRAINT fk_ficha_ex_ficha FOREIGN KEY (id_ficha)
        REFERENCES tb_ficha_treino (id_ficha)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_ficha_ex_exercicio FOREIGN KEY (id_exercicio)
        REFERENCES tb_exercicio (id_exercicio)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- ----------------------------------------------------------------------------
-- 11. ENTIDADE DE MAIOR MOVIMENTO: PAGAMENTO
-- Atende a RN17, RN18, RN19 (Gestão contábil e status financeiro)
-- ----------------------------------------------------------------------------
CREATE TABLE tb_pagamento (
    id_pagamento           SERIAL,
    id_contrato            INT          NOT NULL,
    data_vencimento        DATE         NOT NULL,
    data_pagamento         DATE         NULL,
    valor_faturado         NUMERIC(10,2) NOT NULL,
    valor_pago             NUMERIC(10,2) NULL,
    forma_pagamento        VARCHAR(30)  NULL,
    status_pagamento       VARCHAR(20)  NOT NULL DEFAULT 'Pendente',
    codigo_transacao_banco VARCHAR(80)  NULL,

    CONSTRAINT pk_pagamento PRIMARY KEY (id_pagamento),
    CONSTRAINT ck_pagamento_valor_fat CHECK (valor_faturado > 0.00),
    CONSTRAINT ck_pagamento_valor_pg CHECK (valor_pago IS NULL OR valor_pago >= 0.00),
    CONSTRAINT ck_pagamento_status CHECK (status_pagamento IN ('Pago', 'Pendente', 'Atrasado', 'Cancelado', 'Estornado')),
    CONSTRAINT ck_pagamento_forma CHECK (forma_pagamento IS NULL OR forma_pagamento IN ('Cartão de Crédito', 'Boleto Bancário', 'Pix', 'Dinheiro', 'Débito')),
    CONSTRAINT fk_pagamento_contrato FOREIGN KEY (id_contrato)
        REFERENCES tb_contrato_plano (id_contrato)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
);

-- ----------------------------------------------------------------------------
-- 12. TABELA DE AUDITORIA (Requisito B6 - Triggers e Auditoria)
-- Atende a RN20 (Rastreabilidade de alterações sensíveis)
-- ----------------------------------------------------------------------------
CREATE TABLE tb_auditoria_sistema (
    id_auditoria           SERIAL,
    tabela_afetada         VARCHAR(50)  NOT NULL,
    operacao               VARCHAR(10)  NOT NULL, -- 'INSERT', 'UPDATE', 'DELETE'
    id_registro_afetado    VARCHAR(50)  NOT NULL,
    dados_anteriores       JSONB        NULL,
    dados_novos            JSONB        NULL,
    usuario_banco          VARCHAR(60)  NOT NULL DEFAULT CURRENT_USER,
    data_hora              TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT pk_auditoria PRIMARY KEY (id_auditoria),
    CONSTRAINT ck_auditoria_operacao CHECK (operacao IN ('INSERT', 'UPDATE', 'DELETE'))
);

-- ----------------------------------------------------------------------------
-- ÍNDICES COMPLEMENTARES PARA OTIMIZAÇÃO (Requisito B4 / idx_)
-- ----------------------------------------------------------------------------
CREATE INDEX idx_pessoa_cpf ON tb_pessoa (cpf);
CREATE INDEX idx_contrato_aluno ON tb_contrato_plano (id_aluno);
CREATE INDEX idx_pagamento_status_vencimento ON tb_pagamento (status_pagamento, data_vencimento);
CREATE INDEX idx_avaliacao_aluno_data ON tb_avaliacao_fisica (id_aluno, data_avaliacao);
CREATE INDEX idx_ficha_aluno ON tb_ficha_treino (id_aluno);

-- Fim do Script DDL
>>>>>>> e05d4890ecf0775fec04a7a5ecf22591c15f59d4
