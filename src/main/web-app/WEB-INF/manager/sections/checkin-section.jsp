<%@ page import="java.util.List" %>
<%@ page import="model.Booking" %>
<%@ page import="model.Guest" %>
<%@ page import="java.time.format.DateTimeFormatter" %>

<%
    List<Booking> allBookings = (List<Booking>) request.getAttribute("allBookings");
    List<Guest> allGuests = (List<Guest>) request.getAttribute("allGuests");
    List<Booking> todayCheckins = (List<Booking>) request.getAttribute("todayCheckins");
    List<Booking> todayCheckouts = (List<Booking>) request.getAttribute("todayCheckouts");
    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("MMM dd, yyyy");
%>

<div class="section-header">
    <h2 class="section-title">Check-in / Check-out Management</h2>
</div>

<!-- Today's Check-ins -->
<div class="form-section">
    <h3>Today's Check-ins</h3>
    <div class="data-table">
        <table>
            <thead>
                <tr>
                    <th>Booking ID</th>
                    <th>Guest Name</th>
                    <th>Contact</th>
                    <th>Room Type</th>
                    <th>Guests</th>
                    <th>Check-out Date</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody>
                <% 
                if (todayCheckins != null && !todayCheckins.isEmpty()) {
                    for (Booking booking : todayCheckins) {
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
                %>
                <tr>
                    <td>#<%= booking.getId() %></td>
                    <td><%= guestName %></td>
                    <td><%= guestContact %></td>
                    <td><%= booking.getRoomType() %></td>
                    <td><%= booking.getNumGuests() %></td>
                    <td><%= booking.getCheckOut().format(formatter) %></td>
                    <td>
                        <form action="<%= request.getContextPath() %>/manager" method="post" style="display: inline;">
                            <input type="hidden" name="action" value="checkin">
                            <input type="hidden" name="bookingId" value="<%= booking.getId() %>">
                            <button type="submit" class="btn btn-success">Check In</button>
                        </form>
                    </td>
                </tr>
                <% 
                    }
                } else {
                %>
                <tr>
                    <td colspan="7" style="text-align: center; padding: 20px;">No check-ins scheduled for today</td>
                </tr>
                <% } %>
            </tbody>
        </table>
    </div>
</div>

<!-- Today's Check-outs -->
<div class="form-section">
    <h3>Today's Check-outs</h3>
    <div class="data-table">
        <table>
            <thead>
                <tr>
                    <th>Booking ID</th>
                    <th>Guest Name</th>
                    <th>Contact</th>
                    <th>Room Type</th>
                    <th>Check-in Date</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody>
                <% 
                if (todayCheckouts != null && !todayCheckouts.isEmpty()) {
                    for (Booking booking : todayCheckouts) {
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
                %>
                <tr>
                    <td>#<%= booking.getId() %></td>
                    <td><%= guestName %></td>
                    <td><%= guestContact %></td>
                    <td><%= booking.getRoomType() %></td>
                    <td><%= booking.getCheckIn().format(formatter) %></td>
                    <td>
                        <form action="<%= request.getContextPath() %>/manager" method="post" style="display: inline;">
                            <input type="hidden" name="action" value="checkout">
                            <input type="hidden" name="bookingId" value="<%= booking.getId() %>">
                            <button type="submit" class="btn btn-warning">Check Out</button>
                        </form>
                    </td>
                </tr>
                <% 
                    }
                } else {
                %>
                <tr>
                    <td colspan="6" style="text-align: center; padding: 20px;">No check-outs scheduled for today</td>
                </tr>
                <% } %>
            </tbody>
        </table>
    </div>
</div>

<!-- All Active Bookings -->
<div class="form-section">
    <h3>All Active Bookings</h3>
    <div class="data-table">
        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Guest</th>
                    <th>Room Type</th>
                    <th>Check-in</th>
                    <th>Check-out</th>
                    <th>Status</th>
                    <th>Action</th>
                </tr>
            </thead>
            <tbody>
                <% 
                if (allBookings != null && !allBookings.isEmpty()) {
                    for (Booking booking : allBookings) {
                        String status = booking.getBookingStatus() != null ? booking.getBookingStatus() : "pending";
                        
                        // Only show confirmed and checked-in bookings
                        if (!"confirmed".equals(status) && !"checked-in".equals(status)) {
                            continue;
                        }
                        
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
                    <td>
                        <% if ("confirmed".equals(status)) { %>
                        <form action="<%= request.getContextPath() %>/manager" method="post" style="display: inline;">
                            <input type="hidden" name="action" value="checkin">
                            <input type="hidden" name="bookingId" value="<%= booking.getId() %>">
                            <button type="submit" class="btn btn-success">Check In</button>
                        </form>
                        <% } else if ("checked-in".equals(status)) { %>
                        <form action="<%= request.getContextPath() %>/manager" method="post" style="display: inline;">
                            <input type="hidden" name="action" value="checkout">
                            <input type="hidden" name="bookingId" value="<%= booking.getId() %>">
                            <button type="submit" class="btn btn-warning">Check Out</button>
                        </form>
                        <% } %>
                    </td>
                </tr>
                <% 
                    }
                } else {
                %>
                <tr>
                    <td colspan="7" style="text-align: center; padding: 20px;">No active bookings</td>
                </tr>
                <% } %>
            </tbody>
        </table>
    </div>
</div>
