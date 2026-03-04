package controller;

import DAO.BookingDAO;
import model.Booking;
import model.Guest;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;

@WebServlet("/api/bookings/cancel")
public class CancelBookingServlet extends HttpServlet {

    private BookingDAO bookingDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        bookingDAO = new BookingDAO();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");

        try {
            HttpSession session = request.getSession(false);
            if (session == null) {
                sendErrorResponse(response, "Not logged in");
                return;
            }

            Guest guest = (Guest) session.getAttribute("guest");
            if (guest == null) {
                sendErrorResponse(response, "Not logged in");
                return;
            }

            // Get booking ID from request parameter
            String bookingIdParam = request.getParameter("bookingId");
            if (bookingIdParam == null || bookingIdParam.isEmpty()) {
                sendErrorResponse(response, "Booking ID is required");
                return;
            }

            int bookingId;
            try {
                bookingId = Integer.parseInt(bookingIdParam);
            } catch (NumberFormatException e) {
                sendErrorResponse(response, "Invalid booking ID format");
                return;
            }

            // Get the booking to verify ownership
            Booking booking = bookingDAO.getBookingById(bookingId);
            if (booking == null) {
                sendErrorResponse(response, "Booking not found");
                return;
            }

            if (booking.getGuestId() != guest.getId()) {
                sendErrorResponse(response, "Unauthorized access");
                return;
            }

            // Update booking status to cancelled
            boolean success = bookingDAO.updateBookingStatus(bookingId, "cancelled");

            if (success) {
                sendSuccessResponse(response, "Booking cancelled successfully");
            } else {
                sendErrorResponse(response, "Error cancelling booking");
            }

        } catch (Exception e) {
            e.printStackTrace();
            sendErrorResponse(response, "Error: " + e.getMessage());
        }
    }

    private void sendSuccessResponse(HttpServletResponse response, String message) throws IOException {
        PrintWriter out = response.getWriter();
        out.print("{\"success\":true,\"message\":\"" + message + "\"}");
        out.flush();
    }

    private void sendErrorResponse(HttpServletResponse response, String message) throws IOException {
        PrintWriter out = response.getWriter();
        out.print("{\"success\":false,\"message\":\"" + message + "\"}");
        out.flush();
    }
}

