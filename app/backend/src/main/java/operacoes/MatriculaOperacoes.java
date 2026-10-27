package operacoes;

import banco.Conexao;
import entidades.Matricula;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class MatriculaOperacoes {

    public boolean cadastrarMatricula(Matricula matricula) {
        String sql = "INSERT INTO matricula (id_aluno, id_plano, data_matricula) VALUES (?, ?, ?)";

        try (Connection conn = Conexao.conectar();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, matricula.getIdAluno());
            pstmt.setInt(2, matricula.getIdPlano());
            pstmt.setDate(3, Date.valueOf(
                    matricula.getDataMatricula() != null ? matricula.getDataMatricula() : LocalDate.now()));

            return pstmt.executeUpdate() > 0;

        } catch (Exception e) {
            System.err.println("-> Erro ao cadastrar matrícula: " + e.getMessage());
            return false;
        }
    }

    public List<MatriculaView> listarMatriculas() {
        List<MatriculaView> matriculas = new ArrayList<>();
        String sql = "SELECT m.id_matricula, m.id_aluno, a.nome AS nome_aluno, p.nome AS nome_plano, m.data_matricula " +
                     "FROM matricula m " +
                     "JOIN aluno a ON m.id_aluno = a.id " +
                     "JOIN plano p ON m.id_plano = p.id " +
                     "ORDER BY m.data_matricula DESC";

        try (Connection conn = Conexao.conectar();
             PreparedStatement pstmt = conn.prepareStatement(sql);
             ResultSet rs = pstmt.executeQuery()) {

            while (rs.next()) {
                String dataMatStr = rs.getString("data_matricula");
                if (dataMatStr != null && dataMatStr.length() >= 10) {
                    dataMatStr = dataMatStr.substring(0, 10);
                } else if (dataMatStr == null) {
                    dataMatStr = LocalDate.now().toString();
                }
                matriculas.add(new MatriculaView(
                        rs.getInt("id_matricula"),
                        rs.getInt("id_aluno"),
                        rs.getString("nome_aluno"),
                        rs.getString("nome_plano"),
                        dataMatStr
                ));
            }

        } catch (Exception e) {
            System.err.println("-> Erro ao listar matrículas: " + e.getMessage());
        }
        return matriculas;
    }

    public boolean deletarPorAluno(int idAluno) {
        String sql = "DELETE FROM matricula WHERE id_aluno=?";
        try (Connection conn = Conexao.conectar();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, idAluno);
            ps.executeUpdate();
            return true;
        } catch (Exception e) {
            System.err.println("-> Erro ao deletar matrícula: " + e.getMessage());
            return false;
        }
    }

    public boolean atualizarPlanoDoAluno(int idAluno, int idPlano) {
        deletarPorAluno(idAluno);
        Matricula m = new Matricula(0, idAluno, idPlano, LocalDate.now());
        return cadastrarMatricula(m);
    }

    public static class MatriculaView {
        public int idMatricula;
        public int idAluno;
        public String nomeAluno;
        public String nomePlano;
        public String dataMatricula;

        public MatriculaView(int idMatricula, int idAluno, String nomeAluno, String nomePlano, String dataMatricula) {
            this.idMatricula = idMatricula;
            this.idAluno = idAluno;
            this.nomeAluno = nomeAluno;
            this.nomePlano = nomePlano;
            this.dataMatricula = dataMatricula;
        }
    }
}
