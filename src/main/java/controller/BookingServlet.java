package controller;

import DAO.BookingDAO;
import DAO.GuestDAO;
import DAO.RoomDAO;
import model.Booking;
import model.Guest;
import model.Room;
import util.EmailService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;

@WebServlet("/book")
public class BookingServlet extends HttpServlet {
    private BookingDAO bookingDAO;
    private RoomDAO roomDAO;
    private GuestDAO guestDAO;

    @Override
    public void init() {
        bookingDAO = new BookingDAO();
        roomDAO = new RoomDAO();
        guestDAO = new GuestDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Object guestId = session.getAttribute("guestId");

        if (guestId == null) {
            request.setAttribute("error", "Please login to book a room.");
            response.sendRedirect(request.getContextPath() + "/login.jsp");
            return;
        }

        // Check for AJAX request for available rooms
        String action = request.getParameter("action");
        if ("getAvailableRooms".equals(action)) {
            getAvailableRoomsJSON(request, response);
            return;
        }

        request.getRequestDispatcher("/book_room.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Object guestIdObj = session.getAttribute("guestId");

        // Check if user is logged in
        if (guestIdObj == null) {
            request.setAttribute("error", "Please login to book a room.");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        int guestId = (Integer) guestIdObj;

        // Get form parameters
        String roomType = request.getParameter("roomType");
        String roomIdParam = request.getParameter("roomId");
        String numGuestsStr = request.getParameter("numGuests");
        String checkInStr = request.getParameter("checkIn");
        String checkOutStr = request.getParameter("checkOut");
        String specialRequests = request.getParameter("specialRequests");

        // Validation
        if (roomType == null || roomType.trim().isEmpty()) {
            request.setAttribute("error", "Please select a room type.");
            request.getRequestDispatcher("/book_room.jsp").forward(request, response);
            return;
        }

        if (roomIdParam == null || roomIdParam.trim().isEmpty()) {
            request.setAttribute("error", "Please select a room.");
            request.getRequestDispatcher("/book_room.jsp").forward(request, response);
            return;
        }

        if (numGuestsStr == null || numGuestsStr.trim().isEmpty()) {
            request.setAttribute("error", "Please enter the number of guests.");
            request.getRequestDispatcher("/book_room.jsp").forward(request, response);
            return;
        }

        if (checkInStr == null || checkInStr.trim().isEmpty()) {
            request.setAttribute("error", "Please select a check-in date.");
            request.getRequestDispatcher("/book_room.jsp").forward(request, response);
            return;
        }

        if (checkOutStr == null || checkOutStr.trim().isEmpty()) {
            request.setAttribute("error", "Please select a check-out date.");
            request.getRequestDispatcher("/book_room.jsp").forward(request, response);
            return;
        }

        try {
            int numGuests = Integer.parseInt(numGuestsStr);
            int roomId = Integer.parseInt(roomIdParam);

            if (numGuests <= 0 || numGuests > 10) {
                request.setAttribute("error", "Number of guests must be between 1 and 10.");
                request.getRequestDispatcher("/book_room.jsp").forward(request, response);
                return;
            }

            DateTimeFormatter formatter = DateTimeFormatter.ISO_DATE;
            LocalDate checkIn = LocalDate.parse(checkInStr, formatter);
            LocalDate checkOut = LocalDate.parse(checkOutStr, formatter);

            // Validate dates
            if (checkIn.isBefore(LocalDate.now())) {
                request.setAttribute("error", "Check-in date must be today or in the future.");
                request.getRequestDispatcher("/book_room.jsp").forward(request, response);
                return;
            }

            if (checkOut.isBefore(checkIn) || checkOut.isEqual(checkIn)) {
                request.setAttribute("error", "Check-out date must be after check-in date.");
                request.getRequestDispatcher("/book_room.jsp").forward(request, response);
                return;
            }

            // Verify room is still available
            Room selectedRoom = roomDAO.getRoomById(roomId);
            if (selectedRoom == null) {
                request.setAttribute("error", "Selected room not found.");
                request.getRequestDispatcher("/book_room.jsp").forward(request, response);
                return;
            }

            if (!"available".equalsIgnoreCase(selectedRoom.getStatus())) {
                request.setAttribute("error", "Selected room is no longer available. Please select another room.");
                request.getRequestDispatcher("/book_room.jsp").forward(request, response);
                return;
            }

            // Create booking with room assignment
            Booking booking = new Booking(guestId, roomType, numGuests, checkIn, checkOut, specialRequests);
            booking.setRoomId(roomId);
            booking.setBookingStatus("confirmed");

            if (bookingDAO.createBooking(booking)) {
                // Update room status to occupied
                boolean roomUpdateSuccess = roomDAO.updateRoomStatus(roomId, "occupied");
                
                if (roomUpdateSuccess) {
                    request.setAttribute("success", "Room booked successfully! Your booking ID is: " + booking.getId() + 
                                       ". You have been assigned Room " + selectedRoom.getRoomNumber() + ".");
                } else {
                    System.err.println("WARNING: Booking created but failed to update room status for room ID: " + roomId);
                    request.setAttribute("success", "Room booked successfully! Your booking ID is: " + booking.getId());
                }

                // Send booking confirmation email to the guest
                try {
                    Guest guest = guestDAO.getGuestById(guestId);
                    if (guest != null) {
                        EmailService.sendBookingConfirmation(guest, booking, selectedRoom);
                    }
                } catch (Exception emailEx) {
                    System.err.println("WARNING: Booking confirmed but email notification failed: " + emailEx.getMessage());
                }

                request.setAttribute("bookingId", booking.getId());
                request.getRequestDispatcher("/booking_confirmation.jsp").forward(request, response);
            } else {
                request.setAttribute("error", "Failed to create booking. Please try again.");
                request.getRequestDispatcher("/book_room.jsp").forward(request, response);
            }

        } catch (NumberFormatException e) {
            request.setAttribute("error", "Invalid input format.");
            request.getRequestDispatcher("/book_room.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "An error occurred: " + e.getMessage());
            request.getRequestDispatcher("/book_room.jsp").forward(request, response);
        }
    }

    // API endpoint to get available rooms as JSON
    private void getAvailableRoomsJSON(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        
        try {
            String roomType = request.getParameter("roomType");
            String checkInStr = request.getParameter("checkIn");
            String checkOutStr = request.getParameter("checkOut");
            
            if (roomType == null || checkInStr == null || checkOutStr == null) {
                response.getWriter().write("{\"rooms\": [], \"error\": \"Missing parameters\"}");
                return;
            }
            
            LocalDate checkIn = LocalDate.parse(checkInStr);
            LocalDate checkOut = LocalDate.parse(checkOutStr);
            
            // Get available rooms for the specified dates and type
            List<Room> availableRooms = roomDAO.getAvailableRoomsForDates(roomType, checkIn, checkOut);
            
            // Build JSON response
            StringBuilder json = new StringBuilder();
            json.append("{\"rooms\": [");
            
            for (int i = 0; i < availableRooms.size(); i++) {
                Room room = availableRooms.get(i);
                if (i > 0) json.append(",");
                json.append("{");
                json.append("\"id\": ").append(room.getId()).append(",");
                json.append("\"roomNumber\": \"").append(room.getRoomNumber()).append("\",");
                json.append("\"floor\": ").append(room.getFloor()).append(",");
                json.append("\"pricePerNight\": ").append(room.getPricePerNight()).append(",");
                json.append("\"maxOccupancy\": ").append(room.getMaxOccupancy());
                json.append("}");
            }
            
            json.append("]}");
            response.getWriter().write(json.toString());
            
        } catch (Exception e) {
            System.err.println("ERROR in getAvailableRoomsJSON: " + e.getMessage());
            e.printStackTrace();
            response.getWriter().write("{\"rooms\": [], \"error\": \"" + e.getMessage() + "\"}");
        }
    }
}

