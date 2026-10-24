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

@WebServlet(name = "UserDashboardController", urlPatterns = {"/user/dashboard", "/user/registrations"})
public class UserDashboardController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            RegistrationDAO regDAO = new RegistrationDAO();
            List<Registration> userRegistrations = regDAO.getUserRegistrations(currentUser.getUserId());
            request.setAttribute("userRegistrations", userRegistrations);

            // Chuyển Flash message từ session nếu có
            String flashSuccess = (String) session.getAttribute("flashSuccessMessage");
            if (flashSuccess != null) {
                request.setAttribute("successMessage", flashSuccess);
                session.removeAttribute("flashSuccessMessage");
            }

            // Chuyển tiếp tới giao diện dashboard của công dân
            request.getRequestDispatcher("/WEB-INF/views/user/dashboard.jsp").forward(request, response);

        } catch (ClassNotFoundException ex) {
            request.setAttribute("errorMessage", "Lỗi cơ sở dữ liệu: Không tìm thấy JDBC Driver!");
            request.getRequestDispatcher("/WEB-INF/views/user/dashboard.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}
