# Documentação da Etapa 1 — FIT UP
## Disciplina: Laboratório de Banco de Dados (GPE17M40083) — UCB
**Professor:** Samuel Novais Moura Júnior  

---

### Documentos e Relatórios:
1. (`FIT_UP_Relatorio_Etapa1.pdf`): Documento completo e unificado reunindo os artefatos A1 a A5, tabelas de rastreabilidade, justificativas, demonstração formal de normalização e checklist de entrega.
2. (`FIT_UP_Dicionario_de_Dados.pdf`): Tabela das 12 entidades/tabelas estruturada no padrão oficial do Anexo A do edital.
4. (`modelo-logico.pdf`): Esquema relacional com chaves primárias sublinhadas e decisões de mapeamento fundamentadas.
5. (`mer-conceitual.pdf`): Especificação conceitual, cardinalidades e notação Crow's Foot.

---

###  Scripts Físicos de Banco de Dados:
Os scripts executáveis encontram-se na pasta [`../sql/`]:
- **[`01_ddl.sql`]**: Criação física com restrições padronizadas (`pk_`, `uq_`, `fk_`, `ck_`, `idx_`) e integridade referencial com `ON DELETE` e `ON UPDATE`.
- **[`02_carga.sql`]**: Carga sintética com 50 indivíduos e 114 pagamentos, contemplando casos de contorno.
- **[`03_consultas.sql`]**: 15 Consultas comentadas (5 Básicas, 5 Junções/Agregação, 5 Avançadas com subconsultas e `EXISTS`).
