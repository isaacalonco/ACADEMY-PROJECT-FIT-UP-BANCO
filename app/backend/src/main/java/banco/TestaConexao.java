package banco;

public class TestaConexao {

    public static void main(String[] args) {
        try {
            System.out.println("Testando conexão...");
            
            // Tenta chamar o método de conexão
            java.sql.Connection conn = Conexao.conectar();
            
            if (conn != null) {
                System.out.println("Tudo certo! A conexão com o banco de dados 'academy' foi bem-sucedida.");
                conn.close();
            }
            
        } catch (Exception e) {
            System.err.println("Falha no teste: Não foi possível conectar ao banco de dados.");
            System.err.println("Motivo: " + e.getMessage());
        }
    }
}
