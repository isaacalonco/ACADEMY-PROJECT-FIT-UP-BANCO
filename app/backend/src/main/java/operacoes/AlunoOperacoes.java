package operacoes;

import banco.Conexao;
import banco.DbUtil;
import entidades.Aluno;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class AlunoOperacoes {

    private String ultimoErro;

    public String getUltimoErro() {
        return ultimoErro;
    }

    public boolean cpfJaCadastrado(String cpf, int ignoreId) {
        try (Connection conn = Conexao.conectar()) {
            return DbUtil.cpfJaCadastrado(conn, "aluno", "cpf", cpf, ignoreId);
        } catch (Exception e) {
            System.err.println("-> Erro ao verificar CPF: " + e.getMessage());
            return false;
        }
    }

    public boolean emailJaCadastrado(String email, int ignoreId) {
        String sql = "SELECT COUNT(*) FROM aluno WHERE email = ? AND id != ?";
        try (Connection conn = Conexao.conectar();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            ps.setInt(2, ignoreId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        } catch (Exception e) {
            System.err.println("-> Erro ao verificar e-mail: " + e.getMessage());
            return false;
        }
    }

    public boolean cadastrarAluno(Aluno aluno) {
        ultimoErro = null;
        if (cpfJaCadastrado(aluno.getCpf(), 0)) {
            ultimoErro = "CPF já cadastrado no sistema!";
            System.err.println("-> " + ultimoErro);
            return false;
        }
        if (emailJaCadastrado(aluno.getEmail(), 0)) {
            ultimoErro = "E-mail já cadastrado no sistema!";
            System.err.println("-> " + ultimoErro);
            return false;
        }
        String sql = "INSERT INTO aluno (nome, cpf, email, telefone, endereco, data_nascimento, peso, altura, data_cadastro, ativo) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = Conexao.conectar();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, aluno.getNome());
            ps.setString(2, aluno.getCpf());
            ps.setString(3, aluno.getEmail());
            ps.setString(4, aluno.getTelefone());
            ps.setString(5, aluno.getEndereco());
            ps.setDate(6, Date.valueOf(aluno.getDataNascimento()));
            ps.setDouble(7, aluno.getPeso());
            ps.setDouble(8, aluno.getAltura());
            ps.setDate(9, Date.valueOf(aluno.getDataCadastro() != null ? aluno.getDataCadastro() : LocalDate.now()));
            ps.setBoolean(10, aluno.isAtivo());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            ultimoErro = "Erro ao cadastrar aluno: " + e.getMessage();
            System.err.println("-> " + ultimoErro);
            return false;
        }
    }

    public List<Aluno> listarAlunos() {
        List<Aluno> alunos = new ArrayList<>();
        String sql = "SELECT * FROM aluno ORDER BY id";
        try (Connection conn = Conexao.conectar();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Aluno a = new Aluno();
                a.setId(rs.getInt("id"));
                a.setNome(rs.getString("nome"));
                a.setCpf(rs.getString("cpf"));
                a.setEmail(rs.getString("email"));
                a.setTelefone(rs.getString("telefone"));
                a.setEndereco(rs.getString("endereco"));
                String dataNascStr = rs.getString("data_nascimento");
                if (dataNascStr != null && dataNascStr.length() >= 10) {
                    try {
                        a.setDataNascimento(LocalDate.parse(dataNascStr.substring(0, 10)));
                    } catch (Exception e) {
                        a.setDataNascimento(LocalDate.now());
                    }
                } else {
                    a.setDataNascimento(LocalDate.now());
                }
                a.setPeso(rs.getDouble("peso"));
                a.setAltura(rs.getDouble("altura"));
                String dataCadStr = rs.getString("data_cadastro");
                if (dataCadStr != null && dataCadStr.length() >= 10) {
                    try {
                        a.setDataCadastro(LocalDate.parse(dataCadStr.substring(0, 10)));
                    } catch (Exception e) {
                        a.setDataCadastro(LocalDate.now());
                    }
                } else {
                    a.setDataCadastro(LocalDate.now());
                }
                a.setAtivo(rs.getBoolean("ativo"));
                alunos.add(a);
            }
        } catch (Exception e) {
            System.err.println("-> Erro ao listar alunos: " + e.getMessage());
        }
        return alunos;
    }

    public boolean atualizarAluno(Aluno aluno) {
        ultimoErro = null;
        if (cpfJaCadastrado(aluno.getCpf(), aluno.getId())) {
            ultimoErro = "CPF já pertence a outro aluno!";
            System.err.println("-> " + ultimoErro);
            return false;
        }
        if (emailJaCadastrado(aluno.getEmail(), aluno.getId())) {
            ultimoErro = "E-mail já pertence a outro aluno!";
            System.err.println("-> " + ultimoErro);
            return false;
        }
        String sql = "UPDATE aluno SET nome=?, cpf=?, email=?, telefone=?, endereco=?, data_nascimento=?, peso=?, altura=?, ativo=? WHERE id=?";
        try (Connection conn = Conexao.conectar();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, aluno.getNome());
            ps.setString(2, aluno.getCpf());
            ps.setString(3, aluno.getEmail());
            ps.setString(4, aluno.getTelefone());
            ps.setString(5, aluno.getEndereco());
            ps.setDate(6, Date.valueOf(aluno.getDataNascimento()));
            ps.setDouble(7, aluno.getPeso());
            ps.setDouble(8, aluno.getAltura());
            ps.setBoolean(9, aluno.isAtivo());
            ps.setInt(10, aluno.getId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            ultimoErro = "Erro ao atualizar aluno: " + e.getMessage();
            System.err.println("-> " + ultimoErro);
            return false;
        }
    }

    public boolean deletarAluno(int id) {
        try (Connection conn = Conexao.conectar()) {
            conn.setAutoCommit(false);
            try {
                boolean result = DbUtil.deletarEResetarSeq(conn, "aluno", "id", id);
                conn.commit();
                return result;
            } catch (Exception e) {
                conn.rollback();
                throw e;
            }
        } catch (Exception e) {
            System.err.println("-> Erro ao deletar aluno: " + e.getMessage());
            return false;
        }
    }
}
