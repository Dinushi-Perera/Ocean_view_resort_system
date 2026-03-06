package controller;

import DAO.BookingDAO;
import DAO.CleaningRequestDAO;
import DAO.GuestDAO;
import DAO.RoomDAO;
import model.Booking;
import util.EmailService;
import model.CleaningRequest;
import model.Guest;
import model.Room;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.LocalDate;
import java.time.YearMonth;
import java.time.temporal.ChronoUnit;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.stream.Collectors;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/manager/*")
public class ManagerServlet extends HttpServlet {
    private BookingDAO bookingDAO;
    private GuestDAO guestDAO;
    private RoomDAO roomDAO;
    private CleaningRequestDAO cleaningRequestDAO;

    @Override
    public void init() {
        bookingDAO = new BookingDAO();
        guestDAO = new GuestDAO();
        roomDAO = new RoomDAO();
        cleaningRequestDAO = new CleaningRequestDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("staffRole") == null) {
            System.out.println("DEBUG: No valid session found, redirecting to login");
            response.sendRedirect(request.getContextPath() + "/stafflogin.jsp?redirect=" + 
                java.net.URLEncoder.encode(request.getRequestURI(), "UTF-8"));
            return;
        }

        String staffRole = (String) session.getAttribute("staffRole");
        System.out.println("DEBUG: Staff role from session: " + staffRole);
        
        if (!"manager".equalsIgnoreCase(staffRole) && !"admin".equalsIgnoreCase(staffRole)) {
            System.out.println("DEBUG: Invalid role for manager dashboard: " + staffRole);
            response.sendRedirect(request.getContextPath() + "/stafflogin.jsp?redirect=" + 
                java.net.URLEncoder.encode(request.getRequestURI(), "UTF-8"));
            return;
        }
        
        // Set staff name for display
        String staffUsername = (String) session.getAttribute("staffUsername");
        if (staffUsername != null) {
            request.setAttribute("staffName", staffUsername);
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
            case "/cleaning":
                showCleaning(request, response);
                break;
            case "/billing":
                showBilling(request, response);
                break;
            case "/monthly-report":
                showMonthlyReport(request, response);
                break;
            case "/help":
                showHelp(request, response);
                break;
            default:
                response.sendRedirect(request.getContextPath() + "/manager/dashboard");
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
        if (!"manager".equalsIgnoreCase(staffRole) && !"admin".equalsIgnoreCase(staffRole)) {
            response.sendRedirect(request.getContextPath() + "/stafflogin.jsp?redirect=" + 
                java.net.URLEncoder.encode(request.getRequestURI(), "UTF-8"));
            return;
        }

        String action = request.getParameter("action");

        if ("checkin".equals(action)) {
            performCheckin(request, response);
        } else if ("checkout".equals(action)) {
            performCheckout(request, response);
        } else if ("searchReservations".equals(action)) {
            searchReservations(request, response);
        } else if ("filterRooms".equals(action)) {
            filterRooms(request, response);
        } else if ("generateBill".equals(action)) {
            generateBill(request, response);
        } else if ("createReservation".equals(action)) {
            createReservation(request, response);
        } else if ("updateReservation".equals(action)) {
            updateReservation(request, response);
        } else if ("updateCleaningStatus".equals(action)) {
            updateCleaningStatus(request, response);
        } else if ("updateCleaningRequest".equals(action)) {
            updateCleaningRequest(request, response);
        }
    }

    private void showDashboard(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            List<Booking> allBookings = bookingDAO.getAllBookings();
            List<Guest> allGuests = guestDAO.getAllGuests();
            
            // Calculate statistics
            Map<String, Integer> stats = calculateDashboardStats(allBookings);
            
            // Get recent reservations (last 10)
            List<Booking> recentBookings = allBookings.stream()
                .sorted((b1, b2) -> b2.getId() - b1.getId())
                .limit(10)
                .collect(Collectors.toList());
            
            request.setAttribute("stats", stats);
            request.setAttribute("recentBookings", recentBookings);
            request.setAttribute("allGuests", allGuests);
            request.setAttribute("currentPage", "dashboard");
            
            request.getRequestDispatcher("/WEB-INF/manager/dashboard-main.jsp").forward(request, response);
        } catch (Exception e) {
            System.err.println("ERROR in showDashboard: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("errorMessage", "Failed to load dashboard: " + e.getMessage());
            request.getRequestDispatcher("/WEB-INF/manager/dashboard.jsp").forward(request, response);
        }
    }

    private void showReservations(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Booking> allBookings = bookingDAO.getAllBookings();
        List<Guest> allGuests = guestDAO.getAllGuests();
        List<Room> allRooms = roomDAO.getAllRooms();
        
        request.setAttribute("allBookings", allBookings);
        request.setAttribute("allGuests", allGuests);
        request.setAttribute("allRooms", allRooms);
        request.setAttribute("currentPage", "reservations");
        request.getRequestDispatcher("/WEB-INF/manager/reservations.jsp").forward(request, response);
    }

    private void showRooms(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Room> allRooms = roomDAO.getAllRooms();
        List<Booking> allBookings = bookingDAO.getAllBookings();
        Map<String, Object> roomData = calculateRoomAvailability(allBookings, allRooms);
        
        request.setAttribute("allRooms", allRooms);
        request.setAttribute("roomData", roomData);
        request.setAttribute("currentPage", "rooms");
        request.getRequestDispatcher("/WEB-INF/manager/dashboard.jsp").forward(request, response);
    }

    private void showCheckin(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Booking> allBookings = bookingDAO.getAllBookings();
        List<Guest> allGuests = guestDAO.getAllGuests();
        LocalDate today = LocalDate.now();
        
        // Filter today's check-ins and check-outs
        List<Booking> todayCheckins = allBookings.stream()
            .filter(b -> b.getCheckIn().equals(today) && 
                    !"checked-in".equals(b.getBookingStatus()) && 
                    !"cancelled".equals(b.getBookingStatus()))
            .collect(Collectors.toList());
        
        List<Booking> todayCheckouts = allBookings.stream()
            .filter(b -> b.getCheckOut().equals(today) && "checked-in".equals(b.getBookingStatus()))
            .collect(Collectors.toList());
        
        request.setAttribute("allBookings", allBookings);
        request.setAttribute("allGuests", allGuests);
        request.setAttribute("todayCheckins", todayCheckins);
        request.setAttribute("todayCheckouts", todayCheckouts);
        request.setAttribute("currentPage", "checkin");
        request.getRequestDispatcher("/WEB-INF/manager/dashboard.jsp").forward(request, response);
    }

    private void showCleaning(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Room> allRooms = roomDAO.getAllRooms();
        List<Booking> allBookings = bookingDAO.getAllBookings();
        List<CleaningRequest> cleaningRequests = cleaningRequestDAO.getAllRequests();
        List<Guest> allGuests = guestDAO.getAllGuests();
        
        request.setAttribute("allRooms", allRooms);
        request.setAttribute("cleaningRequests", cleaningRequests);
        request.setAttribute("allGuests", allGuests);
        request.setAttribute("currentPage", "cleaning");
        request.getRequestDispatcher("/WEB-INF/manager/dashboard.jsp").forward(request, response);
    }

    private void showBilling(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Booking> allBookings = bookingDAO.getAllBookings();
        List<Guest> allGuests = guestDAO.getAllGuests();
        
        // Get bookings that can be billed (all except cancelled and pending)
        List<Booking> billableBookings = allBookings.stream()
            .filter(b -> {
                String status = b.getBookingStatus() != null ? b.getBookingStatus() : "pending";
                return !"cancelled".equals(status) && !"pending".equals(status);
            })
            .collect(Collectors.toList());
        
        // Fetch room prices from database
        Map<String, Double> roomPrices = new HashMap<>();
        roomPrices.put("standard", roomDAO.getRoomPriceByType("standard"));
        roomPrices.put("deluxe", roomDAO.getRoomPriceByType("deluxe"));
        roomPrices.put("suite", roomDAO.getRoomPriceByType("suite"));
        roomPrices.put("presidential", roomDAO.getRoomPriceByType("presidential"));
        
        request.setAttribute("allBookings", billableBookings);
        request.setAttribute("allGuests", allGuests);
        request.setAttribute("roomPrices", roomPrices);
        request.setAttribute("currentPage", "billing");
        request.getRequestDispatcher("/WEB-INF/manager/dashboard.jsp").forward(request, response);
    }

    private void showMonthlyReport(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String monthParam = request.getParameter("month");
        String yearParam  = request.getParameter("year");

        request.setAttribute("selectedMonth", monthParam);
        request.setAttribute("selectedYear",  yearParam);

        int reportMonth = 0, reportYear = 0;
        try { reportMonth = Integer.parseInt(monthParam); } catch (Exception ignored) {}
        try { reportYear  = Integer.parseInt(yearParam);  } catch (Exception ignored) {}

        if (reportMonth > 0 && reportYear > 0) {
            try {
                YearMonth ym    = YearMonth.of(reportYear, reportMonth);
                LocalDate start = ym.atDay(1);
                LocalDate end   = ym.atEndOfMonth();

                // ── Direct SQL JOIN query — no Java-side filtering, no NPE risk ──
                List<Map<String, Object>> dbRows = bookingDAO.getMonthlyBookingsWithGuests(start, end);
                System.out.println("DEBUG showMonthlyReport: " + dbRows.size() + " bookings for " + start + " to " + end);

                List<Map<String, Object>> receiptRows = new ArrayList<>();
                Map<String, Double>  revenueByType  = new LinkedHashMap<>();
                Map<String, Integer> countByType    = new LinkedHashMap<>();
                Map<String, Integer> nightsByType   = new LinkedHashMap<>();
                for (String t : new String[]{"standard","deluxe","suite","presidential"}) {
                    revenueByType.put(t, 0.0);
                    countByType.put(t, 0);
                    nightsByType.put(t, 0);
                }

                double actualSubtotal = 0, actualServiceCharge = 0, actualTax = 0, actualRevenue = 0;
                double projectedRevenue = 0;
                int totalNights = 0, checkedOutCount = 0, confirmedCount = 0;
                int checkedInCount = 0, pendingCount = 0, cancelledCount = 0;

                for (Map<String, Object> dbRow : dbRows) {
                    try {
                        String rt     = (String) dbRow.get("roomType");
                        if (rt == null || rt.isEmpty()) rt = "standard";
                        String status = (String) dbRow.get("bookingStatus");
                        if (status == null || status.isEmpty()) status = "pending";

                        LocalDate ci = (LocalDate) dbRow.get("checkIn");
                        LocalDate co = (LocalDate) dbRow.get("checkOut");
                        if (ci == null) ci = start;
                        if (co == null) co = end;

                        double roomRate = roomDAO.getRoomPriceByType(rt);
                        if (roomRate <= 0) roomRate = 0;

                        long nights = java.time.temporal.ChronoUnit.DAYS.between(ci, co);
                        if (nights <= 0) nights = 1;

                        double subtotal      = nights * roomRate;
                        double serviceCharge = subtotal * 0.10;
                        double tax           = subtotal * 0.12;
                        double total         = subtotal + serviceCharge + tax;

                        Map<String, Object> row = new HashMap<>();
                        row.put("bookingId",       dbRow.get("bookingId"));
                        row.put("guestId",         dbRow.get("guestId"));
                        row.put("guestName",       dbRow.get("guestName"));
                        row.put("guestEmail",      dbRow.get("guestEmail"));
                        row.put("guestContact",    dbRow.get("guestContact"));
                        row.put("guestNic",        dbRow.get("guestNic"));
                        row.put("roomNumber",      dbRow.get("roomNumber"));
                        row.put("roomType",        rt);
                        row.put("numGuests",       dbRow.get("numGuests"));
                        row.put("checkIn",         ci.toString());
                        row.put("checkOut",        co.toString());
                        row.put("nights",          nights);
                        row.put("roomRate",        roomRate);
                        row.put("subtotal",        subtotal);
                        row.put("serviceCharge",   serviceCharge);
                        row.put("tax",             tax);
                        row.put("total",           total);
                        row.put("status",          status);
                        row.put("specialRequests", dbRow.get("specialRequests"));
                        String cat = (String) dbRow.get("createdAt");
                        row.put("createdAt", cat != null && cat.length() > 10 ? cat.substring(0, 10) : (cat != null ? cat : "-"));
                        receiptRows.add(row);

                        if (!"cancelled".equals(status)) {
                            revenueByType.put(rt, revenueByType.getOrDefault(rt, 0.0) + total);
                            countByType.put(rt,   countByType.getOrDefault(rt, 0) + 1);
                            nightsByType.put(rt,  nightsByType.getOrDefault(rt, 0) + (int) nights);
                            totalNights += (int) nights;
                        }

                        switch (status) {
                            case "checked-out":
                                checkedOutCount++;
                                actualSubtotal      += subtotal;
                                actualServiceCharge += serviceCharge;
                                actualTax           += tax;
                                actualRevenue       += total;
                                break;
                            case "checked-in":
                                checkedInCount++;
                                projectedRevenue += total;
                                break;
                            case "confirmed":
                                confirmedCount++;
                                projectedRevenue += total;
                                break;
                            case "cancelled":
                                cancelledCount++;
                                break;
                            default:
                                pendingCount++;
                                break;
                        }
                    } catch (Exception rowErr) {
                        System.err.println("WARN: skipping booking row due to error: " + rowErr.getMessage());
                    }
                }

                Map<String, Object> summary = new HashMap<>();
                summary.put("actualRevenue",       actualRevenue);
                summary.put("actualSubtotal",      actualSubtotal);
                summary.put("actualServiceCharge", actualServiceCharge);
                summary.put("actualTax",           actualTax);
                summary.put("netIncome",           actualRevenue - actualServiceCharge - actualTax);
                summary.put("projectedRevenue",    projectedRevenue);
                summary.put("totalBookings",       receiptRows.size());
                summary.put("totalNights",         totalNights);
                summary.put("checkedOutCount",     checkedOutCount);
                summary.put("confirmedCount",      confirmedCount);
                summary.put("checkedInCount",      checkedInCount);
                summary.put("pendingCount",        pendingCount);
                summary.put("cancelledCount",      cancelledCount);
                summary.put("revenueByType",       revenueByType);
                summary.put("countByType",         countByType);
                summary.put("nightsByType",        nightsByType);
                summary.put("periodStart",         start.toString());
                summary.put("periodEnd",           end.toString());

                request.setAttribute("receiptRows", receiptRows);
                request.setAttribute("summary",     summary);

            } catch (Exception e) {
                System.err.println("ERROR in showMonthlyReport: " + e.getMessage());
                e.printStackTrace();
            }
        }

        request.setAttribute("currentPage", "monthly-report");
        request.getRequestDispatcher("/WEB-INF/manager/monthly_report.jsp").forward(request, response);
    }

    private void showHelp(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setAttribute("currentPage", "help");
        request.getRequestDispatcher("/WEB-INF/manager/dashboard.jsp").forward(request, response);
    }

    // POST Action Handlers
    private void performCheckin(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int bookingId = Integer.parseInt(request.getParameter("bookingId"));
            Booking booking = bookingDAO.getBookingById(bookingId);
            
            if (booking != null) {
                booking.setBookingStatus("checked-in");
                boolean success = bookingDAO.updateBooking(booking);
                
                if (success) {
                    request.setAttribute("successMessage", "Guest checked in successfully!");
                } else {
                    request.setAttribute("errorMessage", "Failed to check in guest.");
                }
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
                boolean success = bookingDAO.updateBooking(booking);
                
                if (success) {
                    request.setAttribute("successMessage", "Guest checked out successfully!");
                } else {
                    request.setAttribute("errorMessage", "Failed to check out guest.");
                }
            }
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error: " + e.getMessage());
        }
        
        showCheckin(request, response);
    }

    private void searchReservations(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String searchQuery = request.getParameter("searchQuery");
        List<Booking> allBookings = bookingDAO.getAllBookings();
        List<Guest> allGuests = guestDAO.getAllGuests();
        List<Room> allRooms = roomDAO.getAllRooms();
        
        if (searchQuery != null && !searchQuery.trim().isEmpty()) {
            String query = searchQuery.toLowerCase();
            allBookings = allBookings.stream()
                .filter(b -> {
                    Guest guest = getGuestById(allGuests, b.getGuestId());
                    String guestName = guest != null ? guest.getFullName().toLowerCase() : "";
                    String guestContact = guest != null ? guest.getContact().toLowerCase() : "";
                    String bookingId = String.valueOf(b.getId());
                    return bookingId.contains(query) || 
                           guestName.contains(query) || 
                           guestContact.contains(query);
                })
                .collect(Collectors.toList());
            request.setAttribute("searchQuery", searchQuery);
        }
        
        request.setAttribute("allBookings", allBookings);
        request.setAttribute("allGuests", allGuests);
        request.setAttribute("allRooms", allRooms);
        request.setAttribute("currentPage", "reservations");
        request.getRequestDispatcher("/WEB-INF/manager/dashboard.jsp").forward(request, response);
    }

    private void filterRooms(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String roomType = request.getParameter("roomType");
        List<Room> allRooms = roomDAO.getAllRooms();
        List<Booking> allBookings = bookingDAO.getAllBookings();
        
        if (roomType != null && !roomType.equals("all")) {
            allRooms = allRooms.stream()
                .filter(r -> r.getRoomType().equalsIgnoreCase(roomType))
                .collect(Collectors.toList());
        }
        
        Map<String, Object> roomData = calculateRoomAvailability(allBookings, allRooms);
        
        request.setAttribute("allRooms", allRooms);
        request.setAttribute("roomData", roomData);
        request.setAttribute("filterRoomType", roomType);
        request.setAttribute("currentPage", "rooms");
        request.getRequestDispatcher("/WEB-INF/manager/dashboard.jsp").forward(request, response);
    }

    private void generateBill(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int bookingId = Integer.parseInt(request.getParameter("bookingId"));
            Booking booking = bookingDAO.getBookingById(bookingId);
            Guest guest = guestDAO.getGuestById(booking.getGuestId());
            
            // Calculate bill
            Map<String, Object> billDetails = calculateBill(booking);
            
            request.setAttribute("booking", booking);
            request.setAttribute("guest", guest);
            request.setAttribute("billDetails", billDetails);
            request.setAttribute("showBill", true);
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error generating bill: " + e.getMessage());
        }
        
        showBilling(request, response);
    }

    private void createReservation(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            // Get or create guest
            String guestName = request.getParameter("guestName");
            String guestContact = request.getParameter("guestContact");
            String guestEmail = request.getParameter("guestEmail");
            String guestNic = request.getParameter("guestNic");
            
            // Check if guest exists
            Guest guest = guestDAO.getGuestByContact(guestContact);
            if (guest == null) {
                // Create new guest
                guest = new Guest();
                // Split name into first and last name
                String[] nameParts = guestName.split(" ", 2);
                guest.setFirstName(nameParts[0]);
                guest.setLastName(nameParts.length > 1 ? nameParts[1] : "");
                guest.setContact(guestContact);
                guest.setEmail(guestEmail);
                guest.setNic(guestNic);
                guest.setPassword(util.PasswordUtil.hashPassword("temp123")); // Temporary hashed password
                
                boolean guestCreated = guestDAO.registerGuest(guest);
                if (!guestCreated) {
                    request.setAttribute("errorMessage", "Failed to create guest record.");
                    showReservations(request, response);
                    return;
                }
            }
            
            // Create booking
            String roomType = request.getParameter("roomType");
            int numGuests = Integer.parseInt(request.getParameter("numGuests"));
            LocalDate checkIn = LocalDate.parse(request.getParameter("checkinDate"));
            LocalDate checkOut = LocalDate.parse(request.getParameter("checkoutDate"));
            String specialRequests = request.getParameter("specialRequests");
            
            // Validate dates
            if (checkOut.isBefore(checkIn) || checkOut.equals(checkIn)) {
                request.setAttribute("errorMessage", "Check-out date must be after check-in date.");
                showReservations(request, response);
                return;
            }
            
            if (checkIn.isBefore(LocalDate.now())) {
                request.setAttribute("errorMessage", "Check-in date cannot be in the past.");
                showReservations(request, response);
                return;
            }
            
            Booking booking = new Booking();
            booking.setGuestId(guest.getId());
            booking.setRoomType(roomType);
            booking.setNumGuests(numGuests);
            booking.setCheckIn(checkIn);
            booking.setCheckOut(checkOut);
            booking.setSpecialRequests(specialRequests);
            booking.setBookingStatus("confirmed");
            
            boolean success = bookingDAO.createBooking(booking);
            
            if (success) {
                request.setAttribute("successMessage", "Reservation created successfully! Booking ID: " + booking.getId());

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
            System.err.println("ERROR in createReservation: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("errorMessage", "An error occurred: " + e.getMessage());
        }
        
        showReservations(request, response);
    }

    private void updateReservation(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int bookingId = Integer.parseInt(request.getParameter("reservationId"));
            Booking booking = bookingDAO.getBookingById(bookingId);
            
            if (booking != null) {
                // Update booking details
                String roomType = request.getParameter("roomType");
                int numGuests = Integer.parseInt(request.getParameter("numGuests"));
                LocalDate checkIn = LocalDate.parse(request.getParameter("checkinDate"));
                LocalDate checkOut = LocalDate.parse(request.getParameter("checkoutDate"));
                String specialRequests = request.getParameter("specialRequests");
                
                booking.setRoomType(roomType);
                booking.setNumGuests(numGuests);
                booking.setCheckIn(checkIn);
                booking.setCheckOut(checkOut);
                booking.setSpecialRequests(specialRequests);
                
                boolean success = bookingDAO.updateBooking(booking);
                
                if (success) {
                    request.setAttribute("successMessage", "Reservation updated successfully!");
                } else {
                    request.setAttribute("errorMessage", "Failed to update reservation.");
                }
            }
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error: " + e.getMessage());
        }
        
        showReservations(request, response);
    }

    private void updateCleaningStatus(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int roomId = Integer.parseInt(request.getParameter("roomId"));
            String newStatus = request.getParameter("status");
            
            Room room = roomDAO.getRoomById(roomId);
            if (room != null) {
                room.setCleaningStatus(newStatus);
                boolean success = roomDAO.updateRoom(room);
                
                if (success) {
                    request.setAttribute("successMessage", "Cleaning status updated successfully!");
                } else {
                    request.setAttribute("errorMessage", "Failed to update cleaning status.");
                }
            }
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error: " + e.getMessage());
        }
        
        showCleaning(request, response);
    }

    private void updateCleaningRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int requestId = Integer.parseInt(request.getParameter("requestId"));
            String newStatus = request.getParameter("newStatus");
            
            if (newStatus != null && !newStatus.trim().isEmpty()) {
                boolean success = cleaningRequestDAO.updateRequestStatus(requestId, newStatus);
                
                if (success) {
                    // If cleaning is completed, update room status to available
                    if ("completed".equals(newStatus)) {
                        CleaningRequest cleaningRequest = cleaningRequestDAO.getRequestById(requestId);
                        if (cleaningRequest != null && cleaningRequest.getRoomNumber() != null) {
                            Room room = roomDAO.getRoomByNumber(cleaningRequest.getRoomNumber());
                            if (room != null) {
                                roomDAO.updateRoomStatus(room.getId(), "available");
                                System.out.println("DEBUG: Room " + room.getRoomNumber() + 
                                    " status updated to 'available' after cleaning completion");
                            }
                        }
                    }
                    
                    request.setAttribute("successMessage", 
                        "Cleaning request #" + requestId + " updated to " + newStatus.toUpperCase());
                } else {
                    request.setAttribute("errorMessage", "Failed to update cleaning request.");
                }
            }
        } catch (Exception e) {
            request.setAttribute("errorMessage", "Error: " + e.getMessage());
            e.printStackTrace();
        }
        
        showCleaning(request, response);
    }

    // Helper methods
    private Map<String, Integer> calculateDashboardStats(List<Booking> bookings) {
        Map<String, Integer> stats = new HashMap<>();
        LocalDate today = LocalDate.now();
        
        int totalRooms = 25; // Total rooms in the hotel
        int occupiedRooms = 0;
        int pendingCheckouts = 0;
        
        for (Booking booking : bookings) {
            String status = booking.getBookingStatus() != null ? booking.getBookingStatus() : "pending";
            
            if ("checked-in".equals(status)) {
                occupiedRooms++;
                if (booking.getCheckOut().equals(today)) {
                    pendingCheckouts++;
                }
            }
        }
        
        stats.put("totalRooms", totalRooms);
        stats.put("occupiedRooms", occupiedRooms);
        stats.put("availableRooms", totalRooms - occupiedRooms);
        stats.put("pendingCheckouts", pendingCheckouts);
        
        return stats;
    }

    private Map<String, Object> calculateRoomAvailability(List<Booking> bookings, List<Room> rooms) {
        Map<String, Object> roomData = new HashMap<>();
        LocalDate today = LocalDate.now();
        
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
        
        // Count total rooms by type
        Map<String, Integer> roomCapacity = new HashMap<>();
        for (Room room : rooms) {
            String type = room.getRoomType().toLowerCase();
            roomCapacity.put(type, roomCapacity.getOrDefault(type, 0) + 1);
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
