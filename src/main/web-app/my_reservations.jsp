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
    
    // Fetch all bookings for this guest
    BookingDAO bookingDAO = new BookingDAO();
    List<Booking> bookings = bookingDAO.getBookingsByGuestId(guest.getId());

    // Date formatter
    DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("MMM dd, yyyy");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Reservations - Ocean View Resort</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="style/styles.css">
</head>
<body>
    <div id="guest-dashboard">
        <!-- Header -->
        <header class="app-header">
            <div class="header-content">
                <div class="header-left">
                    <button class="menu-toggle">&#9776;</button>
                    <div class="app-logo">Ocean View Resort - Guest Portal</div>
                </div>
                <div class="user-info">
                    <span class="user-badge">Guest</span>
                    <span>Welcome, <%= guestName %></span>
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
                    <a href="guest.jsp" class="nav-link">
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
                    <a href="my_reservations.jsp" class="nav-link active">
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
            <section class="page-section active">
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
                            <tbody>
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
                                                <form method="POST" action="<%= request.getContextPath() %>/cancel-booking" style="display: inline;"
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
        </main>
    </div>

    <script>
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
