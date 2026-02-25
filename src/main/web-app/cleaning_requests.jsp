<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Guest" %>
<%@ page import="model.CleaningRequest" %>
<%@ page import="model.Booking" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%
    // Check if user is logged in
    Guest guest = (Guest) session.getAttribute("guest");
    if (guest == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String guestName = guest.getFullName();
    List<CleaningRequest> cleaningRequests = (List<CleaningRequest>) request.getAttribute("cleaningRequests");
    List<Booking> currentBookings = (List<Booking>) request.getAttribute("currentBookings");
    String successMessage = (String) request.getAttribute("successMessage");
    String errorMessage = (String) request.getAttribute("errorMessage");
    
    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("MMM dd, yyyy hh:mm a");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cleaning Requests - Ocean View Resort</title>
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
                    <a href="my_reservations.jsp" class="nav-link">
                        <span class="nav-icon">&#128203;</span>
                        My Reservations
                    </a>
                </li>
                <li class="nav-item">
                    <a href="<%= request.getContextPath() %>/cleaningRequest" class="nav-link active">
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
                    <h2 class="page-title">&#129529; Cleaning Requests</h2>
                </div>

                <!-- Success/Error Messages -->
                <% if (successMessage != null) { %>
                <div style="background: #d4edda; color: #155724; padding: 12px 20px; border-radius: 6px; margin-bottom: 20px; border: 1px solid #c3e6cb;">
                    <%= successMessage %>
                </div>
                <% } %>
                
                <% if (errorMessage != null) { %>
                <div style="background: #f8d7da; color: #721c24; padding: 12px 20px; border-radius: 6px; margin-bottom: 20px; border: 1px solid #f5c6cb;">
                    <%= errorMessage %>
                </div>
                <% } %>

                <!-- Request Cleaning Form -->
                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">Submit New Cleaning Request</h3>
                    </div>
                    <div style="padding: 20px;">
                        <form action="<%= request.getContextPath() %>/cleaningRequest" method="post">
                            <input type="hidden" name="action" value="create">
                            
                            <div style="margin-bottom: 15px;">
                                <label style="display: block; margin-bottom: 5px; font-weight: 500;">Room Number *</label>
                                <% if (currentBookings != null && !currentBookings.isEmpty()) { %>
                                <select name="roomNumber" required style="width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px;">
                                    <option value="">Select a room</option>
                                    <% for (Booking booking : currentBookings) { 
                                        String roomDisplay = "Room " + booking.getRoomType() + " - Booking #" + booking.getId();
                                    %>
                                    <option value="<%= booking.getRoomType() %>"><%= roomDisplay %></option>
                                    <% } %>
                                    <option value="other">Other Room</option>
                                </select>
                                <% } else { %>
                                <input type="text" name="roomNumber" placeholder="Enter room number" required 
                                       style="width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px;">
                                <% } %>
                            </div>

                            <div style="margin-bottom: 15px;">
                                <label style="display: block; margin-bottom: 5px; font-weight: 500;">Request Type</label>
                                <select name="requestType" required style="width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px;">
                                    <option value="general">General Cleaning</option>
                                    <option value="extra">Extra Cleaning</option>
                                    <option value="towels">Fresh Towels</option>
                                    <option value="sheets">Bed Sheets Change</option>
                                    <option value="toiletries">Toiletries Refill</option>
                                    <option value="maintenance">Maintenance Issue</option>
                                </select>
                            </div>

                            <div style="margin-bottom: 15px;">
                                <label style="display: block; margin-bottom: 5px; font-weight: 500;">Priority</label>
                                <select name="priority" style="width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px;">
                                    <option value="normal">Normal</option>
                                    <option value="urgent">Urgent</option>
                                </select>
                            </div>

                            <div style="margin-bottom: 15px;">
                                <label style="display: block; margin-bottom: 5px; font-weight: 500;">Special Instructions (Optional)</label>
                                <textarea name="specialInstructions" rows="3" 
                                          placeholder="Any specific requests or instructions..."
                                          style="width: 100%; padding: 8px; border: 1px solid #ddd; border-radius: 4px; resize: vertical;"></textarea>
                            </div>

                            <button type="submit" class="btn btn-primary">Submit Request</button>
                        </form>
                    </div>
                </div>

                <!-- My Cleaning Requests -->
                <div class="card" style="margin-top: 20px;">
                    <div class="card-header">
                        <h3 class="card-title">My Cleaning Requests</h3>
                    </div>
                    <% if (cleaningRequests == null || cleaningRequests.isEmpty()) { %>
                    <div style="padding: 40px; text-align: center; color: #666;">
                        <p>No cleaning requests yet.</p>
                        <p style="margin-top: 10px;">Submit a request above to get started.</p>
                    </div>
                    <% } else { %>
                    <div style="overflow-x: auto;">
                        <table style="width: 100%; border-collapse: collapse;">
                            <thead>
                                <tr style="background: #f8f9fa; border-bottom: 2px solid #dee2e6;">
                                    <th style="padding: 12px; text-align: left;">Request ID</th>
                                    <th style="padding: 12px; text-align: left;">Room</th>
                                    <th style="padding: 12px; text-align: left;">Type</th>
                                    <th style="padding: 12px; text-align: left;">Priority</th>
                                    <th style="padding: 12px; text-align: left;">Status</th>
                                    <th style="padding: 12px; text-align: left;">Requested At</th>
                                    <th style="padding: 12px; text-align: left;">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (CleaningRequest req : cleaningRequests) { 
                                    String statusColor = "pending".equals(req.getRequestStatus()) ? "#f57c00" : 
                                                       "in-progress".equals(req.getRequestStatus()) ? "#1976d2" :
                                                       "completed".equals(req.getRequestStatus()) ? "#388e3c" : "#757575";
                                    String priorityBadge = "urgent".equals(req.getPriority()) ? 
                                        "<span style='background: #d32f2f; color: white; padding: 2px 8px; border-radius: 3px; font-size: 12px;'>URGENT</span>" : "";
                                %>
                                <tr style="border-bottom: 1px solid #dee2e6;">
                                    <td style="padding: 12px;">#<%= req.getId() %></td>
                                    <td style="padding: 12px;"><%= req.getRoomNumber() %></td>
                                    <td style="padding: 12px;"><%= req.getRequestType() %></td>
                                    <td style="padding: 12px;"><%= priorityBadge %> <%= req.getPriority() %></td>
                                    <td style="padding: 12px;">
                                        <span style="color: <%= statusColor %>; font-weight: 500;">
                                            <%= req.getRequestStatus().toUpperCase() %>
                                        </span>
                                    </td>
                                    <td style="padding: 12px;">
                                        <%= req.getRequestedAt() != null ? req.getRequestedAt().format(formatter) : "N/A" %>
                                    </td>
                                    <td style="padding: 12px;">
                                        <% if ("pending".equals(req.getRequestStatus())) { %>
                                        <form action="<%= request.getContextPath() %>/cleaningRequest" method="post" style="display: inline;">
                                            <input type="hidden" name="action" value="cancel">
                                            <input type="hidden" name="requestId" value="<%= req.getId() %>">
                                            <button type="submit" class="btn btn-danger" 
                                                    style="padding: 4px 12px; font-size: 14px;"
                                                    onclick="return confirm('Are you sure you want to cancel this request?');">
                                                Cancel
                                            </button>
                                        </form>
                                        <% } else { %>
                                        <span style="color: #999;">-</span>
                                        <% } %>
                                    </td>
                                </tr>
                                <% if (req.getSpecialInstructions() != null && !req.getSpecialInstructions().trim().isEmpty()) { %>
                                <tr style="background: #f8f9fa;">
                                    <td colspan="7" style="padding: 8px 12px; font-size: 13px; color: #666;">
                                        <strong>Instructions:</strong> <%= req.getSpecialInstructions() %>
                                    </td>
                                </tr>
                                <% } %>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                    <% } %>
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
