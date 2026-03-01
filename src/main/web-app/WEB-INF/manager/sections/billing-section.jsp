<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="model.Booking" %>
<%@ page import="model.Guest" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.time.temporal.ChronoUnit" %>

<%
    List<Booking> allBookings = (List<Booking>) request.getAttribute("allBookings");
    List<Guest> allGuests = (List<Guest>) request.getAttribute("allGuests");
    Map<String, Double> roomPrices = (Map<String, Double>) request.getAttribute("roomPrices");
    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("MMM dd, yyyy");
    
    Boolean showBill = (Boolean) request.getAttribute("showBill");
    Booking billBooking = (Booking) request.getAttribute("booking");
    Guest billGuest = (Guest) request.getAttribute("guest");
    Map<String, Object> billDetails = (Map<String, Object>) request.getAttribute("billDetails");
%>

<div class="section-header">
    <h2 class="section-title">Billing Management</h2>
</div>

<% if (showBill != null && showBill && billBooking != null) { %>
<!-- Bill Display -->
<div class="bill-details">
    <h3>Invoice</h3>
    <hr>
    
    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin: 20px 0;">
        <div>
            <h4>Guest Information</h4>
            <p><strong>Name:</strong> <%= billGuest != null ? billGuest.getFullName() : "N/A" %></p>
            <p><strong>Contact:</strong> <%= billGuest != null ? billGuest.getContact() : "N/A" %></p>
            <p><strong>Email:</strong> <%= billGuest != null ? billGuest.getEmail() : "N/A" %></p>
        </div>
        <div>
            <h4>Booking Information</h4>
            <p><strong>Booking ID:</strong> #<%= billBooking.getId() %></p>
            <p><strong>Room Type:</strong> <%= billBooking.getRoomType() %></p>
            <p><strong>Check-in:</strong> <%= billBooking.getCheckIn().format(formatter) %></p>
            <p><strong>Check-out:</strong> <%= billBooking.getCheckOut().format(formatter) %></p>
        </div>
    </div>
    
    <hr>
    
    <h4>Bill Details</h4>
    <% if (billDetails != null) { %>
    <div class="bill-row">
        <span>Number of Nights:</span>
        <span><%= billDetails.get("nights") %></span>
    </div>
    <div class="bill-row">
        <span>Room Rate (per night):</span>
        <span>LKR <%= String.format("%,.2f", billDetails.get("roomRate")) %></span>
    </div>
    <div class="bill-row">
        <span>Subtotal:</span>
        <span>LKR <%= String.format("%,.2f", billDetails.get("subtotal")) %></span>
    </div>
    <div class="bill-row">
        <span>Service Charge (10%):</span>
        <span>LKR <%= String.format("%,.2f", billDetails.get("serviceCharge")) %></span>
    </div>
    <div class="bill-row">
        <span>Tax (12%):</span>
        <span>LKR <%= String.format("%,.2f", billDetails.get("tax")) %></span>
    </div>
    <div class="bill-row bill-total">
        <span>Total Amount:</span>
        <span>LKR <%= String.format("%,.2f", billDetails.get("total")) %></span>
    </div>
    <% } %>
    
    <div style="margin-top: 20px;">
        <button onclick="window.print()" class="btn btn-primary">Print Invoice</button>
        <a href="<%= request.getContextPath() %>/manager/billing" class="btn btn-secondary">Back to Billing</a>
    </div>
</div>
<% } %>

<!-- Billable Bookings -->
<div class="form-section">
    <h3>Generate Bill for Booking</h3>
    <p>Select a checked-in or checked-out booking to generate an invoice.</p>
</div>

<div class="data-table">
    <table>
        <thead>
            <tr>
                <th>Booking ID</th>
                <th>Guest Name</th>
                <th>Contact</th>
                <th>Room Type</th>
                <th>Check-in</th>
                <th>Check-out</th>
                <th>Nights</th>
                <th>Status</th>
                <th>Action</th>
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
                    long nights = ChronoUnit.DAYS.between(booking.getCheckIn(), booking.getCheckOut());
            %>
            <tr>
                <td>#<%= booking.getId() %></td>
                <td><%= guestName %></td>
                <td><%= guestContact %></td>
                <td><%= booking.getRoomType() %></td>
                <td><%= booking.getCheckIn().format(formatter) %></td>
                <td><%= booking.getCheckOut().format(formatter) %></td>
                <td><%= nights %></td>
                <td>
                    <span class="status-badge status-<%= status %>">
                        <%= status.toUpperCase() %>
                    </span>
                </td>
                <td>
                    <form action="<%= request.getContextPath() %>/manager" method="post" style="display: inline;">
                        <input type="hidden" name="action" value="generateBill">
                        <input type="hidden" name="bookingId" value="<%= booking.getId() %>">
                        <button type="submit" class="btn btn-primary">Generate Bill</button>
                    </form>
                </td>
            </tr>
            <% 
                }
            } else {
            %>
            <tr>
                <td colspan="9" style="text-align: center; padding: 20px;">No billable bookings found</td>
            </tr>
            <% } %>
        </tbody>
    </table>
</div>

<!-- Pricing Information -->
<div class="form-section">
    <h3>Room Rates</h3>
    <% if (roomPrices != null) { %>
    <div style="display: grid; grid-template-columns: repeat(2, 1fr); gap: 15px;">
        <div style="border: 1px solid #ddd; padding: 15px; border-radius: 4px;">
            <h4>Standard Room</h4>
            <p style="font-size: 20px; color: #00796b;"><strong>LKR <%= String.format("%,.2f", roomPrices.get("standard")) %></strong> per night</p>
        </div>
        <div style="border: 1px solid #ddd; padding: 15px; border-radius: 4px;">
            <h4>Deluxe Room</h4>
            <p style="font-size: 20px; color: #00796b;"><strong>LKR <%= String.format("%,.2f", roomPrices.get("deluxe")) %></strong> per night</p>
        </div>
        <div style="border: 1px solid #ddd; padding: 15px; border-radius: 4px;">
            <h4>Suite</h4>
            <p style="font-size: 20px; color: #00796b;"><strong>LKR <%= String.format("%,.2f", roomPrices.get("suite")) %></strong> per night</p>
        </div>
        <div style="border: 1px solid #ddd; padding: 15px; border-radius: 4px;">
            <h4>Presidential Suite</h4>
            <p style="font-size: 20px; color: #00796b;"><strong>LKR <%= String.format("%,.2f", roomPrices.get("presidential")) %></strong> per night</p>
        </div>
    </div>
    <% } %>
    <p style="margin-top: 15px;"><strong>Note:</strong> All bills include 10% service charge and 12% tax.</p>
</div>
