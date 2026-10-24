package Controller;

import DAO.UserDAO;
import Models.District;
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
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.regex.Pattern;

/**
 * Phân hệ Quản lý Cán bộ CSGT dành cho Quản trị viên (ROLE_ADMIN)
 * Xử lý: Liệt kê, Lọc theo Quận/Huyện, Cấp mới tài khoản cán bộ, Điều chuyển địa bàn, Reset mật khẩu
 */
@WebServlet(name = "AdminOfficersController", urlPatterns = {"/admin/officers"})
public class AdminOfficersController extends HttpServlet {

    private static final Pattern CCCD_PATTERN = Pattern.compile("^\\d{12}$");
    private static final Pattern PHONE_PATTERN = Pattern.compile("^\\d{10,11}$");
    private static final Pattern EMAIL_PATTERN = Pattern.compile("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,6}$");

    /**
     * Kiểm tra phiên đăng nhập và quyền Quản trị viên
     */
    private boolean checkAdminAuth(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return false;
        }

        User currentUser = (User) session.getAttribute("currentUser");
        if (currentUser.getRole() == null || !"ROLE_ADMIN".equalsIgnoreCase(currentUser.getRole().getRoleName())) {
            response.sendRedirect(request.getContextPath() + "/home.jsp");
            return false;
        }
        return true;
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!checkAdminAuth(request, response)) {
            return;
        }

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        HttpSession session = request.getSession();
        // Nhận flash messages nếu có
        if (session.getAttribute("flashSuccessMessage") != null) {
            request.setAttribute("flashSuccessMessage", session.getAttribute("flashSuccessMessage"));
            session.removeAttribute("flashSuccessMessage");
        }
        if (session.getAttribute("flashErrorMessage") != null) {
            request.setAttribute("flashErrorMessage", session.getAttribute("flashErrorMessage"));
            session.removeAttribute("flashErrorMessage");
        }

        String keyword = request.getParameter("keyword");
        String districtIdStr = request.getParameter("districtId");
        Integer filterDistrictId = null;
        if (districtIdStr != null && !districtIdStr.trim().isEmpty()) {
            try {
                filterDistrictId = Integer.parseInt(districtIdStr.trim());
            } catch (NumberFormatException ignored) {}
        }

        try {
            UserDAO userDAO = new UserDAO();
            List<User> officersList = userDAO.getAllOfficers(filterDistrictId, keyword);
            List<District> districtList = userDAO.getAllDistricts();
            Map<Integer, Integer> officerCountMap = userDAO.getOfficerCountByDistrict();

            // Tính toán số liệu thống kê nhân sự
            int totalOfficers = userDAO.getAllOfficers(null, null).size();
            int totalDistricts = districtList.size();
            int assignedDistricts = 0;
            for (District d : districtList) {
                Integer count = officerCountMap.get(d.getDistrictId());
                if (count != null && count > 0) {
                    assignedDistricts++;
                }
            }
            int unassignedDistricts = totalDistricts - assignedDistricts;

            request.setAttribute("officersList", officersList);
            request.setAttribute("districtList", districtList);
            request.setAttribute("officerCountMap", officerCountMap);
            request.setAttribute("totalOfficers", totalOfficers);
            request.setAttribute("totalDistricts", totalDistricts);
            request.setAttribute("assignedDistricts", assignedDistricts);
            request.setAttribute("unassignedDistricts", unassignedDistricts);
            request.setAttribute("selectedDistrictId", filterDistrictId);
            request.setAttribute("keyword", keyword);

        } catch (ClassNotFoundException ex) {
            Logger.getLogger(AdminOfficersController.class.getName()).log(Level.SEVERE, "Lỗi kết nối CSDL", ex);
            request.setAttribute("error", "Lỗi kết nối cơ sở dữ liệu!");
        }

        request.getRequestDispatcher("/WEB-INF/views/admin/officers.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!checkAdminAuth(request, response)) {
            return;
        }

        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        HttpSession session = request.getSession();
        String action = request.getParameter("action");
        if (action == null) {
            action = "";
        }

        UserDAO userDAO;
        try {
            userDAO = new UserDAO();
        } catch (ClassNotFoundException ex) {
            session.setAttribute("flashErrorMessage", "Lỗi kết nối cơ sở dữ liệu!");
            response.sendRedirect(request.getContextPath() + "/admin/officers");
            return;
        }

        switch (action) {
            case "create": {
                String userName = request.getParameter("userName");
                String userpassword = request.getParameter("userpassword");
                String fullName = request.getParameter("fullName");
                String identityCard = request.getParameter("identityCard");
                String phone = request.getParameter("phone");
                String email = request.getParameter("email");
                String address = request.getParameter("address");
                String districtIdStr = request.getParameter("districtId");

                // Kiểm tra rỗng
                if (userName == null || userName.trim().isEmpty() ||
                    userpassword == null || userpassword.isEmpty() ||
                    fullName == null || fullName.trim().isEmpty() ||
                    identityCard == null || identityCard.trim().isEmpty() ||
                    phone == null || phone.trim().isEmpty() ||
                    address == null || address.trim().isEmpty() ||
                    districtIdStr == null || districtIdStr.trim().isEmpty()) {

                    session.setAttribute("flashErrorMessage", "Vui lòng điền đầy đủ các thông tin bắt buộc (*).");
                    response.sendRedirect(request.getContextPath() + "/admin/officers");
                    return;
                }

                userName = userName.trim();
                fullName = fullName.trim();
                identityCard = identityCard.trim();
                phone = phone.trim();
                address = address.trim();
                if (email != null) {
                    email = email.trim();
                }

                // Định dạng CCCD 12 số
                if (!CCCD_PATTERN.matcher(identityCard).matches()) {
                    session.setAttribute("flashErrorMessage", "Số CCCD Cán bộ phải bao gồm đúng 12 chữ số.");
                    response.sendRedirect(request.getContextPath() + "/admin/officers");
                    return;
                }

                // Định dạng SĐT 10-11 số
                if (!PHONE_PATTERN.matcher(phone).matches()) {
                    session.setAttribute("flashErrorMessage", "Số điện thoại Cán bộ phải có từ 10 đến 11 chữ số.");
                    response.sendRedirect(request.getContextPath() + "/admin/officers");
                    return;
                }

                // Định dạng Email
                if (email != null && !email.isEmpty() && !EMAIL_PATTERN.matcher(email).matches()) {
                    session.setAttribute("flashErrorMessage", "Địa chỉ email không đúng định dạng.");
                    response.sendRedirect(request.getContextPath() + "/admin/officers");
                    return;
                }

                // Mật khẩu tối thiểu 6 ký tự
                if (userpassword.length() < 6) {
                    session.setAttribute("flashErrorMessage", "Mật khẩu Cán bộ tối thiểu từ 6 ký tự trở lên.");
                    response.sendRedirect(request.getContextPath() + "/admin/officers");
                    return;
                }

                int districtId;
                try {
                    districtId = Integer.parseInt(districtIdStr);
                } catch (NumberFormatException e) {
                    session.setAttribute("flashErrorMessage", "Quận/Huyện phân công không hợp lệ.");
                    response.sendRedirect(request.getContextPath() + "/admin/officers");
                    return;
                }

                // Kiểm tra trùng lặp userName & identityCard
                if (userDAO.isUsernameExists(userName)) {
                    session.setAttribute("flashErrorMessage", "Tên đăng nhập '" + userName + "' đã tồn tại trên hệ thống!");
                    response.sendRedirect(request.getContextPath() + "/admin/officers");
                    return;
                }
                if (userDAO.isIdentityCardExists(identityCard)) {
                    session.setAttribute("flashErrorMessage", "Số CCCD '" + identityCard + "' đã được đăng ký tài khoản khác!");
                    response.sendRedirect(request.getContextPath() + "/admin/officers");
                    return;
                }

                User newOfficer = new User();
                newOfficer.setUserName(userName);
                newOfficer.setUserpassword(userpassword);
                newOfficer.setFullName(fullName);
                newOfficer.setIdentityCard(identityCard);
                newOfficer.setPhone(phone);
                newOfficer.setEmail(email != null && !email.isEmpty() ? email : null);
                newOfficer.setAddress(address);
                newOfficer.setDistrictId(districtId);

                boolean ok = userDAO.createOfficer(newOfficer);
                if (ok) {
                    session.setAttribute("flashSuccessMessage", "Bổ nhiệm và cấp tài khoản Cán bộ CSGT '" + fullName + "' thành công!");
                } else {
                    session.setAttribute("flashErrorMessage", "Lỗi trong quá trình thêm cán bộ vào cơ sở dữ liệu!");
                }
                response.sendRedirect(request.getContextPath() + "/admin/officers");
                break;
            }

            case "updateDistrict": {
                String officerUserIdStr = request.getParameter("officerUserId");
                String newDistrictIdStr = request.getParameter("newDistrictId");

                try {
                    int officerUserId = Integer.parseInt(officerUserIdStr);
                    int newDistrictId = Integer.parseInt(newDistrictIdStr);

                    boolean ok = userDAO.updateOfficerDistrict(officerUserId, newDistrictId);
                    if (ok) {
                        session.setAttribute("flashSuccessMessage", "Điều chuyển Cán bộ sang địa bàn mới thành công!");
                    } else {
                        session.setAttribute("flashErrorMessage", "Không thể điều chuyển địa bàn cho cán bộ này.");
                    }
                } catch (NumberFormatException e) {
                    session.setAttribute("flashErrorMessage", "Dữ liệu điều chuyển không hợp lệ!");
                }
                response.sendRedirect(request.getContextPath() + "/admin/officers");
                break;
            }

            case "resetPassword": {
                String officerUserIdStr = request.getParameter("officerUserId");
                String newPassword = request.getParameter("newPassword");

                if (newPassword == null || newPassword.trim().length() < 6) {
                    session.setAttribute("flashErrorMessage", "Mật khẩu mới phải có tối thiểu 6 ký tự.");
                    response.sendRedirect(request.getContextPath() + "/admin/officers");
                    return;
                }

                try {
                    int officerUserId = Integer.parseInt(officerUserIdStr);
                    boolean ok = userDAO.resetOfficerPassword(officerUserId, newPassword.trim());
                    if (ok) {
                        session.setAttribute("flashSuccessMessage", "Đặt lại mật khẩu cho Cán bộ thành công!");
                    } else {
                        session.setAttribute("flashErrorMessage", "Không thể đặt lại mật khẩu cho cán bộ này.");
                    }
                } catch (NumberFormatException e) {
                    session.setAttribute("flashErrorMessage", "Dữ liệu đặt lại mật khẩu không hợp lệ!");
                }
                response.sendRedirect(request.getContextPath() + "/admin/officers");
                break;
            }

            default:
                response.sendRedirect(request.getContextPath() + "/admin/officers");
                break;
        }
    }
}
