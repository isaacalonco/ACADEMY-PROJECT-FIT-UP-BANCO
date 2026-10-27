package banco;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public final class DbUtil {

    private DbUtil() {}


    public static boolean cpfJaCadastrado(Connection conn, String table, String cpfCol,
                                          String cpf, int ignoreId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM " + table + " WHERE " + cpfCol + " = ? AND id != ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, cpf);
            ps.setInt(2, ignoreId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    public static boolean deletarEResetarSeq(Connection conn, String table, String idCol,
                                             int id) throws SQLException {
        String sqlDelete = "DELETE FROM " + table + " WHERE " + idCol + " = ?";
        String sqlReset  = "UPDATE sqlite_sequence SET seq = "
                         + "(SELECT COALESCE(MAX(" + idCol + "), 0) FROM " + table + ") "
                         + "WHERE name = '" + table + "'";
        try (PreparedStatement psDelete = conn.prepareStatement(sqlDelete);
             PreparedStatement psReset  = conn.prepareStatement(sqlReset)) {
            psDelete.setInt(1, id);
            int rows = psDelete.executeUpdate();
            psReset.executeUpdate();
            return rows > 0;
        }
    }
}
