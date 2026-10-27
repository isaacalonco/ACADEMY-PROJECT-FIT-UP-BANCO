package operacoes;

import banco.Conexao;
import entidades.Plano;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class PlanoOperacoes {

    public boolean cadastrarPlano(Plano p) {
        String sql = "INSERT INTO plano (nome, valor) VALUES (?, ?)";
        try (Connection conn = Conexao.conectar();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, p.getNome());
            ps.setDouble(2, p.getValor());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.err.println("-> Erro ao cadastrar plano: " + e.getMessage());
            return false;
        }
    }

    public List<Plano> listarPlanos() {
        List<Plano> list = new ArrayList<>();
        String sql = "SELECT * FROM plano ORDER BY id";
        try (Connection conn = Conexao.conectar();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new Plano(rs.getInt("id"), rs.getString("nome"), rs.getDouble("valor")));
            }
        } catch (Exception e) {
            System.err.println("-> Erro ao listar planos: " + e.getMessage());
        }
        return list;
    }

    public boolean atualizarPlano(Plano p) {
        String sql = "UPDATE plano SET nome=?, valor=? WHERE id=?";
        try (Connection conn = Conexao.conectar();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, p.getNome());
            ps.setDouble(2, p.getValor());
            ps.setInt(3, p.getId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            System.err.println("-> Erro ao atualizar plano: " + e.getMessage());
            return false;
        }
    }

    public boolean deletarPlano(int id) {
        String sql = "DELETE FROM plano WHERE id=?";
        String sqlResetSeq = "UPDATE sqlite_sequence SET seq = (SELECT COALESCE(MAX(id), 0) FROM plano) WHERE name = 'plano'";
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
            System.err.println("-> Erro ao deletar plano: " + e.getMessage());
            return false;
        }
    }
}
