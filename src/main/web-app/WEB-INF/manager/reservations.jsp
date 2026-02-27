<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.Booking" %>
<%@ page import="model.Guest" %>
<%@ page import="model.Room" %>
<%@ page import="java.time.format.DateTimeFormatter" %>

<%
    List<Booking> allBookings = (List<Booking>) request.getAttribute("allBookings");
    List<Guest> allGuests = (List<Guest>) request.getAttribute("allGuests");
    List<Room> allRooms = (List<Room>) request.getAttribute("allRooms");
    String searchQuery = (String) request.getAttribute("searchQuery");
    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
    DateTimeFormatter displayFormatter = DateTimeFormatter.ofPattern("MMM dd, yyyy");
    
    String staffName = (String) request.getAttribute("staffName");
    if (staffName == null) staffName = "Manager";
    
    String successMessage = (String) request.getAttribute("successMessage");
    String errorMessage = (String) request.getAttribute("errorMessage");
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reservations - Ocean View Resort Manager</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/style/styles.css">
    <style>
        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin-bottom: 30px; }
        .stat-card { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .stat-value { font-size: 32px; font-weight: bold; color: #00796b; }
        .stat-label { color: #666; margin-top: 5px; }
        .data-table { width: 100%; background: white; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .data-table table { width: 100%; border-collapse: collapse; }
        .data-table th { background: #00796b; color: white; padding: 12px; text-align: left; }
        .data-table td { padding: 12px; border-bottom: 1px solid #eee; }
        .data-table tr:hover { background: #f5f5f5; }
        .btn { padding: 8px 16px; border: none; border-radius: 4px; cursor: pointer; text-decoration: none; display: inline-block; margin: 2px; }
        .btn-primary { background: #00796b; color: white; }
        .btn-secondary { background: #0288d1; color: white; }
        .btn-success { background: #388e3c; color: white; }
        .status-badge { padding: 4px 8px; border-radius: 4px; font-size: 12px; font-weight: bold; }
        .status-confirmed { background: #c8e6c9; color: #2e7d32; }
        .status-checked-in { background: #b3e5fc; color: #01579b; }
        .status-checked-out { background: #f0f4c3; color: #827717; }
        .status-cancelled { background: #ffcdd2; color: #c62828; }
        .section-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
        .section-title { font-size: 24px; font-weight: bold; color: #00796b; }
        .alert { padding: 12px 20px; border-radius: 4px; margin-bottom: 20px; }
        .alert-success { background: #c8e6c9; color: #2e7d32; border: 1px solid #4caf50; }
        .alert-error { background: #ffcdd2; color: #c62828; border: 1px solid #f44336; }
        .search-section { background: white; padding: 15px; border-radius: 8px; margin-bottom: 20px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .search-form { display: flex; gap: 10px; align-items: flex-end; }
        .search-form .form-group { margin-bottom: 0; flex: 1; }
        .form-section { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); margin-bottom: 20px; }
        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; margin-bottom: 5px; font-weight: 500; }
        .form-group input, .form-group select, .form-group textarea { width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px; }
    </style>
</head>
<body>
    <div id="main-app">
        <!-- Header -->
        <header class="app-header">
            <div class="header-content">
                <div class="header-left">
                    <div class="app-logo">Ocean View Resort</div>
                </div>
                <div class="user-info">
                    <span class="user-badge">Manager</span>
                    <span>Welcome, <%= staffName %></span>
                    <form action="<%= request.getContextPath() %>/staff-logout" method="post" style="display: inline;">
                        <button type="submit" class="logout-btn">Logout</button>
                    </form>
                </div>
            </div>
        </header>

        <!-- Sidebar -->
        <nav class="sidebar">
            <ul class="nav-menu">
                <li class="nav-item">
                    <a href="<%= request.getContextPath() %>/manager/dashboard" class="nav-link">
                        <span class="nav-icon">&#128202;</span>
                        Dashboard
                    </a>
                </li>
                <li class="nav-item">
                    <a href="<%= request.getContextPath() %>/manager/reservations" class="nav-link active">
                        <span class="nav-icon">&#128203;</span>
                        Reservations
                    </a>
                </li>
                <li class="nav-item">
                    <a href="<%= request.getContextPath() %>/manager/rooms" class="nav-link">
                        <span class="nav-icon">&#128716;</span>
                        Room Availability
                    </a>
                </li>
                <li class="nav-item">
                    <a href="<%= request.getContextPath() %>/manager/checkin" class="nav-link">
                        <span class="nav-icon">&#9989;</span>
                        Check-in / Check-out
                    </a>
                </li>
                <li class="nav-item">
                    <a href="<%= request.getContextPath() %>/manager/cleaning" class="nav-link">
                        <span class="nav-icon">&#129529;</span>
                        Cleaning Service
                    </a>
                </li>
                <li class="nav-item">
                    <a href="<%= request.getContextPath() %>/manager/billing" class="nav-link">
                        <span class="nav-icon">&#128176;</span>
                        Billing
                    </a>
                </li>
                <li class="nav-item">
                    <a href="<%= request.getContextPath() %>/manager/help" class="nav-link">
                        <span class="nav-icon">&#10067;</span>
                        Help & Guide
                    </a>
                </li>
                <!-- <li class="nav-item">
                    <form action="<%= request.getContextPath() %>/staff-logout" method="post">
                        <button type="submit" class="nav-link" style="width: 100%; text-align: left; background: none; border: none; cursor: pointer;">
                            <span class="nav-icon">&#128682;</span>
                            Exit System
                        </button>
                    </form>
                </li> -->
            </ul>
        </nav>

        <!-- Main Content -->
        <main class="main-content">
            <% if (successMessage != null) { %>
                <div class="alert alert-success"><%= successMessage %></div>
            <% } %>
            
            <% if (errorMessage != null) { %>
                <div class="alert alert-error"><%= errorMessage %></div>
            <% } %>

            <div class="section-header">
                <h2 class="section-title">Reservations Management</h2>
            </div>

            <!-- Search Section -->
            <div class="search-section">
                <form action="<%= request.getContextPath() %>/manager" method="post" class="search-form">
                    <input type="hidden" name="action" value="searchReservations">
                    <div class="form-group">
                        <label>Search Reservations</label>
                        <input type="text" name="searchQuery" 
                               placeholder="Search by booking ID, guest name, or contact..." 
                               value="<%= searchQuery != null ? searchQuery : "" %>">
                    </div>
                    <button type="submit" class="btn btn-primary">Search</button>
                    <% if (searchQuery != null) { %>
                        <a href="<%= request.getContextPath() %>/manager/reservations" class="btn btn-secondary">Clear</a>
                    <% } %>
                </form>
            </div>

            <!-- Create New Reservation Form -->
            <div class="form-section">
                <h3>Create New Reservation</h3>
                <form action="<%= request.getContextPath() %>/manager" method="post">
                    <input type="hidden" name="action" value="createReservation">
                    
                    <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 15px;">
                        <div class="form-group">
                            <label>Guest Name *</label>
                            <input type="text" name="guestName" required>
                        </div>
                        <div class="form-group">
                            <label>Contact Number *</label>
                            <input type="text" name="guestContact" required>
                        </div>
                        <div class="form-group">
                            <label>Email</label>
                            <input type="email" name="guestEmail">
                        </div>
                        <div class="form-group">
                            <label>NIC</label>
                            <input type="text" name="guestNic">
                        </div>
                        <div class="form-group">
                            <label>Room Type *</label>
                            <select name="roomType" required>
                                <option value="standard">Standard (LKR 15,000/night)</option>
                                <option value="deluxe">Deluxe (LKR 25,000/night)</option>
                                <option value="suite">Suite (LKR 45,000/night)</option>
                                <option value="presidential">Presidential (LKR 85,000/night)</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Number of Guests *</label>
                            <input type="number" name="numGuests" min="1" max="4" value="2" required>
                        </div>
                        <div class="form-group">
                            <label>Check-in Date *</label>
                            <input type="date" name="checkinDate" required>
                        </div>
                        <div class="form-group">
                            <label>Check-out Date *</label>
                            <input type="date" name="checkoutDate" required>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label>Special Requests</label>
                        <textarea name="specialRequests" rows="2"></textarea>
                    </div>
                    
                    <button type="submit" class="btn btn-success">Create Reservation</button>
                </form>
            </div>

            <!-- All Reservations Table -->
            <div class="data-table">
                <table>
                    <thead>
                        <tr>
                            <th>ID</th>
                            <th>Guest</th>
                            <th>Contact</th>
                            <th>Room Type</th>
                            <th>Guests</th>
                            <th>Check-in</th>
                            <th>Check-out</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% 
                        if (allBookings != null && !allBookings.isEmpty()) {
                            for (Booking booking : allBookings) {
                                Guest guest = null;
                                if (allGuests != null) {
                                    for (Guest g : allGuests) {
                                        if (g.getId() == booking.getGuestId()) {
                                            guest = g;
                                            break;
                                        }
                                    }
                                }
                                String guestName = guest != null ? guest.getFullName() : "Unknown";
                                String guestContact = guest != null ? guest.getContact() : "";
                                String status = booking.getBookingStatus() != null ? booking.getBookingStatus() : "pending";
                        %>
                        <tr>
                            <td>#<%= booking.getId() %></td>
                            <td><%= guestName %></td>
                            <td><%= guestContact %></td>
                            <td><%= booking.getRoomType() %></td>
                            <td><%= booking.getNumGuests() %></td>
                            <td><%= booking.getCheckIn().format(displayFormatter) %></td>
                            <td><%= booking.getCheckOut().format(displayFormatter) %></td>
                            <td>
                                <span class="status-badge status-<%= status %>">
                                    <%= status.toUpperCase() %>
                                </span>
                            </td>
                            <td>
                                <form method="get" style="display: inline;">
                                    <input type="hidden" name="editBooking" value="<%= booking.getId() %>">
                                    <button type="submit" class="btn btn-secondary">Edit</button>
                                </form>
                            </td>
                        </tr>
                        
                        <!-- Edit Form (shown when editBooking matches) -->
                        <% if (request.getParameter("editBooking") != null && 
                               Integer.parseInt(request.getParameter("editBooking")) == booking.getId()) { %>
                        <tr>
                            <td colspan="9" style="background: #f5f5f5; padding: 20px;">
                                <form action="<%= request.getContextPath() %>/manager" method="post">
                                    <input type="hidden" name="action" value="updateReservation">
                                    <input type="hidden" name="reservationId" value="<%= booking.getId() %>">
                                    
                                    <h4>Edit Reservation #<%= booking.getId() %></h4>
                                    <div style="display: grid; grid-template-columns: repeat(3, 1fr); gap: 15px; margin-top: 15px;">
                                        <div class="form-group">
                                            <label>Room Type</label>
                                            <select name="roomType" required>
                                                <option value="standard" <%= "standard".equals(booking.getRoomType()) ? "selected" : "" %>>Standard</option>
                                                <option value="deluxe" <%= "deluxe".equals(booking.getRoomType()) ? "selected" : "" %>>Deluxe</option>
                                                <option value="suite" <%= "suite".equals(booking.getRoomType()) ? "selected" : "" %>>Suite</option>
                                                <option value="presidential" <%= "presidential".equals(booking.getRoomType()) ? "selected" : "" %>>Presidential</option>
                                            </select>
                                        </div>
                                        <div class="form-group">
                                            <label>Number of Guests</label>
                                            <input type="number" name="numGuests" min="1" max="4" 
                                                   value="<%= booking.getNumGuests() %>" required>
                                        </div>
                                        <div class="form-group">
                                            <label>Check-in Date</label>
                                            <input type="date" name="checkinDate" 
                                                   value="<%= booking.getCheckIn().format(formatter) %>" required>
                                        </div>
                                        <div class="form-group">
                                            <label>Check-out Date</label>
                                            <input type="date" name="checkoutDate" 
                                                   value="<%= booking.getCheckOut().format(formatter) %>" required>
                                        </div>
                                        <div class="form-group" style="grid-column: span 2;">
                                            <label>Special Requests</label>
                                            <textarea name="specialRequests" rows="2"><%= booking.getSpecialRequests() != null ? booking.getSpecialRequests() : "" %></textarea>
                                        </div>
                                    </div>
                                    
                                    <button type="submit" class="btn btn-success">Update Reservation</button>
                                    <a href="<%= request.getContextPath() %>/manager/reservations" class="btn btn-secondary">Cancel</a>
                                </form>
                            </td>
                        </tr>
                        <% } %>
                        <% 
                            }
                        } else {
                        %>
                        <tr>
                            <td colspan="9" style="text-align: center; padding: 20px;">No reservations found</td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </main>
    </div>
</body>
</html>
