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
%>

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
