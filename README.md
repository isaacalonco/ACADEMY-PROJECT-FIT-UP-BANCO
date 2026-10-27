# FIT UP — Sistema de Gestão de Academias

Projeto final da disciplina **Laboratório de Banco de Dados (GPE17M40083)** 

## Equipe (Grupo 6)

| Integrante | Papel principal |
|---|---|
| Isaac Alonço Itacarambi de Souza Silva | Analista de domínio / Administrador do banco (interlocutor com o professor) |
| Gustavo Junio de Souza Pereira | Modelador de dados |
| Paulo Vitor Lucena Mendes | Administrador do banco (carga, índices, consultas) |
| Hugo Oliveira da Silva | Desenvolvedor da aplicação |
| Raphael Gondim Oliveira Filho | Desenvolvedor / documentação |

Todos participam de todas as frentes; o histórico de commits identifica a autoria.

## Estrutura do repositório

```text
.
├── README.md                      # este arquivo
├── iniciar.bat                    # sobe a aplicação da Etapa 2 (Windows, 1 clique)
├── docs/
│   ├── relatorio-etapa1.pdf       # relatório único (A1 a A5 + revisão pós-devolutiva), no padrão visual do edital
│   ├── mer-conceitual.pdf         # MER conceitual em notação de Peter Chen (+ mer-conceitual.drawio, arquivo-fonte, e .png)
│   ├── modelo-logico.pdf          # esquema relacional e decisões de mapeamento (+ modelo-logico.png)
│   ├── dicionario-dados.pdf       # dicionário de dados no formato do Anexo A
│   └── fonte/                     # fontes Markdown dos PDFs, .svg dos diagramas e gerar_pdfs.py (ver abaixo)
├── sql/
│   ├── 01_ddl.sql                 # cria o esquema (12 tabelas, restrições nomeadas, índices, 2 visões)
│   ├── 02_carga.sql               # carga sintética coerente (≥ 40 linhas nas tabelas principais) + setval das sequences
│   └── 03_consultas.sql           # 15 consultas comentadas com a pergunta de negócio
└── app/                           # aplicação web Java (Etapa 2) — ver app/README.md
```

## Como reconstruir o banco do zero

Requisito: **PostgreSQL 14 ou superior** (os scripts foram validados em PostgreSQL 16.2).

```bash
# 1. criar uma base limpa
psql -U postgres -c "DROP DATABASE IF EXISTS fitup;"
psql -U postgres -c "CREATE DATABASE fitup;"

# 2. executar os scripts, na ordem, parando no primeiro erro
psql -U postgres -d fitup -v ON_ERROR_STOP=1 -f sql/01_ddl.sql
psql -U postgres -d fitup -v ON_ERROR_STOP=1 -f sql/02_carga.sql
psql -U postgres -d fitup -v ON_ERROR_STOP=1 -f sql/03_consultas.sql
```

No Windows (PowerShell), use o mesmo comando com `psql.exe`; a codificação dos arquivos é UTF-8 (`SET client_encoding = 'UTF8'` é aplicado automaticamente quando o terminal estiver em outra página de código: `chcp 65001`).

### Volume carregado (contado após a execução)

| Tabela | Linhas | Tabela | Linhas |
|---|---:|---|---:|
| tb_pessoa | 50 | tb_avaliacao_fisica | 56 |
| tb_instrutor | 6 | tb_ficha_treino | 53 |
| tb_aluno | 44 | tb_ficha_exercicio | 673 |
| tb_plano | 5 | tb_pagamento | 236 |
| tb_contrato_plano | 52 | tb_historico_matricula | 51 |
| tb_exercicio | 28 | tb_auditoria_sistema | 0 (preenchida pelos gatilhos da Etapa 2) |

## Requisitos mínimos de complexidade (item 4 do edital)

| Requisito | Atendimento |
|---|---|
| ≥ 8 entidades (sem associativas) | 9: PESSOA, ALUNO, INSTRUTOR, PLANO, HISTORICO_MATRICULA, AVALIACAO_FISICA, FICHA_TREINO, EXERCICIO, PAGAMENTO |
| ≥ 2 relacionamentos N:N com atributo próprio | CONTRATO_PLANO (ALUNO × PLANO) e FICHA_EXERCICIO (FICHA_TREINO × EXERCICIO) |
| ≥ 1 autorrelacionamento | 2: INSTRUTOR supervisiona INSTRUTOR; ALUNO indica ALUNO |
| ≥ 1 generalização/especialização | PESSOA → ALUNO, INSTRUTOR (total, disjunta; uma tabela por subclasse) |
| ≥ 1 entidade fraca | AVALIACAO_FISICA, identificada por (id_aluno, num_sequencial) |
| ≥ 1 atributo temporal (histórico datado) | HISTORICO_MATRICULA (situação do aluno ao longo do tempo) |
| 20 regras de negócio | RN01–RN20, com matriz de rastreabilidade no relatório |
| Volume | ≥ 40 linhas nas tabelas principais; 236 em tb_pagamento e 673 em tb_ficha_exercicio |


## Declaração de uso de inteligência artificial

Assistentes de IA foram utilizados como apoio na escrita de código SQL, na geração de dados sintéticos, na revisão textual dos documentos. Todos os scripts foram executados pela equipe do início ao fim em base limpa e todas as contagens e afirmações dos documentos foram conferidas contra o resultado real dessa execução. A seção 7 do relatório detalha o uso.
hugo
