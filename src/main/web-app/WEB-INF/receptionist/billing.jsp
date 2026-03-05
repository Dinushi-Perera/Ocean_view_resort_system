<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, model.Booking, model.Guest" %>
<%
    @SuppressWarnings("unchecked")
    List<Booking> allBookings = (List<Booking>) request.getAttribute("allBookings");
    @SuppressWarnings("unchecked")
    List<Guest> allGuests = (List<Guest>) request.getAttribute("allGuests");
    
    Booking selectedBooking = (Booking) request.getAttribute("booking");
    Guest selectedGuest = (Guest) request.getAttribute("guest");
    @SuppressWarnings("unchecked")
    Map<String, Object> billDetails = (Map<String, Object>) request.getAttribute("billDetails");
    Boolean showBill = (Boolean) request.getAttribute("showBill");
    
    if (allBookings == null) allBookings = new ArrayList<>();
    if (allGuests == null) allGuests = new ArrayList<>();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Billing & Invoices - Ocean View Resort</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/style/styles.css">
    <style>
        .form-group { margin-bottom: 20px; }
        .form-group label { display: block; margin-bottom: 8px; font-weight: 500; color: #333; }
        .form-select { width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 5px; font-size: 14px; }
        .btn { padding: 12px 25px; border: none; border-radius: 5px; cursor: pointer; font-size: 14px; font-weight: 500; }
        .btn-primary { background: #667eea; color: white; }
        .btn-primary:hover { background: #5568d3; }
        .btn-success { background: #1b43d1; color: white; }
        .btn-success:hover { background: #405ed6; }
        .bill-container { background: white; padding: 40px; border-radius: 10px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); max-width: 800px; margin: 0 auto; }
        .bill-header { text-align: center; border-bottom: 3px solid #667eea; padding-bottom: 20px; margin-bottom: 30px; }
        .bill-header h2 { margin: 0 0 10px 0; color: #667eea; font-size: 28px; }
        .bill-header p { margin: 5px 0; color: #666; font-size: 14px; }
        .bill-section { margin-bottom: 30px; }
        .bill-section h3 { margin-bottom: 15px; color: #333; font-size: 18px; border-bottom: 2px solid #e9ecef; padding-bottom: 10px; }
        .bill-row { display: flex; justify-content: space-between; padding: 10px 0; border-bottom: 1px solid #e9ecef; }
        .bill-row.total { background: #f8f9fa; padding: 15px; margin-top: 15px; border: 2px solid #667eea; border-radius: 5px; font-size: 18px; font-weight: bold; }
        .bill-label { color: #666; }
        .bill-value { font-weight: 500; color: #333; }
        @media print {
            .header, .nav-menu, .no-print, .sidebar, .app-header, .page-header, .menu-toggle { display: none !important; }
            body { background: white; margin: 0; padding: 0; }
            .main-content { margin-left: 0; padding: 0; }
            .page-section { padding: 0; margin: 0; }
            .bill-container { 
                box-shadow: none; 
                padding: 20px; 
                margin: 0;
                max-width: 100%;
                page-break-inside: avoid;
            }
            .bill-header, .bill-section { page-break-inside: avoid; }
        }
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
                    <a href="<%= request.getContextPath() %>/receptionist/checkin" class="nav-link">
                        <span class="nav-icon">&#9989;</span>
                        Check-in / Check-out
                    </a>
                </li>
                <li class="nav-item">
                    <a href="<%= request.getContextPath() %>/receptionist/billing" class="nav-link active">
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
                <div class="page-header no-print">
                    <h2 class="page-title">&#128176; Billing & Invoices</h2>
                </div>

                <div class="no-print">
                    <div class="card" style="max-width: 600px;">
                        <h3 class="card-title">Select Reservation</h3>
                        <form action="<%= request.getContextPath() %>/receptionist/billing" method="post">
                            <input type="hidden" name="action" value="generateBill">
                            <div class="form-group">
                                <label for="bookingId">Choose a reservation to generate bill:</label>
                                <select name="bookingId" id="bookingId" class="form-select" required>
                                    <option value="">-- Select a Booking --</option>
                                    <% for (Booking booking : allBookings) {
                                        String status = booking.getBookingStatus() != null ? booking.getBookingStatus() : "pending";
                                        if (!"cancelled".equals(status)) {
                                            Guest guest = null;
                                            for (Guest g : allGuests) {
                                                if (g.getId() == booking.getGuestId()) {
                                                    guest = g;
                                                    break;
                                                }
                                            }
                                            String guestName = (guest != null) ? guest.getFullName() : "Unknown";
                                    %>
                                    <option value="<%= booking.getId() %>" <%= (selectedBooking != null && selectedBooking.getId() == booking.getId()) ? "selected" : "" %>>
                                        #<%= booking.getId() %> - <%= guestName %> - <%= booking.getRoomType() %> (<%= booking.getCheckIn() %> to <%= booking.getCheckOut() %>)
                                    </option>
                                    <% 
                                        }
                                    } %>
                                </select>
                            </div>
                            <button type="submit" class="btn btn-primary">Generate Bill</button>
                        </form>
                    </div>
                </div>

                <% if (showBill != null && showBill && selectedBooking != null && selectedGuest != null && billDetails != null) { %>
        <div class="bill-container">
            <div class="bill-header">
                <h2>&#127958; OCEAN VIEW RESORT</h2>
                <p>123 Lighthouse Street, Galle Fort</p>
                <p>Galle 80000, Sri Lanka</p>
                <p>Tel: +94 91 223 4567 | Email: info@oceanviewresort.lk</p>
            </div>

            <h3 style="text-align: center; margin-bottom: 30px; color: #667eea;">TAX INVOICE</h3>

            <div class="bill-section">
                <h3>Guest Information</h3>
                <div class="bill-row">
                    <span class="bill-label">Guest Name:</span>
                    <span class="bill-value"><%= selectedGuest.getFullName() %></span>
                </div>
                <div class="bill-row">
                    <span class="bill-label">Email:</span>
                    <span class="bill-value"><%= selectedGuest.getEmail() %></span>
                </div>
                <div class="bill-row">
                    <span class="bill-label">Contact:</span>
                    <span class="bill-value"><%= selectedGuest.getContact() %></span>
                </div>
                <div class="bill-row">
                    <span class="bill-label">NIC:</span>
                    <span class="bill-value"><%= selectedGuest.getNic() %></span>
                </div>
            </div>

            <div class="bill-section">
                <h3>Booking Details</h3>
                <div class="bill-row">
                    <span class="bill-label">Reservation ID:</span>
                    <span class="bill-value">#<%= selectedBooking.getId() %></span>
                </div>
                <div class="bill-row">
                    <span class="bill-label">Room Type:</span>
                    <span class="bill-value"><%= selectedBooking.getRoomType().toUpperCase() %></span>
                </div>
                <div class="bill-row">
                    <span class="bill-label">Number of Guests:</span>
                    <span class="bill-value"><%= selectedBooking.getNumGuests() %></span>
                </div>
                <div class="bill-row">
                    <span class="bill-label">Check-in Date:</span>
                    <span class="bill-value"><%= selectedBooking.getCheckIn() %></span>
                </div>
                <div class="bill-row">
                    <span class="bill-label">Check-out Date:</span>
                    <span class="bill-value"><%= selectedBooking.getCheckOut() %></span>
                </div>
                <div class="bill-row">
                    <span class="bill-label">Number of Nights:</span>
                    <span class="bill-value"><%= billDetails.get("nights") %> night(s)</span>
                </div>
                <div class="bill-row">
                    <span class="bill-label">Booking Status:</span>
                    <span class="bill-value"><%= selectedBooking.getBookingStatus().toUpperCase() %></span>
                </div>
            </div>

            <div class="bill-section">
                <h3>Charges</h3>
                <div class="bill-row">
                    <span class="bill-label">Room Rate (per night):</span>
                    <span class="bill-value">Rs. <%= String.format("%.2f", (Double) billDetails.get("roomRate")) %></span>
                </div>
                <div class="bill-row">
                    <span class="bill-label">Subtotal (<%= billDetails.get("nights") %> nights):</span>
                    <span class="bill-value">Rs. <%= String.format("%.2f", (Double) billDetails.get("subtotal")) %></span>
                </div>
                <div class="bill-row">
                    <span class="bill-label">Service Charge (10%):</span>
                    <span class="bill-value">Rs. <%= String.format("%.2f", (Double) billDetails.get("serviceCharge")) %></span>
                </div>
                <div class="bill-row">
                    <span class="bill-label">Tax (12%):</span>
                    <span class="bill-value">Rs. <%= String.format("%.2f", (Double) billDetails.get("tax")) %></span>
                </div>
                <div class="bill-row total">
                    <span style="color: #667eea;">TOTAL AMOUNT:</span>
                    <span style="color: #667eea;">Rs. <%= String.format("%.2f", (Double) billDetails.get("total")) %></span>
                </div>
            </div>

            <div style="margin-top: 40px; padding-top: 20px; border-top: 2px solid #e9ecef; text-align: center; color: #666; font-size: 12px;">
                <p>Thank you for staying at Ocean View Resort!</p>
                <p>We hope to see you again soon.</p>
                <p style="margin-top: 15px;">Generated on: <%= java.time.LocalDateTime.now().format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss")) %></p>
            </div>

            <div class="no-print" style="margin-top: 30px; text-align: center;">
                <button class="btn btn-success" onclick="window.print();">&#128424; Print Invoice</button>
                <a href="<%= request.getContextPath() %>/receptionist/billing" class="btn btn-primary">Generate Another Bill</a>
            </div>
                </div>
                <% } %>
            </section>
        </main>
    </div>

    <script>
        const menuToggle = document.querySelector('.menu-toggle');
        const sidebar = document.getElementById('receptionistSidebar');
        
        menuToggle.addEventListener('click', () => {
            sidebar.classList.toggle('active');
        });
    </script>
</body>
</html>
