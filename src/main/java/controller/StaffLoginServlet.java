package controller;

import DAO.StaffDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/staff-login")
public class StaffLoginServlet extends HttpServlet {
    private StaffDAO staffDAO;

    @Override
    public void init() {
        staffDAO = new StaffDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/stafflogin.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String role = request.getParameter("role");

        System.out.println("DEBUG: Login attempt - Username: " + username + ", Role: " + role);

        boolean isAuthenticated = false;
        
        // Try database authentication first
        try {
            isAuthenticated = staffDAO.authenticateStaff(username, password, role);
            System.out.println("DEBUG: Database authentication result: " + isAuthenticated);
        } catch (Exception e) {
            System.err.println("WARN: Database authentication failed, falling back to hardcoded credentials");
            e.printStackTrace();
            
            // Fallback to hardcoded credentials if database authentication fails
            if (role != null && role.equals("receptionist")) {
                if ("receptionist".equals(username) && "reception123".equals(password)) {
                    isAuthenticated = true;
                }
            } else if (role != null && role.equals("manager")) {
                if ("manager".equals(username) && "manager123".equals(password)) {
                    isAuthenticated = true;
                }
            } else if (role != null && role.equals("admin")) {
                if ("admin".equals(username) && "admin123".equals(password)) {
                    isAuthenticated = true;
                }
            }
        }

        if (isAuthenticated) {
            HttpSession session = request.getSession(true);
            session.setAttribute("staffUsername", username);
            session.setAttribute("staffRole", role);
            session.setMaxInactiveInterval(3600); // 1 hour session timeout
            
            System.out.println("DEBUG: Login successful, session created for: " + username);
            System.out.println("DEBUG: Session ID: " + session.getId());
            System.out.println("DEBUG: Staff role set to: " + role);
            
            // Check for redirect parameter
            String redirectUrl = request.getParameter("redirect");
            if (redirectUrl != null && !redirectUrl.isEmpty()) {
                System.out.println("DEBUG: Redirecting to: " + redirectUrl);
                response.sendRedirect(redirectUrl);
            } else {
                // Redirect based on role
                if ("receptionist".equals(role)) {
                    System.out.println("DEBUG: Redirecting to receptionist dashboard");
                    response.sendRedirect(request.getContextPath() + "/receptionist/dashboard");
                } else if ("manager".equals(role)) {
                    System.out.println("DEBUG: Redirecting to manager dashboard");
                    response.sendRedirect(request.getContextPath() + "/manager/dashboard");
                } else if ("admin".equals(role)) {
                    System.out.println("DEBUG: Redirecting to admin dashboard");
                    response.sendRedirect(request.getContextPath() + "/admin/dashboard");
                } else {
                    response.sendRedirect(request.getContextPath() + "/");
                }
            }
        } else {
            System.out.println("DEBUG: Login failed for username: " + username);
            request.setAttribute("error", "Invalid username, password, or role");
            request.getRequestDispatcher("/stafflogin.jsp").forward(request, response);
        }
    }
}
