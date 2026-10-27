package DAO;

import DAL.DBContext;
import Models.Vehicle;
import Models.VehicleBrand;
import Models.VehicleType;
import java.math.BigDecimal;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class VehicleDAO extends DBContext {

    public VehicleDAO() throws ClassNotFoundException {
        super();
    }

    /**
     * Lấy danh sách tất cả các hãng sản xuất xe máy
     */
    public List<VehicleBrand> getAllBrands() {
        List<VehicleBrand> list = new ArrayList<>();
        if (connection == null) {
            return list;
        }

        String sql = "SELECT brandId, brandName FROM dbo.VEHICLE_BRANDS ORDER BY brandName ASC";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new VehicleBrand(rs.getInt("brandId"), rs.getString("brandName")));
            }
        } catch (SQLException ex) {
            Logger.getLogger(VehicleDAO.class.getName()).log(Level.SEVERE, "Lỗi lấy danh mục hãng xe", ex);
        }
        return list;
    }

    /**
     * Lấy danh sách tất cả các phân loại xe máy
     */
    public List<VehicleType> getAllTypes() {
        List<VehicleType> list = new ArrayList<>();
        if (connection == null) {
            return list;
        }

        String sql = "SELECT typeId, typeName, capacityRange FROM dbo.VEHICLE_TYPES ORDER BY typeId ASC";
        try (PreparedStatement ps = connection.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(new VehicleType(
                    rs.getInt("typeId"), 
                    rs.getString("typeName"), 
                    rs.getString("capacityRange")
                ));
            }
        } catch (SQLException ex) {
            Logger.getLogger(VehicleDAO.class.getName()).log(Level.SEVERE, "Lỗi lấy danh mục loại xe", ex);
        }
        return list;
    }

    /**
     * Kiểm tra số máy (engineNumber) đã tồn tại hay chưa (BR-02: Duy nhất toàn hệ thống)
     */
    public boolean isEngineNumberExists(String engineNumber) {
        if (connection == null || engineNumber == null || engineNumber.trim().isEmpty()) {
            return false;
        }
        String sql = "SELECT COUNT(*) FROM dbo.VEHICLES WHERE UPPER(LTRIM(RTRIM(engineNumber))) = UPPER(?)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, engineNumber.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(VehicleDAO.class.getName()).log(Level.SEVERE, "Lỗi kiểm tra trùng số máy", ex);
        }
        return false;
    }

    /**
     * Kiểm tra số khung (chassisNumber) đã tồn tại hay chưa (BR-02: Duy nhất toàn hệ thống)
     */
    public boolean isChassisNumberExists(String chassisNumber) {
        if (connection == null || chassisNumber == null || chassisNumber.trim().isEmpty()) {
            return false;
        }
        String sql = "SELECT COUNT(*) FROM dbo.VEHICLES WHERE UPPER(LTRIM(RTRIM(chassisNumber))) = UPPER(?)";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, chassisNumber.trim());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(VehicleDAO.class.getName()).log(Level.SEVERE, "Lỗi kiểm tra trùng số khung", ex);
        }
        return false;
    }

    /**
     * FR-03: Khai báo phương tiện và nộp hồ sơ đăng ký mới trong 1 JDBC Transaction
     * 1. INSERT vào bảng VEHICLES (lấy vehicleId tự sinh)
     * 2. INSERT vào bảng REGISTRATIONS (status = 'PENDING', submittedAt = GETDATE())
     * @param vehicle Đối tượng thông tin phương tiện
     * @param districtId Quận/Huyện thường trú của chủ xe (BR-01)
     * @return Mã hồ sơ registrationId nếu thành công, hoặc -1 nếu thất bại
     * @throws SQLException Nếu có lỗi cơ sở dữ liệu
     */
    public int registerNewVehicle(Vehicle vehicle, int districtId) throws SQLException {
        if (connection == null) {
            throw new SQLException("Kết nối cơ sở dữ liệu không khả dụng!");
        }

        int registrationId = -1;
        boolean originalAutoCommit = connection.getAutoCommit();

        String insertVehicleSql = "INSERT INTO dbo.VEHICLES (" +
                "ownerId, brandId, typeId, modelName, engineNumber, chassisNumber, " +
                "color, engineCapacity, vehicleValue, taxReceiptNumber, invoiceNumber, createAt) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, GETDATE())";

        String insertRegSql = "INSERT INTO dbo.REGISTRATIONS (" +
                "vehicleId, ownerId, districtId, status, submittedAt) " +
                "VALUES (?, ?, ?, 'PENDING', GETDATE())";

        try {
            // Bắt đầu Transaction
            connection.setAutoCommit(false);

            // 1. Chèn thông tin xe vào VEHICLES
            int generatedVehicleId = -1;
            try (PreparedStatement psVehicle = connection.prepareStatement(insertVehicleSql, Statement.RETURN_GENERATED_KEYS)) {
                psVehicle.setInt(1, vehicle.getOwnerId());
                psVehicle.setInt(2, vehicle.getBrandId());
                psVehicle.setInt(3, vehicle.getTypeId());
                psVehicle.setString(4, vehicle.getModelName().trim());
                psVehicle.setString(5, vehicle.getEngineNumber().trim().toUpperCase());
                psVehicle.setString(6, vehicle.getChassisNumber().trim().toUpperCase());
                psVehicle.setString(7, vehicle.getColor().trim());
                psVehicle.setInt(8, vehicle.getEngineCapacity());
                psVehicle.setBigDecimal(9, vehicle.getVehicleValue());
                psVehicle.setString(10, vehicle.getTaxReceiptNumber().trim().toUpperCase());
                psVehicle.setString(11, vehicle.getInvoiceNumber().trim().toUpperCase());

                int affected = psVehicle.executeUpdate();
                if (affected == 0) {
                    connection.rollback();
                    throw new SQLException("Chèn thông tin xe vào hệ thống thất bại!");
                }

                try (ResultSet rsKeys = psVehicle.getGeneratedKeys()) {
                    if (rsKeys.next()) {
                        generatedVehicleId = rsKeys.getInt(1);
                    } else {
                        connection.rollback();
                        throw new SQLException("Không lấy được mã định danh xe vừa tạo!");
                    }
                }
            }

            // 2. Chèn hồ sơ đăng ký vào REGISTRATIONS
            try (PreparedStatement psReg = connection.prepareStatement(insertRegSql, Statement.RETURN_GENERATED_KEYS)) {
                psReg.setInt(1, generatedVehicleId);
                psReg.setInt(2, vehicle.getOwnerId());
                psReg.setInt(3, districtId);

                int regAffected = psReg.executeUpdate();
                if (regAffected == 0) {
                    connection.rollback();
                    throw new SQLException("Khởi tạo hồ sơ đăng ký thất bại!");
                }

                try (ResultSet rsRegKeys = psReg.getGeneratedKeys()) {
                    if (rsRegKeys.next()) {
                        registrationId = rsRegKeys.getInt(1);
                    } else {
                        connection.rollback();
                        throw new SQLException("Không lấy được mã hồ sơ đăng ký!");
                    }
                }
            }

            // Commit Transaction thành công
            connection.commit();
            return registrationId;

        } catch (SQLException ex) {
            try {
                connection.rollback();
            } catch (SQLException rEx) {
                Logger.getLogger(VehicleDAO.class.getName()).log(Level.SEVERE, "Lỗi Rollback Transaction", rEx);
            }
            throw ex;
        } finally {
            try {
                connection.setAutoCommit(originalAutoCommit);
            } catch (SQLException acEx) {
                Logger.getLogger(VehicleDAO.class.getName()).log(Level.WARNING, "Lỗi khôi phục autoCommit", acEx);
            }
        }
    }

    /**
     * FR-04: Chỉnh sửa và nộp lại hồ sơ bị từ chối (Resubmit Rejected Registration)
     * Thực hiện UPDATE trực tiếp trên xe cũ và cập nhật hồ sơ về PENDING trong 1 JDBC Transaction,
     * không tạo bản ghi mới để không vi phạm ràng buộc UNIQUE của số khung/số máy.
     * 
     * @param vehicle Đối tượng thông tin phương tiện đã chỉnh sửa
     * @param registrationId Mã hồ sơ đăng ký bị từ chối
     * @param ownerId Mã chủ phương tiện (chống can thiệp chéo)
     * @return true nếu cập nhật thành công
     * @throws SQLException Nếu có lỗi CSDL hoặc vi phạm nghiệp vụ
     */
    public boolean resubmitRejectedRegistration(Vehicle vehicle, int registrationId, int ownerId) throws SQLException {
        if (connection == null) {
            throw new SQLException("Kết nối cơ sở dữ liệu không khả dụng!");
        }

        // 1. Kiểm tra hồ sơ có tồn tại, thuộc quyền sở hữu của ownerId và đang ở trạng thái REJECTED không
        String checkRegSql = "SELECT vehicleId, status FROM dbo.REGISTRATIONS WHERE registrationId = ? AND ownerId = ?";
        int existingVehicleId = -1;
        try (PreparedStatement psCheck = connection.prepareStatement(checkRegSql)) {
            psCheck.setInt(1, registrationId);
            psCheck.setInt(2, ownerId);
            try (ResultSet rs = psCheck.executeQuery()) {
                if (rs.next()) {
                    String status = rs.getString("status");
                    if (!"REJECTED".equalsIgnoreCase(status)) {
                        throw new SQLException("Chỉ hồ sơ bị Từ chối mới được phép chỉnh sửa và nộp lại!");
                    }
                    existingVehicleId = rs.getInt("vehicleId");
                } else {
                    throw new SQLException("Hồ sơ #" + registrationId + " không tồn tại hoặc không thuộc quyền sở hữu của bạn!");
                }
            }
        }

        // 2. Nếu số khung hoặc số máy thay đổi, kiểm tra xem có bị trùng với xe KHÁC (xe khác existingVehicleId) không
        String checkOtherChassisSql = "SELECT COUNT(*) FROM dbo.VEHICLES WHERE UPPER(LTRIM(RTRIM(chassisNumber))) = UPPER(?) AND vehicleId <> ?";
        try (PreparedStatement ps = connection.prepareStatement(checkOtherChassisSql)) {
            ps.setString(1, vehicle.getChassisNumber().trim());
            ps.setInt(2, existingVehicleId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next() && rs.getInt(1) > 0) {
                    throw new SQLException("Số khung '" + vehicle.getChassisNumber().trim() + "' đã được sử dụng bởi phương tiện khác!");
                }
            }
        }

        String checkOtherEngineSql = "SELECT COUNT(*) FROM dbo.VEHICLES WHERE UPPER(LTRIM(RTRIM(engineNumber))) = UPPER(?) AND vehicleId <> ?";
        try (PreparedStatement ps = connection.prepareStatement(checkOtherEngineSql)) {
            ps.setString(1, vehicle.getEngineNumber().trim());
            ps.setInt(2, existingVehicleId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next() && rs.getInt(1) > 0) {
                    throw new SQLException("Số máy '" + vehicle.getEngineNumber().trim() + "' đã được sử dụng bởi phương tiện khác!");
                }
            }
        }

        boolean originalAutoCommit = connection.getAutoCommit();
        String updateVehicleSql = "UPDATE dbo.VEHICLES SET " +
                "brandId = ?, typeId = ?, modelName = ?, engineNumber = ?, chassisNumber = ?, " +
                "color = ?, engineCapacity = ?, vehicleValue = ?, taxReceiptNumber = ?, invoiceNumber = ? " +
                "WHERE vehicleId = ?";

        String updateRegSql = "UPDATE dbo.REGISTRATIONS SET " +
                "status = 'PENDING', rejectionReason = NULL, submittedAt = GETDATE() " +
                "WHERE registrationId = ? AND ownerId = ?";

        try {
            connection.setAutoCommit(false);

            // Cập nhật lại thông tin xe hiện có
            try (PreparedStatement psV = connection.prepareStatement(updateVehicleSql)) {
                psV.setInt(1, vehicle.getBrandId());
                psV.setInt(2, vehicle.getTypeId());
                psV.setString(3, vehicle.getModelName().trim());
                psV.setString(4, vehicle.getEngineNumber().trim().toUpperCase());
                psV.setString(5, vehicle.getChassisNumber().trim().toUpperCase());
                psV.setString(6, vehicle.getColor().trim());
                psV.setInt(7, vehicle.getEngineCapacity());
                psV.setBigDecimal(8, vehicle.getVehicleValue());
                psV.setString(9, vehicle.getTaxReceiptNumber().trim().toUpperCase());
                psV.setString(10, vehicle.getInvoiceNumber().trim().toUpperCase());
                psV.setInt(11, existingVehicleId);

                int vAffected = psV.executeUpdate();
                if (vAffected == 0) {
                    connection.rollback();
                    throw new SQLException("Không thể cập nhật thông tin phương tiện #" + existingVehicleId);
                }
            }

            // Đưa hồ sơ về trạng thái PENDING và xóa lý do từ chối
            try (PreparedStatement psR = connection.prepareStatement(updateRegSql)) {
                psR.setInt(1, registrationId);
                psR.setInt(2, ownerId);

                int rAffected = psR.executeUpdate();
                if (rAffected == 0) {
                    connection.rollback();
                    throw new SQLException("Không thể đặt lại trạng thái hồ sơ #" + registrationId);
                }
            }

            connection.commit();
            return true;

        } catch (SQLException ex) {
            try {
                connection.rollback();
            } catch (SQLException rEx) {
                Logger.getLogger(VehicleDAO.class.getName()).log(Level.SEVERE, "Lỗi Rollback Resubmit", rEx);
            }
            throw ex;
        } finally {
            try {
                connection.setAutoCommit(originalAutoCommit);
            } catch (SQLException acEx) {
                Logger.getLogger(VehicleDAO.class.getName()).log(Level.WARNING, "Lỗi khôi phục autoCommit", acEx);
            }
        }
    }
}
