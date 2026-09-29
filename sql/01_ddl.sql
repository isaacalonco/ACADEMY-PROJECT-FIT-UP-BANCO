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
