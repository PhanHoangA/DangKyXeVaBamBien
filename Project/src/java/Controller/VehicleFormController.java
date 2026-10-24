package Controller;

import DAO.VehicleDAO;
import Models.User;
import Models.Vehicle;
import Models.VehicleBrand;
import Models.VehicleType;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.List;

@WebServlet(name = "VehicleFormController", urlPatterns = {"/user/vehicle-form", "/user/register-vehicle"})
public class VehicleFormController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        // 1. Kiểm tra xác thực đăng nhập
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // 2. Kiểm tra quyền (ROLE_USER hoặc ROLE_ADMIN)
        String roleName = (currentUser.getRole() != null) ? currentUser.getRole().getRoleName() : "";
        if (!"ROLE_USER".equalsIgnoreCase(roleName) && !"ROLE_ADMIN".equalsIgnoreCase(roleName)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Chức năng chỉ dành cho công dân khai báo đăng ký phương tiện!");
            return;
        }

        try {
            VehicleDAO vehicleDAO = new VehicleDAO();
            List<VehicleBrand> brands = vehicleDAO.getAllBrands();
            List<VehicleType> types = vehicleDAO.getAllTypes();

            request.setAttribute("brands", brands);
            request.setAttribute("types", types);

            // Forward tới giao diện khai báo xe chuẩn VNeID trong WEB-INF/views/user/
            request.getRequestDispatcher("/WEB-INF/views/user/vehicle-form.jsp").forward(request, response);

        } catch (ClassNotFoundException ex) {
            request.setAttribute("errorMessage", "Lỗi cơ sở dữ liệu: Không tìm thấy JDBC Driver!");
            request.getRequestDispatcher("/WEB-INF/views/user/vehicle-form.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        // 1. Kiểm tra đăng nhập
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // 2. Thu thập dữ liệu từ Form (Thuần túy POST không JavaScript)
        String brandIdStr = request.getParameter("brandId");
        String typeIdStr = request.getParameter("typeId");
        String modelName = request.getParameter("modelName");
        String engineNumber = request.getParameter("engineNumber");
        String chassisNumber = request.getParameter("chassisNumber");
        String color = request.getParameter("color");
        String engineCapacityStr = request.getParameter("engineCapacity");
        String vehicleValueStr = request.getParameter("vehicleValue");
        String taxReceiptNumber = request.getParameter("taxReceiptNumber");
        String invoiceNumber = request.getParameter("invoiceNumber");

        // Giữ lại giá trị người dùng đã nhập để điền lại form nếu có lỗi
        request.setAttribute("paramBrandId", brandIdStr);
        request.setAttribute("paramTypeId", typeIdStr);
        request.setAttribute("paramModelName", modelName);
        request.setAttribute("paramEngineNumber", engineNumber);
        request.setAttribute("paramChassisNumber", chassisNumber);
        request.setAttribute("paramColor", color);
        request.setAttribute("paramEngineCapacity", engineCapacityStr);
        request.setAttribute("paramVehicleValue", vehicleValueStr);
        request.setAttribute("paramTaxReceiptNumber", taxReceiptNumber);
        request.setAttribute("paramInvoiceNumber", invoiceNumber);

        // 3. Kiểm tra rỗng bắt buộc
        if (brandIdStr == null || brandIdStr.trim().isEmpty() ||
            typeIdStr == null || typeIdStr.trim().isEmpty() ||
            modelName == null || modelName.trim().isEmpty() ||
            engineNumber == null || engineNumber.trim().isEmpty() ||
            chassisNumber == null || chassisNumber.trim().isEmpty() ||
            color == null || color.trim().isEmpty() ||
            engineCapacityStr == null || engineCapacityStr.trim().isEmpty() ||
            vehicleValueStr == null || vehicleValueStr.trim().isEmpty() ||
            taxReceiptNumber == null || taxReceiptNumber.trim().isEmpty() ||
            invoiceNumber == null || invoiceNumber.trim().isEmpty()) {

            forwardWithError(request, response, "Vui lòng điền đầy đủ tất cả các trường thông tin phương tiện bắt buộc!");
            return;
        }

        int brandId;
        int typeId;
        int engineCapacity;
        BigDecimal vehicleValue;

        try {
            brandId = Integer.parseInt(brandIdStr.trim());
            typeId = Integer.parseInt(typeIdStr.trim());
        } catch (NumberFormatException e) {
            forwardWithError(request, response, "Hãng xe hoặc Loại xe được chọn không hợp lệ!");
            return;
        }

        try {
            engineCapacity = Integer.parseInt(engineCapacityStr.trim());
            // BR-05: engineCapacity >= 0 (bằng 0 đối với xe máy điện)
            if (engineCapacity < 0) {
                forwardWithError(request, response, "Dung tích xi-lanh không được là số âm (Nhập 0 đối với xe máy điện)!");
                return;
            }
        } catch (NumberFormatException e) {
            forwardWithError(request, response, "Dung tích xi-lanh phải là số nguyên hợp lệ (cm³)!");
            return;
        }

        try {
            String cleanValue = vehicleValueStr.trim().replaceAll("[,.]", "");
            vehicleValue = new BigDecimal(cleanValue);
            // BR-05: vehicleValue > 0
            if (vehicleValue.compareTo(BigDecimal.ZERO) <= 0) {
                forwardWithError(request, response, "Giá trị phương tiện khai báo trên hóa đơn phải lớn hơn 0 VNĐ!");
                return;
            }
        } catch (NumberFormatException e) {
            forwardWithError(request, response, "Giá trị xe khai báo phải là số tiền hợp lệ!");
            return;
        }

        try {
            VehicleDAO vehicleDAO = new VehicleDAO();

            // 4. Kiểm tra quy tắc duy nhất (BR-02: engineNumber & chassisNumber duy nhất toàn hệ thống)
            if (vehicleDAO.isEngineNumberExists(engineNumber)) {
                forwardWithError(request, response, "Số máy '" + engineNumber.trim() + "' đã tồn tại trên hệ thống dữ liệu đăng ký phương tiện!");
                return;
            }

            if (vehicleDAO.isChassisNumberExists(chassisNumber)) {
                forwardWithError(request, response, "Số khung '" + chassisNumber.trim() + "' đã tồn tại trên hệ thống dữ liệu đăng ký phương tiện!");
                return;
            }

            // 5. Khởi tạo đối tượng Vehicle
            Vehicle vehicle = new Vehicle();
            vehicle.setOwnerId(currentUser.getUserId());
            vehicle.setBrandId(brandId);
            vehicle.setTypeId(typeId);
            vehicle.setModelName(modelName.trim());
            vehicle.setEngineNumber(engineNumber.trim().toUpperCase());
            vehicle.setChassisNumber(chassisNumber.trim().toUpperCase());
            vehicle.setColor(color.trim());
            vehicle.setEngineCapacity(engineCapacity);
            vehicle.setVehicleValue(vehicleValue);
            vehicle.setTaxReceiptNumber(taxReceiptNumber.trim().toUpperCase());
            vehicle.setInvoiceNumber(invoiceNumber.trim().toUpperCase());

            // 6. Thực thi JDBC Transaction (FR-03)
            int districtId = currentUser.getDistrictId(); // Biển số được cấp theo Quận thường trú của chủ xe (BR-01)
            int registrationId = vehicleDAO.registerNewVehicle(vehicle, districtId);

            if (registrationId > 0) {
                // Đăng ký thành công -> Gửi Flash Message vào Session và chuyển hướng
                session.setAttribute("flashSuccessMessage", 
                    "Khai báo phương tiện thành công! Hồ sơ #" + registrationId + " (" + modelName.trim() + ") " +
                    "đã được chuyển tới Công An " + currentUser.getDistrict().getDistrictName() + " thẩm định.");
                
                response.sendRedirect(request.getContextPath() + "/home.jsp");
            } else {
                forwardWithError(request, response, "Không thể lưu hồ sơ đăng ký. Vui lòng kiểm tra lại dữ liệu và thử lại!");
            }

        } catch (ClassNotFoundException ex) {
            forwardWithError(request, response, "Lỗi kết nối cơ sở dữ liệu: Không tìm thấy JDBC Driver!");
        } catch (SQLException ex) {
            forwardWithError(request, response, "Lỗi cơ sở dữ liệu khi lưu hồ sơ: " + ex.getMessage());
        }
    }

    /**
     * Nạp lại danh mục Hãng/Loại xe và forward lại form kèm thông báo lỗi
     */
    private void forwardWithError(HttpServletRequest request, HttpServletResponse response, String message)
            throws ServletException, IOException {
        try {
            VehicleDAO dao = new VehicleDAO();
            request.setAttribute("brands", dao.getAllBrands());
            request.setAttribute("types", dao.getAllTypes());
        } catch (ClassNotFoundException ignored) {
        }
        request.setAttribute("errorMessage", message);
        request.getRequestDispatcher("/WEB-INF/views/user/vehicle-form.jsp").forward(request, response);
    }
}
