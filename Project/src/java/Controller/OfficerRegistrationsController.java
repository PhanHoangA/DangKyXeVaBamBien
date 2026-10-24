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
import java.util.List;
import java.util.Map;

@WebServlet(name = "OfficerRegistrationsController", urlPatterns = {"/officer/registrations", "/officer/home"})
public class OfficerRegistrationsController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        // 1. Kiểm tra xác thực (Authentication)
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // 2. Kiểm tra phân quyền (Role: Cán bộ CSGT hoặc Admin)
        String roleName = (currentUser.getRole() != null) ? currentUser.getRole().getRoleName() : "";
        if (!"ROLE_OFFICER".equalsIgnoreCase(roleName) && !"ROLE_ADMIN".equalsIgnoreCase(roleName)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập vào phân hệ Cán bộ CSGT!");
            return;
        }

        // 3. Đọc tham số lọc & tìm kiếm từ form GET thuần túy (FR-06)
        String status = request.getParameter("status");
        if (status == null || status.trim().isEmpty()) {
            status = "ALL"; // Mặc định hiển thị tất cả hồ sơ thuộc địa bàn
        } else {
            status = status.trim().toUpperCase();
        }

        String keyword = request.getParameter("keyword");
        if (keyword != null) {
            keyword = keyword.trim();
        }

        try {
            RegistrationDAO dao = new RegistrationDAO();
            int districtId = currentUser.getDistrictId();

            // Lấy danh sách hồ sơ thuộc đúng địa bàn của Cán bộ (BR-01)
            List<Registration> registrations = dao.getOfficerRegistrations(districtId, status, keyword);

            // Lấy thống kê số lượng hồ sơ
            Map<String, Integer> stats = dao.getDistrictStats(districtId);

            // Chuyển flash message từ Session sang Request (nếu có sau khi phê duyệt/từ chối)
            String flashMessage = (String) session.getAttribute("flashSuccessMessage");
            if (flashMessage != null) {
                request.setAttribute("successMessage", flashMessage);
                session.removeAttribute("flashSuccessMessage");
            }
            String flashError = (String) session.getAttribute("flashErrorMessage");
            if (flashError != null) {
                request.setAttribute("errorMessage", flashError);
                session.removeAttribute("flashErrorMessage");
            }

            // Gán dữ liệu vào Request Scope
            request.setAttribute("registrations", registrations);
            request.setAttribute("stats", stats);
            request.setAttribute("currentStatus", status);
            request.setAttribute("keyword", keyword);

            // Chuyển tiếp sang trang JSP thuần trong WEB-INF/views/officer/
            request.getRequestDispatcher("/WEB-INF/views/officer/dashboard.jsp").forward(request, response);

        } catch (ClassNotFoundException ex) {
            request.setAttribute("errorMessage", "Không thể kết nối đến cơ sở dữ liệu: Lỗi JDBC Driver!");
            request.getRequestDispatcher("/WEB-INF/views/officer/dashboard.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
