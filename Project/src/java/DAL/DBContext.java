package DAL;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

public class DBContext {
    protected Connection connection;

    public DBContext() throws ClassNotFoundException {
        try {
            connection = null;
            String driverName = "com.microsoft.sqlserver.jdbc.SQLServerDriver";
            String dbUrl = "jdbc:sqlserver://localhost:1433;databasename=DangKyXeVaBamBienProject;trustServerCertificate=true";
            Class.forName(driverName);
            String uid = "sa";
            String pwd = "123";
            connection = DriverManager.getConnection(dbUrl, uid, pwd);
        } catch (SQLException ex) {
            Logger.getLogger(DBContext.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

    public static void main(String[] args) throws ClassNotFoundException {
        DBContext _context = new DBContext();
        System.out.println(_context.connection);
    }
}
