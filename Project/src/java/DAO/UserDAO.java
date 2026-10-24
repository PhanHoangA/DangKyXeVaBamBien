package DAO;

import DAL.DBContext;
import Models.District;
import Models.Role;
import Models.User;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;

public class UserDAO extends DBContext {

    public UserDAO() throws ClassNotFoundException {
        super();
    }

    /**
     * Xác thực thông tin đăng nhập theo tên đăng nhập hoặc số CCCD 12 chữ số
     * @param usernameOrIdentity Tên tài khoản hoặc CCCD
     * @param password Mật khẩu
     * @return User nếu thông tin chính xác kèm theo Role và District, ngược lại trả về null
     */
    public User login(String usernameOrIdentity, String password) {
        if (connection == null || usernameOrIdentity == null || password == null) {
            return null;
        }

        String sql = "SELECT u.userId, u.userName, u.userpassword, u.fullName, u.identityCard, " +
                     "       u.phone, u.email, u.address, u.districtId, u.roleId, u.createAt, " +
                     "       r.roleName, " +
                     "       d.provinceName, d.districtName, d.platePrefix " +
                     "FROM dbo.USERS u " +
                     "JOIN dbo.ROLES r ON u.roleId = r.roleId " +
                     "JOIN dbo.DISTRICTS d ON u.districtId = d.districtId " +
                     "WHERE (u.userName = ? OR u.identityCard = ?) AND u.userpassword = ?";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            String cleanInput = usernameOrIdentity.trim();
            ps.setString(1, cleanInput);
            ps.setString(2, cleanInput);
            ps.setString(3, password);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    User user = new User();
                    user.setUserId(rs.getInt("userId"));
                    user.setUserName(rs.getString("userName"));
                    user.setUserpassword(rs.getString("userpassword"));
                    user.setFullName(rs.getString("fullName"));
                    user.setIdentityCard(rs.getString("identityCard"));
                    user.setPhone(rs.getString("phone"));
                    user.setEmail(rs.getString("email"));
                    user.setAddress(rs.getString("address"));
                    user.setDistrictId(rs.getInt("districtId"));
                    user.setRoleId(rs.getInt("roleId"));
                    user.setCreateAt(rs.getTimestamp("createAt"));

                    // Gán Role
                    Role role = new Role(user.getRoleId(), rs.getString("roleName"));
                    user.setRole(role);

                    // Gán District
                    District district = new District(user.getDistrictId(), 
                                                     rs.getString("provinceName"), 
                                                     rs.getString("districtName"), 
                                                     rs.getString("platePrefix"));
                    user.setDistrict(district);

                    return user;
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(UserDAO.class.getName()).log(Level.SEVERE, "Lỗi truy vấn login trong UserDAO", ex);
        }
        return null;
    }

    /**
     * Kiểm tra xem tên đăng nhập (userName) đã tồn tại trong USERS hay chưa
     */
    public boolean isUsernameExists(String userName) {
        if (connection == null || userName == null || userName.trim().isEmpty()) {
            return false;
        }
        String sql = "SELECT 1 FROM dbo.USERS WHERE userName = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, userName.trim());
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException ex) {
            Logger.getLogger(UserDAO.class.getName()).log(Level.SEVERE, "Lỗi kiểm tra trùng userName", ex);
        }
        return false;
    }

    /**
     * Kiểm tra xem số định danh cá nhân (identityCard) 12 số đã tồn tại hay chưa
     */
    public boolean isIdentityCardExists(String identityCard) {
        if (connection == null || identityCard == null || identityCard.trim().isEmpty()) {
            return false;
        }
        String sql = "SELECT 1 FROM dbo.USERS WHERE identityCard = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, identityCard.trim());
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException ex) {
            Logger.getLogger(UserDAO.class.getName()).log(Level.SEVERE, "Lỗi kiểm tra trùng identityCard", ex);
        }
        return false;
    }

    /**
     * Lấy danh sách tất cả Quận/Huyện cho form đăng ký công dân
     */
    public java.util.List<District> getAllDistricts() {
        java.util.List<District> list = new java.util.ArrayList<>();
        if (connection == null) {
            return list;
        }
        String sql = "SELECT districtId, provinceName, districtName, platePrefix FROM dbo.DISTRICTS ORDER BY provinceName, districtName";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new District(
                    rs.getInt("districtId"),
                    rs.getString("provinceName"),
                    rs.getString("districtName"),
                    rs.getString("platePrefix")
                ));
            }
        } catch (SQLException ex) {
            Logger.getLogger(UserDAO.class.getName()).log(Level.SEVERE, "Lỗi lấy danh sách Quận/Huyện trong UserDAO", ex);
        }
        return list;
    }

    /**
     * Lấy roleId của ROLE_USER (mặc định 3 nếu không tìm thấy)
     */
    public int getCitizenRoleId() {
        if (connection == null) {
            return 3;
        }
        String sql = "SELECT roleId FROM dbo.ROLES WHERE roleName = 'ROLE_USER'";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt("roleId");
            }
        } catch (SQLException ex) {
            Logger.getLogger(UserDAO.class.getName()).log(Level.WARNING, "Không truy vấn được roleId cho ROLE_USER, dùng mặc định 3", ex);
        }
        return 3;
    }

    /**
     * FR-01: Đăng ký tài khoản Công dân mới (ROLE_USER)
     * @param user Thông tin công dân đăng ký
     * @return true nếu lưu thành công, false nếu thất bại
     */
    public boolean registerCitizen(User user) {
        if (connection == null || user == null) {
            return false;
        }

        int citizenRoleId = getCitizenRoleId();

        String sql = "INSERT INTO dbo.USERS (userName, userpassword, fullName, identityCard, phone, email, address, districtId, roleId, createAt) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE())";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, user.getUserName().trim());
            ps.setString(2, user.getUserpassword());
            ps.setString(3, user.getFullName().trim());
            ps.setString(4, user.getIdentityCard().trim());
            ps.setString(5, user.getPhone().trim());
            ps.setString(6, user.getEmail() != null && !user.getEmail().trim().isEmpty() ? user.getEmail().trim() : null);
            ps.setString(7, user.getAddress().trim());
            ps.setInt(8, user.getDistrictId());
            ps.setInt(9, citizenRoleId);

            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException ex) {
            Logger.getLogger(UserDAO.class.getName()).log(Level.SEVERE, "Lỗi đăng ký công dân trong UserDAO", ex);
            return false;
        }
    }

    /**
     * Lấy roleId của ROLE_OFFICER (mặc định 2 nếu không tìm thấy)
     */
    public int getOfficerRoleId() {
        if (connection == null) {
            return 2;
        }
        String sql = "SELECT roleId FROM dbo.ROLES WHERE roleName = 'ROLE_OFFICER'";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt("roleId");
            }
        } catch (SQLException ex) {
            Logger.getLogger(UserDAO.class.getName()).log(Level.WARNING, "Không truy vấn được roleId cho ROLE_OFFICER, dùng mặc định 2", ex);
        }
        return 2;
    }

    /**
     * Lấy danh sách toàn bộ Cán bộ CSGT (ROLE_OFFICER) kèm bộ lọc theo Quận/Huyện và từ khóa
     */
    public java.util.List<User> getAllOfficers(Integer filterDistrictId, String keyword) {
        java.util.List<User> list = new java.util.ArrayList<>();
        if (connection == null) {
            return list;
        }

        StringBuilder sql = new StringBuilder(
            "SELECT u.userId, u.userName, u.userpassword, u.fullName, u.identityCard, " +
            "       u.phone, u.email, u.address, u.districtId, u.roleId, u.createAt, " +
            "       r.roleName, " +
            "       d.provinceName, d.districtName, d.platePrefix " +
            "FROM dbo.USERS u " +
            "JOIN dbo.ROLES r ON u.roleId = r.roleId " +
            "JOIN dbo.DISTRICTS d ON u.districtId = d.districtId " +
            "WHERE r.roleName = 'ROLE_OFFICER' "
        );

        if (filterDistrictId != null && filterDistrictId > 0) {
            sql.append(" AND u.districtId = ? ");
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (u.fullName LIKE ? OR u.userName LIKE ? OR u.identityCard LIKE ? OR u.phone LIKE ?) ");
        }

        sql.append(" ORDER BY d.districtName ASC, u.fullName ASC");

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            int paramIdx = 1;
            if (filterDistrictId != null && filterDistrictId > 0) {
                ps.setInt(paramIdx++, filterDistrictId);
            }
            if (keyword != null && !keyword.trim().isEmpty()) {
                String pattern = "%" + keyword.trim() + "%";
                ps.setString(paramIdx++, pattern);
                ps.setString(paramIdx++, pattern);
                ps.setString(paramIdx++, pattern);
                ps.setString(paramIdx++, pattern);
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    User officer = new User();
                    officer.setUserId(rs.getInt("userId"));
                    officer.setUserName(rs.getString("userName"));
                    officer.setUserpassword(rs.getString("userpassword"));
                    officer.setFullName(rs.getString("fullName"));
                    officer.setIdentityCard(rs.getString("identityCard"));
                    officer.setPhone(rs.getString("phone"));
                    officer.setEmail(rs.getString("email"));
                    officer.setAddress(rs.getString("address"));
                    officer.setDistrictId(rs.getInt("districtId"));
                    officer.setRoleId(rs.getInt("roleId"));
                    officer.setCreateAt(rs.getTimestamp("createAt"));

                    Role role = new Role(officer.getRoleId(), rs.getString("roleName"));
                    officer.setRole(role);

                    District district = new District(
                        officer.getDistrictId(),
                        rs.getString("provinceName"),
                        rs.getString("districtName"),
                        rs.getString("platePrefix")
                    );
                    officer.setDistrict(district);

                    list.add(officer);
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(UserDAO.class.getName()).log(Level.SEVERE, "Lỗi lấy danh sách cán bộ CSGT", ex);
        }
        return list;
    }

    /**
     * Thống kê số lượng Cán bộ CSGT được phân công theo từng Quận/Huyện (districtId -> count)
     */
    public java.util.Map<Integer, Integer> getOfficerCountByDistrict() {
        java.util.Map<Integer, Integer> map = new java.util.HashMap<>();
        if (connection == null) {
            return map;
        }

        String sql = "SELECT d.districtId, COUNT(u.userId) AS officerCount " +
                     "FROM dbo.DISTRICTS d " +
                     "LEFT JOIN dbo.USERS u ON d.districtId = u.districtId AND u.roleId = ? " +
                     "GROUP BY d.districtId";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, getOfficerRoleId());
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    map.put(rs.getInt("districtId"), rs.getInt("officerCount"));
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(UserDAO.class.getName()).log(Level.SEVERE, "Lỗi thống kê số lượng cán bộ theo quận", ex);
        }
        return map;
    }

    /**
     * Quản trị viên tạo tài khoản Cán bộ CSGT mới (ROLE_OFFICER)
     */
    public boolean createOfficer(User officer) {
        if (connection == null || officer == null) {
            return false;
        }

        int officerRoleId = getOfficerRoleId();

        String sql = "INSERT INTO dbo.USERS (userName, userpassword, fullName, identityCard, phone, email, address, districtId, roleId, createAt) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE())";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, officer.getUserName().trim());
            ps.setString(2, officer.getUserpassword());
            ps.setString(3, officer.getFullName().trim());
            ps.setString(4, officer.getIdentityCard().trim());
            ps.setString(5, officer.getPhone().trim());
            ps.setString(6, officer.getEmail() != null && !officer.getEmail().trim().isEmpty() ? officer.getEmail().trim() : null);
            ps.setString(7, officer.getAddress().trim());
            ps.setInt(8, officer.getDistrictId());
            ps.setInt(9, officerRoleId);

            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException ex) {
            Logger.getLogger(UserDAO.class.getName()).log(Level.SEVERE, "Lỗi tạo tài khoản cán bộ CSGT trong UserDAO", ex);
            return false;
        }
    }

    /**
     * Điều chuyển Cán bộ CSGT sang phụ trách Quận/Huyện khác
     */
    public boolean updateOfficerDistrict(int officerUserId, int newDistrictId) {
        if (connection == null) {
            return false;
        }

        String sql = "UPDATE dbo.USERS SET districtId = ? WHERE userId = ? AND roleId = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, newDistrictId);
            ps.setInt(2, officerUserId);
            ps.setInt(3, getOfficerRoleId());

            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException ex) {
            Logger.getLogger(UserDAO.class.getName()).log(Level.SEVERE, "Lỗi điều chuyển quận công tác cho cán bộ", ex);
            return false;
        }
    }

    /**
     * Đặt lại mật khẩu (Reset password) cho Cán bộ CSGT
     */
    public boolean resetOfficerPassword(int officerUserId, String newPassword) {
        if (connection == null || newPassword == null || newPassword.trim().isEmpty()) {
            return false;
        }

        String sql = "UPDATE dbo.USERS SET userpassword = ? WHERE userId = ? AND roleId = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, newPassword);
            ps.setInt(2, officerUserId);
            ps.setInt(3, getOfficerRoleId());

            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
        } catch (SQLException ex) {
            Logger.getLogger(UserDAO.class.getName()).log(Level.SEVERE, "Lỗi đặt lại mật khẩu cho cán bộ", ex);
            return false;
        }
    }
}
