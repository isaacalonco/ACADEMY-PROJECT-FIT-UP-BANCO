package operacoes;

import banco.Conexao;
import entidades.Pagamento;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class PagamentoOperacoes {

    public boolean cadastrarPagamento(Pagamento p) {
        String sql = "INSERT INTO pagamento (id_aluno, valor, status) VALUES (?, ?, ?)";
        try (Connection conn = Conexao.conectar();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, p.getIdAluno());
            ps.setDouble(2, p.getValor());
            ps.setString(3, p.getStatus());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.err.println("-> Erro ao cadastrar pagamento: " + e.getMessage());
            return false;
        }
    }

    public List<PagamentoView> listarPagamentos() {
        List<PagamentoView> list = new ArrayList<>();
        String sql = "SELECT pg.id_pagamento, a.nome AS nome_aluno, pg.valor, pg.status " +
                     "FROM pagamento pg JOIN aluno a ON pg.id_aluno = a.id ORDER BY pg.id_pagamento DESC";
        try (Connection conn = Conexao.conectar();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new PagamentoView(
                    rs.getInt("id_pagamento"), rs.getString("nome_aluno"),
                    rs.getDouble("valor"), rs.getString("status")
                ));
            }
        } catch (Exception e) {
            System.err.println("-> Erro ao listar pagamentos: " + e.getMessage());
        }
        return list;
    }

    public boolean deletarPagamento(int id) {
        String sql = "DELETE FROM pagamento WHERE id_pagamento=?";
        String sqlResetSeq = "UPDATE sqlite_sequence SET seq = (SELECT COALESCE(MAX(id_pagamento), 0) FROM pagamento) WHERE name = 'pagamento'";
        try (Connection conn = Conexao.conectar()) {
            conn.setAutoCommit(false);
            try (PreparedStatement ps = conn.prepareStatement(sql);
                 PreparedStatement psReset = conn.prepareStatement(sqlResetSeq)) {
                ps.setInt(1, id);
                int res = ps.executeUpdate();
                psReset.executeUpdate();
                conn.commit();
                return res > 0;
            } catch (Exception e) {
                conn.rollback();
                throw e;
            }
        } catch (Exception e) {
            System.err.println("-> Erro ao deletar pagamento: " + e.getMessage());
            return false;
        }
    }

    public boolean atualizarStatusPagamento(int id, String novoStatus) {
        if (novoStatus == null) return false;
        String status = novoStatus.trim();
        if (status.equalsIgnoreCase("Pago")) status = "Pago";
        else if (status.equalsIgnoreCase("Pendente")) status = "Pendente";
        else if (status.equalsIgnoreCase("Atrasado")) status = "Atrasado";
        else return false;

        String sql = "UPDATE pagamento SET status=? WHERE id_pagamento=?";
        try (Connection conn = Conexao.conectar();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.err.println("-> Erro ao atualizar status do pagamento: " + e.getMessage());
            return false;
        }
    }

    public boolean atualizarPagamento(Pagamento p) {
        String sql = "UPDATE pagamento SET id_aluno=?, valor=?, status=? WHERE id_pagamento=?";
        try (Connection conn = Conexao.conectar();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, p.getIdAluno());
            ps.setDouble(2, p.getValor());
            ps.setString(3, p.getStatus());
            ps.setInt(4, p.getIdPagamento());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.err.println("-> Erro ao atualizar pagamento: " + e.getMessage());
            return false;
        }
    }

    public static class PagamentoView {
        public int idPagamento;
        public String nomeAluno;
        public double valor;
        public String status;
        public PagamentoView(int idPagamento, String nomeAluno, double valor, String status) {
            this.idPagamento = idPagamento;
            this.nomeAluno = nomeAluno;
            this.valor = valor;
            this.status = status;
        }
    }
}
