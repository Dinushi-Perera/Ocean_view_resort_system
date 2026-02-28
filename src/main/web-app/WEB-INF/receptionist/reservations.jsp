<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, model.Booking, model.Guest" %>
<%
    @SuppressWarnings("unchecked")
    List<Booking> allBookings = (List<Booking>) request.getAttribute("allBookings");
    @SuppressWarnings("unchecked")
    List<Guest> allGuests = (List<Guest>) request.getAttribute("allGuests");
    String searchQuery = (String) request.getAttribute("searchQuery");
    
    if (allBookings == null) allBookings = new ArrayList<>();
    if (allGuests == null) allGuests = new ArrayList<>();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reservations - Ocean View Resort</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/style/styles.css">
    <style>
        .search-box { margin-bottom: 20px; }
        .search-box form { display: flex; gap: 10px; }
        .search-input { flex: 1; padding: 12px; border: 1px solid #ddd; border-radius: 5px; font-size: 14px; }
        .btn { padding: 12px 25px; border: none; border-radius: 5px; cursor: pointer; font-size: 14px; font-weight: 500; }
        .btn-primary { background: #667eea; color: white; }
        .btn-primary:hover { background: #5568d3; }
        .btn-secondary { background: #6c757d; color: white; }
        .btn-secondary:hover { background: #5a6268; }
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
                    <a href="<%= request.getContextPath() %>/receptionist/reservations" class="nav-link active">
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
                    <h2 class="page-title">&#128203; All Reservations</h2>
                </div>

        <div class="search-box">
            <form action="<%= request.getContextPath() %>/receptionist/reservations" method="post">
                <input type="hidden" name="action" value="search">
                <input type="text" name="searchQuery" class="search-input" 
                       placeholder="Search by reservation ID or guest name..." 
                       value="<%= searchQuery != null ? searchQuery : "" %>">
                <button type="submit" class="btn btn-primary">Search</button>
                <% if (searchQuery != null && !searchQuery.isEmpty()) { %>
                    <a href="<%= request.getContextPath() %>/receptionist/reservations" class="btn btn-secondary">Clear</a>
                <% } %>
            </form>
        </div>

        <div class="card">
            <% if (searchQuery != null && !searchQuery.isEmpty()) { %>
                <p style="color: #666; margin-bottom: 15px;">Showing results for: "<strong><%= searchQuery %></strong>" (<%= allBookings.size() %> result(s))</p>
            <% } %>
            
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Guest Name</th>
                        <th>Email</th>
                        <th>Contact</th>
                        <th>Room Type</th>
                        <th>Guests</th>
                        <th>Check-in</th>
                        <th>Check-out</th>
                        <th>Status</th>
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
                        String email = (guest != null) ? guest.getEmail() : "N/A";
                        String contact = (guest != null) ? guest.getContact() : "N/A";
                        String status = booking.getBookingStatus() != null ? booking.getBookingStatus() : "pending";
                        String badgeClass = "badge-" + status;
                    %>
                    <tr>
                        <td>#<%= booking.getId() %></td>
                        <td><%= guestName %></td>
                        <td><%= email %></td>
                        <td><%= contact %></td>
                        <td><%= booking.getRoomType() %></td>
                        <td><%= booking.getNumGuests() %></td>
                        <td><%= booking.getCheckIn() %></td>
                        <td><%= booking.getCheckOut() %></td>
                        <td><span class="badge <%= badgeClass %>"><%= status.toUpperCase() %></span></td>
                    </tr>
                    <% } %>
                    <% if (allBookings.isEmpty()) { %>
                    <tr>
                        <td colspan="9" style="text-align: center; color: #999; padding: 30px;">
                            <% if (searchQuery != null && !searchQuery.isEmpty()) { %>
                                No reservations found matching your search.
                            <% } else { %>
                                No reservations found in the system.
                            <% } %>
                        </td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        </div>

                <div style="background: #e7f3ff; border-left: 4px solid #2196F3; padding: 15px; border-radius: 5px; margin-top: 20px;">
                    <strong>ℹ️ Note:</strong> As a receptionist, you can view all reservation details. To modify or cancel reservations, please contact the hotel manager.
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
