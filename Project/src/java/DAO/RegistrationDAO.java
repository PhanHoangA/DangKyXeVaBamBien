package DAO;

import DAL.DBContext;
import Models.District;
import Models.LicensePlate;
import Models.Registration;
import Models.User;
import Models.Vehicle;
import Models.VehicleBrand;
import Models.VehicleType;
import java.math.BigDecimal;
import java.security.SecureRandom;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

public class RegistrationDAO extends DBContext {

    private static final SecureRandom RANDOM = new SecureRandom();

    public RegistrationDAO() throws ClassNotFoundException {
        super();
    }

    /**
     * Tra cứu và lọc danh sách hồ sơ đăng ký theo địa bàn của Cán bộ (FR-06 & BR-01)
     * @param districtId Mã Quận/Huyện của cán bộ phụ trách
     * @param status Bộ lọc trạng thái (PENDING, APPROVED, DRAWN, REJECTED hoặc rỗng/all)
     * @param keyword Từ khóa tìm kiếm (CCCD, Số khung, Số máy, Họ tên chủ xe)
     * @return Danh sách hồ sơ kèm đầy đủ thông tin xe, chủ xe, biển số
     */
    public List<Registration> getOfficerRegistrations(int districtId, String status, String keyword) {
        List<Registration> list = new ArrayList<>();
        if (connection == null) {
            return list;
        }

        StringBuilder sql = new StringBuilder(
            "SELECT r.registrationId, r.vehicleId, r.ownerId, r.districtId, r.plateId, r.officerId, " +
            "       r.drawCode, r.feeAmount, r.status, r.rejectionReason, r.submittedAt, r.approvedAt, r.drawnAt, " +
            "       v.modelName, v.engineNumber, v.chassisNumber, v.color, v.engineCapacity, v.vehicleValue, " +
            "       v.taxReceiptNumber, v.invoiceNumber, v.createAt AS vehicleCreateAt, " +
            "       b.brandId, b.brandName, " +
            "       t.typeId, t.typeName, t.capacityRange, " +
            "       u.fullName AS ownerName, u.identityCard AS ownerIdentity, u.phone AS ownerPhone, " +
            "       u.email AS ownerEmail, u.address AS ownerAddress, " +
            "       d.provinceName, d.districtName, d.platePrefix, " +
            "       lp.plateNumber, lp.fullPlate, lp.status AS plateStatus, lp.assignedAt, " +
            "       o.fullName AS officerName " +
            "FROM dbo.REGISTRATIONS r " +
            "JOIN dbo.VEHICLES v ON r.vehicleId = v.vehicleId " +
            "JOIN dbo.USERS u ON r.ownerId = u.userId " +
            "JOIN dbo.DISTRICTS d ON r.districtId = d.districtId " +
            "JOIN dbo.VEHICLE_BRANDS b ON v.brandId = b.brandId " +
            "JOIN dbo.VEHICLE_TYPES t ON v.typeId = t.typeId " +
            "LEFT JOIN dbo.LICENSE_PLATES lp ON r.plateId = lp.plateId " +
            "LEFT JOIN dbo.USERS o ON r.officerId = o.userId " +
            "WHERE r.districtId = ? "
        );

        List<Object> params = new ArrayList<>();
        params.add(districtId);

        if (status != null && !status.trim().isEmpty() && !status.equalsIgnoreCase("ALL")) {
            sql.append("AND r.status = ? ");
            params.add(status.trim().toUpperCase());
        }

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND (u.identityCard LIKE ? OR v.chassisNumber LIKE ? OR v.engineNumber LIKE ? OR u.fullName LIKE ?) ");
            String searchPattern = "%" + keyword.trim() + "%";
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
            params.add(searchPattern);
        }

        // Ưu tiên hiển thị PENDING lên trước, sau đó sắp xếp theo thời gian nộp mới nhất
        sql.append("ORDER BY CASE WHEN r.status = 'PENDING' THEN 0 ELSE 1 END, r.submittedAt DESC");

        try (PreparedStatement ps = connection.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Registration reg = new Registration();
                    reg.setRegistrationId(rs.getInt("registrationId"));
                    reg.setVehicleId(rs.getInt("vehicleId"));
                    reg.setOwnerId(rs.getInt("ownerId"));
                    reg.setDistrictId(rs.getInt("districtId"));
                    
                    int pId = rs.getInt("plateId");
                    reg.setPlateId(rs.wasNull() ? null : pId);

                    int offId = rs.getInt("officerId");
                    reg.setOfficerId(rs.wasNull() ? null : offId);

                    reg.setDrawCode(rs.getString("drawCode"));
                    reg.setFeeAmount(rs.getBigDecimal("feeAmount"));
                    reg.setStatus(rs.getString("status"));
                    reg.setRejectionReason(rs.getString("rejectionReason"));
                    reg.setSubmittedAt(rs.getTimestamp("submittedAt"));
                    reg.setApprovedAt(rs.getTimestamp("approvedAt"));
                    reg.setDrawnAt(rs.getTimestamp("drawnAt"));

                    // Gán Chủ xe (User)
                    User owner = new User();
                    owner.setUserId(reg.getOwnerId());
                    owner.setFullName(rs.getString("ownerName"));
                    owner.setIdentityCard(rs.getString("ownerIdentity"));
                    owner.setPhone(rs.getString("ownerPhone"));
                    owner.setEmail(rs.getString("ownerEmail"));
                    owner.setAddress(rs.getString("ownerAddress"));
                    reg.setOwner(owner);

                    // Gán Xe (Vehicle)
                    Vehicle v = new Vehicle();
                    v.setVehicleId(reg.getVehicleId());
                    v.setOwnerId(reg.getOwnerId());
                    v.setModelName(rs.getString("modelName"));
                    v.setEngineNumber(rs.getString("engineNumber"));
                    v.setChassisNumber(rs.getString("chassisNumber"));
                    v.setColor(rs.getString("color"));
                    v.setEngineCapacity(rs.getInt("engineCapacity"));
                    v.setVehicleValue(rs.getBigDecimal("vehicleValue"));
                    v.setTaxReceiptNumber(rs.getString("taxReceiptNumber"));
                    v.setInvoiceNumber(rs.getString("invoiceNumber"));
                    v.setCreateAt(rs.getTimestamp("vehicleCreateAt"));

                    // Gán Hãng và Loại xe
                    VehicleBrand brand = new VehicleBrand(rs.getInt("brandId"), rs.getString("brandName"));
                    v.setBrand(brand);
                    VehicleType type = new VehicleType(rs.getInt("typeId"), rs.getString("typeName"), rs.getString("capacityRange"));
                    v.setType(type);
                    reg.setVehicle(v);

                    // Gán District
                    District dist = new District(reg.getDistrictId(), rs.getString("provinceName"), 
                                                 rs.getString("districtName"), rs.getString("platePrefix"));
                    reg.setDistrict(dist);

                    // Gán Biển số (nếu đã có)
                    if (reg.getPlateId() != null) {
                        LicensePlate plate = new LicensePlate();
                        plate.setPlateId(reg.getPlateId());
                        plate.setDistrictId(reg.getDistrictId());
                        plate.setPlateNumber(rs.getString("plateNumber"));
                        plate.setFullPlate(rs.getString("fullPlate"));
                        plate.setStatus(rs.getString("plateStatus"));
                        plate.setAssignedAt(rs.getTimestamp("assignedAt"));
                        reg.setPlate(plate);
                    }

                    // Gán Cán bộ duyệt
                    if (reg.getOfficerId() != null) {
                        User officer = new User();
                        officer.setUserId(reg.getOfficerId());
                        officer.setFullName(rs.getString("officerName"));
                        reg.setOfficer(officer);
                    }

                    list.add(reg);
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(RegistrationDAO.class.getName()).log(Level.SEVERE, "Lỗi lấy danh sách hồ sơ cán bộ", ex);
        }
        return list;
    }

    /**
     * Lấy thông tin 1 hồ sơ cụ thể
     */
    public Registration getRegistrationById(int registrationId) {
        String sql = "SELECT registrationId, vehicleId, ownerId, districtId, plateId, officerId, " +
                     "       drawCode, feeAmount, status, rejectionReason, submittedAt, approvedAt, drawnAt " +
                     "FROM dbo.REGISTRATIONS WHERE registrationId = ?";
        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, registrationId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Registration reg = new Registration();
                    reg.setRegistrationId(rs.getInt("registrationId"));
                    reg.setVehicleId(rs.getInt("vehicleId"));
                    reg.setOwnerId(rs.getInt("ownerId"));
                    reg.setDistrictId(rs.getInt("districtId"));

                    int pId = rs.getInt("plateId");
                    reg.setPlateId(rs.wasNull() ? null : pId);

                    int offId = rs.getInt("officerId");
                    reg.setOfficerId(rs.wasNull() ? null : offId);

                    reg.setDrawCode(rs.getString("drawCode"));
                    reg.setFeeAmount(rs.getBigDecimal("feeAmount"));
                    reg.setStatus(rs.getString("status"));
                    reg.setRejectionReason(rs.getString("rejectionReason"));
                    reg.setSubmittedAt(rs.getTimestamp("submittedAt"));
                    reg.setApprovedAt(rs.getTimestamp("approvedAt"));
                    reg.setDrawnAt(rs.getTimestamp("drawnAt"));
                    return reg;
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(RegistrationDAO.class.getName()).log(Level.SEVERE, "Lỗi tìm hồ sơ theo ID", ex);
        }
        return null;
    }

    /**
     * Lấy danh sách hồ sơ xe đã nộp của công dân (ROLE_USER)
     * @param ownerId userId của công dân
     * @return Danh sách hồ sơ đăng ký kèm thông tin xe, biển số
     */
    public List<Registration> getUserRegistrations(int ownerId) {
        List<Registration> list = new ArrayList<>();
        if (connection == null) {
            return list;
        }

        String sql = "SELECT r.registrationId, r.vehicleId, r.ownerId, r.districtId, r.plateId, r.officerId, " +
                     "       r.drawCode, r.feeAmount, r.status, r.rejectionReason, r.submittedAt, r.approvedAt, r.drawnAt, " +
                     "       v.modelName, v.engineNumber, v.chassisNumber, v.color, v.engineCapacity, v.vehicleValue, " +
                     "       v.taxReceiptNumber, v.invoiceNumber, v.createAt AS vehicleCreateAt, " +
                     "       b.brandId, b.brandName, " +
                     "       t.typeId, t.typeName, t.capacityRange, " +
                     "       u.fullName AS ownerName, u.identityCard AS ownerIdentity, u.phone AS ownerPhone, " +
                     "       u.email AS ownerEmail, u.address AS ownerAddress, " +
                     "       d.provinceName, d.districtName, d.platePrefix, " +
                     "       lp.plateNumber, lp.fullPlate, lp.status AS plateStatus, lp.assignedAt, " +
                     "       o.fullName AS officerName " +
                     "FROM dbo.REGISTRATIONS r " +
                     "JOIN dbo.VEHICLES v ON r.vehicleId = v.vehicleId " +
                     "JOIN dbo.USERS u ON r.ownerId = u.userId " +
                     "JOIN dbo.DISTRICTS d ON r.districtId = d.districtId " +
                     "JOIN dbo.VEHICLE_BRANDS b ON v.brandId = b.brandId " +
                     "JOIN dbo.VEHICLE_TYPES t ON v.typeId = t.typeId " +
                     "LEFT JOIN dbo.LICENSE_PLATES lp ON r.plateId = lp.plateId " +
                     "LEFT JOIN dbo.USERS o ON r.officerId = o.userId " +
                     "WHERE r.ownerId = ? " +
                     "ORDER BY r.submittedAt DESC";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, ownerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Registration reg = new Registration();
                    reg.setRegistrationId(rs.getInt("registrationId"));
                    reg.setVehicleId(rs.getInt("vehicleId"));
                    reg.setOwnerId(rs.getInt("ownerId"));
                    reg.setDistrictId(rs.getInt("districtId"));

                    int pId = rs.getInt("plateId");
                    reg.setPlateId(rs.wasNull() ? null : pId);

                    int offId = rs.getInt("officerId");
                    reg.setOfficerId(rs.wasNull() ? null : offId);

                    reg.setDrawCode(rs.getString("drawCode"));
                    reg.setFeeAmount(rs.getBigDecimal("feeAmount"));
                    reg.setStatus(rs.getString("status"));
                    reg.setRejectionReason(rs.getString("rejectionReason"));
                    reg.setSubmittedAt(rs.getTimestamp("submittedAt"));
                    reg.setApprovedAt(rs.getTimestamp("approvedAt"));
                    reg.setDrawnAt(rs.getTimestamp("drawnAt"));

                    // Gán Chủ xe (User)
                    User owner = new User();
                    owner.setUserId(reg.getOwnerId());
                    owner.setFullName(rs.getString("ownerName"));
                    owner.setIdentityCard(rs.getString("ownerIdentity"));
                    owner.setPhone(rs.getString("ownerPhone"));
                    owner.setEmail(rs.getString("ownerEmail"));
                    owner.setAddress(rs.getString("ownerAddress"));
                    reg.setOwner(owner);

                    // Gán Xe (Vehicle)
                    Vehicle v = new Vehicle();
                    v.setVehicleId(reg.getVehicleId());
                    v.setOwnerId(reg.getOwnerId());
                    v.setModelName(rs.getString("modelName"));
                    v.setEngineNumber(rs.getString("engineNumber"));
                    v.setChassisNumber(rs.getString("chassisNumber"));
                    v.setColor(rs.getString("color"));
                    v.setEngineCapacity(rs.getInt("engineCapacity"));
                    v.setVehicleValue(rs.getBigDecimal("vehicleValue"));
                    v.setTaxReceiptNumber(rs.getString("taxReceiptNumber"));
                    v.setInvoiceNumber(rs.getString("invoiceNumber"));
                    v.setCreateAt(rs.getTimestamp("vehicleCreateAt"));

                    VehicleBrand brand = new VehicleBrand(rs.getInt("brandId"), rs.getString("brandName"));
                    v.setBrand(brand);
                    VehicleType type = new VehicleType(rs.getInt("typeId"), rs.getString("typeName"), rs.getString("capacityRange"));
                    v.setType(type);
                    reg.setVehicle(v);

                    District dist = new District(reg.getDistrictId(), rs.getString("provinceName"), rs.getString("districtName"), rs.getString("platePrefix"));
                    reg.setDistrict(dist);

                    if (reg.getPlateId() != null) {
                        LicensePlate plate = new LicensePlate();
                        plate.setPlateId(reg.getPlateId());
                        plate.setPlateNumber(rs.getString("plateNumber"));
                        plate.setFullPlate(rs.getString("fullPlate"));
                        plate.setStatus(rs.getString("plateStatus"));
                        plate.setAssignedAt(rs.getTimestamp("assignedAt"));
                        reg.setPlate(plate);
                    }

                    if (reg.getOfficerId() != null) {
                        User officer = new User();
                        officer.setUserId(reg.getOfficerId());
                        officer.setFullName(rs.getString("officerName"));
                        reg.setOfficer(officer);
                    }

                    list.add(reg);
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(RegistrationDAO.class.getName()).log(Level.SEVERE, "Lỗi lấy danh sách hồ sơ công dân", ex);
        }
        return list;
    }

    /**
     * Tự động sinh mã bấm biển ngẫu nhiên duy nhất (DRAW-XXXXXX - FR-07)
     */
    public String generateUniqueDrawCode() {
        String code;
        boolean exists;
        int maxAttempts = 20;
        int attempts = 0;

        do {
            int randomNum = 100000 + RANDOM.nextInt(900000);
            code = "DRAW-" + randomNum;
            attempts++;

            String checkSql = "SELECT COUNT(*) FROM dbo.REGISTRATIONS WHERE drawCode = ?";
            exists = false;
            try (PreparedStatement ps = connection.prepareStatement(checkSql)) {
                ps.setString(1, code);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next() && rs.getInt(1) > 0) {
                        exists = true;
                    }
                }
            } catch (SQLException ex) {
                Logger.getLogger(RegistrationDAO.class.getName()).log(Level.SEVERE, "Lỗi kiểm tra drawCode", ex);
            }
        } while (exists && attempts < maxAttempts);

        return code;
    }

    /**
     * Cán bộ CSGT phê duyệt hồ sơ và cấp mã bấm biển (FR-07)
     * Chỉ áp dụng cho hồ sơ đang PENDING (BR-03)
     */
    public boolean approveRegistration(int registrationId, int officerId, BigDecimal feeAmount, String drawCode) {
        String sql = "UPDATE dbo.REGISTRATIONS " +
                     "SET status = 'APPROVED', " +
                     "    officerId = ?, " +
                     "    feeAmount = ?, " +
                     "    drawCode = ?, " +
                     "    approvedAt = GETDATE(), " +
                     "    rejectionReason = NULL " +
                     "WHERE registrationId = ? AND status = 'PENDING'";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, officerId);
            ps.setBigDecimal(2, feeAmount);
            ps.setString(3, drawCode);
            ps.setInt(4, registrationId);
            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (SQLException ex) {
            Logger.getLogger(RegistrationDAO.class.getName()).log(Level.SEVERE, "Lỗi phê duyệt hồ sơ", ex);
        }
        return false;
    }

    /**
     * Cán bộ CSGT từ chối hồ sơ kèm lý do sai lệch (FR-08)
     * Chỉ áp dụng cho hồ sơ đang PENDING (BR-03)
     */
    public boolean rejectRegistration(int registrationId, int officerId, String rejectionReason) {
        String sql = "UPDATE dbo.REGISTRATIONS " +
                     "SET status = 'REJECTED', " +
                     "    officerId = ?, " +
                     "    rejectionReason = ?, " +
                     "    approvedAt = NULL, " +
                     "    drawCode = NULL " +
                     "WHERE registrationId = ? AND status = 'PENDING'";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, officerId);
            ps.setString(2, rejectionReason != null ? rejectionReason.trim() : "Hồ sơ không hợp lệ");
            ps.setInt(3, registrationId);
            int rows = ps.executeUpdate();
            return rows > 0;
        } catch (SQLException ex) {
            Logger.getLogger(RegistrationDAO.class.getName()).log(Level.SEVERE, "Lỗi từ chối hồ sơ", ex);
        }
        return false;
    }

    /**
     * Thống kê số lượng hồ sơ theo trạng thái cho địa bàn của cán bộ
     */
    public Map<String, Integer> getDistrictStats(int districtId) {
        Map<String, Integer> stats = new HashMap<>();
        stats.put("ALL", 0);
        stats.put("PENDING", 0);
        stats.put("APPROVED", 0);
        stats.put("DRAWN", 0);
        stats.put("REJECTED", 0);

        String sql = "SELECT status, COUNT(*) AS total " +
                     "FROM dbo.REGISTRATIONS " +
                     "WHERE districtId = ? " +
                     "GROUP BY status";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, districtId);
            try (ResultSet rs = ps.executeQuery()) {
                int totalAll = 0;
                while (rs.next()) {
                    String st = rs.getString("status");
                    int count = rs.getInt("total");
                    stats.put(st.toUpperCase(), count);
                    totalAll += count;
                }
                stats.put("ALL", totalAll);
            }
        } catch (SQLException ex) {
            Logger.getLogger(RegistrationDAO.class.getName()).log(Level.SEVERE, "Lỗi lấy thống kê hồ sơ", ex);
        }
        return stats;
    }

    /**
     * Lấy danh sách hồ sơ xe của công dân đủ điều kiện bấm biển (status = 'APPROVED' và plateId IS NULL)
     */
    public List<Registration> getApprovedRegistrationsByUser(int ownerId) {
        List<Registration> list = new ArrayList<>();
        if (connection == null) {
            return list;
        }

        String sql = "SELECT r.registrationId, r.vehicleId, r.ownerId, r.districtId, r.drawCode, r.feeAmount, r.status, r.approvedAt, " +
                     "       v.modelName, v.engineNumber, v.chassisNumber, v.color, v.engineCapacity, " +
                     "       b.brandName, t.typeName, " +
                     "       d.provinceName, d.districtName, d.platePrefix " +
                     "FROM dbo.REGISTRATIONS r " +
                     "JOIN dbo.VEHICLES v ON r.vehicleId = v.vehicleId " +
                     "JOIN dbo.DISTRICTS d ON r.districtId = d.districtId " +
                     "JOIN dbo.VEHICLE_BRANDS b ON v.brandId = b.brandId " +
                     "JOIN dbo.VEHICLE_TYPES t ON v.typeId = t.typeId " +
                     "WHERE r.ownerId = ? AND r.status = 'APPROVED' AND r.plateId IS NULL " +
                     "ORDER BY r.approvedAt DESC";

        try (PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, ownerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Registration reg = new Registration();
                    reg.setRegistrationId(rs.getInt("registrationId"));
                    reg.setVehicleId(rs.getInt("vehicleId"));
                    reg.setOwnerId(rs.getInt("ownerId"));
                    reg.setDistrictId(rs.getInt("districtId"));
                    reg.setDrawCode(rs.getString("drawCode"));
                    reg.setFeeAmount(rs.getBigDecimal("feeAmount"));
                    reg.setStatus(rs.getString("status"));
                    reg.setApprovedAt(rs.getTimestamp("approvedAt"));

                    Vehicle v = new Vehicle();
                    v.setVehicleId(reg.getVehicleId());
                    v.setModelName(rs.getString("modelName"));
                    v.setEngineNumber(rs.getString("engineNumber"));
                    v.setChassisNumber(rs.getString("chassisNumber"));
                    v.setColor(rs.getString("color"));
                    v.setEngineCapacity(rs.getInt("engineCapacity"));

                    VehicleBrand brand = new VehicleBrand();
                    brand.setBrandName(rs.getString("brandName"));
                    v.setBrand(brand);

                    VehicleType type = new VehicleType();
                    type.setTypeName(rs.getString("typeName"));
                    v.setType(type);

                    reg.setVehicle(v);

                    District dist = new District();
                    dist.setDistrictId(reg.getDistrictId());
                    dist.setProvinceName(rs.getString("provinceName"));
                    dist.setDistrictName(rs.getString("districtName"));
                    dist.setPlatePrefix(rs.getString("platePrefix"));
                    reg.setDistrict(dist);

                    list.add(reg);
                }
            }
        } catch (SQLException ex) {
            Logger.getLogger(RegistrationDAO.class.getName()).log(Level.SEVERE, "Lỗi lấy danh sách hồ sơ APPROVED", ex);
        }
        return list;
    }

    /**
     * FR-05 & NFR-01: Bấm biển số ngẫu nhiên trực tuyến (Atomic Random Plate Draw)
     * Thực thi trong khối đồng bộ & JDBC Transaction với gợi ý khóa dòng SQL Server
     * @param registrationId Mã hồ sơ đăng ký
     * @param ownerId ID của chủ xe (công dân đang đăng nhập)
     * @param inputDrawCode Mã dự thưởng do người dùng nhập
     * @return Đối tượng LicensePlate vừa bấm được
     * @throws Exception Các ngoại lệ nghiệp vụ (Sai mã, hết biển, trạng thái không hợp lệ...)
     */
    public LicensePlate atomicDrawPlate(int registrationId, int ownerId, String inputDrawCode) throws Exception {
        if (connection == null) {
            throw new Exception("Không có kết nối đến cơ sở dữ liệu!");
        }

        if (inputDrawCode == null || inputDrawCode.trim().isEmpty()) {
            throw new Exception("Vui lòng nhập mã bấm biển số (Draw Code) do CSGT cấp!");
        }

        boolean originalAutoCommit = connection.getAutoCommit();
        LicensePlate assignedPlate = null;

        try {
            connection.setAutoCommit(false);

            // 1. Xác thực hồ sơ và mã bấm biển (BR-01, BR-03, FR-05)
            String verifySql = "SELECT r.registrationId, r.ownerId, r.districtId, r.status, r.plateId, r.drawCode, " +
                               "       d.provinceName, d.districtName, d.platePrefix " +
                               "FROM dbo.REGISTRATIONS r " +
                               "JOIN dbo.DISTRICTS d ON r.districtId = d.districtId " +
                               "WHERE r.registrationId = ?";

            int districtId = -1;
            String dbDrawCode = null;
            String status = null;
            Integer plateId = null;
            int regOwnerId = -1;
            String platePrefix = "";
            String districtName = "";

            try (PreparedStatement ps = connection.prepareStatement(verifySql)) {
                ps.setInt(1, registrationId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        regOwnerId = rs.getInt("ownerId");
                        districtId = rs.getInt("districtId");
                        status = rs.getString("status");
                        int p = rs.getInt("plateId");
                        plateId = rs.wasNull() ? null : p;
                        dbDrawCode = rs.getString("drawCode");
                        platePrefix = rs.getString("platePrefix");
                        districtName = rs.getString("districtName");
                    } else {
                        connection.rollback();
                        throw new Exception("Không tìm thấy hồ sơ đăng ký #" + registrationId);
                    }
                }
            }

            // Kiểm tra quyền sở hữu hồ sơ
            if (regOwnerId != ownerId) {
                connection.rollback();
                throw new Exception("Hồ sơ này không thuộc quyền sở hữu của bạn!");
            }

            // Kiểm tra trạng thái hồ sơ (BR-03 & BR-04)
            if ("DRAWN".equalsIgnoreCase(status) || plateId != null) {
                connection.rollback();
                throw new Exception("Hồ sơ này đã được bấm biển số thành công từ trước (BR-04: Dữ liệu bất biến)!");
            }

            if (!"APPROVED".equalsIgnoreCase(status)) {
                connection.rollback();
                throw new Exception("Hồ sơ chưa được Cán bộ CSGT phê duyệt (Trạng thái hiện tại: " + status + ")!");
            }

            // Kiểm tra mã drawCode (FR-05)
            if (dbDrawCode == null || !dbDrawCode.trim().equalsIgnoreCase(inputDrawCode.trim())) {
                connection.rollback();
                throw new Exception("Mã bấm biển số (Draw Code) không chính xác! Vui lòng kiểm tra lại mã đã được cấp.");
            }

            // 2. Truy vấn chọn ngẫu nhiên 01 biển số khả dụng thuộc đúng Quận kèm khóa dòng chống tranh chấp (FR-05)
            String selectPlateSql = "SELECT TOP 1 plateId, plateNumber, fullPlate " +
                                    "FROM dbo.LICENSE_PLATES WITH (UPDLOCK, READPAST, ROWLOCK) " +
                                    "WHERE districtId = ? AND status = N'AVAILABLE' " +
                                    "ORDER BY NEWID()";

            int chosenPlateId = -1;
            String chosenPlateNumber = null;
            String chosenFullPlate = null;

            try (PreparedStatement psPlate = connection.prepareStatement(selectPlateSql)) {
                psPlate.setInt(1, districtId);
                try (ResultSet rsPlate = psPlate.executeQuery()) {
                    if (rsPlate.next()) {
                        chosenPlateId = rsPlate.getInt("plateId");
                        chosenPlateNumber = rsPlate.getString("plateNumber");
                        chosenFullPlate = rsPlate.getString("fullPlate");
                    } else {
                        connection.rollback();
                        throw new Exception("Kho biển số của " + districtName + " (" + platePrefix + ") hiện tại đã hết hoặc chưa được khởi tạo! Vui lòng liên hệ Đội CSGT địa bàn.");
                    }
                }
            }

            // 3. Cập nhật biển số sang ASSIGNED
            String updatePlateSql = "UPDATE dbo.LICENSE_PLATES " +
                                    "SET status = N'ASSIGNED', assignedAt = GETDATE() " +
                                    "WHERE plateId = ?";
            try (PreparedStatement psUpPlate = connection.prepareStatement(updatePlateSql)) {
                psUpPlate.setInt(1, chosenPlateId);
                int up1 = psUpPlate.executeUpdate();
                if (up1 == 0) {
                    connection.rollback();
                    throw new Exception("Không thể cấp biển số. Vui lòng thử lại!");
                }
            }

            // 4. Cập nhật hồ sơ sang DRAWN
            String updateRegSql = "UPDATE dbo.REGISTRATIONS " +
                                  "SET plateId = ?, status = N'DRAWN', drawnAt = GETDATE() " +
                                  "WHERE registrationId = ?";
            try (PreparedStatement psUpReg = connection.prepareStatement(updateRegSql)) {
                psUpReg.setInt(1, chosenPlateId);
                psUpReg.setInt(2, registrationId);
                int up2 = psUpReg.executeUpdate();
                if (up2 == 0) {
                    connection.rollback();
                    throw new Exception("Không thể cập nhật hồ sơ đăng ký. Vui lòng thử lại!");
                }
            }

            // 5. Commit Transaction
            connection.commit();

            assignedPlate = new LicensePlate();
            assignedPlate.setPlateId(chosenPlateId);
            assignedPlate.setDistrictId(districtId);
            assignedPlate.setPlateNumber(chosenPlateNumber);
            assignedPlate.setFullPlate(chosenFullPlate);
            assignedPlate.setStatus(LicensePlate.STATUS_ASSIGNED);

            return assignedPlate;

        } catch (Exception ex) {
            try {
                connection.rollback();
            } catch (SQLException rEx) {
                Logger.getLogger(RegistrationDAO.class.getName()).log(Level.SEVERE, "Lỗi rollback bấm biển", rEx);
            }
            throw ex;
        } finally {
            try {
                connection.setAutoCommit(originalAutoCommit);
            } catch (SQLException acEx) {
                Logger.getLogger(RegistrationDAO.class.getName()).log(Level.WARNING, "Lỗi khôi phục autoCommit", acEx);
            }
        }
    }
}
