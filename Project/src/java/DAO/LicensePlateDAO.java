package DAO;

import DAL.DBContext;
import Models.District;
import Models.LicensePlate;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

public class LicensePlateDAO extends DBContext {

    public LicensePlateDAO() throws ClassNotFoundException {
        super();
    }

    /**
     * Lấy danh sách tất cả các Quận/Huyện trong hệ thống
     */
    public List<District> getAllDistricts() {
        List<District> list = new ArrayList<>();
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
                        rs.getString("platePrefix")));
            }
        } catch (SQLException ex) {
            Logger.getLogger(LicensePlateDAO.class.getName()).log(Level.SEVERE, "Lỗi lấy danh mục Quận/Huyện", ex);
        }
        return list;
    }

    /**
     * Lấy thông tin chi tiết một Quận/Huyện theo ID
     */
    public District getDistrictById(int districtId) {
        if (connection == null) {
            return null;
        }
        String sql = "SELECT districtId, provinceName, districtName, platePrefix FROM dbo.DISTRICTS WHERE districtId = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, districtId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return new District(
                            rs.getInt("districtId"),
                            rs.getString("provinceName"),
                            rs.getString("districtName"),
                            rs.getString("platePrefix"));
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(LicensePlateDAO.class.getName()).log(Level.SEVERE, "Lỗi tìm Quận theo ID", ex);
        }
        return null;
    }

    /**
     * Thống kê tổng số lượng biển số theo từng trạng thái trên toàn quốc
     */
    public Map<String, Integer> getPlateStats(int districtId) {
        Map<String, Integer> stats = new HashMap<>();
        stats.put("TOTAL", 0);
        stats.put("AVAILABLE", 0);
        stats.put("ASSIGNED", 0);
        stats.put("BLOCKED", 0);

        if (connection == null) {
            return stats;
        }

        StringBuilder sql = new StringBuilder(
                "SELECT status, COUNT(*) AS countNum FROM dbo.LICENSE_PLATES ");
        if (districtId > 0) {
            sql.append("WHERE districtId = ? ");
        }
        sql.append("GROUP BY status");

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            if (districtId > 0) {
                ps.setInt(1, districtId);
            }
            try (ResultSet rs = ps.executeQuery()) {
                int total = 0;
                while (rs.next()) {
                    String st = rs.getString("status");
                    int count = rs.getInt("countNum");
                    if (st != null) {
                        stats.put(st.toUpperCase(), count);
                    }
                    total += count;
                }
                stats.put("TOTAL", total);
            }
        } catch (SQLException ex) {
            Logger.getLogger(LicensePlateDAO.class.getName()).log(Level.SEVERE, "Lỗi thống kê kho biển", ex);
        }
        return stats;
    }

    /**
     * Thống kê toàn cảnh hệ thống dành cho Admin Dashboard
     */
    public Map<String, Integer> getSystemWideStats() {
        Map<String, Integer> stats = new HashMap<>();
        stats.put("TOTAL_CITIZENS", 0);
        stats.put("TOTAL_OFFICERS", 0);
        stats.put("TOTAL_VEHICLES", 0);
        stats.put("TOTAL_REGISTRATIONS", 0);
        stats.put("REG_PENDING", 0);
        stats.put("REG_APPROVED", 0);
        stats.put("REG_DRAWN", 0);
        stats.put("REG_REJECTED", 0);

        if (connection == null) {
            return stats;
        }

        try {
            // Đếm người dùng theo vai trò
            String userSql = "SELECT r.roleName, COUNT(*) AS total FROM dbo.USERS u JOIN dbo.ROLES r ON u.roleId = r.roleId GROUP BY r.roleName";
            try (PreparedStatement ps = connection.prepareStatement(userSql);
                    ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    String role = rs.getString("roleName");
                    int c = rs.getInt("total");
                    if ("ROLE_USER".equalsIgnoreCase(role)) {
                        stats.put("TOTAL_CITIZENS", c);
                    } else if ("ROLE_OFFICER".equalsIgnoreCase(role)) {
                        stats.put("TOTAL_OFFICERS", c);
                    }
                }
            }

            // Đếm phương tiện
            String vehSql = "SELECT COUNT(*) FROM dbo.VEHICLES";
            try (PreparedStatement ps = connection.prepareStatement(vehSql);
                    ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    stats.put("TOTAL_VEHICLES", rs.getInt(1));
                }
            }

            // Đếm hồ sơ theo trạng thái
            String regSql = "SELECT status, COUNT(*) AS total FROM dbo.REGISTRATIONS GROUP BY status";
            try (PreparedStatement ps = connection.prepareStatement(regSql);
                    ResultSet rs = ps.executeQuery()) {
                int totalReg = 0;
                while (rs.next()) {
                    String st = rs.getString("status");
                    int c = rs.getInt("total");
                    totalReg += c;
                    if ("PENDING".equalsIgnoreCase(st))
                        stats.put("REG_PENDING", c);
                    else if ("APPROVED".equalsIgnoreCase(st))
                        stats.put("REG_APPROVED", c);
                    else if ("DRAWN".equalsIgnoreCase(st))
                        stats.put("REG_DRAWN", c);
                    else if ("REJECTED".equalsIgnoreCase(st))
                        stats.put("REG_REJECTED", c);
                }
                stats.put("TOTAL_REGISTRATIONS", totalReg);
            }

        } catch (SQLException ex) {
            Logger.getLogger(LicensePlateDAO.class.getName()).log(Level.SEVERE, "Lỗi lấy thống kê toàn cảnh hệ thống",
                    ex);
        }
        return stats;
    }

    /**
     * Tra cứu danh sách biển số có lọc và tìm kiếm theo Quận, trạng thái, từ khóa
     */
    public List<LicensePlate> getPlates(int districtId, String status, String keyword, int limit) {
        List<LicensePlate> list = new ArrayList<>();
        if (connection == null) {
            return list;
        }

        StringBuilder sql = new StringBuilder(
                "SELECT TOP (?) lp.plateId, lp.districtId, lp.plateNumber, lp.fullPlate, lp.status, lp.assignedAt, " +
                        "       d.provinceName, d.districtName, d.platePrefix " +
                        "FROM dbo.LICENSE_PLATES lp " +
                        "JOIN dbo.DISTRICTS d ON lp.districtId = d.districtId " +
                        "WHERE 1=1 ");

        List<Object> params = new ArrayList<>();
        params.add(limit > 0 ? limit : 200);

        if (districtId > 0) {
            sql.append("AND lp.districtId = ? ");
            params.add(districtId);
        }

        if (status != null && !status.trim().isEmpty() && !status.equalsIgnoreCase("ALL")) {
            sql.append("AND lp.status = ? ");
            params.add(status.trim().toUpperCase());
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (lp.fullPlate LIKE ? OR lp.plateNumber LIKE ?) ");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
        }

        sql.append("ORDER BY lp.plateId DESC");

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    LicensePlate plate = new LicensePlate();
                    plate.setPlateId(rs.getInt("plateId"));
                    plate.setDistrictId(rs.getInt("districtId"));
                    plate.setPlateNumber(rs.getString("plateNumber"));
                    plate.setFullPlate(rs.getString("fullPlate"));
                    plate.setStatus(rs.getString("status"));
                    plate.setAssignedAt(rs.getTimestamp("assignedAt"));

                    District d = new District(
                            plate.getDistrictId(),
                            rs.getString("provinceName"),
                            rs.getString("districtName"),
                            rs.getString("platePrefix"));
                    plate.setDistrict(d);

                    list.add(plate);
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(LicensePlateDAO.class.getName()).log(Level.SEVERE, "Lỗi lấy danh sách biển số", ex);
        }
        return list;
    }

    /**
     * Kiểm tra biển số đẹp (Ngũ quý, Sảnh tiến, Tứ quý) theo quy định FR-09
     * 
     * @param plateNumber Định dạng 5 chữ số có dấu chấm (VD: "555.55", "123.45")
     */
    public boolean isSpecialPlate(String plateNumber) {
        if (plateNumber == null)
            return false;
        String digits = plateNumber.replace(".", "").trim();
        if (digits.length() != 5)
            return false;

        char c0 = digits.charAt(0);
        char c1 = digits.charAt(1);
        char c2 = digits.charAt(2);
        char c3 = digits.charAt(3);
        char c4 = digits.charAt(4);

        // 1. Ngũ quý (5 số giống nhau, VD: 111.11, 888.88, 999.99)
        if (c0 == c1 && c1 == c2 && c2 == c3 && c3 == c4) {
            return true;
        }

        // 2. Tứ quý (4 số giống nhau, VD: 888.81, 188.88)
        if ((c0 == c1 && c1 == c2 && c2 == c3) || (c1 == c2 && c2 == c3 && c3 == c4)) {
            return true;
        }

        // 3. Sảnh tiến (Dãy số liên tiếp tăng dần, VD: 123.45, 234.56, 345.67, 456.78,
        // 567.89)
        if (c1 == c0 + 1 && c2 == c1 + 1 && c3 == c2 + 1 && c4 == c3 + 1) {
            return true;
        }

        // 4. Lộc phát / Phát lộc kép (VD: 686.88, 868.68, 688.68)
        if (digits.endsWith("68") || digits.endsWith("86") || digits.endsWith("79") || digits.endsWith("39")) {
            if (digits.equals("686.88") || digits.equals("868.68") || digits.equals("688.88")
                    || digits.equals("888.68")) {
                return true;
            }
        }

        return false;
    }

    /**
     * FR-09: Sinh kho biển số tự động theo dải (Batch Plate Generation)
     * Sử dụng PreparedStatement.addBatch() và executeBatch()
     * 
     * @param districtId   Quận/Huyện được chọn
     * @param startNumber  Số bắt đầu (VD: 10000)
     * @param endNumber    Số kết thúc (VD: 10199)
     * @param blockSpecial Tự động khóa biển đẹp sang BLOCKED
     * @return Số lượng biển số chèn thành công
     */
    public int batchGeneratePlates(int districtId, int startNumber, int endNumber, boolean blockSpecial)
            throws SQLException {
        if (connection == null) {
            throw new SQLException("Không có kết nối CSDL!");
        }

        District district = getDistrictById(districtId);
        if (district == null) {
            throw new SQLException("Quận/Huyện ID #" + districtId + " không tồn tại!");
        }

        String platePrefix = district.getPlatePrefix(); // VD: "29-P1"

        String checkSql = "SELECT COUNT(*) FROM dbo.LICENSE_PLATES WHERE fullPlate = ?";
        String insertSql = "INSERT INTO dbo.LICENSE_PLATES (districtId, plateNumber, fullPlate, status) VALUES (?, ?, ?, ?)";

        int countSuccess = 0;
        boolean originalAutoCommit = connection.getAutoCommit();

        try {
            connection.setAutoCommit(false);

            try (PreparedStatement psCheck = connection.prepareStatement(checkSql);
                    PreparedStatement psInsert = connection.prepareStatement(insertSql)) {

                for (int num = startNumber; num <= endNumber; num++) {
                    String digits = String.format("%05d", num);
                    String plateNumber = digits.substring(0, 3) + "." + digits.substring(3); // VD: "100.00"
                    String fullPlate = platePrefix + " " + plateNumber; // VD: "29-P1 100.00"

                    // Kiểm tra xem biển đã tồn tại chưa
                    psCheck.setString(1, fullPlate);
                    boolean exists = false;
                    try (ResultSet rs = psCheck.executeQuery()) {
                        if (rs.next() && rs.getInt(1) > 0) {
                            exists = true;
                        }
                    }

                    if (!exists) {
                        String initStatus = LicensePlate.STATUS_AVAILABLE;
                        if (blockSpecial && isSpecialPlate(plateNumber)) {
                            initStatus = LicensePlate.STATUS_BLOCKED; // Khóa biển đẹp để đấu giá
                        }

                        psInsert.setInt(1, districtId);
                        psInsert.setString(2, plateNumber);
                        psInsert.setString(3, fullPlate);
                        psInsert.setString(4, initStatus);
                        psInsert.addBatch();
                        countSuccess++;
                    }
                }

                if (countSuccess > 0) {
                    psInsert.executeBatch();
                }
            }

            connection.commit();
            return countSuccess;

        } catch (SQLException ex) {
            connection.rollback();
            throw ex;
        } finally {
            connection.setAutoCommit(originalAutoCommit);
        }
    }

    /**
     * FR-10: Khóa / Mở khóa biển số (Block / Unblock Plate)
     * Nghiêm cấm thay đổi trạng thái nếu biển số đã có status = 'ASSIGNED' (BR-04)
     * 
     * @param plateId      Mã biển số
     * @param targetStatus Trạng thái đích ('AVAILABLE' hoặc 'BLOCKED')
     * @return true nếu thành công
     */
    public boolean updatePlateStatus(int plateId, String targetStatus) throws Exception {
        if (connection == null) {
            throw new Exception("Không có kết nối CSDL!");
        }

        // Kiểm tra trạng thái hiện tại
        String checkSql = "SELECT status, fullPlate FROM dbo.LICENSE_PLATES WHERE plateId = ?";
        try (PreparedStatement psCheck = connection.prepareStatement(checkSql)) {
            psCheck.setInt(1, plateId);
            try (ResultSet rs = psCheck.executeQuery()) {
                if (rs.next()) {
                    String currentStatus = rs.getString("status");
                    String fullPlate = rs.getString("fullPlate");

                    // Ràng buộc BR-04 & FR-10: Tuyệt đối không thay đổi biển đã cấp
                    if (LicensePlate.STATUS_ASSIGNED.equalsIgnoreCase(currentStatus)) {
                        throw new Exception("Biển số [" + fullPlate
                                + "] đã được cấp định danh cho công dân (ASSIGNED). Hệ thống nghiêm cấm thay đổi trạng thái!");
                    }
                } else {
                    throw new Exception("Không tìm thấy biển số ID #" + plateId);
                }
            }
        }

        String sql = "UPDATE dbo.LICENSE_PLATES SET status = ? WHERE plateId = ? AND status <> N'ASSIGNED'";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, targetStatus.trim().toUpperCase());
            ps.setInt(2, plateId);
            int rows = ps.executeUpdate();
            return rows > 0;
        }
    }
}
