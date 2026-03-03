package controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/navigate")
public class NavigationServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        handleNavigation(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        handleNavigation(request, response);
    }

    private void handleNavigation(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String page = request.getParameter("page");
        HttpSession session = request.getSession(false);
        String contextPath = request.getContextPath();

        if (page == null || page.isEmpty()) {
            response.sendRedirect(contextPath + "/login.jsp");
            return;
        }

        // Check if user is logged in for protected pages
        boolean isLoggedIn = (session != null && session.getAttribute("guestId") != null);

        switch (page.toLowerCase()) {
            case "home":
            case "guest":
                if (isLoggedIn) {
                    response.sendRedirect(contextPath + "/guest.jsp");
                } else {
                    response.sendRedirect(contextPath + "/login.jsp");
                }
                break;

            case "login":
                if (isLoggedIn) {
                    response.sendRedirect(contextPath + "/guest.jsp");
                } else {
                    response.sendRedirect(contextPath + "/login.jsp");
                }
                break;

            case "register":
                if (isLoggedIn) {
                    response.sendRedirect(contextPath + "/guest.jsp");
                } else {
                    response.sendRedirect(contextPath + "/register.jsp");
                }
                break;

            case "book":
            case "booking":
                if (isLoggedIn) {
                    response.sendRedirect(contextPath + "/book_room.jsp");
                } else {
                    request.setAttribute("error", "Please login to book a room.");
                    response.sendRedirect(contextPath + "/login.jsp");
                }
                break;

            case "mybills":
            case "bills":
                if (isLoggedIn) {
                    response.sendRedirect(contextPath + "/my_bills.jsp");
                } else {
                    response.sendRedirect(contextPath + "/login.jsp");
                }
                break;

            case "stafflogin":
            case "staff":
                response.sendRedirect(contextPath + "/stafflogin.jsp");
                break;

            case "logout":
                if (session != null) {
                    session.invalidate();
                }
                response.sendRedirect(contextPath + "/login.jsp");
                break;

            default:
                // If page not found, redirect to appropriate default
                if (isLoggedIn) {
                    response.sendRedirect(contextPath + "/guest.jsp");
                } else {
                    response.sendRedirect(contextPath + "/login.jsp");
                }
                break;
        }
    }
}
