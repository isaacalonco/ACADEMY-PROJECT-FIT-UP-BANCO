package operacoes;

import banco.Conexao;
import banco.DbUtil;
import entidades.Instrutor;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class InstrutorOperacoes {

    private String ultimoErro;

    public String getUltimoErro() {
        return ultimoErro;
    }

    public boolean cpfJaCadastrado(String cpf, int ignoreId) {
        String sql = "SELECT COUNT(*) FROM instrutor WHERE cpf = ? AND id_instrutor != ?";
        try (Connection conn = Conexao.conectar();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, cpf);
            ps.setInt(2, ignoreId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            System.err.println("-> Erro ao verificar CPF: " + e.getMessage());
            return false;
        }
    }

    public boolean cadastrarInstrutor(Instrutor i) {
        ultimoErro = null;
        if (cpfJaCadastrado(i.getCpf(), 0)) {
            ultimoErro = "CPF já cadastrado no sistema!";
            System.err.println("-> " + ultimoErro);
            return false;
        }
        String sql = "INSERT INTO instrutor (nome, cpf, email, telefone, especialidade) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = Conexao.conectar();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, i.getNome());
            ps.setString(2, i.getCpf());
            ps.setString(3, i.getEmail());
            ps.setString(4, i.getTelefone());
            ps.setString(5, i.getEspecialidade());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            ultimoErro = "Erro ao cadastrar instrutor: " + e.getMessage();
            System.err.println("-> " + ultimoErro);
            return false;
        }
    }

    public List<Instrutor> listarInstrutores() {
        List<Instrutor> list = new ArrayList<>();
        String sql = "SELECT * FROM instrutor ORDER BY id_instrutor";
        try (Connection conn = Conexao.conectar();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Instrutor i = new Instrutor(
                    rs.getInt("id_instrutor"),
                    rs.getString("nome"),
                    rs.getString("cpf"),
                    rs.getString("email"),
                    rs.getString("telefone"),
                    rs.getString("especialidade")
                );
                list.add(i);
            }
        } catch (Exception e) {
            System.err.println("-> Erro ao listar instrutores: " + e.getMessage());
        }
        return list;
    }

    public boolean atualizarInstrutor(Instrutor i) {
        ultimoErro = null;
        if (cpfJaCadastrado(i.getCpf(), i.getIdInstrutor())) {
            ultimoErro = "CPF já pertence a outro instrutor!";
            System.err.println("-> " + ultimoErro);
            return false;
        }
        String sql = "UPDATE instrutor SET nome=?, cpf=?, email=?, telefone=?, especialidade=? WHERE id_instrutor=?";
        try (Connection conn = Conexao.conectar();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, i.getNome());
            ps.setString(2, i.getCpf());
            ps.setString(3, i.getEmail());
            ps.setString(4, i.getTelefone());
            ps.setString(5, i.getEspecialidade());
            ps.setInt(6, i.getIdInstrutor());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            ultimoErro = "Erro ao atualizar instrutor: " + e.getMessage();
            System.err.println("-> " + ultimoErro);
            return false;
        }
    }

    public boolean deletarInstrutor(int id) {
        try (Connection conn = Conexao.conectar()) {
            conn.setAutoCommit(false);
            try {
                boolean result = DbUtil.deletarEResetarSeq(conn, "instrutor", "id_instrutor", id);
                conn.commit();
                return result;
            } catch (Exception e) {
                conn.rollback();
                throw e;
            }
        } catch (Exception e) {
            System.err.println("-> Erro ao deletar instrutor: " + e.getMessage());
            return false;
        }
    }
}
