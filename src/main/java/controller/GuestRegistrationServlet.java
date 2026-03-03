package controller;

import DAO.GuestDAO;
import model.Guest;
import util.PasswordUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/register")
public class GuestRegistrationServlet extends HttpServlet {
    private GuestDAO guestDAO;

    @Override
    public void init() {
        guestDAO = new GuestDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Get form parameters
        String firstName = request.getParameter("firstName");
        String lastName = request.getParameter("lastName");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String contact = request.getParameter("contact");
        String nic = request.getParameter("nic");

        // Validation
        if (firstName == null || firstName.trim().isEmpty() ||
            lastName == null || lastName.trim().isEmpty() ||
            email == null || email.trim().isEmpty() ||
            password == null || password.trim().isEmpty() ||
            contact == null || contact.trim().isEmpty() ||
            nic == null || nic.trim().isEmpty()) {

            request.setAttribute("error", "All fields are required.");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        // Password validation
        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Passwords do not match.");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        if (password.length() < 6) {
            request.setAttribute("error", "Password must be at least 6 characters long.");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        // Check if email already exists
        if (guestDAO.emailExists(email)) {
            request.setAttribute("error", "Email already registered. Please use a different email or login.");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
            return;
        }

        // Create guest object
        Guest guest = new Guest();
        guest.setFirstName(firstName);
        guest.setLastName(lastName);
        guest.setEmail(email);
        guest.setPassword(PasswordUtil.hashPassword(password)); // Hash password using BCrypt
        guest.setContact(contact);
        guest.setNic(nic);

        // Register the guest
        boolean registered = guestDAO.registerGuest(guest);

        if (registered) {
            request.setAttribute("success", "Registration successful! Please login to continue.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        } else {
            request.setAttribute("error", "Registration failed. Please try again.");
            request.getRequestDispatcher("/register.jsp").forward(request, response);
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/register.jsp").forward(request, response);
    }
}

