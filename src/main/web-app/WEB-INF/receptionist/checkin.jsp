<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.time.LocalDate, model.Booking, model.Guest" %>
<%
    @SuppressWarnings("unchecked")
    List<Booking> allBookings = (List<Booking>) request.getAttribute("allBookings");
    @SuppressWarnings("unchecked")
    List<Guest> allGuests = (List<Guest>) request.getAttribute("allGuests");
    String message = (String) request.getAttribute("message");
    String error = (String) request.getAttribute("error");
    
    if (allBookings == null) allBookings = new ArrayList<>();
    if (allGuests == null) allGuests = new ArrayList<>();
    
    LocalDate today = LocalDate.now();
    List<Booking> todayCheckIns = new ArrayList<>();
    List<Booking> todayCheckOuts = new ArrayList<>();
    
    for (Booking booking : allBookings) {
        String status = booking.getBookingStatus() != null ? booking.getBookingStatus() : "pending";
        if (booking.getCheckIn().equals(today) && !"cancelled".equals(status) && !"checked-out".equals(status)) {
            todayCheckIns.add(booking);
        }
        if (booking.getCheckOut().equals(today) && "checked-in".equals(status)) {
            todayCheckOuts.add(booking);
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Check-in/Check-out - Ocean View Resort</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/style/styles.css">
    <style>
        .alert { padding: 15px; border-radius: 5px; margin-bottom: 20px; }
        .alert-success { background: #d4edda; color: #155724; border-left: 4px solid #28a745; }
        .alert-danger { background: #f8d7da; color: #721c24; border-left: 4px solid #dc3545; }
        .badge { padding: 5px 10px; border-radius: 12px; font-size: 12px; font-weight: bold; }
        .badge-pending { background: #fff3cd; color: #856404; }
        .badge-confirmed { background: #d4edda; color: #152e57; }
        .badge-checked-in { background: #d1ecf1; color: #0c5460; }
        .badge-checked-out { background: #f8d7da; color: #721c24; }
        .badge-cancelled { background: #f8d7da; color: #721c24; }
        .checkin-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(500px, 1fr)); gap: 20px; margin-bottom: 30px; }
        .checkin-card { background: white; padding: 25px; border-radius: 10px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
        .checkin-card h3 { margin-top: 0; padding-bottom: 15px; border-bottom: 2px solid #e9ecef; }
        .booking-item { padding: 15px; background: #f8f9fa; margin-bottom: 10px; border-radius: 5px; border-left: 4px solid #667eea; }
        .booking-item.checkin { border-left-color: #3528a7; }
        .booking-item.checkout { border-left-color: #dc3545; }
        .booking-info { display: grid; grid-template-columns: 1fr 1fr; gap: 10px; margin-bottom: 10px; font-size: 14px; }
        .booking-info-label { color: #666; }
        .booking-info-value { font-weight: 500; }
        .btn { padding: 10px 20px; border: none; border-radius: 5px; cursor: pointer; font-size: 14px; font-weight: 500; margin-top: 10px; }
        .btn-success { background: #2870a7; color: white; }
        .btn-success:hover { background: #213988; }
        .btn-danger { background: #dc3545; color: white; }
        .btn-danger:hover { background: #c82333; }
        .btn:disabled { background: #6c757d; cursor: not-allowed; opacity: 0.6; }
    </style>
</head>
<body>
    <div class="toast-container" id="toastContainer"></div>

    <div id="guest-dashboard">
        <header class="app-header">
            <div class="header-content">
                <div class="header-left">
                    <button class="menu-toggle">&#9776;</button>
                    <div class="app-logo">Ocean View Resort - Receptionist Portal</div>
                </div>
                <div class="user-info">
                    <span class="user-badge">Receptionist</span>
                    <span>Welcome, <%= session.getAttribute("staffUsername") %></span>
                    <form action="<%= request.getContextPath() %>/staff-logout" method="post" style="display: inline;">
                        <button type="submit" class="logout-btn">Logout</button>
                    </form>
                </div>
            </div>
        </header>

        <nav class="sidebar" id="receptionistSidebar">
            <ul class="nav-menu">
                <li class="nav-item">
                    <a href="<%= request.getContextPath() %>/receptionist/dashboard" class="nav-link">
                        <span class="nav-icon">&#128202;</span>
                        Dashboard
                    </a>
                </li>
                <li class="nav-item">
                    <a href="<%= request.getContextPath() %>/receptionist/reservations" class="nav-link">
                        <span class="nav-icon">&#128203;</span>
                        Reservations
                    </a>
                </li>
                <li class="nav-item">
                    <a href="<%= request.getContextPath() %>/receptionist/rooms" class="nav-link">
                        <span class="nav-icon">&#128716;</span>
                        Room Availability
                    </a>
                </li>
                <li class="nav-item">
                    <a href="<%= request.getContextPath() %>/receptionist/checkin" class="nav-link active">
                        <span class="nav-icon">&#9989;</span>
                        Check-in / Check-out
                    </a>
                </li>
                <li class="nav-item">
                    <a href="<%= request.getContextPath() %>/receptionist/billing" class="nav-link">
                        <span class="nav-icon">&#128176;</span>
                        Billing
                    </a>
                </li>
                <li class="nav-item">
                    <a href="<%= request.getContextPath() %>/receptionist/help" class="nav-link">
                        <span class="nav-icon">&#10067;</span>
                        Help & Guide
                    </a>
                </li>
            </ul>
        </nav>

        <main class="main-content">
            <section class="page-section active">
                <div class="page-header">
                    <h2 class="page-title">&#9989; Check-in / Check-out Management</h2>
                </div>

                <% if (message != null) { %>
            <div class="alert alert-success">✓ <%= message %></div>
        <% } %>
                <% if (error != null) { %>
                    <div class="alert alert-danger">✗ <%= error %></div>
                <% } %>

                <div style="margin-bottom: 20px;">
                    <p style="color: #666;">Today's Date: <strong><%= today %></strong></p>
                </div>

                <div class="checkin-grid">
                    <!-- Today's Check-ins -->
                    <div class="checkin-card">
                        <h3 style="color: #28a745;">&#128229; Today's Check-ins (<%= todayCheckIns.size() %>)</h3>
                        <% if (todayCheckIns.isEmpty()) { %>
                            <p style="color: #999; text-align: center; padding: 20px;">No check-ins scheduled for today</p>
                        <% } else { %>
                            <% for (Booking booking : todayCheckIns) {
                                Guest guest = null;
                                for (Guest g : allGuests) {
                                    if (g.getId() == booking.getGuestId()) {
                                        guest = g;
                                        break;
                                    }
                                }
                                String guestName = (guest != null) ? guest.getFullName() : "Unknown";
                                String status = booking.getBookingStatus() != null ? booking.getBookingStatus() : "pending";
                                boolean canCheckin = !"checked-in".equals(status) && !"checked-out".equals(status);
                            %>
                            <div class="booking-item checkin">
                                <div class="booking-info">
                                    <div class="booking-info-label">Guest:</div>
                                    <div class="booking-info-value"><%= guestName %></div>
                                    <div class="booking-info-label">Booking ID:</div>
                                    <div class="booking-info-value">#<%= booking.getId() %></div>
                                    <div class="booking-info-label">Room Type:</div>
                                    <div class="booking-info-value"><%= booking.getRoomType() %></div>
                                    <div class="booking-info-label">Status:</div>
                                    <div class="booking-info-value"><span class="badge badge-<%= status %>"><%= status.toUpperCase() %></span></div>
                                </div>
                                <form action="<%= request.getContextPath() %>/receptionist/checkin" method="post" style="display: inline;">
                                    <input type="hidden" name="action" value="checkin">
                                    <input type="hidden" name="bookingId" value="<%= booking.getId() %>">
                                    <button type="submit" class="btn btn-success" <%= !canCheckin ? "disabled" : "" %>>
                                        <% if ("checked-in".equals(status)) { %>
                                            Already Checked In
                                        <% } else { %>
                                            Check In Guest
                                        <% } %>
                                    </button>
                                </form>
                            </div>
                            <% } %>
                        <% } %>
                    </div>

                    <!-- Today's Check-outs -->
                    <div class="checkin-card">
                        <h3 style="color: #dc3545;">&#128228; Today's Check-outs (<%= todayCheckOuts.size() %>)</h3>
                        <% if (todayCheckOuts.isEmpty()) { %>
                            <p style="color: #999; text-align: center; padding: 20px;">No check-outs scheduled for today</p>
                        <% } else { %>
                            <% for (Booking booking : todayCheckOuts) {
                                Guest guest = null;
                                for (Guest g : allGuests) {
                                    if (g.getId() == booking.getGuestId()) {
                                        guest = g;
                                        break;
                                    }
                                }
                                String guestName = (guest != null) ? guest.getFullName() : "Unknown";
                            %>
                            <div class="booking-item checkout">
                                <div class="booking-info">
                                    <div class="booking-info-label">Guest:</div>
                                    <div class="booking-info-value"><%= guestName %></div>
                                    <div class="booking-info-label">Booking ID:</div>
                                    <div class="booking-info-value">#<%= booking.getId() %></div>
                                    <div class="booking-info-label">Room Type:</div>
                                    <div class="booking-info-value"><%= booking.getRoomType() %></div>
                                    <div class="booking-info-label">Status:</div>
                                    <div class="booking-info-value"><span class="badge badge-checked-in">CHECKED-IN</span></div>
                                </div>
                                <form action="<%= request.getContextPath() %>/receptionist/checkin" method="post" style="display: inline;">
                                    <input type="hidden" name="action" value="checkout">
                                    <input type="hidden" name="bookingId" value="<%= booking.getId() %>">
                                    <button type="submit" class="btn btn-danger">Check Out Guest</button>
                                </form>
                            </div>
                            <% } %>
                        <% } %>
                    </div>
                </div>

                <!-- All Bookings Table -->
                <div class="card">
                    <h3 class="card-title">All Booking Status</h3>
                    <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Guest Name</th>
                        <th>Room Type</th>
                        <th>Check-in Date</th>
                        <th>Check-out Date</th>
                        <th>Status</th>
                        <th>Actions</th>
                    </tr>
                </thead>
                <tbody>
                    <% for (Booking booking : allBookings) {
                        Guest guest = null;
                        for (Guest g : allGuests) {
                            if (g.getId() == booking.getGuestId()) {
                                guest = g;
                                break;
                            }
                        }
                        String guestName = (guest != null) ? guest.getFullName() : "Unknown";
                        String status = booking.getBookingStatus() != null ? booking.getBookingStatus() : "pending";
                        String badgeClass = "badge-" + status;
                    %>
                    <tr>
                        <td>#<%= booking.getId() %></td>
                        <td><%= guestName %></td>
                        <td><%= booking.getRoomType() %></td>
                        <td><%= booking.getCheckIn() %></td>
                        <td><%= booking.getCheckOut() %></td>
                        <td><span class="badge <%= badgeClass %>"><%= status.toUpperCase() %></span></td>
                        <td>
                            <% if ("pending".equals(status) || "confirmed".equals(status)) { %>
                                <form action="<%= request.getContextPath() %>/receptionist/checkin" method="post" style="display: inline;">
                                    <input type="hidden" name="action" value="checkin">
                                    <input type="hidden" name="bookingId" value="<%= booking.getId() %>">
                                    <button type="submit" class="btn btn-success" style="margin: 0;">Check In</button>
                                </form>
                            <% } else if ("checked-in".equals(status)) { %>
                                <form action="<%= request.getContextPath() %>/receptionist/checkin" method="post" style="display: inline;">
                                    <input type="hidden" name="action" value="checkout">
                                    <input type="hidden" name="bookingId" value="<%= booking.getId() %>">
                                    <button type="submit" class="btn btn-danger" style="margin: 0;">Check Out</button>
                                </form>
                            <% } else { %>
                                <span style="color: #999;">No action</span>
                            <% } %>
                        </td>
                    </tr>
                    <% } %>
                    <% if (allBookings.isEmpty()) { %>
                    <tr>
                        <td colspan="7" style="text-align: center; color: #999; padding: 30px;">No bookings found</td>
                    </tr>
                    <% } %>
                    </tbody>
                    </table>
                </div>
            </section>
        </main>
    </div>

    <script>
        const menuToggle = document.querySelector('.menu-toggle');
        if (menuToggle) {
            menuToggle.addEventListener('click', function() {
                document.getElementById('receptionistSidebar').classList.toggle('active');
            });
        }
    </script>
</body>
</html>
