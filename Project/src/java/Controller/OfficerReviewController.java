package Controller;

import DAO.RegistrationDAO;
import Models.Registration;
import Models.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.math.BigDecimal;

@WebServlet(name = "OfficerReviewController", urlPatterns = {"/officer/review"})
public class OfficerReviewController extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        // 1. Kiểm tra xác thực cán bộ
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String roleName = (currentUser.getRole() != null) ? currentUser.getRole().getRoleName() : "";
        if (!"ROLE_OFFICER".equalsIgnoreCase(roleName) && !"ROLE_ADMIN".equalsIgnoreCase(roleName)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền thực hiện chức năng thẩm định!");
            return;
        }

        // 2. Lấy tham số gửi lên từ Form thuần túy
        String regIdStr = request.getParameter("registrationId");
        String action = request.getParameter("action"); // "approve" hoặc "reject"

        if (regIdStr == null || regIdStr.trim().isEmpty() || action == null) {
            response.sendRedirect(request.getContextPath() + "/officer/registrations");
            return;
        }

        int registrationId;
        try {
            registrationId = Integer.parseInt(regIdStr.trim());
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/officer/registrations");
            return;
        }

        try {
            RegistrationDAO dao = new RegistrationDAO();
            Registration reg = dao.getRegistrationById(registrationId);

            if (reg == null) {
                session.setAttribute("flashErrorMessage", "Không tìm thấy hồ sơ đăng ký #" + registrationId);
                response.sendRedirect(request.getContextPath() + "/officer/registrations");
                return;
            }

            // Kiểm tra quy tắc khóa vùng địa lý (BR-01): Cán bộ chỉ được duyệt hồ sơ thuộc Quận của mình
            if (reg.getDistrictId() != currentUser.getDistrictId() && !"ROLE_ADMIN".equalsIgnoreCase(roleName)) {
                session.setAttribute("flashErrorMessage", "Vi phạm phân quyền địa bàn: Hồ sơ không thuộc Quận/Huyện bạn phụ trách!");
                response.sendRedirect(request.getContextPath() + "/officer/registrations");
                return;
            }

            // Kiểm tra quy tắc trạng thái (BR-03): Chỉ hồ sơ PENDING mới được phê duyệt hoặc từ chối
            if (!"PENDING".equalsIgnoreCase(reg.getStatus())) {
                session.setAttribute("flashErrorMessage", "Hồ sơ #" + registrationId + " hiện không ở trạng thái Chờ duyệt (PENDING)!");
                response.sendRedirect(request.getContextPath() + "/officer/registrations");
                return;
            }

            // 3. Xử lý hành động Phê duyệt (Approve - FR-07)
            if ("approve".equalsIgnoreCase(action)) {
                String feeStr = request.getParameter("feeAmount");
                BigDecimal feeAmount;

                try {
                    if (feeStr == null || feeStr.trim().isEmpty()) {
                        feeAmount = new BigDecimal("100000.00"); // Lệ phí mặc định nếu để trống
                    } else {
                        // Loại bỏ dấu phẩy hoặc chấm phân cách hàng nghìn nếu có
                        String cleanFee = feeStr.trim().replaceAll("[,.]", "");
                        feeAmount = new BigDecimal(cleanFee);
                    }

                    // BR-05: Lệ phí phê duyệt phải lớn hơn 0
                    if (feeAmount.compareTo(BigDecimal.ZERO) <= 0) {
                        session.setAttribute("flashErrorMessage", "Mức lệ phí cấp biển phải lớn hơn 0 VNĐ!");
                        response.sendRedirect(request.getContextPath() + "/officer/registrations");
                        return;
                    }
                } catch (NumberFormatException ex) {
                    session.setAttribute("flashErrorMessage", "Định dạng lệ phí không hợp lệ!");
                    response.sendRedirect(request.getContextPath() + "/officer/registrations");
                    return;
                }

                // Sinh mã bấm biển ngẫu nhiên duy nhất
                String drawCode = dao.generateUniqueDrawCode();
                boolean success = dao.approveRegistration(registrationId, currentUser.getUserId(), feeAmount, drawCode);

                if (success) {
                    session.setAttribute("flashSuccessMessage", 
                        "Thẩm định thành công hồ sơ #" + registrationId + 
                        "! Đã cấp mã bấm biển: " + drawCode + " (Lệ phí: " + feeAmount + " VNĐ). Người dân đã có thể bấm biển số!");
                } else {
                    session.setAttribute("flashErrorMessage", "Không thể phê duyệt hồ sơ. Vui lòng thử lại!");
                }

            // 4. Xử lý hành động Từ chối (Reject - FR-08)
            } else if ("reject".equalsIgnoreCase(action)) {
                String rejectionReason = request.getParameter("rejectionReason");

                if (rejectionReason == null || rejectionReason.trim().isEmpty()) {
                    session.setAttribute("flashErrorMessage", "Vui lòng nhập lý do từ chối hồ sơ để công dân sửa đổi!");
                    response.sendRedirect(request.getContextPath() + "/officer/registrations");
                    return;
                }

                if (rejectionReason.trim().length() > 225) {
                    rejectionReason = rejectionReason.trim().substring(0, 225);
                }

                boolean success = dao.rejectRegistration(registrationId, currentUser.getUserId(), rejectionReason);

                if (success) {
                    session.setAttribute("flashSuccessMessage", 
                        "Đã từ chối và trả lại hồ sơ #" + registrationId + " kèm lý do. Công dân có thể chỉnh sửa nộp lại!");
                } else {
                    session.setAttribute("flashErrorMessage", "Không thể từ chối hồ sơ. Vui lòng thử lại!");
                }
            }

        } catch (ClassNotFoundException ex) {
            session.setAttribute("flashErrorMessage", "Lỗi cơ sở dữ liệu: Không tìm thấy JDBC Driver!");
        }

        // Chuyển hướng về trang danh sách
        response.sendRedirect(request.getContextPath() + "/officer/registrations");
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/officer/registrations");
    }
}
