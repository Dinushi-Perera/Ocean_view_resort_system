<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, model.Booking, model.Guest" %>
<%
    @SuppressWarnings("unchecked")
    Map<String, Integer> stats = (Map<String, Integer>) request.getAttribute("stats");
    @SuppressWarnings("unchecked")
    List<Booking> allBookings = (List<Booking>) request.getAttribute("allBookings");
    @SuppressWarnings("unchecked")
    List<Guest> allGuests = (List<Guest>) request.getAttribute("allGuests");
    
    if (stats == null) stats = new HashMap<>();
    if (allBookings == null) allBookings = new ArrayList<>();
    if (allGuests == null) allGuests = new ArrayList<>();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Receptionist Dashboard - Ocean View Resort</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/style/styles.css">
</head>
<body>
    <!-- Toast Container -->
    <div class="toast-container" id="toastContainer"></div>

    <!-- Receptionist Dashboard -->
    <div id="guest-dashboard">
        <!-- Header -->
        <header class="app-header">
            <div class="header-content">
                <div class="header-left">
                    <button class="menu-toggle">&#9776;</button>
                    <div class="app-logo">Ocean View Resort - Receptionist Portal</div>
                </div>
                <div class="user-info">
                    <span class="user-badge" id="receptionistRoleBadge">Receptionist</span>
                    <span id="currentReceptionist">Welcome, <%= session.getAttribute("staffUsername") %></span>
                    <form action="<%= request.getContextPath() %>/staff-logout" method="post" style="display: inline;">
                        <button type="submit" class="logout-btn">Logout</button>
                    </form>
                </div>
            </div>
        </header>

        <!-- Sidebar -->
        <nav class="sidebar" id="receptionistSidebar">
            <ul class="nav-menu">
                <li class="nav-item">
                    <a href="<%= request.getContextPath() %>/receptionist/dashboard" class="nav-link active">
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

        <!-- Main Content -->
        <main class="main-content">
            <!-- Dashboard Section -->
            <section class="page-section active" id="receptionistDashboard">
                <div class="page-header">
                    <h2 class="page-title">&#128202; Receptionist Dashboard</h2>
                    <span id="currentDate"></span>
                </div>

                <% if (request.getAttribute("errorMessage") != null) { %>
                    <div style="background: #f8d7da; color: #721c24; padding: 15px; border-radius: 5px; margin-bottom: 20px;">
                        <%= request.getAttribute("errorMessage") %>
                    </div>
                <% } %>

                <div class="stats-grid">
                    <div class="stat-card">
                        <div class="stat-number"><%= stats.getOrDefault("totalRooms", 0) %></div>
                        <div class="stat-label">Total Rooms</div>
                    </div>
                    <div class="stat-card success">
                        <div class="stat-number"><%= stats.getOrDefault("availableRooms", 0) %></div>
                        <div class="stat-label">Available Rooms</div>
                    </div>
                    <div class="stat-card warning">
                        <div class="stat-number"><%= stats.getOrDefault("occupiedRooms", 0) %></div>
                        <div class="stat-label">Occupied Rooms</div>
                    </div>
                    <div class="stat-card danger">
                        <div class="stat-number"><%= stats.getOrDefault("pendingCheckouts", 0) %></div>
                        <div class="stat-label">Pending Checkouts</div>
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
                                    <th>Guest Name</th>
                                    <th>Room Type</th>
                                    <th>Check-in</th>
                                    <th>Check-out</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% 
                                int count = 0;
                                for (Booking booking : allBookings) {
                                    if (count >= 10) break;
                                    Guest guest = null;
                                    for (Guest g : allGuests) {
                                        if (g.getId() == booking.getGuestId()) {
                                            guest = g;
                                            break;
                                        }
                                    }
                                    String guestName = (guest != null) ? guest.getFullName() : "Unknown";
                                    String status = booking.getBookingStatus() != null ? booking.getBookingStatus() : "pending";
                                    String statusClass = "";
                                    switch (status.toLowerCase()) {
                                        case "confirmed": statusClass = "status-confirmed"; break;
                                        case "pending": statusClass = "status-pending"; break;
                                        case "checked-in": statusClass = "status-checked-in"; break;
                                        case "checked-out": statusClass = "status-checked-out"; break;
                                        case "cancelled": statusClass = "status-cancelled"; break;
                                        default: statusClass = "status-pending";
                                    }
                                    count++;
                                %>
                                <tr>
                                    <td><strong>#<%= booking.getId() %></strong></td>
                                    <td><%= guestName %></td>
                                    <td><%= booking.getRoomType() %></td>
                                    <td><%= booking.getCheckIn() %></td>
                                    <td><%= booking.getCheckOut() %></td>
                                    <td><span class="status-badge <%= statusClass %>"><%= status.toUpperCase() %></span></td>
                                </tr>
                                <% } %>
                                <% if (allBookings.isEmpty()) { %>
                                <tr>
                                    <td colspan="6" style="text-align: center; padding: 20px; color: #999;">No reservations found</td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            </section>
        </main>
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
                document.getElementById('receptionistSidebar').classList.toggle('active');
            });
        }
    </script>
</body>
</html>
