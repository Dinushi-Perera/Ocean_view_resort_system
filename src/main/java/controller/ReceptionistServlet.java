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
import java.time.temporal.ChronoUnit;
import java.util.List;
import java.util.stream.Collectors;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/receptionist/*")
public class ReceptionistServlet extends HttpServlet {
    private BookingDAO bookingDAO;
    private GuestDAO guestDAO;
    private RoomDAO roomDAO;

    @Override
    public void init() {
        bookingDAO = new BookingDAO();
        guestDAO = new GuestDAO();
        roomDAO = new RoomDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("staffRole") == null) {
            response.sendRedirect(request.getContextPath() + "/stafflogin.jsp?redirect=" + 
                java.net.URLEncoder.encode(request.getRequestURI(), "UTF-8"));
            return;
        }

        String staffRole = (String) session.getAttribute("staffRole");
        if (!"receptionist".equalsIgnoreCase(staffRole) && !"admin".equalsIgnoreCase(staffRole)) {
            response.sendRedirect(request.getContextPath() + "/stafflogin.jsp?redirect=" + 
                java.net.URLEncoder.encode(request.getRequestURI(), "UTF-8"));
            return;
        }

        // Check for AJAX request for available rooms
        String action = request.getParameter("action");
        if ("getAvailableRooms".equals(action)) {
            getAvailableRoomsJSON(request, response);
            return;
        }

        String pathInfo = request.getPathInfo();
        if (pathInfo == null) {
            pathInfo = "/dashboard";
        }

        switch (pathInfo) {
            case "/dashboard":
                showDashboard(request, response);
                break;
            case "/reservations":
                showReservations(request, response);
                break;
            case "/rooms":
                showRooms(request, response);
                break;
            case "/checkin":
                showCheckin(request, response);
                break;
            case "/billing":
                showBilling(request, response);
                break;
            case "/help":
                showHelp(request, response);
                break;
            case "/book-room":
                showBookingForm(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/receptionist/dashboard");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("staffRole") == null) {
            response.sendRedirect(request.getContextPath() + "/stafflogin.jsp?redirect=" + 
                java.net.URLEncoder.encode(request.getRequestURI(), "UTF-8"));
            return;
        }

        String staffRole = (String) session.getAttribute("staffRole");
        if (!"receptionist".equalsIgnoreCase(staffRole) && !"admin".equalsIgnoreCase(staffRole)) {
            response.sendRedirect(request.getContextPath() + "/stafflogin.jsp?redirect=" + 
                java.net.URLEncoder.encode(request.getRequestURI(), "UTF-8"));
            return;
        }

        String action = request.getParameter("action");

        if ("checkin".equals(action)) {
            performCheckin(request, response);
        } else if ("checkout".equals(action)) {
            performCheckout(request, response);
        } else if ("search".equals(action)) {
            searchReservations(request, response);
        } else if ("filterRooms".equals(action)) {
            filterRooms(request, response);
        } else if ("generateBill".equals(action)) {
            generateBill(request, response);
        } else if ("createBooking".equals(action)) {
            createBooking(request, response);
        }
    }

    private void showDashboard(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            List<Booking> allBookings = bookingDAO.getAllBookings();
            List<Guest> allGuests = guestDAO.getAllGuests();
            
            // Calculate statistics
            Map<String, Integer> stats = calculateDashboardStats(allBookings);
            request.setAttribute("stats", stats);
            request.setAttribute("allBookings", allBookings);
            request.setAttribute("allGuests", allGuests);
            
            request.getRequestDispatcher("/WEB-INF/receptionist/dashboard.jsp").forward(request, response);
        } catch (Exception e) {
            System.err.println("ERROR in showDashboard: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("errorMessage", "Failed to load dashboard: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/receptionist/dashboard.jsp").forward(request, response);
        }
    }

    private void showReservations(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Booking> allBookings = bookingDAO.getAllBookings();
        List<Guest> allGuests = guestDAO.getAllGuests();
        request.setAttribute("allBookings", allBookings);
        request.setAttribute("allGuests", allGuests);
        request.getRequestDispatcher("/WEB-INF/receptionist/reservations.jsp").forward(request, response);
    }

    private void showRooms(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Room> allRooms = roomDAO.getAllRooms();
        List<Booking> allBookings = bookingDAO.getAllBookings();
        Map<String, Object> roomData = calculateRoomAvailability(allBookings);
        
        request.setAttribute("allRooms", allRooms);
        request.setAttribute("roomData", roomData);
        request.getRequestDispatcher("/WEB-INF/receptionist/rooms.jsp").forward(request, response);
    }

    private void showBookingForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Guest> allGuests = guestDAO.getAllGuests();
        List<Room> allRooms = roomDAO.getAllRooms();
        
        request.setAttribute("allGuests", allGuests);
        request.setAttribute("allRooms", allRooms);
        request.getRequestDispatcher("/WEB-INF/receptionist/book-room.jsp").forward(request, response);
    }

    private void showCheckin(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Booking> allBookings = bookingDAO.getAllBookings();
        List<Guest> allGuests = guestDAO.getAllGuests();
        request.setAttribute("allBookings", allBookings);
        request.setAttribute("allGuests", allGuests);
        request.getRequestDispatcher("/WEB-INF/receptionist/checkin.jsp").forward(request, response);
    }

    private void showBilling(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Booking> allBookings = bookingDAO.getAllBookings();
        List<Guest> allGuests = guestDAO.getAllGuests();
        request.setAttribute("allBookings", allBookings);
        request.setAttribute("allGuests", allGuests);
        request.getRequestDispatcher("/WEB-INF/receptionist/billing.jsp").forward(request, response);
    }

    private void showHelp(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/receptionist/help.jsp").forward(request, response);
    }

    private void performCheckin(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int bookingId = Integer.parseInt(request.getParameter("bookingId"));
            Booking booking = bookingDAO.getBookingById(bookingId);
            
            if (booking == null) {
                request.setAttribute("error", "Booking not found.");
                showCheckin(request, response);
                return;
            }
            
            boolean success = bookingDAO.updateBookingStatus(bookingId, "checked-in");

            if (success) {
                // Update room status to occupied if room is assigned
                if (booking.getRoomId() != null) {
                    boolean roomUpdateSuccess = roomDAO.updateRoomStatus(booking.getRoomId(), "occupied");
                    if (roomUpdateSuccess) {
                        request.setAttribute("message", "Guest checked in successfully! Room marked as occupied.");
                    } else {
                        request.setAttribute("message", "Guest checked in successfully! (Room status update warning)");
                    }
                } else {
                    request.setAttribute("message", "Guest checked in successfully!");
                }
            } else {
                request.setAttribute("error", "Failed to check in guest.");
            }

            showCheckin(request, response);
        } catch (Exception e) {
            System.err.println("ERROR in performCheckin: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "An error occurred during check-in.");
            showCheckin(request, response);
        }
    }

    private void performCheckout(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int bookingId = Integer.parseInt(request.getParameter("bookingId"));
            Booking booking = bookingDAO.getBookingById(bookingId);
            
            if (booking == null) {
                request.setAttribute("error", "Booking not found.");
                showCheckin(request, response);
                return;
            }
            
            boolean success = bookingDAO.updateBookingStatus(bookingId, "checked-out");

            if (success) {
                // Update room status to cleaning if room is assigned
                if (booking.getRoomId() != null) {
                    boolean roomUpdateSuccess = roomDAO.updateRoomStatus(booking.getRoomId(), "cleaning");
                    if (roomUpdateSuccess) {
                        request.setAttribute("message", "Guest checked out successfully! Room marked for cleaning.");
                    } else {
                        request.setAttribute("message", "Guest checked out successfully! (Room status update warning)");
                    }
                } else {
                    request.setAttribute("message", "Guest checked out successfully!");
                }

                // Send bill email to the guest
                try {
                    Guest guest = guestDAO.getGuestById(booking.getGuestId());
                    Room room = (booking.getRoomId() != null) ? roomDAO.getRoomById(booking.getRoomId()) : null;
                    Map<String, Object> billDetails = calculateBill(booking);
                    if (guest != null) {
                        EmailService.sendCheckoutBill(guest, booking, room, billDetails);
                    }
                } catch (Exception emailEx) {
                    System.err.println("WARNING: Checkout successful but bill email failed: " + emailEx.getMessage());
                }
            } else {
                request.setAttribute("error", "Failed to check out guest.");
            }

            showCheckin(request, response);
        } catch (Exception e) {
            System.err.println("ERROR in performCheckout: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "An error occurred during checkout.");
            showCheckin(request, response);
        }
    }

    private void searchReservations(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String searchQuery = request.getParameter("searchQuery");
        List<Booking> allBookings = bookingDAO.getAllBookings();
        List<Guest> allGuests = guestDAO.getAllGuests();
        
        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
            allBookings = allBookings.stream()
                .filter(b -> {
                    Guest guest = getGuestById(allGuests, b.getGuestId());
                    String guestName = guest != null ? guest.getFullName().toLowerCase() : "";
                    String bookingId = String.valueOf(b.getId());
                    return bookingId.contains(searchQuery) || guestName.contains(searchQuery.toLowerCase());
                })
                .collect(Collectors.toList());
            request.setAttribute("searchQuery", searchQuery);
        }
        
        request.setAttribute("allBookings", allBookings);
        request.setAttribute("allGuests", allGuests);
        request.getRequestDispatcher("/WEB-INF/receptionist/reservations.jsp").forward(request, response);
    }

    private void filterRooms(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String roomType = request.getParameter("roomType");
        List<Booking> allBookings = bookingDAO.getAllBookings();
        Map<String, Object> roomData = calculateRoomAvailability(allBookings);
        
        request.setAttribute("roomData", roomData);
        request.setAttribute("filterRoomType", roomType);
        request.getRequestDispatcher("/WEB-INF/receptionist/rooms.jsp").forward(request, response);
    }

    private void generateBill(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        int bookingId = Integer.parseInt(request.getParameter("bookingId"));
        Booking booking = bookingDAO.getBookingById(bookingId);
        Guest guest = guestDAO.getGuestById(booking.getGuestId());
        
        // Calculate bill
        Map<String, Object> billDetails = calculateBill(booking);
        
        request.setAttribute("booking", booking);
        request.setAttribute("guest", guest);
        request.setAttribute("billDetails", billDetails);
        request.setAttribute("showBill", true);
        
        List<Booking> allBookings = bookingDAO.getAllBookings();
        List<Guest> allGuests = guestDAO.getAllGuests();
        request.setAttribute("allBookings", allBookings);
        request.setAttribute("allGuests", allGuests);
        
        request.getRequestDispatcher("/WEB-INF/receptionist/billing.jsp").forward(request, response);
    }

    private void createBooking(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int guestId = Integer.parseInt(request.getParameter("guestId"));
            String roomType = request.getParameter("roomType");
            String roomIdParam = request.getParameter("roomId");
            int numGuests = Integer.parseInt(request.getParameter("numGuests"));
            LocalDate checkIn = LocalDate.parse(request.getParameter("checkIn"));
            LocalDate checkOut = LocalDate.parse(request.getParameter("checkOut"));
            String specialRequests = request.getParameter("specialRequests");
            
            // Validate dates
            if (checkOut.isBefore(checkIn) || checkOut.equals(checkIn)) {
                request.setAttribute("error", "Check-out date must be after check-in date.");
                showBookingForm(request, response);
                return;
            }
            
            if (checkIn.isBefore(LocalDate.now())) {
                request.setAttribute("error", "Check-in date cannot be in the past.");
                showBookingForm(request, response);
                return;
            }
            
            // Validate room selection
            if (roomIdParam == null || roomIdParam.trim().isEmpty()) {
                request.setAttribute("error", "Please select a room.");
                showBookingForm(request, response);
                return;
            }
            
            int roomId = Integer.parseInt(roomIdParam);
            
            // Verify room is still available
            Room selectedRoom = roomDAO.getRoomById(roomId);
            if (selectedRoom == null) {
                request.setAttribute("error", "Selected room not found.");
                showBookingForm(request, response);
                return;
            }
            
            if (!"available".equalsIgnoreCase(selectedRoom.getStatus())) {
                request.setAttribute("error", "Selected room is no longer available.");
                showBookingForm(request, response);
                return;
            }
            
            // Create booking with room assignment
            Booking booking = new Booking();
            booking.setGuestId(guestId);
            booking.setRoomId(roomId);
            booking.setRoomType(roomType);
            booking.setNumGuests(numGuests);
            booking.setCheckIn(checkIn);
            booking.setCheckOut(checkOut);
            booking.setSpecialRequests(specialRequests);
            booking.setBookingStatus("confirmed");
            
            boolean bookingSuccess = bookingDAO.createBooking(booking);
            
            if (bookingSuccess) {
                // Update room status to occupied
                boolean roomUpdateSuccess = roomDAO.updateRoomStatus(roomId, "occupied");
                
                if (roomUpdateSuccess) {
                    request.setAttribute("message", "Booking created successfully! Booking ID: " + booking.getId() + 
                                       " - Room " + selectedRoom.getRoomNumber() + " has been assigned and marked as occupied.");
                } else {
                    System.err.println("WARNING: Booking created but failed to update room status for room ID: " + roomId);
                    request.setAttribute("message", "Booking created successfully! Booking ID: " + booking.getId() + 
                                       " (Note: Room status update warning)");
                }

                // Send booking confirmation email if the staff checked the checkbox
                String sendEmail = request.getParameter("sendEmail");
                if ("true".equals(sendEmail)) {
                    try {
                        Guest bookingGuest = guestDAO.getGuestById(guestId);
                        if (bookingGuest != null) {
                            EmailService.sendBookingConfirmation(bookingGuest, booking, selectedRoom);
                        }
                    } catch (Exception emailEx) {
                        System.err.println("WARNING: Booking created but email notification failed: " + emailEx.getMessage());
                    }
                }

                showReservations(request, response);
            } else {
                request.setAttribute("error", "Failed to create booking. Please try again.");
                showBookingForm(request, response);
            }
            
        } catch (NumberFormatException e) {
            System.err.println("ERROR in createBooking: Invalid number format - " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "Invalid input format.");
            showBookingForm(request, response);
        } catch (Exception e) {
            System.err.println("ERROR in createBooking: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("error", "An error occurred: " + e.getMessage());
            showBookingForm(request, response);
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

    // Helper methods
    private Map<String, Integer> calculateDashboardStats(List<Booking> bookings) {
        Map<String, Integer> stats = new HashMap<>();
        LocalDate today = LocalDate.now();
        
        int totalRooms = 25; // Total rooms in the hotel
        int occupiedRooms = 0;
        int pendingCheckouts = 0;
        int todayCheckins = 0;
        
        for (Booking booking : bookings) {
            String status = booking.getBookingStatus() != null ? booking.getBookingStatus() : "pending";
            
            if ("checked-in".equals(status)) {
                occupiedRooms++;
                if (booking.getCheckOut().equals(today)) {
                    pendingCheckouts++;
                }
            }
            
            if (booking.getCheckIn().equals(today) && !"cancelled".equals(status)) {
                todayCheckins++;
            }
        }
        
        stats.put("totalRooms", totalRooms);
        stats.put("occupiedRooms", occupiedRooms);
        stats.put("availableRooms", totalRooms - occupiedRooms);
        stats.put("pendingCheckouts", pendingCheckouts);
        stats.put("todayCheckins", todayCheckins);
        
        return stats;
    }

    private Map<String, Object> calculateRoomAvailability(List<Booking> bookings) {
        Map<String, Object> roomData = new HashMap<>();
        LocalDate today = LocalDate.now();
        
        // Room type capacity
        Map<String, Integer> roomCapacity = new HashMap<>();
        roomCapacity.put("standard", 10);
        roomCapacity.put("deluxe", 8);
        roomCapacity.put("suite", 5);
        roomCapacity.put("presidential", 2);
        
        // Count occupied rooms by type
        Map<String, Integer> occupiedByType = new HashMap<>();
        occupiedByType.put("standard", 0);
        occupiedByType.put("deluxe", 0);
        occupiedByType.put("suite", 0);
        occupiedByType.put("presidential", 0);
        
        for (Booking booking : bookings) {
            if ("checked-in".equals(booking.getBookingStatus())) {
                String type = booking.getRoomType().toLowerCase();
                occupiedByType.put(type, occupiedByType.getOrDefault(type, 0) + 1);
            }
        }
        
        roomData.put("roomCapacity", roomCapacity);
        roomData.put("occupiedByType", occupiedByType);
        
        return roomData;
    }

    private Map<String, Object> calculateBill(Booking booking) {
        Map<String, Object> billDetails = new HashMap<>();
        
        // Fetch actual room rate from database
        double roomRate = roomDAO.getRoomPriceByType(booking.getRoomType().toLowerCase());
        
        long nights = ChronoUnit.DAYS.between(booking.getCheckIn(), booking.getCheckOut());
        double subtotal = nights * roomRate;
        double serviceCharge = subtotal * 0.10; // 10% service charge
        double tax = subtotal * 0.12; // 12% tax
        double total = subtotal + serviceCharge + tax;
        
        billDetails.put("nights", nights);
        billDetails.put("roomRate", roomRate);
        billDetails.put("subtotal", subtotal);
        billDetails.put("serviceCharge", serviceCharge);
        billDetails.put("tax", tax);
        billDetails.put("total", total);
        
        return billDetails;
    }

    private Guest getGuestById(List<Guest> guests, int guestId) {
        for (Guest guest : guests) {
            if (guest.getId() == guestId) {
                return guest;
            }
        }
        return null;
    }
}
