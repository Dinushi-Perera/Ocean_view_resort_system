package controller;

import DAO.BookingDAO;
import DAO.CleaningRequestDAO;
import model.Booking;
import model.CleaningRequest;
import model.Guest;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;

@WebServlet("/cleaningRequest")
public class CleaningRequestServlet extends HttpServlet {
    private CleaningRequestDAO cleaningRequestDAO;
    private BookingDAO bookingDAO;

    @Override
    public void init() {
        cleaningRequestDAO = new CleaningRequestDAO();
        bookingDAO = new BookingDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("guest") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        Guest guest = (Guest) session.getAttribute("guest");
        
        // Get all cleaning requests for this guest
        List<CleaningRequest> requests = cleaningRequestDAO.getRequestsByGuestId(guest.getId());
        request.setAttribute("cleaningRequests", requests);
        
        // Get active bookings for this guest to show room numbers
        List<Booking> activeBookings = bookingDAO.getBookingsByGuestId(guest.getId());
        List<Booking> currentBookings = activeBookings.stream()
            .filter(b -> ("confirmed".equals(b.getBookingStatus()) || 
                         "checked-in".equals(b.getBookingStatus())) &&
                         !b.getCheckOut().isBefore(LocalDate.now()))
            .toList();
        
        request.setAttribute("currentBookings", currentBookings);
        request.setAttribute("guestName", guest.getFullName());
        
        request.getRequestDispatcher("/cleaning_requests.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("guest") == null) {
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        Guest guest = (Guest) session.getAttribute("guest");
        String action = request.getParameter("action");

        if ("create".equals(action)) {
            createCleaningRequest(request, response, guest);
        } else if ("cancel".equals(action)) {
            cancelCleaningRequest(request, response);
        } else {
            doGet(request, response);
        }
    }

    private void createCleaningRequest(HttpServletRequest request, HttpServletResponse response, 
                                      Guest guest) throws ServletException, IOException {
        try {
            String bookingIdStr = request.getParameter("bookingId");
            String roomNumber = request.getParameter("roomNumber");
            String requestType = request.getParameter("requestType");
            String priority = request.getParameter("priority");
            String specialInstructions = request.getParameter("specialInstructions");

            // Validate inputs
            if (roomNumber == null || roomNumber.trim().isEmpty()) {
                request.setAttribute("errorMessage", "Please specify a room number.");
                doGet(request, response);
                return;
            }

            if (requestType == null || requestType.trim().isEmpty()) {
                requestType = "general";
            }

            if (priority == null || priority.trim().isEmpty()) {
                priority = "normal";
            }

            // Create the cleaning request
            CleaningRequest cleaningRequest = new CleaningRequest(
                guest.getId(),
                roomNumber,
                requestType,
                priority,
                specialInstructions
            );

            // Set booking ID if provided
            if (bookingIdStr != null && !bookingIdStr.trim().isEmpty()) {
                try {
                    cleaningRequest.setBookingId(Integer.parseInt(bookingIdStr));
                } catch (NumberFormatException e) {
                    System.err.println("Invalid booking ID: " + bookingIdStr);
                }
            }

            boolean success = cleaningRequestDAO.createRequest(cleaningRequest);

            if (success) {
                request.setAttribute("successMessage", 
                    "Cleaning request submitted successfully! Our staff will attend to it shortly.");
            } else {
                request.setAttribute("errorMessage", 
                    "Failed to submit cleaning request. Please try again.");
            }

        } catch (Exception e) {
            System.err.println("ERROR: Exception while creating cleaning request");
            e.printStackTrace();
            request.setAttribute("errorMessage", 
                "An error occurred while submitting your request: " + e.getMessage());
        }

        doGet(request, response);
    }

    private void cancelCleaningRequest(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        try {
            int requestId = Integer.parseInt(request.getParameter("requestId"));
            
            boolean success = cleaningRequestDAO.updateRequestStatus(requestId, "cancelled");

            if (success) {
                request.setAttribute("successMessage", "Cleaning request cancelled successfully.");
            } else {
                request.setAttribute("errorMessage", "Failed to cancel cleaning request.");
            }

        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error: " + e.getMessage());
        }

        doGet(request, response);
    }
}
