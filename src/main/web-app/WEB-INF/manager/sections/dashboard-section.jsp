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
%>

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
