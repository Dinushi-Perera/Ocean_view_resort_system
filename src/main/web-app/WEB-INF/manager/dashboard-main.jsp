<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Booking" %>
<%@ page import="model.Guest" %>
<%@ page import="java.time.format.DateTimeFormatter" %>

<%
    Map<String, Integer> stats = (Map<String, Integer>) request.getAttribute("stats");
    List<Booking> recentBookings = (List<Booking>) request.getAttribute("recentBookings");
    List<Guest> allGuests = (List<Guest>) request.getAttribute("allGuests");
    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("MMM dd, yyyy");
    
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
    <title>Manager Dashboard - Ocean View Resort</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/style/styles.css">
    <style>
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        .stat-card {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .stat-value {
            font-size: 32px;
            font-weight: bold;
            color: #0284c7;
        }
        .stat-label {
            color: #666;
            margin-top: 5px;
        }
        .data-table {
            width: 100%;
            background: white;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .data-table table {
            width: 100%;
            border-collapse: collapse;
        }
        .data-table th {
            background: #0284c7;
            color: white;
            padding: 12px;
            text-align: left;
        }
        .data-table td {
            padding: 12px;
            border-bottom: 1px solid #eee;
        }
        .data-table tr:hover {
            background: #f5f5f5;
        }
        .btn {
            padding: 8px 16px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            margin: 2px;
        }
        .btn-primary {
            background: #0c4a6e;
            color: white;
        }
        .status-badge {
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 12px;
            font-weight: bold;
        }
        .status-confirmed {
            background: #c8e6c9;
            color: #107db0;
        }
        .status-checked-in {
            background: #b3e5fc;
            color: #01579b;
        }
        .status-checked-out {
            background: #f0f4c3;
            color: #06b6d4;
        }
        .status-cancelled {
            background: #ffcdd2;
            color: #c62828;
        }
        .section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        .section-title {
            font-size: 24px;
            font-weight: bold;
            color: #01579b;
        }
        .alert {
            padding: 12px 20px;
            border-radius: 4px;
            margin-bottom: 20px;
        }
        .alert-success {
            background: #c8e6c9;
            color: #06b6d4;
            border: 1px solid #01579b;
        }
        .alert-error {
            background: #ffcdd2;
            color: #c62828;
            border: 1px solid #f44336;
        }
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
                    <a href="<%= request.getContextPath() %>/manager/dashboard" class="nav-link active">
                        <span class="nav-icon">&#128202;</span>
                        Dashboard
                    </a>
                </li>
                <li class="nav-item">
                    <a href="<%= request.getContextPath() %>/manager/reservations" class="nav-link">
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
                    <a href="<%= request.getContextPath() %>/manager/monthly-report" class="nav-link">
                        <span class="nav-icon">&#128200;</span>
                        Monthly Report
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
                <h2 class="section-title">Manager Dashboard</h2>
            </div>

            <!-- Statistics Cards -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-value"><%= stats != null ? stats.get("totalRooms") : 0 %></div>
                    <div class="stat-label">Total Rooms</div>
                </div>
                <div class="stat-card">
                    <div class="stat-value"><%= stats != null ? stats.get("occupiedRooms") : 0 %></div>
                    <div class="stat-label">Occupied Rooms</div>
                </div>
                <div class="stat-card">
                    <div class="stat-value"><%= stats != null ? stats.get("availableRooms") : 0 %></div>
                    <div class="stat-label">Available Rooms</div>
                </div>
                <div class="stat-card">
                    <div class="stat-value"><%= stats != null ? stats.get("pendingCheckouts") : 0 %></div>
                    <div class="stat-label">Today's Checkouts</div>
                </div>
            </div>

            <!-- Recent Reservations -->
            <div class="section-header">
                <h3 class="section-title">Recent Reservations</h3>
                <a href="<%= request.getContextPath() %>/manager/reservations" class="btn btn-primary">View All</a>
            </div>

            <div class="data-table">
                <table>
                    <thead>
                        <tr>
                            <th>Booking ID</th>
                            <th>Guest Name</th>
                            <th>Room Type</th>
                            <th>Check-in</th>
                            <th>Check-out</th>
                            <th>Status</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% 
                        if (recentBookings != null && !recentBookings.isEmpty()) {
                            for (Booking booking : recentBookings) {
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
                                String status = booking.getBookingStatus() != null ? booking.getBookingStatus() : "pending";
                        %>
                        <tr>
                            <td>#<%= booking.getId() %></td>
                            <td><%= guestName %></td>
                            <td><%= booking.getRoomType() %></td>
                            <td><%= booking.getCheckIn().format(formatter) %></td>
                            <td><%= booking.getCheckOut().format(formatter) %></td>
                            <td>
                                <span class="status-badge status-<%= status %>">
                                    <%= status.toUpperCase() %>
                                </span>
                            </td>
                        </tr>
                        <% 
                            }
                        } else {
                        %>
                        <tr>
                            <td colspan="6" style="text-align: center; padding: 20px;">No recent reservations</td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </main>
    </div>
</body>
</html>
