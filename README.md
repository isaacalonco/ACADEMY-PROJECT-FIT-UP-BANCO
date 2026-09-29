# Central de Documentação da Etapa 1 — FIT UP
## Disciplina: Laboratório de Banco de Dados (GPE17M40083) — UCB
**Professor:** Samuel Novais Moura Júnior  

---

Esta pasta contém todos os artefatos exigidos para a entrega da **Etapa 1 (N1)** do projeto final da disciplina:

### 📄 Documentos e Relatórios:
1. **[Relatório Técnico Consolidado da Etapa 1](FIT_UP_Relatorio_Etapa1.pdf)** (`FIT_UP_Relatorio_Etapa1.pdf`): Documento completo e unificado reunindo os artefatos A1 a A5, tabelas de rastreabilidade, justificativas, demonstração formal de normalização e checklist de entrega.
2. **[Documento de Visão do Sistema](FIT_UP_Documento_de_Visao_do_Sistema.pdf)** (`FIT_UP_Documento_de_Visao_do_Sistema.pdf`): Escopo, partes interessadas, requisitos e regras de negócio do FIT UP.
3. **[Dicionário de Dados Conceitual](FIT_UP_Dicionario_de_Dados.pdf)** (`FIT_UP_Dicionario_de_Dados.pdf`): Tabela das 12 entidades/tabelas estruturada no padrão oficial do Anexo A do edital.
4. **[Modelo Lógico Relacional e Justificativas](modelo-logico.pdf)** (`modelo-logico.pdf`): Esquema relacional com chaves primárias sublinhadas e decisões de mapeamento fundamentadas.
5. **[Modelo Entidade-Relacionamento Conceitual (MER)](mer-conceitual.pdf)** (`mer-conceitual.pdf`): Especificação conceitual, cardinalidades e notação Crow's Foot.

---

###  Scripts Físicos de Banco de Dados:
Os scripts executáveis encontram-se na pasta [`../sql/`](../sql/):
- **[`01_ddl.sql`](../sql/01_ddl.sql)**: Criação física com restrições padronizadas (`pk_`, `uq_`, `fk_`, `ck_`, `idx_`) e integridade referencial com `ON DELETE` e `ON UPDATE`.
- **[`02_carga.sql`](../sql/02_carga.sql)**: Carga sintética com 50 indivíduos e 114 pagamentos, contemplando casos de contorno.
- **[`03_consultas.sql`](../sql/03_consultas.sql)**: 15 Consultas comentadas (5 Básicas, 5 Junções/Agregação, 5 Avançadas com subconsultas e `EXISTS`).
