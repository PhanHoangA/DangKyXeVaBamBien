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
}
