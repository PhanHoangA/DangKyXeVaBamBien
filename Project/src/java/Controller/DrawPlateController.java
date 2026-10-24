package Controller;

import DAO.RegistrationDAO;
import Models.LicensePlate;
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
import java.util.concurrent.ConcurrentHashMap;

@WebServlet(name = "DrawPlateController", urlPatterns = {"/user/draw-plate"})
public class DrawPlateController extends HttpServlet {

    // NFR-01: Khóa đồng bộ mức ứng dụng theo districtId để chống tranh chấp đồng thời
    private static final ConcurrentHashMap<Integer, Object> DISTRICT_LOCKS = new ConcurrentHashMap<>();

    private static Object getDistrictLock(int districtId) {
        return DISTRICT_LOCKS.computeIfAbsent(districtId, k -> new Object());
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        // 1. Kiểm tra xác thực
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            RegistrationDAO dao = new RegistrationDAO();
            List<Registration> approvedList = dao.getApprovedRegistrationsByUser(currentUser.getUserId());
            request.setAttribute("approvedRegistrations", approvedList);

            // Kiểm tra nếu người dùng chọn một hồ sơ cụ thể qua param ?regId=...
            String regIdStr = request.getParameter("registrationId");
            Registration selectedReg = null;

            if (regIdStr != null && !regIdStr.trim().isEmpty()) {
                try {
                    int regId = Integer.parseInt(regIdStr.trim());
                    for (Registration r : approvedList) {
                        if (r.getRegistrationId() == regId) {
                            selectedReg = r;
                            break;
                        }
                    }
                } catch (NumberFormatException ignored) {
                }
            }

            // Nếu chưa chọn hoặc không tìm thấy, mặc định chọn hồ sơ đầu tiên (nếu có)
            if (selectedReg == null && !approvedList.isEmpty()) {
                selectedReg = approvedList.get(0);
            }

            request.setAttribute("selectedRegistration", selectedReg);

            // Chuyển tiếp tới giao diện phòng quay số chuẩn VNeID (Zero JS)
            request.getRequestDispatcher("/WEB-INF/views/user/draw-plate.jsp").forward(request, response);

        } catch (ClassNotFoundException ex) {
            request.setAttribute("errorMessage", "Lỗi cơ sở dữ liệu: Không tìm thấy JDBC Driver!");
            request.getRequestDispatcher("/WEB-INF/views/user/draw-plate.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        // 1. Kiểm tra xác thực
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String regIdStr = request.getParameter("registrationId");
        String drawCode = request.getParameter("drawCode");

        if (regIdStr == null || regIdStr.trim().isEmpty() || drawCode == null || drawCode.trim().isEmpty()) {
            forwardWithError(request, response, currentUser.getUserId(), "Vui lòng chọn hồ sơ xe và nhập mã bấm biển số (Draw Code) do CSGT cấp!");
            return;
        }

        int registrationId;
        try {
            registrationId = Integer.parseInt(regIdStr.trim());
        } catch (NumberFormatException e) {
            forwardWithError(request, response, currentUser.getUserId(), "Mã hồ sơ đăng ký không hợp lệ!");
            return;
        }

        try {
            RegistrationDAO dao = new RegistrationDAO();

            // NFR-01: Đồng bộ hóa mức ứng dụng theo districtId kết hợp giao dịch JDBC
            int districtId = currentUser.getDistrictId();
            LicensePlate drawnPlate;

            synchronized (getDistrictLock(districtId)) {
                drawnPlate = dao.atomicDrawPlate(registrationId, currentUser.getUserId(), drawCode.trim());
            }

            if (drawnPlate != null) {
                // Tải lại thông tin hồ sơ vừa bấm biển
                Registration updatedReg = dao.getRegistrationById(registrationId);
                request.setAttribute("drawnPlate", drawnPlate);
                request.setAttribute("selectedRegistration", updatedReg);
                request.setAttribute("successMessage", 
                    "Chúc mừng bạn đã bấm thành công biển số định danh: " + drawnPlate.getFullPlate() + "!");

                // Nạp lại danh sách hồ sơ còn lại
                List<Registration> approvedList = dao.getApprovedRegistrationsByUser(currentUser.getUserId());
                request.setAttribute("approvedRegistrations", approvedList);

                // Hiển thị trực tiếp kết quả bấm biển trên giao diện
                request.getRequestDispatcher("/WEB-INF/views/user/draw-plate.jsp").forward(request, response);
            } else {
                forwardWithError(request, response, currentUser.getUserId(), "Không thể bấm biển số. Vui lòng thử lại!");
            }

        } catch (ClassNotFoundException ex) {
            forwardWithError(request, response, currentUser.getUserId(), "Lỗi cơ sở dữ liệu: Không tìm thấy JDBC Driver!");
        } catch (Exception ex) {
            forwardWithError(request, response, currentUser.getUserId(), ex.getMessage());
        }
    }

    private void forwardWithError(HttpServletRequest request, HttpServletResponse response, int userId, String message)
            throws ServletException, IOException {
        try {
            RegistrationDAO dao = new RegistrationDAO();
            List<Registration> approvedList = dao.getApprovedRegistrationsByUser(userId);
            request.setAttribute("approvedRegistrations", approvedList);

            String regIdStr = request.getParameter("registrationId");
            if (regIdStr != null) {
                try {
                    int rId = Integer.parseInt(regIdStr);
                    request.setAttribute("selectedRegistration", dao.getRegistrationById(rId));
                } catch (Exception ignored) {
                }
            }
        } catch (Exception ignored) {
        }
        request.setAttribute("errorMessage", message);
        request.getRequestDispatcher("/WEB-INF/views/user/draw-plate.jsp").forward(request, response);
    }
}
