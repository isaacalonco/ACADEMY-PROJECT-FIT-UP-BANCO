SELECT 
    p.id_pessoa,
    p.nome_completo,
    p.cpf,
    p.email,
    a.codigo_matricula,
    a.status_cadastral
FROM tb_pessoa p
INNER JOIN tb_aluno a ON p.id_pessoa = a.id_aluno
WHERE p.nome_completo LIKE 'M%' 
   OR p.nome_completo LIKE 'P%'
ORDER BY p.nome_completo ASC;

-- ----------------------------------------------------------------------------
-- CONSULTA 02 (Básica - BETWEEN e Operador Numérico)
-- Pergunta de negócio: "Quais planos de assinatura custam entre R$ 80,00 e 
-- R$ 130,00 por mês, indicando os planos intermediários da academia?"
-- ----------------------------------------------------------------------------
SELECT 
    id_plano,
    nome_plano,
    duracao_meses,
    valor_mensal,
    permite_todas_unidades
FROM tb_plano
WHERE valor_mensal BETWEEN 80.00 AND 130.00
ORDER BY valor_mensal ASC;

-- ----------------------------------------------------------------------------
-- CONSULTA 03 (Básica - Tratamento de NULL com IS NULL e COALESCE)
-- Pergunta de negócio: "Quais alunos não possuem telefone cadastrado ou 
-- precisam de atualização cadastral nos meios de contato?"
-- ----------------------------------------------------------------------------
SELECT 
    p.nome_completo,
    p.email,
    COALESCE(p.telefone, 'TELEFONE NÃO INFORMADO') AS contato_telefonico,
    a.status_cadastral
FROM tb_pessoa p
INNER JOIN tb_aluno a ON p.id_pessoa = a.id_aluno
WHERE p.telefone IS NULL
ORDER BY p.nome_completo;

-- ----------------------------------------------------------------------------
-- CONSULTA 04 (Básica - Operador IN e Projeção com Filtro Específico)
-- Pergunta de negócio: "Quais pagamentos foram processados especificamente 
-- através de Pix ou Cartão de Crédito com status 'Pago'?"
-- ----------------------------------------------------------------------------
SELECT 
    id_pagamento,
    id_contrato,
    data_vencimento,
    data_pagamento,
    valor_pago,
    forma_pagamento,
    status_pagamento
FROM tb_pagamento
WHERE forma_pagamento IN ('Pix', 'Cartão de Crédito')
  AND status_pagamento = 'Pago'
ORDER BY data_pagamento DESC;

-- ----------------------------------------------------------------------------
-- CONSULTA 05 (Básica - Filtro Temporal e Expressões Lógicas)
-- Pergunta de negócio: "Quais contratos foram iniciados durante o mês de 
-- fevereiro de 2024 e estão atualmente com a situação 'Vigente'?"
-- ----------------------------------------------------------------------------
SELECT 
    id_contrato,
    id_aluno,
    id_plano,
    data_inicio,
    data_termino,
    valor_acordado,
    situacao_contrato
FROM tb_contrato_plano
WHERE data_inicio BETWEEN '2024-02-01' AND '2024-02-29'
  AND situacao_contrato = 'Vigente'
ORDER BY data_inicio ASC;


-- ============================================================================
-- CATEGORIA 2: JUNÇÕES E AGREGAÇÃO (5 Consultas)
-- Requisitos: Ao menos uma com 3 tabelas, uma com LEFT JOIN, uma com GROUP BY e HAVING
-- ============================================================================

-- ----------------------------------------------------------------------------
-- CONSULTA 06 (Junção de Três Tabelas - INNER JOIN)
-- Pergunta de negócio: "Qual o nome do aluno, seu plano contratado e a data de 
-- término da vigência para todos os contratos vigentes?"
-- ----------------------------------------------------------------------------
SELECT 
    p.nome_completo AS nome_aluno,
    a.codigo_matricula,
    pl.nome_plano,
    c.valor_acordado,
    c.data_inicio,
    c.data_termino
FROM tb_aluno a
INNER JOIN tb_pessoa p ON a.id_aluno = p.id_pessoa
INNER JOIN tb_contrato_plano c ON a.id_aluno = c.id_aluno
INNER JOIN tb_plano pl ON c.id_plano = pl.id_plano
WHERE c.situacao_contrato = 'Vigente'
ORDER BY p.nome_completo;

-- ----------------------------------------------------------------------------
-- CONSULTA 07 (LEFT JOIN - Detecção de Alunos sem Avaliação Física)
-- Pergunta de negócio: "Quais alunos matriculados ainda não realizaram nenhuma 
-- avaliação física na academia?"
-- ----------------------------------------------------------------------------
SELECT 
    p.nome_completo AS nome_aluno,
    a.codigo_matricula,
    p.telefone,
    av.data_avaliacao,
    av.peso_kg
FROM tb_aluno a
INNER JOIN tb_pessoa p ON a.id_aluno = p.id_pessoa
LEFT JOIN tb_avaliacao_fisica av ON a.id_aluno = av.id_aluno
WHERE av.id_aluno IS NULL
ORDER BY p.nome_completo;

-- ----------------------------------------------------------------------------
-- CONSULTA 08 (GROUP BY, SUM, COUNT - Receita por Plano)
-- Pergunta de negócio: "Qual é a receita total faturada e a quantidade de 
-- contratos fechados agrupados por cada plano de assinatura?"
-- ----------------------------------------------------------------------------
SELECT 
    pl.nome_plano,
    COUNT(c.id_contrato) AS total_contratos,
    SUM(c.valor_acordado) AS receita_total_planejada,
    ROUND(AVG(c.valor_acordado), 2) AS ticket_medio
FROM tb_plano pl
INNER JOIN tb_contrato_plano c ON pl.id_plano = c.id_plano
GROUP BY pl.id_plano, pl.nome_plano
ORDER BY receita_total_planejada DESC;

-- ----------------------------------------------------------------------------
-- CONSULTA 09 (GROUP BY e HAVING - Instrutores com Grande Volume de Fichas)
-- Pergunta de negócio: "Quais instrutores prescreveram mais de 1 ficha de treino, 
-- com suas respectivas médias de validade?"
-- ----------------------------------------------------------------------------
SELECT 
    p.nome_completo AS nome_instrutor,
    i.registro_cref,
    i.especialidade_primaria,
    COUNT(f.id_ficha) AS total_fichas_prescritas
FROM tb_instrutor i
INNER JOIN tb_pessoa p ON i.id_instrutor = p.id_pessoa
INNER JOIN tb_ficha_treino f ON i.id_instrutor = f.id_instrutor
GROUP BY i.id_instrutor, p.nome_completo, i.registro_cref, i.especialidade_primaria
HAVING COUNT(f.id_ficha) >= 1
ORDER BY total_fichas_prescritas DESC;

-- ----------------------------------------------------------------------------
-- CONSULTA 10 (Junção de Quatro Tabelas com Agregação e Formatação)
-- Pergunta de negócio: "Qual o total financeiro já efetivamente pago por cada 
-- aluno em todo o histórico de mensalidades?"
-- ----------------------------------------------------------------------------
SELECT 
    p.nome_completo AS aluno,
    a.codigo_matricula,
    COUNT(pg.id_pagamento) AS quantidade_mensalidades_pagas,
    SUM(pg.valor_pago) AS total_gasto_reais
FROM tb_pessoa p
INNER JOIN tb_aluno a ON p.id_pessoa = a.id_aluno
INNER JOIN tb_contrato_plano c ON a.id_aluno = c.id_aluno
INNER JOIN tb_pagamento pg ON c.id_contrato = pg.id_contrato
WHERE pg.status_pagamento = 'Pago'
GROUP BY p.nome_completo, a.codigo_matricula
HAVING SUM(pg.valor_pago) > 200.00
ORDER BY total_gasto_reais DESC;


-- ============================================================================
-- CATEGORIA 3: CONSULTAS AVANÇADAS (5 Consultas)
-- Requisitos: Ao menos uma com subconsulta correlacionada, uma com EXISTS e 
-- uma respondendo a pergunta não-trivial do domínio
-- ============================================================================

-- ----------------------------------------------------------------------------
-- CONSULTA 11 (Subconsulta Correlacionada - Última Avaliação Física de Cada Aluno)
-- Pergunta de negócio: "Qual é o peso e a data da avaliação física mais recente 
-- (último número sequencial) de cada aluno?"
-- ----------------------------------------------------------------------------
SELECT 
    p.nome_completo AS aluno,
    av.num_sequencial AS sequencial_recente,
    av.data_avaliacao,
    av.peso_kg,
    av.altura_m,
    ROUND(av.peso_kg / (av.altura_m * av.altura_m), 2) AS imc_calculado
FROM tb_avaliacao_fisica av
INNER JOIN tb_aluno a ON av.id_aluno = a.id_aluno
INNER JOIN tb_pessoa p ON a.id_aluno = p.id_pessoa
WHERE av.num_sequencial = (
    SELECT MAX(av_sub.num_sequencial)
    FROM tb_avaliacao_fisica av_sub
    WHERE av_sub.id_aluno = av.id_aluno
)
ORDER BY p.nome_completo;

-- ----------------------------------------------------------------------------
-- CONSULTA 12 (Subconsulta com EXISTS - Alunos Inadimplentes)
-- Pergunta de negócio: "Quais alunos possuem pelo menos uma parcela com status 
-- 'Atrasado' em seus contratos de matrícula?"
-- ----------------------------------------------------------------------------
SELECT 
    p.nome_completo AS aluno_inadimplente,
    p.cpf,
    p.telefone,
    p.email,
    a.codigo_matricula
FROM tb_aluno a
INNER JOIN tb_pessoa p ON a.id_aluno = p.id_pessoa
WHERE EXISTS (
    SELECT 1 
    FROM tb_contrato_plano c
    INNER JOIN tb_pagamento pg ON c.id_contrato = pg.id_contrato
    WHERE c.id_aluno = a.id_aluno
      AND pg.status_pagamento = 'Atrasado'
);

-- ----------------------------------------------------------------------------
-- CONSULTA 13 (Subconsulta com NOT EXISTS - Exercícios Nunca Prescritos)
-- Pergunta de negócio: "Quais exercícios do catálogo oficial da academia 
-- ainda não foram utilizados em nenhuma ficha de treino de alunos?"
-- ----------------------------------------------------------------------------
SELECT 
    e.id_exercicio,
    e.nome_exercicio,
    e.grupo_muscular,
    e.tipo_exercicio
FROM tb_exercicio e
WHERE NOT EXISTS (
    SELECT 1 
    FROM tb_ficha_exercicio fe
    WHERE fe.id_exercicio = e.id_exercicio
)
ORDER BY e.grupo_muscular, e.nome_exercicio;

-- ----------------------------------------------------------------------------
-- CONSULTA 14 (Autorrelacionamento - Programa de Indicação de Novos Alunos)
-- Pergunta de negócio: "Quais alunos já indicaram outros alunos para a academia 
-- e qual o total de indicações bem-sucedidas realizadas por cada um?"
-- ----------------------------------------------------------------------------
SELECT 
    p_indicador.nome_completo AS aluno_indicador,
    a_indicador.codigo_matricula AS matricula_indicador,
    COUNT(a_indicado.id_aluno) AS total_amigos_indicados,
    STRING_AGG(p_indicado.nome_completo, '; ') AS alunos_indicados
FROM tb_aluno a_indicador
INNER JOIN tb_pessoa p_indicador ON a_indicador.id_aluno = p_indicador.id_pessoa
INNER JOIN tb_aluno a_indicado ON a_indicador.id_aluno = a_indicado.id_aluno_indicador
INNER JOIN tb_pessoa p_indicado ON a_indicado.id_aluno = p_indicado.id_pessoa
GROUP BY p_indicador.nome_completo, a_indicador.codigo_matricula
ORDER BY total_amigos_indicados DESC;

-- ----------------------------------------------------------------------------
-- CONSULTA 15 (Pergunta Complexa e Não-Trivial - Eficácia Nutricional e Treino)
-- Pergunta de negócio: "Quais alunos apresentaram evolução positiva mensurável 
-- (redução de peso corporal entre a primeira e a última avaliação física), 
-- juntamente com seus respectivos instrutores e o percentual de redução?"
-- ----------------------------------------------------------------------------
WITH PrimeiraAvaliacao AS (
    SELECT id_aluno, peso_kg AS peso_inicial, data_avaliacao AS data_inicio
    FROM tb_avaliacao_fisica
    WHERE num_sequencial = 1
),
UltimaAvaliacao AS (
    SELECT av.id_aluno, av.peso_kg AS peso_final, av.data_avaliacao AS data_fim, av.id_instrutor_avaliador
    FROM tb_avaliacao_fisica av
    WHERE av.num_sequencial = (
        SELECT MAX(sub.num_sequencial) 
        FROM tb_avaliacao_fisica sub 
        WHERE sub.id_aluno = av.id_aluno
    )
    AND av.num_sequencial > 1 -- Apenas alunos com 2 ou mais avaliações
)
SELECT 
    p_aluno.nome_completo AS aluno,
    pa.peso_inicial || ' kg' AS peso_primeira_avaliacao,
    ua.peso_final || ' kg' AS peso_ultima_avaliacao,
    ROUND(pa.peso_inicial - ua.peso_final, 2) || ' kg' AS reducao_total_peso,
    ROUND(((pa.peso_inicial - ua.peso_final) / pa.peso_inicial) * 100, 1) || '%' AS percentual_reducao,
    p_inst.nome_completo AS instrutor_responsavel
FROM PrimeiraAvaliacao pa
INNER JOIN UltimaAvaliacao ua ON pa.id_aluno = ua.id_aluno
INNER JOIN tb_aluno a ON pa.id_aluno = a.id_aluno
INNER JOIN tb_pessoa p_aluno ON a.id_aluno = p_aluno.id_pessoa
INNER JOIN tb_instrutor i ON ua.id_instrutor_avaliador = i.id_instrutor
INNER JOIN tb_pessoa p_inst ON i.id_instrutor = p_inst.id_pessoa
WHERE pa.peso_inicial > ua.peso_final -- Somente casos de sucesso (redução)
ORDER BY (pa.peso_inicial - ua.peso_final) DESC;

-- Fim do Script de Consultas
