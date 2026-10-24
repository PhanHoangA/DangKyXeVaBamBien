package Controller;

import DAO.LicensePlateDAO;
import Models.District;
import Models.LicensePlate;
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

@WebServlet(name = "AdminController", urlPatterns = {"/admin/home", "/admin/dashboard", "/admin/license-plates"})
public class AdminController extends HttpServlet {

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

        // 2. Kiểm tra phân quyền (Authorization - ROLE_ADMIN)
        String roleName = (currentUser.getRole() != null) ? currentUser.getRole().getRoleName() : "";
        if (!"ROLE_ADMIN".equalsIgnoreCase(roleName)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập vào phân hệ Quản trị hệ thống!");
            return;
        }

        // 3. Đọc tham số lọc & tìm kiếm từ form GET
        String districtIdStr = request.getParameter("districtId");
        int districtId = 0;
        if (districtIdStr != null && !districtIdStr.trim().isEmpty()) {
            try {
                districtId = Integer.parseInt(districtIdStr.trim());
            } catch (NumberFormatException ignored) {
            }
        }

        String status = request.getParameter("status");
        if (status == null || status.trim().isEmpty()) {
            status = "ALL";
        } else {
            status = status.trim().toUpperCase();
        }

        String keyword = request.getParameter("keyword");
        if (keyword != null) {
            keyword = keyword.trim();
        }

        try {
            LicensePlateDAO dao = new LicensePlateDAO();

            List<District> districts = dao.getAllDistricts();
            Map<String, Integer> plateStats = dao.getPlateStats(districtId);
            Map<String, Integer> systemStats = dao.getSystemWideStats();
            List<LicensePlate> plates = dao.getPlates(districtId, status, keyword, 200);

            // Chuyển flash message từ Session sang Request
            String flashSuccess = (String) session.getAttribute("flashSuccessMessage");
            if (flashSuccess != null) {
                request.setAttribute("successMessage", flashSuccess);
                session.removeAttribute("flashSuccessMessage");
            }
            String flashError = (String) session.getAttribute("flashErrorMessage");
            if (flashError != null) {
                request.setAttribute("errorMessage", flashError);
                session.removeAttribute("flashErrorMessage");
            }

            request.setAttribute("districts", districts);
            request.setAttribute("plateStats", plateStats);
            request.setAttribute("systemStats", systemStats);
            request.setAttribute("plates", plates);
            request.setAttribute("currentDistrictId", districtId);
            request.setAttribute("currentStatus", status);
            request.setAttribute("keyword", keyword);

            // Chuyển tiếp tới giao diện Admin Dashboard chuẩn VNeID (Zero JS)
            request.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp").forward(request, response);

        } catch (ClassNotFoundException ex) {
            request.setAttribute("errorMessage", "Lỗi cơ sở dữ liệu: Không tìm thấy JDBC Driver!");
            request.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String roleName = (currentUser.getRole() != null) ? currentUser.getRole().getRoleName() : "";
        if (!"ROLE_ADMIN".equalsIgnoreCase(roleName)) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền thực hiện thao tác quản trị!");
            return;
        }

        String action = request.getParameter("action");

        try {
            LicensePlateDAO dao = new LicensePlateDAO();

            // 1. Thao tác Sinh kho biển số tự động (FR-09)
            if ("batch_generate".equalsIgnoreCase(action)) {
                String distStr = request.getParameter("districtId");
                String startStr = request.getParameter("startNumber");
                String endStr = request.getParameter("endNumber");
                boolean blockSpecial = request.getParameter("blockSpecial") != null;

                if (distStr == null || startStr == null || endStr == null ||
                    distStr.trim().isEmpty() || startStr.trim().isEmpty() || endStr.trim().isEmpty()) {
                    session.setAttribute("flashErrorMessage", "Vui lòng nhập đầy đủ Quận/Huyện, Dải số bắt đầu và Dải số kết thúc!");
                    response.sendRedirect(request.getContextPath() + "/admin/home");
                    return;
                }

                int districtId = Integer.parseInt(distStr.trim());
                int startNumber = Integer.parseInt(startStr.trim());
                int endNumber = Integer.parseInt(endStr.trim());

                if (startNumber < 0 || endNumber < startNumber) {
                    session.setAttribute("flashErrorMessage", "Dải số không hợp lệ! Số bắt đầu phải nhỏ hơn hoặc bằng số kết thúc và >= 0.");
                    response.sendRedirect(request.getContextPath() + "/admin/home");
                    return;
                }

                if (endNumber - startNumber > 5000) {
                    session.setAttribute("flashErrorMessage", "Giới hạn mỗi lần sinh tối đa là 5,000 biển số để đảm bảo hiệu năng hệ thống!");
                    response.sendRedirect(request.getContextPath() + "/admin/home");
                    return;
                }

                int count = dao.batchGeneratePlates(districtId, startNumber, endNumber, blockSpecial);
                District d = dao.getDistrictById(districtId);
                String distName = (d != null) ? (d.getDistrictName() + " [" + d.getPlatePrefix() + "]") : ("Quận #" + districtId);

                session.setAttribute("flashSuccessMessage", 
                    "Khởi tạo thành công " + count + " biển số mới vào kho của " + distName + "!" +
                    (blockSpecial ? " (Đã tự động lọc và khóa các biển số đẹp sang trạng thái Đấu giá BLOCKED)" : ""));

            // 2. Thao tác Khóa / Mở khóa biển số (FR-10)
            } else if ("toggle_status".equalsIgnoreCase(action)) {
                String plateIdStr = request.getParameter("plateId");
                String targetStatus = request.getParameter("targetStatus");

                if (plateIdStr != null && targetStatus != null) {
                    int plateId = Integer.parseInt(plateIdStr.trim());
                    boolean success = dao.updatePlateStatus(plateId, targetStatus);
                    if (success) {
                        session.setAttribute("flashSuccessMessage", 
                            "Cập nhật trạng thái biển số #" + plateId + " sang [" + targetStatus + "] thành công!");
                    } else {
                        session.setAttribute("flashErrorMessage", "Không thể cập nhật trạng thái biển số!");
                    }
                }
            }

        } catch (ClassNotFoundException ex) {
            session.setAttribute("flashErrorMessage", "Lỗi cơ sở dữ liệu: Không tìm thấy JDBC Driver!");
        } catch (Exception ex) {
            session.setAttribute("flashErrorMessage", "Lỗi xử lý: " + ex.getMessage());
        }

        response.sendRedirect(request.getContextPath() + "/admin/home");
    }
}
