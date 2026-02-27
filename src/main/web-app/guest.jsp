<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Guest" %>
<%@ page import="model.Booking" %>
<%@ page import="DAO.BookingDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    // Check if user is logged in
    Guest guest = (Guest) session.getAttribute("guest");
    if (guest == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String guestName = guest.getFullName();
    String guestEmail = guest.getEmail();

    // Fetch all bookings for this guest
    BookingDAO bookingDAO = new BookingDAO();
    List<Booking> bookings = bookingDAO.getBookingsByGuestId(guest.getId());

    // Calculate statistics
    int totalReservations = bookings.size();
    int activeBookings = 0;
    int upcomingBookings = 0;
    LocalDate today = LocalDate.now();

    for (Booking booking : bookings) {
        if (booking.getCheckIn().compareTo(today) <= 0 && booking.getCheckOut().compareTo(today) >= 0) {
            activeBookings++;
        }
        if (booking.getCheckIn().compareTo(today) > 0 &&
            (booking.getBookingStatus().equals("confirmed") || booking.getBookingStatus().equals("pending"))) {
            upcomingBookings++;
        }
    }

    // Date formatter
    DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("MMM dd, yyyy");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Guest Portal - Ocean View Resort</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="style/styles.css">

</head>
<body>
    <!-- Toast Container -->
    <div class="toast-container" id="toastContainer"></div>


    <!-- ============================================
         GUEST DASHBOARD
    ============================================ -->
    <div id="guest-dashboard">
        <!-- Header -->
        <header class="app-header">
            <div class="header-content">
                <div class="header-left">
                    <button class="menu-toggle">&#9776;</button>
                    <div class="app-logo">Ocean View Resort - Guest Portal</div>
                </div>
                <div class="user-info">
                    <span class="user-badge" id="guestRoleBadge">Guest</span>
                    <span id="currentGuest">Welcome, <%= guestName %></span>
                    <form action="<%= request.getContextPath() %>/navigate" method="get" style="display: inline;">
                        <input type="hidden" name="page" value="logout">
                        <button type="submit" class="logout-btn">Logout</button>
                    </form>
                </div>
            </div>
        </header>

        <!-- Sidebar -->
        <nav class="sidebar" id="guestSidebar">
            <ul class="nav-menu">
                <li class="nav-item">
                    <a href="guest.jsp" class="nav-link active">
                        <span class="nav-icon">&#128202;</span>
                        Dashboard
                    </a>
                </li>
                <li class="nav-item">
                    <a href="book_room.jsp" class="nav-link">
                        <span class="nav-icon">&#128716;</span>
                        Book Room
                    </a>
                </li>
                <li class="nav-item">
                    <a href="my_reservations.jsp" class="nav-link">
                        <span class="nav-icon">&#128203;</span>
                        My Reservations
                    </a>
                </li>
                <li class="nav-item">
                    <a href="<%= request.getContextPath() %>/cleaningRequest" class="nav-link">
                        <span class="nav-icon">&#129529;</span>
                        Cleaning Requests
                    </a>
                </li>
                <li class="nav-item">
                    <a href="my_bills.jsp" class="nav-link">
                        <span class="nav-icon">&#128176;</span>
                        My Bills
                    </a>
                </li>
                <li class="nav-item">
                    <a href="help.jsp" class="nav-link">
                        <span class="nav-icon">&#10067;</span>
                        Help & Support
                    </a>
                </li>
            </ul>
        </nav>

        <!-- Main Content -->
        <main class="main-content">
            <!-- Dashboard Section -->
            <section class="page-section active" id="guestDashboard">
                <div class="page-header">
                    <h2 class="page-title">&#128202; Guest Dashboard</h2>
                    <span id="currentDate"></span>
                </div>

                <div class="stats-grid">
                    <div class="stat-card">
                        <div class="stat-number" id="totalGuestReservations"><%= totalReservations %></div>
                        <div class="stat-label">Total Reservations</div>
                    </div>
                    <div class="stat-card success">
                        <div class="stat-number" id="activeBookings"><%= activeBookings %></div>
                        <div class="stat-label">Active Bookings</div>
                    </div>
                    <div class="stat-card warning">
                        <div class="stat-number" id="upcomingBookings"><%= upcomingBookings %></div>
                        <div class="stat-label">Upcoming Stays</div>
                    </div>
                    <div class="stat-card info">
                        <div class="stat-number" id="cleaningRequests">0</div>
                        <div class="stat-label">Service Requests</div>
                    </div>
                </div>

                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">Recent Reservations</h3>
                    </div>
                    <div class="table-container">
                        <table>
                            <thead>
                                <tr>
                                    <th>Reservation #</th>
                                    <th>Room Type</th>
                                    <th>Check-in</th>
                                    <th>Check-out</th>
                                    <th>Status</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody id="guestRecentReservations">
                                <%
                                if (bookings.isEmpty()) {
                                %>
                                    <tr>
                                        <td colspan="6" style="text-align: center; padding: 20px;">No recent reservations</td>
                                    </tr>
                                <%
                                } else {
                                    int count = 0;
                                    for (Booking booking : bookings) {
                                        if (count >= 3) break; // Show only 3 recent bookings
                                        count++;
                                        String statusClass = "";
                                        switch (booking.getBookingStatus().toLowerCase()) {
                                            case "confirmed": statusClass = "status-confirmed"; break;
                                            case "pending": statusClass = "status-pending"; break;
                                            case "checked-in": statusClass = "status-checked-in"; break;
                                            case "checked-out": statusClass = "status-checked-out"; break;
                                            case "cancelled": statusClass = "status-cancelled"; break;
                                            default: statusClass = "status-pending";
                                        }
                                %>
                                    <tr>
                                        <td><strong>#<%= booking.getId() %></strong></td>
                                        <td><%= booking.getRoomType() %></td>
                                        <td><%= booking.getCheckIn().format(dateFormatter) %></td>
                                        <td><%= booking.getCheckOut().format(dateFormatter) %></td>
                                        <td><span class="status-badge <%= statusClass %>"><%= booking.getBookingStatus().toUpperCase() %></span></td>
                                        <td>
                                            <a href="my_reservations.jsp" class="btn-action">View All</a>
                                        </td>
                                    </tr>
                                <%
                                    }
                                }
                                %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </section>

            <!-- New Booking Section -->
            <section class="page-section" id="newBooking">
                <div class="page-header">
                    <h2 class="page-title">&#128716; Book a Room</h2>
                </div>

                <div class="card" style="max-width: 700px;">
                    <div class="card-header">
                        <h3 class="card-title">Make a New Reservation</h3>
                    </div>
                    <form id="newBookingForm" >
                        <div class="modal-form-row">
                            <div class="form-group">
                                <label>Room Type *</label>
                                <select id="guestRoomType" required>
                                    <option value="">Choose room type</option>
                                    <option value="standard">Standard Room - LKR 15,000/night</option>
                                    <option value="deluxe">Deluxe Room - LKR 25,000/night</option>
                                    <option value="suite">Suite - LKR 45,000/night</option>
                                    <option value="presidential">Presidential Suite - LKR 85,000/night</option>
                                </select>
                            </div>
                            <div class="form-group">
                                <label>Number of Guests *</label>
                                <select id="guestNumGuests" required>
                                    <option value="">Select guests</option>
                                    <option value="1">1 Guest</option>
                                    <option value="2">2 Guests</option>
                                    <option value="3">3 Guests</option>
                                    <option value="4">4 Guests</option>
                                    <option value="5">5+ Guests</option>
                                </select>
                            </div>
                        </div>
                        <div class="modal-form-row">
                            <div class="form-group">
                                <label>Check-in Date *</label>
                                <input type="date" id="guestCheckinDate" required>
                            </div>
                            <div class="form-group">
                                <label>Check-out Date *</label>
                                <input type="date" id="guestCheckoutDate" required>
                            </div>
                        </div>
                        <div class="form-group">
                            <label>Special Requests</label>
                            <textarea id="guestSpecialRequests" placeholder="Any special requirements or requests..." rows="3"></textarea>
                        </div>

                        <!-- Booking Summary -->
                        <div id="guestBookingSummary" class="booking-summary" style="display: none;">
                            <h4>Booking Summary</h4>
                            <div id="guestBookingDetails"></div>
                        </div>

                        <button type="submit" class="btn btn-primary">Make Reservation</button>
                    </form>
                </div>
            </section>

            <!-- My Reservations Section -->
            <section class="page-section" id="myReservations">
                <div class="page-header">
                    <h2 class="page-title">&#128203; My Reservations</h2>
                </div>

                <div class="card">
                    <div class="table-container">
                        <table>
                            <thead>
                                <tr>
                                    <th>Reservation #</th>
                                    <th>Room Type</th>
                                    <th>Room #</th>
                                    <th>Check-in</th>
                                    <th>Check-out</th>
                                    <th>Guests</th>
                                    <th>Status</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody id="myReservationsTable">
                                <%
                                if (bookings.isEmpty()) {
                                %>
                                    <tr>
                                        <td colspan="8" style="text-align: center; padding: 20px;">No reservations found</td>
                                    </tr>
                                <%
                                } else {
                                    for (Booking booking : bookings) {
                                        String statusClass = "";
                                        switch (booking.getBookingStatus().toLowerCase()) {
                                            case "confirmed": statusClass = "status-confirmed"; break;
                                            case "pending": statusClass = "status-pending"; break;
                                            case "checked-in": statusClass = "status-checked-in"; break;
                                            case "checked-out": statusClass = "status-checked-out"; break;
                                            case "cancelled": statusClass = "status-cancelled"; break;
                                            default: statusClass = "status-pending";
                                        }

                                        boolean canCancel = booking.getBookingStatus().equalsIgnoreCase("pending") ||
                                                          booking.getBookingStatus().equalsIgnoreCase("confirmed");
                                %>
                                    <tr>
                                        <td><strong>#<%= booking.getId() %></strong></td>
                                        <td><%= booking.getRoomType() %></td>
                                        <td>TBD</td>
                                        <td><%= booking.getCheckIn().format(dateFormatter) %></td>
                                        <td><%= booking.getCheckOut().format(dateFormatter) %></td>
                                        <td><%= booking.getNumGuests() %></td>
                                        <td><span class="status-badge <%= statusClass %>"><%= booking.getBookingStatus().toUpperCase() %></span></td>
                                        <td>
                                            <form method="GET" action="view_booking.jsp" style="display: inline;">
                                                <input type="hidden" name="bookingId" value="<%= booking.getId() %>">
                                                <button type="submit" class="btn-action">View</button>
                                            </form>
                                            <% if (canCancel) { %>
                                                <form method="POST" action="<%= request.getContextPath() %>/api/bookings/cancel" style="display: inline;"
                                                      onsubmit="return confirm('Are you sure you want to cancel this reservation?');">
                                                    <input type="hidden" name="bookingId" value="<%= booking.getId() %>">
                                                    <button type="submit" class="btn-action cancel">Cancel</button>
                                                </form>
                                            <% } %>
                                        </td>
                                    </tr>
                                <%
                                    }
                                }
                                %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </section>

            <!-- Cleaning Requests Section -->
            <section class="page-section" id="cleaningRequests">
                <div class="page-header">
                    <h2 class="page-title">&#129529; Cleaning Requests</h2>
                    <button class="btn btn-primary">+ Request Cleaning</button>
                </div>

                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">My Cleaning Requests</h3>
                    </div>
                    <div id="guestCleaningList"></div>
                </div>
            </section>

            <!-- My Bills Section -->
            <section class="page-section" id="myBills">
                <div class="page-header">
                    <h2 class="page-title">&#128176; My Bills & Invoices</h2>
                </div>

                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">Generate Bill</h3>
                    </div>
                    <div style="max-width: 500px; margin-bottom: 30px; padding: 20px;">
                        <div class="form-group">
                            <label>Select Reservation</label>
                            <select id="guestBillSelect">
                                <option value="">Choose a reservation</option>
                            </select>
                        </div>
                    </div>

                    <div id="guestBillOutput" style="display: none;">
                        <div class="bill-container">
                            <div class="bill-header">
                                <h2>Ocean View Resort</h2>
                                <p>123 Lighthouse Street, Galle Fort, Galle 80000, Sri Lanka</p>
                                <p>Tel: +94 91 223 4567 | Email: info@oceanviewresort.lk</p>
                            </div>
                            <h3 style="text-align: center; margin-bottom: 30px;">GUEST INVOICE</h3>
                            <div id="guestBillDetails"></div>
                            <div style="margin-top: 40px; text-align: center;">
                                <button class="btn btn-primary" >Download Invoice</button>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <!-- Help & Support Section -->
            <section class="page-section" id="guestHelp">
                <div class="page-header">
                    <h2 class="page-title">&#10067; Help & Support</h2>
                </div>

                <div class="help-grid">
                    <div class="help-section">
                        <h3 style="color: var(--primary); margin-bottom: 20px;">Booking & Reservations</h3>
                        <div class="help-item">
                            <span>How do I book a room?</span>
                            <div class="help-content">
                                <p>Navigate to the "Book Room" section, select your preferred room type, choose your check-in and check-out dates, specify the number of guests, and submit the booking form. You'll receive a confirmation with your reservation number.</p>
                            </div>
                        </div>
                        <div class="help-item">
                            <span>Can I modify my reservation?</span>
                            <div class="help-content">
                                <p>Yes, you can modify confirmed reservations from the "My Reservations" section. Click on your reservation and use the "Edit" option. Note that changes are subject to availability and may incur additional charges.</p>
                            </div>
                        </div>
                        <div class="help-item">
                            <span>How do I cancel my booking?</span>
                            <div class="help-content">
                                <p>Go to "My Reservations" and click the "Cancel" button next to your booking. Please note our cancellation policy: cancellations made 24 hours before check-in are fully refundable.</p>
                            </div>
                        </div>
                    </div>

                    <div class="help-section">
                        <h3 style="color: var(--primary); margin-bottom: 20px;">Services & Requests</h3>
                        <div class="help-item">
                            <span>How can I request room cleaning?</span>
                            <div class="help-content">
                                <p>Go to the "Cleaning Requests" section and click "Request Cleaning". Select your reservation and preferred time. Our housekeeping staff will be notified and will service your room accordingly.</p>
                            </div>
                        </div>
                        <div class="help-item">
                            <span>How do I generate my bill?</span>
                            <div class="help-content">
                                <p>Visit the "My Bills" section, select your reservation from the dropdown, and click "Generate Bill". You can download and print your invoice for record-keeping.</p>
                            </div>
                        </div>
                    </div>

                    <div class="help-section">
                        <h3 style="color: var(--primary); margin-bottom: 20px;">Account & Support</h3>
                        <div class="help-item">
                            <span>How do I update my information?</span>
                            <div class="help-content">
                                <p>Your account information can be updated by contacting our front desk at +94 91 223 4567 or info@oceanviewresort.lk. We'll be happy to update your details.</p>
                            </div>
                        </div>
                        <div class="help-item">
                            <span>Need additional assistance?</span>
                            <div class="help-content">
                                <p>Contact our 24/7 front desk: +94 91 223 4567<br>
                                Email: info@oceanviewresort.lk<br>
                                WhatsApp: +94 77 123 4567</p>
                            </div>
                        </div>
                    </div>
                </div>
            </section>
        </main>
    </div>

    <!-- Reservation Detail Modal -->
    <div class="modal-overlay" id="guestReservationModal">
        <div class="modal">
            <div class="modal-header">
                <h3 class="modal-title">Reservation Details</h3>
                <button class="modal-close">&#10005;</button>
            </div>
            <div id="guestReservationContent"></div>
        </div>
    </div>

    <!-- Cleaning Request Modal -->
    <div class="modal-overlay" id="cleaningRequestModal">
        <div class="modal">
            <div class="modal-header">
                <h3 class="modal-title">Request Cleaning Service</h3>
                <button class="modal-close">&#10005;</button>
            </div>
            <form id="cleaningRequestForm">
                <div class="form-group">
                    <label>Select Reservation</label>
                    <select id="cleaningReservationSelect" required>
                        <option value="">Choose a reservation</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Preferred Time</label>
                    <select id="cleaningTime" required>
                        <option value="">Select time</option>
                        <option value="morning">Morning (9:00 AM - 12:00 PM)</option>
                        <option value="afternoon">Afternoon (12:00 PM - 4:00 PM)</option>
                        <option value="evening">Evening (4:00 PM - 7:00 PM)</option>
                    </select>
                </div>
                <div class="form-group">
                    <label>Special Instructions</label>
                    <textarea id="cleaningInstructions" placeholder="Any special cleaning requirements..." rows="3"></textarea>
                </div>
                <div style="display: flex; gap: 10px; margin-top: 20px;">
                    <button type="submit" class="btn btn-primary">Submit Request</button>
                    <button type="button" class="btn btn-secondary">Cancel</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        // Display current date
        document.addEventListener('DOMContentLoaded', function() {
            const options = { weekday: 'long', year: 'numeric', month: 'long', day: 'numeric' };
            const today = new Date().toLocaleDateString('en-US', options);
            const dateElement = document.getElementById('currentDate');
            if (dateElement) {
                dateElement.textContent = today;
            }
        });

        // Menu toggle for mobile
        const menuToggle = document.querySelector('.menu-toggle');
        if (menuToggle) {
            menuToggle.addEventListener('click', function() {
                document.getElementById('guestSidebar').classList.toggle('active');
            });
        }
    </script>
</body>
</html>

