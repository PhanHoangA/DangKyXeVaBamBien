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
import java.util.logging.Level;
import java.util.logging.Logger;
import java.util.regex.Pattern;

/**
 * FR-01: Đăng ký tài khoản Công dân (ROLE_USER)
 * Xử lý xác thực đầu vào, kiểm tra trùng lặp và lưu trữ công dân mới
 */
@WebServlet(name = "RegisterController", urlPatterns = {"/register"})
public class RegisterController extends HttpServlet {

    private static final Pattern CCCD_PATTERN = Pattern.compile("^\\d{12}$");
    private static final Pattern PHONE_PATTERN = Pattern.compile("^\\d{10,11}$");
    private static final Pattern EMAIL_PATTERN = Pattern.compile("^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,6}$");

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        // Nếu đã đăng nhập, chuyển hướng người dùng về trang chủ
        if (session != null && session.getAttribute("currentUser") != null) {
            response.sendRedirect(request.getContextPath() + "/home.jsp");
            return;
        }

        try {
            UserDAO userDAO = new UserDAO();
            List<District> districtList = userDAO.getAllDistricts();
            request.setAttribute("districtList", districtList);
        } catch (ClassNotFoundException ex) {
            Logger.getLogger(RegisterController.class.getName()).log(Level.SEVERE, "Lỗi kết nối CSDL", ex);
            request.setAttribute("error", "Lỗi kết nối cơ sở dữ liệu. Vui lòng thử lại sau!");
        }

        request.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String userName = request.getParameter("userName");
        String userpassword = request.getParameter("userpassword");
        String confirmPassword = request.getParameter("confirmPassword");
        String fullName = request.getParameter("fullName");
        String identityCard = request.getParameter("identityCard");
        String phone = request.getParameter("phone");
        String email = request.getParameter("email");
        String address = request.getParameter("address");
        String districtIdStr = request.getParameter("districtId");

        // Giữ lại dữ liệu trên form khi có lỗi
        request.setAttribute("userName", userName);
        request.setAttribute("fullName", fullName);
        request.setAttribute("identityCard", identityCard);
        request.setAttribute("phone", phone);
        request.setAttribute("email", email);
        request.setAttribute("address", address);
        request.setAttribute("selectedDistrictId", districtIdStr);

        UserDAO userDAO;
        try {
            userDAO = new UserDAO();
            List<District> districtList = userDAO.getAllDistricts();
            request.setAttribute("districtList", districtList);
        } catch (ClassNotFoundException ex) {
            request.setAttribute("error", "Lỗi kết nối cơ sở dữ liệu!");
            request.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(request, response);
            return;
        }

        // 1. Kiểm tra trường bắt buộc
        if (userName == null || userName.trim().isEmpty() ||
            userpassword == null || userpassword.isEmpty() ||
            confirmPassword == null || confirmPassword.isEmpty() ||
            fullName == null || fullName.trim().isEmpty() ||
            identityCard == null || identityCard.trim().isEmpty() ||
            phone == null || phone.trim().isEmpty() ||
            address == null || address.trim().isEmpty() ||
            districtIdStr == null || districtIdStr.trim().isEmpty()) {

            request.setAttribute("error", "Vui lòng điền đầy đủ tất cả các trường bắt buộc (*).");
            request.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(request, response);
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

        // 2. Kiểm tra định dạng CCCD (FR-01: đúng 12 chữ số)
        if (!CCCD_PATTERN.matcher(identityCard).matches()) {
            request.setAttribute("error", "Số CCCD/Định danh cá nhân phải bao gồm đúng 12 chữ số.");
            request.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(request, response);
            return;
        }

        // 3. Kiểm tra định dạng Số điện thoại (FR-01: từ 10-11 chữ số)
        if (!PHONE_PATTERN.matcher(phone).matches()) {
            request.setAttribute("error", "Số điện thoại liên hệ phải có từ 10 đến 11 chữ số.");
            request.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(request, response);
            return;
        }

        // 4. Kiểm tra Email hợp lệ nếu người dùng có nhập
        if (email != null && !email.isEmpty() && !EMAIL_PATTERN.matcher(email).matches()) {
            request.setAttribute("error", "Địa chỉ email không đúng định dạng.");
            request.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(request, response);
            return;
        }

        // 5. Kiểm tra mật khẩu và xác nhận mật khẩu
        if (userpassword.length() < 6) {
            request.setAttribute("error", "Mật khẩu bảo mật phải có ít nhất 6 ký tự.");
            request.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(request, response);
            return;
        }

        if (!userpassword.equals(confirmPassword)) {
            request.setAttribute("error", "Xác nhận mật khẩu không trùng khớp với mật khẩu đã nhập.");
            request.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(request, response);
            return;
        }

        // 6. Kiểm tra Quận/Huyện hợp lệ
        int districtId;
        try {
            districtId = Integer.parseInt(districtIdStr);
        } catch (NumberFormatException e) {
            request.setAttribute("error", "Vui lòng chọn Quận/Huyện thường trú hợp lệ.");
            request.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(request, response);
            return;
        }

        // 7. Kiểm tra trùng lặp (FR-01: userName và identityCard chưa tồn tại)
        if (userDAO.isUsernameExists(userName)) {
            request.setAttribute("error", "Tên đăng nhập '" + userName + "' đã tồn tại trên hệ thống. Vui lòng chọn tên khác.");
            request.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(request, response);
            return;
        }

        if (userDAO.isIdentityCardExists(identityCard)) {
            request.setAttribute("error", "Số CCCD '" + identityCard + "' đã được đăng ký trên hệ thống. Vui lòng đăng nhập hoặc liên hệ hỗ trợ.");
            request.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(request, response);
            return;
        }

        // 8. Tạo đối tượng User và lưu vào CSDL (roleId = 3 / ROLE_USER)
        User newUser = new User();
        newUser.setUserName(userName);
        newUser.setUserpassword(userpassword);
        newUser.setFullName(fullName);
        newUser.setIdentityCard(identityCard);
        newUser.setPhone(phone);
        newUser.setEmail(email != null && !email.isEmpty() ? email : null);
        newUser.setAddress(address);
        newUser.setDistrictId(districtId);

        boolean success = userDAO.registerCitizen(newUser);

        if (success) {
            HttpSession session = request.getSession();
            session.setAttribute("successMessage", "Đăng ký tài khoản công dân thành công! Vui lòng đăng nhập để bắt đầu sử dụng dịch vụ.");
            response.sendRedirect(request.getContextPath() + "/login");
        } else {
            request.setAttribute("error", "Có lỗi xảy ra trong quá trình lưu thông tin tài khoản. Vui lòng thử lại!");
            request.getRequestDispatcher("/WEB-INF/views/auth/register.jsp").forward(request, response);
        }
    }
}
