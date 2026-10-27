package banco;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.stream.Collectors;

public class Conexao {

    private static final String URL = "jdbc:sqlite:academy.db";

    public static Connection conectar() {
        try {
            return DriverManager.getConnection(URL);
        } catch (Exception erro) {
            throw new RuntimeException("Erro ao conectar: " + erro.getMessage());
        }
    }

    public static void inicializarBanco() {
        try (Connection conn = conectar(); Statement stmt = conn.createStatement()) {
            stmt.execute("PRAGMA foreign_keys = ON;");
            
            InputStream in = Conexao.class.getResourceAsStream("/schema.sql");
            if (in != null) {
                String sql = new BufferedReader(new InputStreamReader(in, java.nio.charset.StandardCharsets.UTF_8))
                                .lines().collect(Collectors.joining("\n"));
                
                String[] comandos = sql.split(";");
                for (String comando : comandos) {
                    if (!comando.trim().isEmpty()) {
                        stmt.execute(comando);
                    }
                }
            }

            popularBancoSeNecessario(stmt);

        } catch (Exception e) {
            System.err.println("-> Erro ao inicializar banco: " + e.getMessage());
        }
    }

    private static void popularBancoSeNecessario(Statement stmt) {
        try {
            // 1. Popular Planos se houver menos de 3
            ResultSet rsPlanos = stmt.executeQuery("SELECT COUNT(*) FROM plano");
            int totalPlanos = rsPlanos.next() ? rsPlanos.getInt(1) : 0;
            rsPlanos.close();

            if (totalPlanos < 3) {
                stmt.executeUpdate("INSERT OR IGNORE INTO plano (id, nome, valor) VALUES " +
                        "(1, 'Plano Black VIP', 139.90)," +
                        "(2, 'Plano Fit Smart', 89.90)," +
                        "(3, 'Plano Anual Prime', 109.90)," +
                        "(4, 'Plano Universitário', 69.90)," +
                        "(5, 'Plano Premium Família', 199.90);");
            }

            // 2. Popular Instrutores se houver menos de 3
            ResultSet rsInst = stmt.executeQuery("SELECT COUNT(*) FROM instrutor");
            int totalInst = rsInst.next() ? rsInst.getInt(1) : 0;
            rsInst.close();

            if (totalInst < 3) {
                stmt.executeUpdate("INSERT OR IGNORE INTO instrutor (id_instrutor, nome, cpf, email, telefone, especialidade) VALUES " +
                        "(1, 'Carlos Eduardo Silveira', '101.000.111-01', 'carlos.silveira@fitup.com', '(61) 98111-0001', 'Coordenação & Fisiologia')," +
                        "(2, 'Mariana Ferreira Lima', '101.000.111-02', 'mariana.lima@fitup.com', '(61) 98111-0002', 'Musculação & Hipertrofia')," +
                        "(3, 'Rodrigo Santos Barreto', '101.000.111-03', 'rodrigo.barreto@fitup.com', '(61) 98111-0003', 'CrossFit & Funcional')," +
                        "(4, 'Camila Guimarães Rocha', '101.000.111-04', 'camila.rocha@fitup.com', '(61) 98111-0004', 'Pilates & Reabilitação')," +
                        "(5, 'Felipe Nogueira Dias', '101.000.111-05', 'felipe.dias@fitup.com', '(61) 98111-0005', 'Cardio & HIIT')," +
                        "(6, 'Juliana Barbosa Mendes', '101.000.111-06', 'juliana.mendes@fitup.com', '(61) 98111-0006', 'Zumba, Dança & Ritmos');");
            }

            // 3. Popular Alunos se houver menos de 5
            ResultSet rsAlunos = stmt.executeQuery("SELECT COUNT(*) FROM aluno");
            int totalAlunos = rsAlunos.next() ? rsAlunos.getInt(1) : 0;
            rsAlunos.close();

            if (totalAlunos < 5) {
                stmt.executeUpdate("INSERT OR IGNORE INTO aluno (id, nome, cpf, email, telefone, endereco, data_nascimento, peso, altura, data_cadastro, ativo) VALUES " +
                        "(3, 'Lucas Gabriel Santos', '202.000.222-01', 'lucas.santos@email.com', '(61) 99123-0001', 'Asa Norte, Bloco C, Brasília-DF', '1995-02-15', 78.5, 1.80, '2026-01-10', 1)," +
                        "(4, 'Beatriz Albuquerque Lima', '202.000.222-02', 'beatriz.lima@email.com', '(61) 99123-0002', 'Asa Sul, Quadra 402, Brasília-DF', '1998-06-20', 58.0, 1.65, '2026-01-15', 1)," +
                        "(5, 'Gustavo Henrique Prado', '202.000.222-03', 'gustavo.prado@email.com', '(61) 99123-0003', 'Águas Claras, Rua 12, Brasília-DF', '1993-10-11', 85.0, 1.78, '2026-02-01', 1)," +
                        "(6, 'Larissa Vasconcelos Rios', '202.000.222-04', 'larissa.rios@email.com', '(61) 99123-0004', 'Sudoeste, QMSW 5, Brasília-DF', '2000-04-03', 54.2, 1.62, '2026-02-05', 1)," +
                        "(7, 'Thiago Carvalho Melo', '202.000.222-05', 'thiago.melo@email.com', '(61) 99123-0005', 'Lago Norte, SHIN QL 2, Brasília-DF', '1987-12-25', 92.0, 1.84, '2026-02-10', 1)," +
                        "(8, 'Fernanda Antunes Maia', '202.000.222-06', 'fernanda.maia@email.com', '(61) 99123-0006', 'Taguatinga Norte, QND 15, Taguatinga-DF', '1996-08-19', 64.0, 1.70, '2026-02-15', 1)," +
                        "(9, 'Matheus Dantas Castro', '202.000.222-07', 'matheus.castro@email.com', '(61) 99123-0007', 'Guará II, QE 19, Guará-DF', '1991-05-14', 76.0, 1.75, '2026-02-20', 1)," +
                        "(10, 'Patricia Fontes Ribeiro', '202.000.222-08', 'patricia.ribeiro@email.com', '(61) 99123-0008', 'Noroeste, SQNW 104, Brasília-DF', '1989-03-08', 61.5, 1.68, '2026-02-25', 1)," +
                        "(11, 'Andre Luis Camargo', '202.000.222-09', 'andre.camargo@email.com', '(61) 99123-0009', 'Vicente Pires, Rua 3, Vicente Pires-DF', '1994-09-29', 88.0, 1.82, '2026-03-01', 1)," +
                        "(12, 'Renata Farias Bezerra', '202.000.222-10', 'renata.bezerra@email.com', '(61) 99123-0010', 'Asa Norte, CLN 210, Brasília-DF', '1997-11-17', 56.0, 1.60, '2026-03-05', 1);");

                // 4. Matrículas correspondentes
                stmt.executeUpdate("INSERT OR IGNORE INTO matricula (id_aluno, id_plano, data_matricula) VALUES " +
                        "(1, 1, '2026-01-10')," +
                        "(2, 2, '2026-01-10')," +
                        "(3, 1, '2026-01-10')," +
                        "(4, 2, '2026-01-15')," +
                        "(5, 3, '2026-02-01')," +
                        "(6, 4, '2026-02-05')," +
                        "(7, 1, '2026-02-10')," +
                        "(8, 5, '2026-02-15')," +
                        "(9, 2, '2026-02-20')," +
                        "(10, 3, '2026-02-25')," +
                        "(11, 1, '2026-03-01')," +
                        "(12, 4, '2026-03-05');");

                // 5. Pagamentos com status variados
                stmt.executeUpdate("INSERT OR IGNORE INTO pagamento (id_aluno, valor, status) VALUES " +
                        "(3, 139.90, 'Pago')," +
                        "(4, 89.90, 'Pago')," +
                        "(5, 109.90, 'Pago')," +
                        "(6, 69.90, 'Pendente')," +
                        "(7, 139.90, 'Atrasado')," +
                        "(8, 199.90, 'Pago')," +
                        "(9, 89.90, 'Pago')," +
                        "(10, 109.90, 'Pendente')," +
                        "(11, 139.90, 'Pago')," +
                        "(12, 69.90, 'Pago');");
            }

        } catch (Exception e) {
            System.err.println("-> Erro ao popular dados iniciais: " + e.getMessage());
        }
    }
}