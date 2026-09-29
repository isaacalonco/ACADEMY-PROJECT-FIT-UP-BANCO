-- ----------------------------------------------------------------------------
-- 1. CARGA DE PESSOAS (50 Registros: Instrutores e Alunos)
-- ----------------------------------------------------------------------------
INSERT INTO tb_pessoa (nome_completo, cpf, email, telefone, data_nascimento, genero, data_cadastro) VALUES
-- Instrutores (IDs 1 a 6)
('Carlos Eduardo Silveira', '10100011101', 'carlos.silveira@fitup.com', '(61) 98111-0001', '1985-03-12', 'M', '2024-01-10 08:00:00'),
('Mariana Ferreira Lima',   '10100011102', 'mariana.lima@fitup.com',     '(61) 98111-0002', '1989-07-22', 'F', '2024-01-10 08:30:00'),
('Rodrigo Santos Barreto',  '10100011103', 'rodrigo.barreto@fitup.com',  '(61) 98111-0003', '1992-11-05', 'M', '2024-01-15 09:00:00'),
('Camila Guimaraes Rocha',  '10100011104', 'camila.rocha@fitup.com',     '(61) 98111-0004', '1994-01-30', 'F', '2024-01-15 09:30:00'),
('Felipe Nogueira Dias',    '10100011105', 'felipe.dias@fitup.com',       NULL,              '1990-09-18', 'M', '2024-02-01 10:00:00'), -- Telefone opcional nulo
('Juliana Barbosa Mendes',  '10100011106', 'juliana.mendes@fitup.com',    '(61) 98111-0006', '1988-04-14', 'F', '2024-02-01 10:30:00'),

-- Alunos (IDs 7 a 50) - 44 alunos cadastrados
('Lucas Gabriel Santos',     '20200022201', 'lucas.santos@email.com',     '(61) 99123-0001', '1995-02-15', 'M', '2024-02-05 14:00:00'),
('Beatriz Albuquerque Lima','20200022202', 'beatriz.lima@email.com',     '(61) 99123-0002', '1998-06-20', 'F', '2024-02-05 14:15:00'),
('Gustavo Henrique Prado',   '20200022203', 'gustavo.prado@email.com',    '(61) 99123-0003', '1993-10-11', 'M', '2024-02-06 11:00:00'),
('Larissa Vasconcelos Rios', '20200022204', 'larissa.rios@email.com',     NULL,              '2000-04-03', 'F', '2024-02-06 11:30:00'), -- Telefone opcional nulo
('Thiago Carvalho Melo',     '20200022205', 'thiago.melo@email.com',      '(61) 99123-0005', '1987-12-25', 'M', '2024-02-07 16:00:00'),
('Fernanda Antunes Maia',    '20200022206', 'fernanda.maia@email.com',    '(61) 99123-0006', '1996-08-19', 'F', '2024-02-07 16:20:00'),
('Matheus Dantas Castro',    '20200022207', 'matheus.castro@email.com',   '(61) 99123-0007', '1991-05-14', 'M', '2024-02-08 09:10:00'),
('Patricia Fontes Ribeiro',  '20200022208', 'patricia.ribeiro@email.com', '(61) 99123-0008', '1989-03-08', 'F', '2024-02-08 09:40:00'),
('Andre Luis Camargo',       '20200022209', 'andre.camargo@email.com',    '(61) 99123-0009', '1994-09-29', 'M', '2024-02-09 15:00:00'),
('Renata Farias Bezerra',    '20200022210', 'renata.bezerra@email.com',   NULL,              '1997-11-17', 'F', '2024-02-09 15:30:00'),
('Vinicius Macedo Paiva',    '20200022211', 'vinicius.paiva@email.com',   '(61) 99123-0011', '1992-01-09', 'M', '2024-02-10 10:00:00'),
('Vanessa Teixeira Costa',   '20200022212', 'vanessa.costa@email.com',    '(61) 99123-0012', '1999-07-13', 'F', '2024-02-10 10:30:00'),
('Diego Moreira Brandao',    '20200022213', 'diego.brandao@email.com',    '(61) 99123-0013', '1986-04-27', 'M', '2024-02-11 11:15:00'),
('Aline Pimentel Duarte',    '20200022214', 'aline.duarte@email.com',     '(61) 99123-0014', '2001-02-28', 'F', '2024-02-11 11:45:00'),
('Rafael Gomes Correa',      '20200022215', 'rafael.correa@email.com',    '(61) 99123-0015', '1990-12-04', 'M', '2024-02-12 14:10:00'),
('Tatiane Soares Moura',     '20200022216', 'tatiane.moura@email.com',    '(61) 99123-0016', '1995-09-02', 'F', '2024-02-12 14:40:00'),
('Leonardo Couto Viana',     '20200022217', 'leonardo.viana@email.com',   '(61) 99123-0017', '1993-06-18', 'M', '2024-02-13 16:00:00'),
('Bruna Peixoto Ramos',      '20200022218', 'bruna.ramos@email.com',      '(61) 99123-0018', '1998-03-23', 'F', '2024-02-13 16:30:00'),
('Marcio Azevedo Cruz',      '20200022219', 'marcio.cruz@email.com',      NULL,              '1984-08-16', 'M', '2024-02-14 09:00:00'),
('Priscila Muniz Borges',    '20200022220', 'priscila.borges@email.com',  '(61) 99123-0020', '1996-10-31', 'F', '2024-02-14 09:30:00'),
('Alexandre Siqueira Neves', '20200022221', 'alexandre.neves@email.com', '(61) 99123-0021', '1988-05-07', 'M', '2024-02-15 13:00:00'),
('Monique Guedes Santana',   '20200022222', 'monique.santana@email.com',  '(61) 99123-0022', '1997-04-12', 'F', '2024-02-15 13:30:00'),
('Leandro Barros Rezende',   '20200022223', 'leandro.rezende@email.com',  '(61) 99123-0023', '1991-02-19', 'M', '2024-02-16 10:15:00'),
('Debora Cavalcante Brito',  '20200022224', 'debora.brito@email.com',     '(61) 99123-0024', '1994-12-08', 'F', '2024-02-16 10:45:00'),
('Caio Freitas Medeiros',    '20200022225', 'caio.medeiros@email.com',    '(61) 99123-0025', '1996-01-21', 'M', '2024-02-17 14:00:00'),
('Jessica Dorneles Bueno',   '20200022226', 'jessica.bueno@email.com',    '(61) 99123-0026', '1993-07-15', 'F', '2024-02-17 14:30:00'),
('Igor Esteves Figueiredo',  '20200022227', 'igor.figueiredo@email.com',  '(61) 99123-0027', '1990-11-28', 'M', '2024-02-18 15:20:00'),
('Sabrina Toledo Queiroz',   '20200022228', 'sabrina.queiroz@email.com',  NULL,              '1999-05-09', 'F', '2024-02-18 15:50:00'),
('Victor Hugo Sanches',      '20200022229', 'victor.sanches@email.com',   '(61) 99123-0029', '1995-03-14', 'M', '2024-02-19 09:00:00'),
('Flavia Pacheco Lacerda',   '20200022230', 'flavia.lacerda@email.com',   '(61) 99123-0030', '1987-10-06', 'F', '2024-02-19 09:30:00'),
('Samuel Xavier Teles',      '20200022231', 'samuel.teles@email.com',     '(61) 99123-0031', '1992-08-24', 'M', '2024-02-20 11:00:00'),
('Helena Godoy Meireles',    '20200022232', 'helena.meireles@email.com',  '(61) 99123-0032', '1998-12-16', 'F', '2024-02-20 11:30:00'),
('Murilo Assis Fagundes',    '20200022233', 'murilo.fagundes@email.com',  '(61) 99123-0033', '1994-04-18', 'M', '2024-02-21 14:00:00'),
('Leticia Abreu Cunha',      '20200022234', 'leticia.cunha@email.com',    '(61) 99123-0034', '2000-09-07', 'F', '2024-02-21 14:30:00'),
('Danilo Antenor Frota',     '20200022235', 'danilo.frota@email.com',     '(61) 99123-0035', '1991-06-30', 'M', '2024-02-22 16:00:00'),
('Renan Salgado Munhoz',     '20200022236', 'renan.munhoz@email.com',     '(61) 99123-0036', '1996-03-05', 'M', '2024-02-22 16:30:00'),
('Viviane Leite Barcellos',  '20200022237', 'viviane.leite@email.com',    NULL,              '1993-11-22', 'F', '2024-02-23 09:10:00'),
('Douglas Marques Esteves',  '20200022238', 'douglas.esteves@email.com',  '(61) 99123-0038', '1989-08-11', 'M', '2024-02-23 09:40:00'),
('Isabela Franco Pimentel',  '20200022239', 'isabela.franco@email.com',   '(61) 99123-0039', '1997-01-19', 'F', '2024-02-24 10:00:00'),
('Guilherme Paes Landim',    '20200022240', 'guilherme.paes@email.com',   '(61) 99123-0040', '1990-07-27', 'M', '2024-02-24 10:30:00'),
('Lorena Aguiar Portela',    '20200022241', 'lorena.portela@email.com',   '(61) 99123-0041', '1995-10-15', 'F', '2024-02-25 15:00:00'),
('Arthur Meneses Ferraz',    '20200022242', 'arthur.ferraz@email.com',    '(61) 99123-0042', '1992-05-03', 'M', '2024-02-25 15:30:00'),
('Barbara Zanin Dornelles',  '20200022243', 'barbara.zanin@email.com',    '(61) 99123-0043', '1998-02-12', 'F', '2024-02-26 11:15:00'),
('Wesley Batista Pinheiro',  '20200022244', 'wesley.pinheiro@email.com',  '(61) 99123-0044', '1988-12-09', 'M', '2024-02-26 11:45:00');

-- ----------------------------------------------------------------------------
-- 2. CARGA DE INSTRUTORES (Com autorrelacionamento de supervisão)
-- ----------------------------------------------------------------------------
-- Carlos (1) é o coordenador geral (supervisor = NULL)
INSERT INTO tb_instrutor (id_instrutor, registro_cref, especialidade_primaria, data_admissao, salario_base, id_supervisor) VALUES
(1, 'CREF-012345-G/DF', 'Coordenação e Fisiologia', '2022-01-15', 5500.00, NULL),
(2, 'CREF-023456-G/DF', 'Musculação e Hipertrofia', '2022-06-01', 3800.00, 1),
(3, 'CREF-034567-G/DF', 'Treinamento Funcional',     '2023-02-10', 3600.00, 1),
(4, 'CREF-045678-G/DF', 'Pilates e Reabilitação',    '2023-05-15', 4000.00, 1),
(5, 'CREF-056789-G/DF', 'Cardiovascular e HIIT',    '2023-08-20', 3500.00, 1),
(6, 'CREF-067890-G/DF', 'Artes Marciais e Luta',     '2023-11-01', 3700.00, 1);

-- ----------------------------------------------------------------------------
-- 3. CARGA DE ALUNOS (44 Registros com autorrelacionamento de indicação)
-- ----------------------------------------------------------------------------
INSERT INTO tb_aluno (id_aluno, codigo_matricula, status_cadastral, id_aluno_indicador) VALUES
(7,  'MAT-2024-0001', 'Ativo',        NULL),
(8,  'MAT-2024-0002', 'Ativo',        7),    -- Beatriz indicada por Lucas (7)
(9,  'MAT-2024-0003', 'Ativo',        7),    -- Gustavo indicado por Lucas (7)
(10, 'MAT-2024-0004', 'Trancado',     NULL), -- Aluno com matrícula trancada (caso de contorno)
(11, 'MAT-2024-0005', 'Ativo',        NULL),
(12, 'MAT-2024-0006', 'Ativo',        11),
(13, 'MAT-2024-0007', 'Ativo',        NULL),
(14, 'MAT-2024-0008', 'Ativo',        NULL),
(15, 'MAT-2024-0009', 'Ativo',        14),
(16, 'MAT-2024-0010', 'Inadimplente', NULL), -- Aluno inadimplente (caso de contorno)
(17, 'MAT-2024-0011', 'Ativo',        NULL),
(18, 'MAT-2024-0012', 'Ativo',        17),
(19, 'MAT-2024-0013', 'Cancelado',    NULL), -- Aluno cancelado (caso de contorno)
(20, 'MAT-2024-0014', 'Ativo',        NULL),
(21, 'MAT-2024-0015', 'Ativo',        20),
(22, 'MAT-2024-0016', 'Ativo',        NULL),
(23, 'MAT-2024-0017', 'Ativo',        NULL),
(24, 'MAT-2024-0018', 'Ativo',        23),
(25, 'MAT-2024-0019', 'Ativo',        NULL),
(26, 'MAT-2024-0020', 'Ativo',        NULL),
(27, 'MAT-2024-0021', 'Ativo',        26),
(28, 'MAT-2024-0022', 'Ativo',        NULL),
(29, 'MAT-2024-0023', 'Ativo',        NULL),
(30, 'MAT-2024-0024', 'Ativo',        NULL),
(31, 'MAT-2024-0025', 'Ativo',        NULL),
(32, 'MAT-2024-0026', 'Ativo',        NULL),
(33, 'MAT-2024-0027', 'Ativo',        NULL),
(34, 'MAT-2024-0028', 'Ativo',        NULL),
(35, 'MAT-2024-0029', 'Ativo',        NULL),
(36, 'MAT-2024-0030', 'Ativo',        NULL),
(37, 'MAT-2024-0031', 'Ativo',        NULL),
(38, 'MAT-2024-0032', 'Ativo',        NULL),
(39, 'MAT-2024-0033', 'Ativo',        NULL),
(40, 'MAT-2024-0034', 'Ativo',        NULL),
(41, 'MAT-2024-0035', 'Ativo',        NULL),
(42, 'MAT-2024-0036', 'Ativo',        NULL),
(43, 'MAT-2024-0037', 'Ativo',        NULL),
(44, 'MAT-2024-0038', 'Ativo',        NULL),
(45, 'MAT-2024-0039', 'Ativo',        NULL),
(46, 'MAT-2024-0040', 'Ativo',        NULL),
(47, 'MAT-2024-0041', 'Ativo',        NULL),
(48, 'MAT-2024-0042', 'Ativo',        NULL),
(49, 'MAT-2024-0043', 'Ativo',        NULL),
(50, 'MAT-2024-0044', 'Ativo',        NULL);

-- ----------------------------------------------------------------------------
-- 4. CARGA DE PLANOS (5 Opções Comerciais)
-- ----------------------------------------------------------------------------
INSERT INTO tb_plano (nome_plano, descricao, duracao_meses, valor_mensal, permite_todas_unidades, ativo) VALUES
('Plano Mensal Start',     'Acesso exclusivo à musculação em horário livre',            1,   89.90, FALSE, TRUE),
('Plano Trimestral Fit',    'Musculação + Aulas Coletivas (Spinning, Zumba)',            3,  109.90, FALSE, TRUE),
('Plano Semestral Pro',     'Musculação + Coletivas + 1 Avaliação Física gratuita',      6,  129.90, FALSE, TRUE),
('Plano Anual Black VIP',   'Livre acesso a todas as unidades, toalha e bioimpedância', 12,  149.90, TRUE,  TRUE),
('Plano Universitário Off', 'Horário restrito das 10h às 16h com desconto especial',    1,   69.90, FALSE, TRUE);

-- ----------------------------------------------------------------------------
-- 5. CARGA DE CONTRATOS DE PLANOS (44 Contratos - Mais de 40 Linhas)
-- ----------------------------------------------------------------------------
INSERT INTO tb_contrato_plano (id_aluno, id_plano, data_inicio, data_termino, valor_acordado, dia_vencimento_mensal, situacao_contrato) VALUES
(7,  4, '2024-02-05', '2025-02-05', 149.90, 10, 'Vigente'),
(8,  3, '2024-02-05', '2024-08-05', 129.90, 10, 'Vigente'),
(9,  4, '2024-02-06', '2025-02-06', 149.90, 15, 'Vigente'),
(10, 1, '2024-02-06', '2024-03-06',  89.90,  5, 'Suspenso'),
(11, 2, '2024-02-07', '2024-05-07', 109.90, 10, 'Vigente'),
(12, 4, '2024-02-07', '2025-02-07', 149.90, 20, 'Vigente'),
(13, 3, '2024-02-08', '2024-08-08', 129.90, 10, 'Vigente'),
(14, 1, '2024-02-08', '2024-03-08',  89.90, 10, 'Vigente'),
(15, 4, '2024-02-09', '2025-02-09', 149.90, 15, 'Vigente'),
(16, 1, '2024-02-09', '2024-03-09',  89.90,  5, 'Vigente'),
(17, 3, '2024-02-10', '2024-08-10', 129.90, 10, 'Vigente'),
(18, 4, '2024-02-10', '2025-02-10', 149.90, 10, 'Vigente'),
(19, 1, '2024-02-11', '2024-03-11',  89.90, 10, 'Rescindido'),
(20, 2, '2024-02-11', '2024-05-11', 109.90, 15, 'Vigente'),
(21, 4, '2024-02-12', '2025-02-12', 149.90, 20, 'Vigente'),
(22, 5, '2024-02-12', '2024-03-12',  69.90, 10, 'Vigente'),
(23, 4, '2024-02-13', '2025-02-13', 149.90, 10, 'Vigente'),
(24, 3, '2024-02-13', '2024-08-13', 129.90, 15, 'Vigente'),
(25, 4, '2024-02-14', '2025-02-14', 149.90, 10, 'Vigente'),
(26, 2, '2024-02-14', '2024-05-14', 109.90,  5, 'Vigente'),
(27, 4, '2024-02-15', '2025-02-15', 149.90, 10, 'Vigente'),
(28, 5, '2024-02-15', '2024-03-15',  69.90, 10, 'Vigente'),
(29, 3, '2024-02-16', '2024-08-16', 129.90, 15, 'Vigente'),
(30, 4, '2024-02-16', '2025-02-16', 149.90, 20, 'Vigente'),
(31, 1, '2024-02-17', '2024-03-17',  89.90, 10, 'Vigente'),
(32, 4, '2024-02-17', '2025-02-17', 149.90, 10, 'Vigente'),
(33, 2, '2024-02-18', '2024-05-18', 109.90,  5, 'Vigente'),
(34, 4, '2024-02-18', '2025-02-18', 149.90, 15, 'Vigente'),
(35, 3, '2024-02-19', '2024-08-19', 129.90, 10, 'Vigente'),
(36, 4, '2024-02-19', '2025-02-19', 149.90, 10, 'Vigente'),
(37, 5, '2024-02-20', '2024-03-20',  69.90, 20, 'Vigente'),
(38, 4, '2024-02-20', '2025-02-20', 149.90, 10, 'Vigente'),
(39, 1, '2024-02-21', '2024-03-21',  89.90,  5, 'Vigente'),
(40, 4, '2024-02-21', '2025-02-21', 149.90, 15, 'Vigente'),
(41, 3, '2024-02-22', '2024-08-22', 129.90, 10, 'Vigente'),
(42, 2, '2024-02-22', '2024-05-22', 109.90, 10, 'Vigente'),
(43, 4, '2024-02-23', '2025-02-23', 149.90, 20, 'Vigente'),
(44, 1, '2024-02-23', '2024-03-23',  89.90, 10, 'Vigente'),
(45, 4, '2024-02-24', '2025-02-24', 149.90, 15, 'Vigente'),
(46, 5, '2024-02-24', '2024-03-24',  69.90, 10, 'Vigente'),
(47, 4, '2024-02-25', '2025-02-25', 149.90, 10, 'Vigente'),
(48, 3, '2024-02-25', '2024-08-25', 129.90,  5, 'Vigente'),
(49, 4, '2024-02-26', '2025-02-26', 149.90, 10, 'Vigente'),
(50, 2, '2024-02-26', '2024-05-26', 109.90, 15, 'Vigente');

-- ----------------------------------------------------------------------------
-- 6. CARGA DE AVALIAÇÕES FÍSICAS (Entidade Fraca: Chave Composta Aluno + Seq)
-- Séries históricas: múltiplos exames por aluno demonstrando evolução
-- ----------------------------------------------------------------------------
INSERT INTO tb_avaliacao_fisica (id_aluno, num_sequencial, id_instrutor_avaliador, data_avaliacao, peso_kg, altura_m, percentual_gordura, circunferencia_cintura, circunferencia_quadril, pressao_arterial, observacoes_clinicas) VALUES
-- Aluno 7: 3 avaliações ao longo do tempo (evolução evidente)
(7, 1, 1, '2024-02-06', 86.50, 1.80, 24.50, 94.00, 102.00, '12/8', 'Início dos treinos. Leve sobrepeso, sem restrições articulares.'),
(7, 2, 2, '2024-05-10', 82.00, 1.80, 19.80, 88.00, 100.00, '12/8', 'Evolução favorável, perda de gordura e ganho de massa magra.'),
(7, 3, 2, '2024-08-15', 79.50, 1.80, 16.20, 84.00,  99.00, '11/7', 'Excelente condicionamento. Meta de peso atingida.'),

-- Aluno 8: 2 avaliações
(8, 1, 4, '2024-02-08', 64.00, 1.65, 27.00, 74.00,  98.00, '11/7', 'Objetivo de tonificação e condicionamento cardiorrespiratório.'),
(8, 2, 4, '2024-06-12', 61.20, 1.65, 22.50, 69.00,  95.00, '11/7', 'Boa adesão aos treinos de Pilates e musculação.'),

-- Aluno 9: 2 avaliações
(9, 1, 3, '2024-02-10', 94.00, 1.85, 26.00, 98.00, 106.00, '13/8', 'Hipertrofia com atenção à postura lombar.'),
(9, 2, 3, '2024-07-02', 91.00, 1.85, 20.50, 92.00, 104.00, '12/8', 'Redução da gordura visceral e melhora no agachamento.'),

-- Demais alunos: pelo menos 1 avaliação inicial
(11, 1, 2, '2024-02-15', 75.00, 1.74, 18.00, 82.00, 96.00, '12/8', 'Perfil atlético.'),
(12, 1, 4, '2024-02-18', 58.00, 1.62, 23.00, 68.00, 92.00, '11/7', 'Aptidão normal.'),
(13, 1, 5, '2024-02-20', 82.00, 1.78, 21.00, 86.00, 99.00, '12/8', 'Foco em emagrecimento.'),
(15, 1, 1, '2024-02-22', 77.00, 1.75, 19.50, 83.00, 97.00, '12/8', 'Aptidão total.'),
(17, 1, 2, '2024-02-25', 88.00, 1.82, 25.00, 93.00, 103.00, '13/8', 'Iniciante.'),
(18, 1, 4, '2024-02-27', 62.00, 1.68, 24.00, 71.00, 94.00, '11/7', 'Sem queixas.');

-- ----------------------------------------------------------------------------
-- 7. CARGA DE EXERCÍCIOS (Catálogo com 12 Exercícios)
-- ----------------------------------------------------------------------------
INSERT INTO tb_exercicio (nome_exercicio, grupo_muscular, equipamento_utilizado, tipo_exercicio) VALUES
('Supino Reto com Barra',       'Peitoral',    'Banco e Barra Olímpica', 'Musculação'),
('Supino Inclinado com Halteres','Peitoral',    'Banco Inclinado e Halteres', 'Musculação'),
('Puxada Frontal Aberta',       'Dorsal',      'Aparelho Pulley',        'Musculação'),
('Remada Curvada',              'Dorsal',      'Barra e Anilhas',        'Musculação'),
('Agachamento Livre',           'Quadríceps',  'Gaiola de Agachamento',  'Musculação'),
('Leg Press 45 Graus',          'Quadríceps',  'Máquina Leg Press 45',   'Musculação'),
('Mesa Flexora',                'Posterior',   'Máquina Flexora',        'Musculação'),
('Desenvolvimento Militar',     'Ombros',      'Halteres',               'Musculação'),
('Elevação Lateral',            'Ombros',      'Halteres',               'Musculação'),
('Rosca Direta',                'Bíceps',      'Barra W',                'Musculação'),
('Tríceps Corda',               'Tríceps',     'Polia Alta',             'Musculação'),
('Corrida Intervalada na Esteira','Cardiovascular','Esteira Ergométrica', 'Cardiovascular');

-- ----------------------------------------------------------------------------
-- 8. CARGA DE FICHAS DE TREINO E FICHA_EXERCICIO (Relacionamento N:N com atributos)
-- ----------------------------------------------------------------------------
INSERT INTO tb_ficha_treino (id_aluno, id_instrutor, data_prescricao, data_validade, objetivo_treino, nivel_dificuldade, observacoes) VALUES
(7, 2, '2024-02-07', '2024-05-07', 'Hipertrofia ABC', 'Intermediário', 'Priorizar amplitude e cadência de 3 segundos na fase excêntrica.'),
(8, 4, '2024-02-09', '2024-05-09', 'Condicionamento Geral', 'Iniciante', 'Foco na postura e respiração diafragmática.'),
(9, 3, '2024-02-12', '2024-05-12', 'Ganho de Força', 'Avançado', 'Cargas progressivas semanais.');

-- Ficha 1 x Exercícios (Treino A de Peito e Tríceps / Treino B de Costas)
INSERT INTO tb_ficha_exercicio (id_ficha, id_exercicio, ordem_execucao, dia_semana_divisao, series, repeticoes, carga_sugerida_kg, tempo_descanso_seg) VALUES
(1, 1,  1, 'A', 4, '8 a 10',   60.00, 90),
(1, 2,  2, 'A', 3, '10 a 12',  22.00, 60),
(1, 8,  3, 'A', 3, '10 a 12',  16.00, 60),
(1, 11, 4, 'A', 4, '12 a 15',  35.00, 45),
(1, 3,  1, 'B', 4, '10 a 12',  55.00, 75),
(1, 4,  2, 'B', 3, '8 a 10',   45.00, 75),
(1, 10, 3, 'B', 3, '10 a 12',  14.00, 60),
-- Ficha 2 x Exercícios
(2, 5,  1, 'A', 3, '12 a 15',  20.00, 60),
(2, 6,  2, 'A', 3, '12 a 15', 100.00, 60),
(2, 12, 3, 'A', 1, '20 min',    NULL, 0);

-- ----------------------------------------------------------------------------
-- 9. CARGA DA TABELA DE MAIOR MOVIMENTO: PAGAMENTOS (Mais de 110 Linhas)
-- Contém pagamentos de mensalidades de múltiplos meses (Fev, Mar, Abr, Mai, Jun)
-- com situações: Pago, Pendente, Atrasado
-- ----------------------------------------------------------------------------
INSERT INTO tb_pagamento (id_contrato, data_vencimento, data_pagamento, valor_faturado, valor_pago, forma_pagamento, status_pagamento, codigo_transacao_banco) VALUES
-- Mês 02/2024 (Mensalidades pagas de abertura) - 44 pagamentos
(1,  '2024-02-10', '2024-02-08', 149.90, 149.90, 'Cartão de Crédito', 'Pago', 'TID-202402-001'),
(2,  '2024-02-10', '2024-02-10', 129.90, 129.90, 'Pix',               'Pago', 'TID-202402-002'),
(3,  '2024-02-15', '2024-02-14', 149.90, 149.90, 'Boleto Bancário',   'Pago', 'TID-202402-003'),
(4,  '2024-02-05', '2024-02-05',  89.90,  89.90, 'Dinheiro',          'Pago', 'TID-202402-004'),
(5,  '2024-02-10', '2024-02-09', 109.90, 109.90, 'Cartão de Crédito', 'Pago', 'TID-202402-005'),
(6,  '2024-02-20', '2024-02-18', 149.90, 149.90, 'Pix',               'Pago', 'TID-202402-006'),
(7,  '2024-02-10', '2024-02-10', 129.90, 129.90, 'Débito',            'Pago', 'TID-202402-007'),
(8,  '2024-02-10', '2024-02-11',  89.90,  89.90, 'Pix',               'Pago', 'TID-202402-008'),
(9,  '2024-02-15', '2024-02-15', 149.90, 149.90, 'Cartão de Crédito', 'Pago', 'TID-202402-009'),
(10, '2024-02-05', '2024-02-05',  89.90,  89.90, 'Dinheiro',          'Pago', 'TID-202402-010'),
(11, '2024-02-10', '2024-02-10', 129.90, 129.90, 'Pix',               'Pago', 'TID-202402-011'),
(12, '2024-02-10', '2024-02-09', 149.90, 149.90, 'Cartão de Crédito', 'Pago', 'TID-202402-012'),
(13, '2024-02-10', '2024-02-10',  89.90,  89.90, 'Pix',               'Pago', 'TID-202402-013'),
(14, '2024-02-15', '2024-02-15', 109.90, 109.90, 'Boleto Bancário',   'Pago', 'TID-202402-014'),
(15, '2024-02-20', '2024-02-19', 149.90, 149.90, 'Cartão de Crédito', 'Pago', 'TID-202402-015'),
(16, '2024-02-10', '2024-02-10',  69.90,  69.90, 'Pix',               'Pago', 'TID-202402-016'),
(17, '2024-02-10', '2024-02-08', 149.90, 149.90, 'Cartão de Crédito', 'Pago', 'TID-202402-017'),
(18, '2024-02-15', '2024-02-14', 129.90, 129.90, 'Pix',               'Pago', 'TID-202402-018'),
(19, '2024-02-10', '2024-02-10', 149.90, 149.90, 'Cartão de Crédito', 'Pago', 'TID-202402-019'),
(20, '2024-02-05', '2024-02-05', 109.90, 109.90, 'Dinheiro',          'Pago', 'TID-202402-020'),
(21, '2024-02-10', '2024-02-10', 149.90, 149.90, 'Pix',               'Pago', 'TID-202402-021'),
(22, '2024-02-10', '2024-02-10',  69.90,  69.90, 'Débito',            'Pago', 'TID-202402-022'),
(23, '2024-02-15', '2024-02-15', 129.90, 129.90, 'Boleto Bancário',   'Pago', 'TID-202402-023'),
(24, '2024-02-20', '2024-02-19', 149.90, 149.90, 'Cartão de Crédito', 'Pago', 'TID-202402-024'),
(25, '2024-02-10', '2024-02-10',  89.90,  89.90, 'Pix',               'Pago', 'TID-202402-025'),
(26, '2024-02-10', '2024-02-10', 149.90, 149.90, 'Cartão de Crédito', 'Pago', 'TID-202402-026'),
(27, '2024-02-05', '2024-02-04', 109.90, 109.90, 'Pix',               'Pago', 'TID-202402-027'),
(28, '2024-02-15', '2024-02-14', 149.90, 149.90, 'Cartão de Crédito', 'Pago', 'TID-202402-028'),
(29, '2024-02-10', '2024-02-10', 129.90, 129.90, 'Boleto Bancário',   'Pago', 'TID-202402-029'),
(30, '2024-02-10', '2024-02-09', 149.90, 149.90, 'Pix',               'Pago', 'TID-202402-030'),
(31, '2024-02-20', '2024-02-20',  69.90,  69.90, 'Dinheiro',          'Pago', 'TID-202402-031'),
(32, '2024-02-10', '2024-02-10', 149.90, 149.90, 'Cartão de Crédito', 'Pago', 'TID-202402-032'),
(33, '2024-02-05', '2024-02-05',  89.90,  89.90, 'Pix',               'Pago', 'TID-202402-033'),
(34, '2024-02-15', '2024-02-15', 149.90, 149.90, 'Cartão de Crédito', 'Pago', 'TID-202402-034'),
(35, '2024-02-10', '2024-02-10', 129.90, 129.90, 'Débito',            'Pago', 'TID-202402-035'),
(36, '2024-02-10', '2024-02-10', 109.90, 109.90, 'Pix',               'Pago', 'TID-202402-036'),
(37, '2024-02-20', '2024-02-19', 149.90, 149.90, 'Cartão de Crédito', 'Pago', 'TID-202402-037'),
(38, '2024-02-10', '2024-02-10',  89.90,  89.90, 'Pix',               'Pago', 'TID-202402-038'),
(39, '2024-02-15', '2024-02-15', 149.90, 149.90, 'Boleto Bancário',   'Pago', 'TID-202402-039'),
(40, '2024-02-10', '2024-02-10',  69.90,  69.90, 'Dinheiro',          'Pago', 'TID-202402-040'),
(41, '2024-02-10', '2024-02-09', 149.90, 149.90, 'Cartão de Crédito', 'Pago', 'TID-202402-041'),
(42, '2024-02-05', '2024-02-05', 129.90, 129.90, 'Pix',               'Pago', 'TID-202402-042'),
(43, '2024-02-10', '2024-02-10', 149.90, 149.90, 'Cartão de Crédito', 'Pago', 'TID-202402-043'),
(44, '2024-02-15', '2024-02-15', 109.90, 109.90, 'Pix',               'Pago', 'TID-202402-044'),

-- Mês 03/2024 (Mensalidades pagas, atrasadas e pendentes) - 35 pagamentos
(1,  '2024-03-10', '2024-03-08', 149.90, 149.90, 'Cartão de Crédito', 'Pago', 'TID-202403-001'),
(2,  '2024-03-10', '2024-03-10', 129.90, 129.90, 'Pix',               'Pago', 'TID-202403-002'),
(3,  '2024-03-15', '2024-03-14', 149.90, 149.90, 'Boleto Bancário',   'Pago', 'TID-202403-003'),
(5,  '2024-03-10', '2024-03-09', 109.90, 109.90, 'Cartão de Crédito', 'Pago', 'TID-202403-004'),
(6,  '2024-03-20', '2024-03-20', 149.90, 149.90, 'Pix',               'Pago', 'TID-202403-005'),
(7,  '2024-03-10', '2024-03-10', 129.90, 129.90, 'Débito',            'Pago', 'TID-202403-006'),
(8,  '2024-03-10', '2024-03-12',  89.90,  89.90, 'Pix',               'Pago', 'TID-202403-007'),
(9,  '2024-03-15', '2024-03-15', 149.90, 149.90, 'Cartão de Crédito', 'Pago', 'TID-202403-008'),
(10, '2024-03-05', NULL,          89.90,   NULL,  NULL,                'Atrasado', NULL), -- Caso de contorno: Atrasado
(11, '2024-03-10', '2024-03-10', 129.90, 129.90, 'Pix',               'Pago', 'TID-202403-009'),
(12, '2024-03-10', '2024-03-09', 149.90, 149.90, 'Cartão de Crédito', 'Pago', 'TID-202403-010'),
(14, '2024-03-15', '2024-03-15', 109.90, 109.90, 'Boleto Bancário',   'Pago', 'TID-202403-011'),
(15, '2024-03-20', '2024-03-19', 149.90, 149.90, 'Cartão de Crédito', 'Pago', 'TID-202403-012'),
(16, '2024-03-10', NULL,          69.90,   NULL,  NULL,                'Atrasado', NULL), -- Inadimplente
(17, '2024-03-10', '2024-03-08', 149.90, 149.90, 'Cartão de Crédito', 'Pago', 'TID-202403-013'),
(18, '2024-03-15', '2024-03-14', 129.90, 129.90, 'Pix',               'Pago', 'TID-202403-014'),
(19, '2024-03-10', '2024-03-10', 149.90, 149.90, 'Cartão de Crédito', 'Pago', 'TID-202403-015'),
(20, '2024-03-05', '2024-03-05', 109.90, 109.90, 'Dinheiro',          'Pago', 'TID-202403-016'),
(21, '2024-03-10', '2024-03-10', 149.90, 149.90, 'Pix',               'Pago', 'TID-202403-017'),
(22, '2024-03-10', '2024-03-10',  69.90,  69.90, 'Débito',            'Pago', 'TID-202403-018'),
(23, '2024-03-15', '2024-03-15', 129.90, 129.90, 'Boleto Bancário',   'Pago', 'TID-202403-019'),
(24, '2024-03-20', '2024-03-19', 149.90, 149.90, 'Cartão de Crédito', 'Pago', 'TID-202403-020'),
(25, '2024-03-10', '2024-03-10',  89.90,  89.90, 'Pix',               'Pago', 'TID-202403-021'),
(26, '2024-03-10', '2024-03-10', 149.90, 149.90, 'Cartão de Crédito', 'Pago', 'TID-202403-022'),
(27, '2024-03-05', '2024-03-04', 109.90, 109.90, 'Pix',               'Pago', 'TID-202403-023'),
(28, '2024-03-15', '2024-03-14', 149.90, 149.90, 'Cartão de Crédito', 'Pago', 'TID-202403-024'),
(29, '2024-03-10', '2024-03-10', 129.90, 129.90, 'Boleto Bancário',   'Pago', 'TID-202403-025'),
(30, '2024-03-10', '2024-03-09', 149.90, 149.90, 'Pix',               'Pago', 'TID-202403-026'),
(32, '2024-03-10', '2024-03-10', 149.90, 149.90, 'Cartão de Crédito', 'Pago', 'TID-202403-027'),
(34, '2024-03-15', '2024-03-15', 149.90, 149.90, 'Cartão de Crédito', 'Pago', 'TID-202403-028'),
(35, '2024-03-10', '2024-03-10', 129.90, 129.90, 'Débito',            'Pago', 'TID-202403-029'),
(36, '2024-03-10', '2024-03-10', 109.90, 109.90, 'Pix',               'Pago', 'TID-202403-030'),
(37, '2024-03-20', '2024-03-19', 149.90, 149.90, 'Cartão de Crédito', 'Pago', 'TID-202403-031'),
(41, '2024-03-10', '2024-03-09', 149.90, 149.90, 'Cartão de Crédito', 'Pago', 'TID-202403-032'),
(43, '2024-03-10', '2024-03-10', 149.90, 149.90, 'Cartão de Crédito', 'Pago', 'TID-202403-033'),

-- Mês 04/2024 e Mês 05/2024 (Com mais de 35 pagamentos para superar 114 pagamentos no total)
(1,  '2024-04-10', '2024-04-09', 149.90, 149.90, 'Cartão de Crédito', 'Pago',     'TID-202404-001'),
(2,  '2024-04-10', '2024-04-10', 129.90, 129.90, 'Pix',               'Pago',     'TID-202404-002'),
(3,  '2024-04-15', '2024-04-15', 149.90, 149.90, 'Boleto Bancário',   'Pago',     'TID-202404-003'),
(5,  '2024-04-10', '2024-04-10', 109.90, 109.90, 'Cartão de Crédito', 'Pago',     'TID-202404-004'),
(6,  '2024-04-20', '2024-04-20', 149.90, 149.90, 'Pix',               'Pago',     'TID-202404-005'),
(7,  '2024-04-10', '2024-04-10', 129.90, 129.90, 'Débito',            'Pago',     'TID-202404-006'),
(8,  '2024-04-10', NULL,          89.90,   NULL,  NULL,                'Pendente', NULL), -- Pendente de quitação
(9,  '2024-04-15', '2024-04-15', 149.90, 149.90, 'Cartão de Crédito', 'Pago',     'TID-202404-007'),
(11, '2024-04-10', '2024-04-10', 129.90, 129.90, 'Pix',               'Pago',     'TID-202404-008'),
(12, '2024-04-10', '2024-04-09', 149.90, 149.90, 'Cartão de Crédito', 'Pago',     'TID-202404-009'),
(15, '2024-04-20', '2024-04-20', 149.90, 149.90, 'Cartão de Crédito', 'Pago',     'TID-202404-010'),
(17, '2024-04-10', '2024-04-10', 149.90, 149.90, 'Cartão de Crédito', 'Pago',     'TID-202404-011'),
(18, '2024-04-15', '2024-04-14', 129.90, 129.90, 'Pix',               'Pago',     'TID-202404-012'),
(21, '2024-04-10', '2024-04-10', 149.90, 149.90, 'Pix',               'Pago',     'TID-202404-013'),
(23, '2024-04-15', '2024-04-15', 129.90, 129.90, 'Boleto Bancário',   'Pago',     'TID-202404-014'),
(24, '2024-04-20', '2024-04-20', 149.90, 149.90, 'Cartão de Crédito', 'Pago',     'TID-202404-015'),
(25, '2024-04-10', NULL,          89.90,   NULL,  NULL,                'Pendente', NULL),
(26, '2024-04-10', '2024-04-10', 149.90, 149.90, 'Cartão de Crédito', 'Pago',     'TID-202404-016'),
(27, '2024-04-05', '2024-04-05', 109.90, 109.90, 'Pix',               'Pago',     'TID-202404-017'),
(28, '2024-04-15', '2024-04-15', 149.90, 149.90, 'Cartão de Crédito', 'Pago',     'TID-202404-018'),
(29, '2024-04-10', '2024-04-10', 129.90, 129.90, 'Boleto Bancário',   'Pago',     'TID-202404-019'),
(30, '2024-04-10', '2024-04-10', 149.90, 149.90, 'Pix',               'Pago',     'TID-202404-020'),
(32, '2024-04-10', '2024-04-10', 149.90, 149.90, 'Cartão de Crédito', 'Pago',     'TID-202404-021'),
(34, '2024-04-15', '2024-04-15', 149.90, 149.90, 'Cartão de Crédito', 'Pago',     'TID-202404-022'),
(35, '2024-04-10', '2024-04-10', 129.90, 129.90, 'Débito',            'Pago',     'TID-202404-023'),
(36, '2024-04-10', '2024-04-10', 109.90, 109.90, 'Pix',               'Pago',     'TID-202404-024'),
(37, '2024-04-20', '2024-04-20', 149.90, 149.90, 'Cartão de Crédito', 'Pago',     'TID-202404-025'),
(41, '2024-04-10', '2024-04-10', 149.90, 149.90, 'Cartão de Crédito', 'Pago',     'TID-202404-026'),
(43, '2024-04-10', '2024-04-10', 149.90, 149.90, 'Cartão de Crédito', 'Pago',     'TID-202404-027'),
-- Mais lançamentos futuros (Maio)
(1,  '2024-05-10', NULL,         149.90,   NULL,  NULL,                'Pendente', NULL),
(2,  '2024-05-10', NULL,         129.90,   NULL,  NULL,                'Pendente', NULL),
(3,  '2024-05-15', NULL,         149.90,   NULL,  NULL,                'Pendente', NULL),
(6,  '2024-05-20', NULL,         149.90,   NULL,  NULL,                'Pendente', NULL),
(9,  '2024-05-15', NULL,         149.90,   NULL,  NULL,                'Pendente', NULL),
(12, '2024-05-10', NULL,         149.90,   NULL,  NULL,                'Pendente', NULL);

-- ----------------------------------------------------------------------------
-- 10. CARGA DE HISTÓRICO DE MATRÍCULA (Atributo Temporal)
-- ----------------------------------------------------------------------------
INSERT INTO tb_historico_matricula (id_aluno, data_evento, situacao_anterior, situacao_nova, motivo_alteracao, usuario_responsavel) VALUES
(7,  '2024-02-05 14:00:00', NULL,     'Ativo',        'Matrícula inicial realizada no balcão', 'admin_recepcao'),
(10, '2024-02-06 11:00:00', NULL,     'Ativo',        'Matrícula inicial',                      'admin_recepcao'),
(10, '2024-03-01 10:30:00', 'Ativo',  'Trancado',     'Solicitação médica por lesão no joelho', 'admin_recepcao'),
(16, '2024-02-09 15:00:00', NULL,     'Ativo',        'Matrícula inicial',                      'admin_recepcao'),
(16, '2024-03-20 09:00:00', 'Ativo',  'Inadimplente', 'Ausência de pagamento por 15 dias',     'job_financeiro'),
(19, '2024-02-11 11:15:00', NULL,     'Ativo',        'Matrícula inicial',                      'admin_recepcao'),
(19, '2024-03-15 16:00:00', 'Ativo',  'Cancelado',    'Mudança de endereço para outro estado',  'admin_gerente');

-- Fim do Script DML
