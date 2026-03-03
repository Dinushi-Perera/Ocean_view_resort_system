package controller;

import DAO.GuestDAO;
import model.Guest;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/login")
public class GuestLoginServlet extends HttpServlet {
    private GuestDAO guestDAO;

    @Override
    public void init() {
        guestDAO = new GuestDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Get form parameters
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String rememberMe = request.getParameter("rememberMe");

        // Validation
        if (email == null || email.trim().isEmpty() ||
            password == null || password.trim().isEmpty()) {

            request.setAttribute("error", "Email and password are required.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        // Validate credentials
        Guest guest = guestDAO.validateLogin(email, password);

        if (guest != null) {
            // Create session
            HttpSession session = request.getSession();
            session.setAttribute("guest", guest);
            session.setAttribute("guestId", guest.getId());
            session.setAttribute("guestName", guest.getFullName());
            session.setAttribute("guestEmail", guest.getEmail());
            session.setMaxInactiveInterval(30 * 60); // 30 minutes

            // Handle remember me
            if ("on".equals(rememberMe)) {
                session.setMaxInactiveInterval(7 * 24 * 60 * 60); // 7 days
            }

            // Redirect to guest dashboard
            response.sendRedirect(request.getContextPath() + "/guest.jsp");
        } else {
            request.setAttribute("error", "Invalid email or password. Please try again.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/login.jsp").forward(request, response);
    }
}

