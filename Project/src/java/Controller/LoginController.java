package Controller;

import DAO.UserDAO;
import Models.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "LoginController", urlPatterns = {"/login"})
public class LoginController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        // Nếu người dùng đã đăng nhập từ trước, chuyển hướng theo vai trò
        if (session != null && session.getAttribute("currentUser") != null) {
            User user = (User) session.getAttribute("currentUser");
            if (user.getRole() != null) {
                String role = user.getRole().getRoleName();
                if ("ROLE_ADMIN".equalsIgnoreCase(role)) {
                    response.sendRedirect(request.getContextPath() + "/admin/home");
                    return;
                } else if ("ROLE_OFFICER".equalsIgnoreCase(role)) {
                    response.sendRedirect(request.getContextPath() + "/officer/home");
                    return;
                }
            }
            response.sendRedirect(request.getContextPath() + "/home.jsp");
            return;
        }

        // Chuyển tiếp flash successMessage từ session sang request nếu có (sau khi đăng ký thành công)
        if (session != null && session.getAttribute("successMessage") != null) {
            request.setAttribute("successMessage", session.getAttribute("successMessage"));
            session.removeAttribute("successMessage");
        }

        // Chuyển tiếp tới giao diện login.jsp trong WEB-INF/views/auth/
        request.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        response.setContentType("text/html;charset=UTF-8");

        String userName = request.getParameter("userName");
        String userpassword = request.getParameter("userpassword");

        // 1. Kiểm tra đầu vào rỗng
        if (userName == null || userName.trim().isEmpty() || 
            userpassword == null || userpassword.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập đầy đủ số CCCD / Tên đăng nhập và mật khẩu!");
            request.setAttribute("userName", userName);
            request.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(request, response);
            return;
        }

        try {
            UserDAO userDAO = new UserDAO();
            User user = userDAO.login(userName, userpassword);

            // 2. Kiểm tra thông tin đăng nhập
            if (user != null) {
                // Đăng nhập thành công -> Lưu vào Session
                HttpSession session = request.getSession();
                session.setAttribute("currentUser", user);

                // Phân luồng chuyển hướng dựa trên vai trò
                if (user.getRole() != null) {
                    String role = user.getRole().getRoleName();
                    if ("ROLE_ADMIN".equalsIgnoreCase(role)) {
                        response.sendRedirect(request.getContextPath() + "/admin/home");
                        return;
                    } else if ("ROLE_OFFICER".equalsIgnoreCase(role)) {
                        response.sendRedirect(request.getContextPath() + "/officer/home");
                        return;
                    }
                }
                response.sendRedirect(request.getContextPath() + "/home.jsp");
            } else {
                // Sai tài khoản hoặc mật khẩu
                request.setAttribute("error", "Số định danh / Tên đăng nhập hoặc mật khẩu không chính xác!");
                request.setAttribute("userName", userName);
                request.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(request, response);
            }
        } catch (ClassNotFoundException ex) {
            request.setAttribute("error", "Lỗi kết nối cơ sở dữ liệu: Không tìm thấy JDBC Driver!");
            request.getRequestDispatcher("/WEB-INF/views/auth/login.jsp").forward(request, response);
        }
    }
}
