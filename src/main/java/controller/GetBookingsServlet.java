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
import java.util.List;

@WebServlet("/api/bookings")
public class GetBookingsServlet extends HttpServlet {

    private BookingDAO bookingDAO;

    @Override
    public void init() throws ServletException {
        super.init();
        bookingDAO = new BookingDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
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

            String guestIdParam = request.getParameter("guestId");
            if (guestIdParam == null || guestIdParam.isEmpty()) {
                sendErrorResponse(response, "Guest ID is required");
                return;
            }

            int guestId = Integer.parseInt(guestIdParam);

            // Verify that the guest is only requesting their own bookings
            if (guestId != guest.getId()) {
                sendErrorResponse(response, "Unauthorized access");
                return;
            }

            List<Booking> bookings = bookingDAO.getBookingsByGuestId(guestId);

            // Build JSON response manually
            StringBuilder json = new StringBuilder();
            json.append("{\"success\":true,\"bookings\":[");

            for (int i = 0; i < bookings.size(); i++) {
                Booking booking = bookings.get(i);
                if (i > 0) json.append(",");

                json.append("{");
                json.append("\"id\":").append(booking.getId()).append(",");
                json.append("\"guestId\":").append(booking.getGuestId()).append(",");
                json.append("\"roomType\":\"").append(escapeJson(booking.getRoomType())).append("\",");
                json.append("\"numGuests\":").append(booking.getNumGuests()).append(",");
                json.append("\"checkIn\":\"").append(booking.getCheckIn()).append("\",");
                json.append("\"checkOut\":\"").append(booking.getCheckOut()).append("\",");
                json.append("\"specialRequests\":\"").append(escapeJson(booking.getSpecialRequests())).append("\",");
                json.append("\"bookingStatus\":\"").append(escapeJson(booking.getBookingStatus())).append("\",");
                json.append("\"createdAt\":\"").append(escapeJson(booking.getCreatedAt())).append("\",");
                json.append("\"roomNumber\":\"TBD\"");
                json.append("}");
            }

            json.append("]}");

            PrintWriter out = response.getWriter();
            out.print(json.toString());
            out.flush();

        } catch (NumberFormatException e) {
            sendErrorResponse(response, "Invalid guest ID format");
        } catch (Exception e) {
            e.printStackTrace();
            sendErrorResponse(response, "Error loading bookings: " + e.getMessage());
        }
    }

    private String escapeJson(String str) {
        if (str == null) return "";
        return str.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("\n", "\\n")
                  .replace("\r", "\\r")
                  .replace("\t", "\\t");
    }

    private void sendErrorResponse(HttpServletResponse response, String message) throws IOException {
        PrintWriter out = response.getWriter();
        out.print("{\"success\":false,\"message\":\"" + escapeJson(message) + "\"}");
        out.flush();
    }
}

