package controller;

import DAO.BookingDAO;
import DAO.CleaningRequestDAO;
import DAO.GuestDAO;
import DAO.RoomDAO;
import DAO.StaffDAO;
import model.Booking;
import util.EmailService;
import model.CleaningRequest;
import model.Guest;
import model.Room;
import model.Staff;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.*;
import java.util.stream.Collectors;

@WebServlet("/admin/*")
public class AdminServlet extends HttpServlet {

    private BookingDAO bookingDAO;
    private GuestDAO guestDAO;
    private RoomDAO roomDAO;
    private CleaningRequestDAO cleaningRequestDAO;
    private StaffDAO staffDAO;

    @Override
    public void init() {
        bookingDAO = new BookingDAO();
        guestDAO = new GuestDAO();
        roomDAO = new RoomDAO();
        cleaningRequestDAO = new CleaningRequestDAO();
        staffDAO = new StaffDAO();
    }

    // ─── Auth Guard ──────────────────────────────────────────────────────────

    private boolean isAuthorized(HttpServletRequest request, HttpServletResponse response) throws IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("staffRole") == null) {
            response.sendRedirect(request.getContextPath() + "/stafflogin.jsp");
            return false;
        }
        String role = (String) session.getAttribute("staffRole");
        if (!"admin".equalsIgnoreCase(role)) {
            response.sendRedirect(request.getContextPath() + "/stafflogin.jsp");
            return false;
        }
        return true;
    }

    // ─── GET ─────────────────────────────────────────────────────────────────

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isAuthorized(request, response)) return;

        HttpSession session = request.getSession(false);
        String staffUsername = (String) session.getAttribute("staffUsername");
        request.setAttribute("staffName", staffUsername != null ? staffUsername : "Admin");

        String pathInfo = request.getPathInfo();
        if (pathInfo == null || pathInfo.equals("/")) pathInfo = "/dashboard";

        switch (pathInfo) {
            case "/dashboard":  showDashboard(request, response);   break;
            case "/reservations": showReservations(request, response); break;
            case "/rooms":      showRooms(request, response);       break;
            case "/checkin":    showCheckin(request, response);     break;
            case "/cleaning":   showCleaning(request, response);    break;
            case "/billing":    showBilling(request, response);     break;
            case "/staff":      showStaff(request, response);       break;
            case "/help":       showHelp(request, response);        break;
            default:
                response.sendRedirect(request.getContextPath() + "/admin/dashboard");
        }
    }

    // ─── POST ────────────────────────────────────────────────────────────────

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        if (!isAuthorized(request, response)) return;

        HttpSession session = request.getSession(false);
        String staffUsername = (String) session.getAttribute("staffUsername");
        request.setAttribute("staffName", staffUsername != null ? staffUsername : "Admin");

        String action = request.getParameter("action");
        if (action == null) action = "";

        switch (action) {
            // Check-in / Check-out
            case "checkin":             performCheckin(request, response);      break;
            case "checkout":            performCheckout(request, response);     break;
            // Reservations
            case "createReservation":   createReservation(request, response);  break;
            case "updateReservation":   updateReservation(request, response);  break;
            case "cancelReservation":   cancelReservation(request, response);  break;
            case "searchReservations":  searchReservations(request, response); break;
            // Rooms
            case "filterRooms":         filterRooms(request, response);        break;
            // Cleaning
            case "updateCleaningStatus":   updateCleaningStatus(request, response);  break;
            case "updateCleaningRequest":  updateCleaningRequest(request, response); break;
            // Billing
            case "generateBill":        generateBill(request, response);       break;
            // Staff Management
            case "createStaff":         createStaff(request, response);        break;
            case "deleteStaff":         deleteStaff(request, response);        break;
            case "toggleStaff":         toggleStaffStatus(request, response);  break;
            default:
                response.sendRedirect(request.getContextPath() + "/admin/dashboard");
        }
    }

    // ─── Section Renderers ───────────────────────────────────────────────────

    private void showDashboard(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            List<Booking> allBookings = bookingDAO.getAllBookings();
            List<Guest> allGuests = guestDAO.getAllGuests();
            List<Staff> allStaff = staffDAO.getAllStaff();

            Map<String, Integer> stats = calculateDashboardStats(allBookings, allStaff);

            List<Booking> recentBookings = allBookings.stream()
                    .sorted((a, b) -> b.getId() - a.getId())
                    .limit(10)
                    .collect(Collectors.toList());

            request.setAttribute("stats", stats);
            request.setAttribute("recentBookings", recentBookings);
            request.setAttribute("allGuests", allGuests);
            request.setAttribute("currentPage", "dashboard");
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Failed to load dashboard: " + e.getMessage());
        }
        request.getRequestDispatcher("/WEB-INF/admin/dashboard.jsp").forward(request, response);
    }

    private void showReservations(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("allBookings", bookingDAO.getAllBookings());
        request.setAttribute("allGuests",   guestDAO.getAllGuests());
        request.setAttribute("allRooms",    roomDAO.getAllRooms());
        request.setAttribute("currentPage", "reservations");
        request.getRequestDispatcher("/WEB-INF/admin/dashboard.jsp").forward(request, response);
    }

    private void showRooms(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Room> allRooms = roomDAO.getAllRooms();
        List<Booking> allBookings = bookingDAO.getAllBookings();
        request.setAttribute("allRooms",    allRooms);
        request.setAttribute("roomData",    calculateRoomAvailability(allBookings, allRooms));
        request.setAttribute("currentPage", "rooms");
        request.getRequestDispatcher("/WEB-INF/admin/dashboard.jsp").forward(request, response);
    }

    private void showCheckin(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Booking> allBookings = bookingDAO.getAllBookings();
        LocalDate today = LocalDate.now();

        List<Booking> todayCheckins = allBookings.stream()
                .filter(b -> b.getCheckIn().equals(today)
                        && !"checked-in".equals(b.getBookingStatus())
                        && !"cancelled".equals(b.getBookingStatus()))
                .collect(Collectors.toList());

        List<Booking> todayCheckouts = allBookings.stream()
                .filter(b -> b.getCheckOut().equals(today)
                        && "checked-in".equals(b.getBookingStatus()))
                .collect(Collectors.toList());

        request.setAttribute("allBookings",    allBookings);
        request.setAttribute("allGuests",      guestDAO.getAllGuests());
        request.setAttribute("todayCheckins",  todayCheckins);
        request.setAttribute("todayCheckouts", todayCheckouts);
        request.setAttribute("currentPage", "checkin");
        request.getRequestDispatcher("/WEB-INF/admin/dashboard.jsp").forward(request, response);
    }

    private void showCleaning(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("allRooms",         roomDAO.getAllRooms());
        request.setAttribute("cleaningRequests", cleaningRequestDAO.getAllRequests());
        request.setAttribute("allGuests",        guestDAO.getAllGuests());
        request.setAttribute("currentPage", "cleaning");
        request.getRequestDispatcher("/WEB-INF/admin/dashboard.jsp").forward(request, response);
    }

    private void showBilling(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Booking> allBookings = bookingDAO.getAllBookings();
        List<Booking> billable = allBookings.stream()
                .filter(b -> {
                    String s = b.getBookingStatus() != null ? b.getBookingStatus() : "pending";
                    return !"cancelled".equals(s) && !"pending".equals(s);
                })
                .collect(Collectors.toList());

        Map<String, Double> roomPrices = new HashMap<>();
        roomPrices.put("standard",     roomDAO.getRoomPriceByType("standard"));
        roomPrices.put("deluxe",       roomDAO.getRoomPriceByType("deluxe"));
        roomPrices.put("suite",        roomDAO.getRoomPriceByType("suite"));
        roomPrices.put("presidential", roomDAO.getRoomPriceByType("presidential"));

        request.setAttribute("allBookings", billable);
        request.setAttribute("allGuests",   guestDAO.getAllGuests());
        request.setAttribute("roomPrices",  roomPrices);
        request.setAttribute("currentPage", "billing");
        request.getRequestDispatcher("/WEB-INF/admin/dashboard.jsp").forward(request, response);
    }

    private void showStaff(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("allStaff",    staffDAO.getAllStaff());
        request.setAttribute("currentPage", "staff");
        request.getRequestDispatcher("/WEB-INF/admin/dashboard.jsp").forward(request, response);
    }

    private void showHelp(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("currentPage", "help");
        request.getRequestDispatcher("/WEB-INF/admin/dashboard.jsp").forward(request, response);
    }

    // ─── POST Action Handlers ─────────────────────────────────────────────────

    private void performCheckin(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int bookingId = Integer.parseInt(request.getParameter("bookingId"));
            Booking booking = bookingDAO.getBookingById(bookingId);
            if (booking != null) {
                booking.setBookingStatus("checked-in");
                boolean ok = bookingDAO.updateBooking(booking);
                request.setAttribute(ok ? "successMessage" : "errorMessage",
                        ok ? "Guest checked in successfully!" : "Failed to check in guest.");
            }
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error: " + e.getMessage());
        }
        showCheckin(request, response);
    }

    private void performCheckout(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int bookingId = Integer.parseInt(request.getParameter("bookingId"));
            Booking booking = bookingDAO.getBookingById(bookingId);
            if (booking != null) {
                booking.setBookingStatus("checked-out");
                boolean ok = bookingDAO.updateBooking(booking);
                request.setAttribute(ok ? "successMessage" : "errorMessage",
                        ok ? "Guest checked out successfully!" : "Failed to check out guest.");
            }
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error: " + e.getMessage());
        }
        showCheckin(request, response);
    }

    private void createReservation(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String guestName    = request.getParameter("guestName");
            String guestContact = request.getParameter("guestContact");
            String guestEmail   = request.getParameter("guestEmail");
            String guestNic     = request.getParameter("guestNic");

            Guest guest = guestDAO.getGuestByContact(guestContact);
            if (guest == null) {
                guest = new Guest();
                String[] parts = guestName.split(" ", 2);
                guest.setFirstName(parts[0]);
                guest.setLastName(parts.length > 1 ? parts[1] : "");
                guest.setContact(guestContact);
                guest.setEmail(guestEmail);
                guest.setNic(guestNic);
                guest.setPassword(util.PasswordUtil.hashPassword("temp123"));
                if (!guestDAO.registerGuest(guest)) {
                    request.setAttribute("errorMessage", "Failed to create guest record.");
                    showReservations(request, response);
                    return;
                }
            }

            String roomType = request.getParameter("roomType");
            int numGuests   = Integer.parseInt(request.getParameter("numGuests"));
            LocalDate checkIn  = LocalDate.parse(request.getParameter("checkinDate"));
            LocalDate checkOut = LocalDate.parse(request.getParameter("checkoutDate"));

            if (checkOut.isBefore(checkIn) || checkOut.equals(checkIn)) {
                request.setAttribute("errorMessage", "Check-out must be after check-in.");
                showReservations(request, response);
                return;
            }

            Booking booking = new Booking();
            booking.setGuestId(guest.getId());
            booking.setRoomType(roomType);
            booking.setNumGuests(numGuests);
            booking.setCheckIn(checkIn);
            booking.setCheckOut(checkOut);
            booking.setSpecialRequests(request.getParameter("specialRequests"));
            booking.setBookingStatus("confirmed");

            boolean ok = bookingDAO.createBooking(booking);
            if (ok) {
                request.setAttribute("successMessage", "Reservation created! Booking #" + booking.getId());

                // Send confirmation email if requested
                String sendEmail = request.getParameter("sendEmail");
                if ("true".equals(sendEmail)) {
                    try {
                        EmailService.sendBookingConfirmation(guest, booking, null);
                    } catch (Exception emailEx) {
                        System.err.println("WARNING: Reservation created but email notification failed: " + emailEx.getMessage());
                    }
                }
            } else {
                request.setAttribute("errorMessage", "Failed to create reservation.");
            }
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error: " + e.getMessage());
        }
        showReservations(request, response);
    }

    private void updateReservation(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int bookingId = Integer.parseInt(request.getParameter("reservationId"));
            Booking booking = bookingDAO.getBookingById(bookingId);
            if (booking != null) {
                booking.setRoomType(request.getParameter("roomType"));
                booking.setNumGuests(Integer.parseInt(request.getParameter("numGuests")));
                booking.setCheckIn(LocalDate.parse(request.getParameter("checkinDate")));
                booking.setCheckOut(LocalDate.parse(request.getParameter("checkoutDate")));
                booking.setSpecialRequests(request.getParameter("specialRequests"));
                boolean ok = bookingDAO.updateBooking(booking);
                request.setAttribute(ok ? "successMessage" : "errorMessage",
                        ok ? "Reservation updated!" : "Failed to update reservation.");
            }
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error: " + e.getMessage());
        }
        showReservations(request, response);
    }

    private void cancelReservation(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int bookingId = Integer.parseInt(request.getParameter("bookingId"));
            Booking booking = bookingDAO.getBookingById(bookingId);
            if (booking != null) {
                booking.setBookingStatus("cancelled");
                boolean ok = bookingDAO.updateBooking(booking);
                request.setAttribute(ok ? "successMessage" : "errorMessage",
                        ok ? "Reservation cancelled." : "Failed to cancel reservation.");
            }
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error: " + e.getMessage());
        }
        showReservations(request, response);
    }

    private void searchReservations(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String query = request.getParameter("searchQuery");
        List<Booking> allBookings = bookingDAO.getAllBookings();
        List<Guest> allGuests = guestDAO.getAllGuests();

        if (query != null && !query.trim().isEmpty()) {
            final String q = query.toLowerCase();
            allBookings = allBookings.stream()
                    .filter(b -> {
                        Guest g = getGuestFromList(allGuests, b.getGuestId());
                        String name = g != null ? g.getFullName().toLowerCase() : "";
                        String contact = g != null ? g.getContact().toLowerCase() : "";
                        return String.valueOf(b.getId()).contains(q) || name.contains(q) || contact.contains(q);
                    })
                    .collect(Collectors.toList());
            request.setAttribute("searchQuery", query);
        }

        request.setAttribute("allBookings", allBookings);
        request.setAttribute("allGuests",   allGuests);
        request.setAttribute("allRooms",    roomDAO.getAllRooms());
        request.setAttribute("currentPage", "reservations");
        request.getRequestDispatcher("/WEB-INF/admin/dashboard.jsp").forward(request, response);
    }

    private void filterRooms(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String roomType = request.getParameter("roomType");
        List<Room> allRooms = roomDAO.getAllRooms();
        List<Booking> allBookings = bookingDAO.getAllBookings();

        if (roomType != null && !"all".equals(roomType)) {
            final String rt = roomType;
            allRooms = allRooms.stream()
                    .filter(r -> r.getRoomType().equalsIgnoreCase(rt))
                    .collect(Collectors.toList());
        }

        request.setAttribute("allRooms",        allRooms);
        request.setAttribute("roomData",         calculateRoomAvailability(allBookings, allRooms));
        request.setAttribute("filterRoomType",   roomType);
        request.setAttribute("currentPage", "rooms");
        request.getRequestDispatcher("/WEB-INF/admin/dashboard.jsp").forward(request, response);
    }

    private void updateCleaningStatus(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int roomId = Integer.parseInt(request.getParameter("roomId"));
            String newStatus = request.getParameter("status");
            Room room = roomDAO.getRoomById(roomId);
            if (room != null) {
                room.setCleaningStatus(newStatus);
                boolean ok = roomDAO.updateRoom(room);
                request.setAttribute(ok ? "successMessage" : "errorMessage",
                        ok ? "Cleaning status updated!" : "Failed to update cleaning status.");
            }
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error: " + e.getMessage());
        }
        showCleaning(request, response);
    }

    private void updateCleaningRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int requestId  = Integer.parseInt(request.getParameter("requestId"));
            String newStatus = request.getParameter("newStatus");
            if (newStatus != null && !newStatus.isEmpty()) {
                boolean ok = cleaningRequestDAO.updateRequestStatus(requestId, newStatus);
                if (ok && "completed".equals(newStatus)) {
                    CleaningRequest cr = cleaningRequestDAO.getRequestById(requestId);
                    if (cr != null && cr.getRoomNumber() != null) {
                        Room room = roomDAO.getRoomByNumber(cr.getRoomNumber());
                        if (room != null) roomDAO.updateRoomStatus(room.getId(), "available");
                    }
                }
                request.setAttribute(ok ? "successMessage" : "errorMessage",
                        ok ? "Cleaning request #" + requestId + " updated to " + newStatus.toUpperCase()
                           : "Failed to update cleaning request.");
            }
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error: " + e.getMessage());
        }
        showCleaning(request, response);
    }

    private void generateBill(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int bookingId = Integer.parseInt(request.getParameter("bookingId"));
            Booking booking = bookingDAO.getBookingById(bookingId);
            Guest guest = guestDAO.getGuestById(booking.getGuestId());
            request.setAttribute("booking",     booking);
            request.setAttribute("guest",       guest);
            request.setAttribute("billDetails", calculateBill(booking));
            request.setAttribute("showBill",    true);
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error generating bill: " + e.getMessage());
        }
        showBilling(request, response);
    }

    // ─── Staff Management Actions ─────────────────────────────────────────────

    private void createStaff(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String username  = request.getParameter("username");
            String password  = request.getParameter("password");
            String role      = request.getParameter("staffRole");
            String firstName = request.getParameter("firstName");
            String lastName  = request.getParameter("lastName");
            String email     = request.getParameter("email");
            String contact   = request.getParameter("contact");

            if (staffDAO.usernameExists(username)) {
                request.setAttribute("errorMessage", "Username '" + username + "' already exists.");
            } else {
                Staff staff = new Staff(username, password, role, firstName, lastName, email, contact);
                boolean ok = staffDAO.createStaff(staff);
                request.setAttribute(ok ? "successMessage" : "errorMessage",
                        ok ? "Staff member '" + username + "' created successfully!"
                           : "Failed to create staff member.");
            }
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error creating staff: " + e.getMessage());
        }
        showStaff(request, response);
    }

    private void deleteStaff(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int staffId = Integer.parseInt(request.getParameter("staffId"));
            // Don't allow deleting self
            HttpSession session = request.getSession(false);
            String currentUser = (String) session.getAttribute("staffUsername");
            Staff target = staffDAO.getStaffById(staffId);
            if (target != null && target.getUsername().equals(currentUser)) {
                request.setAttribute("errorMessage", "You cannot delete your own account.");
            } else {
                boolean ok = staffDAO.deleteStaff(staffId);
                request.setAttribute(ok ? "successMessage" : "errorMessage",
                        ok ? "Staff member deleted." : "Failed to delete staff member.");
            }
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error deleting staff: " + e.getMessage());
        }
        showStaff(request, response);
    }

    private void toggleStaffStatus(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int staffId = Integer.parseInt(request.getParameter("staffId"));
            boolean ok = staffDAO.toggleStaffStatus(staffId);
            request.setAttribute(ok ? "successMessage" : "errorMessage",
                    ok ? "Staff status toggled." : "Failed to toggle staff status.");
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error: " + e.getMessage());
        }
        showStaff(request, response);
    }

    // ─── Calculation Helpers ──────────────────────────────────────────────────

    private Map<String, Integer> calculateDashboardStats(List<Booking> bookings, List<Staff> staffList) {
        Map<String, Integer> stats = new HashMap<>();
        LocalDate today = LocalDate.now();
        int occupied = 0, pendingCheckouts = 0, todayCheckins = 0;

        for (Booking b : bookings) {
            String s = b.getBookingStatus() != null ? b.getBookingStatus() : "pending";
            if ("checked-in".equals(s)) {
                occupied++;
                if (b.getCheckOut().equals(today)) pendingCheckouts++;
            }
            if (b.getCheckIn().equals(today) && !"cancelled".equals(s) && !"checked-in".equals(s))
                todayCheckins++;
        }

        long activeStaff = staffList.stream().filter(Staff::isActive).count();

        stats.put("totalRooms",       25);
        stats.put("occupiedRooms",    occupied);
        stats.put("availableRooms",   25 - occupied);
        stats.put("pendingCheckouts", pendingCheckouts);
        stats.put("todayCheckins",    todayCheckins);
        stats.put("totalBookings",    bookings.size());
        stats.put("totalStaff",       (int) activeStaff);

        return stats;
    }

    private Map<String, Object> calculateRoomAvailability(List<Booking> bookings, List<Room> rooms) {
        Map<String, Integer> occupied = new HashMap<>();
        Map<String, Integer> capacity = new HashMap<>();

        for (Booking b : bookings) {
            if ("checked-in".equals(b.getBookingStatus())) {
                String t = b.getRoomType().toLowerCase();
                occupied.put(t, occupied.getOrDefault(t, 0) + 1);
            }
        }
        for (Room r : rooms) {
            String t = r.getRoomType().toLowerCase();
            capacity.put(t, capacity.getOrDefault(t, 0) + 1);
        }

        Map<String, Object> data = new HashMap<>();
        data.put("roomCapacity",  capacity);
        data.put("occupiedByType", occupied);
        return data;
    }

    private Map<String, Object> calculateBill(Booking booking) {
        double roomRate  = roomDAO.getRoomPriceByType(booking.getRoomType().toLowerCase());
        long   nights    = ChronoUnit.DAYS.between(booking.getCheckIn(), booking.getCheckOut());
        double subtotal  = nights * roomRate;
        double service   = subtotal * 0.10;
        double tax       = subtotal * 0.12;

        Map<String, Object> bill = new HashMap<>();
        bill.put("nights",        nights);
        bill.put("roomRate",      roomRate);
        bill.put("subtotal",      subtotal);
        bill.put("serviceCharge", service);
        bill.put("tax",           tax);
        bill.put("total",         subtotal + service + tax);
        return bill;
    }

    private Guest getGuestFromList(List<Guest> guests, int guestId) {
        for (Guest g : guests) {
            if (g.getId() == guestId) return g;
        }
        return null;
    }
}
