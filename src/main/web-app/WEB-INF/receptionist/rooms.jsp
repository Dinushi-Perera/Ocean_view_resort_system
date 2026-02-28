<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Room" %>
<%
    @SuppressWarnings("unchecked")
    Map<String, Object> roomData = (Map<String, Object>) request.getAttribute("roomData");
    @SuppressWarnings("unchecked")
    List<Room> allRooms = (List<Room>) request.getAttribute("allRooms");
    String filterRoomType = (String) request.getAttribute("filterRoomType");
    
    if (roomData == null) roomData = new java.util.HashMap<>();
    if (allRooms == null) allRooms = new java.util.ArrayList<>();
    
    @SuppressWarnings("unchecked")
    Map<String, Integer> roomCapacity = (Map<String, Integer>) roomData.get("roomCapacity");
    @SuppressWarnings("unchecked")
    Map<String, Integer> occupiedByType = (Map<String, Integer>) roomData.get("occupiedByType");
    
    if (roomCapacity == null) roomCapacity = new java.util.HashMap<>();
    if (occupiedByType == null) occupiedByType = new java.util.HashMap<>();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Room Availability - Ocean View Resort</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/style/styles.css">
    <style>
        .filter-bar { background: white; padding: 20px; border-radius: 10px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); margin-bottom: 20px; }
        .filter-bar form { display: flex; align-items: center; gap: 15px; }
        .filter-bar label { font-weight: 500; color: #333; }
        .filter-select { padding: 12px; border: 1px solid #ddd; border-radius: 5px; font-size: 14px; flex: 1; max-width: 300px; }
        .btn { padding: 12px 25px; border: none; border-radius: 5px; cursor: pointer; font-size: 14px; font-weight: 500; }
        .btn-primary { background: #667eea; color: white; }
        .btn-primary:hover { background: #5568d3; }
        .btn-secondary { background: #6c757d; color: white; }
        .btn-secondary:hover { background: #5a6268; }
        .btn-success { background: #28a745; color: white; margin-bottom: 20px; }
        .btn-success:hover { background: #218838; }
        .rooms-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 20px; }
        .room-card { background: white; padding: 25px; border-radius: 10px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); border-left: 4px solid #667eea; }
        .room-card.available { border-left-color: #28a745; }
        .room-card.occupied { border-left-color: #dc3545; }
        .room-type { font-size: 20px; font-weight: bold; margin-bottom: 15px; color: #333; text-transform: capitalize; }
        .room-stats { display: flex; justify-content: space-between; margin-bottom: 10px; padding: 10px; background: #f8f9fa; border-radius: 5px; }
        .room-stat { text-align: center; }
        .room-stat-number { font-size: 24px; font-weight: bold; }
        .room-stat-label { font-size: 12px; color: #666; margin-top: 5px; }
        .availability-bar { height: 20px; background: #e9ecef; border-radius: 10px; overflow: hidden; margin-top: 10px; }
        .availability-fill { height: 100%; background: linear-gradient(90deg, #28a745, #20c997); transition: width 0.3s; }
        .availability-fill.medium { background: linear-gradient(90deg, #ffc107, #fd7e14); }
        .availability-fill.low { background: linear-gradient(90deg, #dc3545, #e83e8c); }
        
        /* Individual Room Styles */
        .section-title { font-size: 24px; font-weight: bold; margin: 30px 0 20px 0; padding-bottom: 10px; border-bottom: 2px solid #667eea; }
        .room-detail-card { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 6px rgba(0,0,0,0.08); margin-bottom: 15px; display: flex; justify-content: space-between; align-items: center; border-left: 4px solid #e0e0e0; transition: all 0.3s; }
        .room-detail-card:hover { box-shadow: 0 4px 12px rgba(0,0,0,0.12); transform: translateY(-2px); }
        .room-detail-card.available { border-left-color: #28a745; }
        .room-detail-card.occupied { border-left-color: #dc3545; }
        .room-detail-card.maintenance { border-left-color: #ffc107; }
        .room-detail-left { flex: 1; }
        .room-detail-number { font-size: 20px; font-weight: bold; color: #333; margin-bottom: 5px; }
        .room-detail-type { font-size: 14px; color: #667eea; font-weight: 600; text-transform: capitalize; margin-bottom: 8px; }
        .room-detail-info { font-size: 13px; color: #666; margin-bottom: 3px; }
        .room-detail-amenities { font-size: 12px; color: #888; margin-top: 8px; font-style: italic; }
        .room-detail-right { text-align: right; }
        .room-detail-price { font-size: 22px; font-weight: bold; color: #667eea; margin-bottom: 8px; }
        .room-detail-status { display: inline-block; padding: 6px 16px; border-radius: 20px; font-size: 12px; font-weight: 600; text-transform: uppercase; }
        .status-available { background: #d4edda; color: #155724; }
        .status-occupied { background: #f8d7da; color: #721c24; }
        .status-maintenance { background: #fff3cd; color: #856404; }
        .no-rooms { text-align: center; padding: 40px; color: #999; font-size: 16px; }
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
                    <a href="<%= request.getContextPath() %>/receptionist/reservations" class="nav-link">
                        <span class="nav-icon">&#128203;</span>
                        Reservations
                    </a>
                </li>
                <li class="nav-item">
                    <a href="<%= request.getContextPath() %>/receptionist/rooms" class="nav-link active">
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
                    <h2 class="page-title">&#128716; Room Availability Status</h2>
                </div>

        <!-- Book Room Button -->
        <div style="margin-bottom: 20px;">
            <a href="<%= request.getContextPath() %>/receptionist/book-room" style="text-decoration: none;">
                <button class="btn btn-success">&#10133; Book New Room</button>
            </a>
        </div>

        <div class="filter-bar">
            <form action="<%= request.getContextPath() %>/receptionist/rooms" method="post">
                <input type="hidden" name="action" value="filterRooms">
                <label for="roomType">Filter by Room Type:</label>
                <select name="roomType" id="roomType" class="filter-select">
                    <option value="all" <%= (filterRoomType == null || "all".equals(filterRoomType)) ? "selected" : "" %>>All Room Types</option>
                    <option value="standard" <%= "standard".equals(filterRoomType) ? "selected" : "" %>>Standard</option>
                    <option value="deluxe" <%= "deluxe".equals(filterRoomType) ? "selected" : "" %>>Deluxe</option>
                    <option value="suite" <%= "suite".equals(filterRoomType) ? "selected" : "" %>>Suite</option>
                    <option value="presidential" <%= "presidential".equals(filterRoomType) ? "selected" : "" %>>Presidential</option>
                </select>
                <button type="submit" class="btn btn-primary">Apply Filter</button>
                <% if (filterRoomType != null && !"all".equals(filterRoomType)) { %>
                    <a href="<%= request.getContextPath() %>/receptionist/rooms" class="btn btn-secondary">Clear Filter</a>
                <% } %>
            </form>
        </div>

        <div class="rooms-grid">
            <% 
            String[] roomTypes = {"standard", "deluxe", "suite", "presidential"};
            for (String type : roomTypes) {
                if (filterRoomType != null && !"all".equals(filterRoomType) && !type.equals(filterRoomType)) {
                    continue;
                }
                
                int capacity = roomCapacity.getOrDefault(type, 0);
                int occupied = occupiedByType.getOrDefault(type, 0);
                int available = capacity - occupied;
                double occupancyRate = capacity > 0 ? ((double)occupied / capacity) * 100 : 0;
                
                String cardClass = available > 0 ? "available" : "occupied";
                String fillClass = "";
                if (occupancyRate >= 80) fillClass = "low";
                else if (occupancyRate >= 50) fillClass = "medium";
            %>
            <div class="room-card <%= cardClass %>">
                <div class="room-type">&#128716; <%= type.substring(0, 1).toUpperCase() + type.substring(1) %></div>
                
                <div class="room-stats">
                    <div class="room-stat">
                        <div class="room-stat-number" style="color: #667eea;"><%= capacity %></div>
                        <div class="room-stat-label">Total</div>
                    </div>
                    <div class="room-stat">
                        <div class="room-stat-number" style="color: #28a745;"><%= available %></div>
                        <div class="room-stat-label">Available</div>
                    </div>
                    <div class="room-stat">
                        <div class="room-stat-number" style="color: #dc3545;"><%= occupied %></div>
                        <div class="room-stat-label">Occupied</div>
                    </div>
                </div>
                
                <div style="margin-top: 15px;">
                    <div style="display: flex; justify-content: space-between; font-size: 12px; color: #666; margin-bottom: 5px;">
                        <span>Occupancy Rate</span>
                        <span><strong><%= String.format("%.1f", occupancyRate) %>%</strong></span>
                    </div>
                    <div class="availability-bar">
                        <div class="availability-fill <%= fillClass %>" style="width: <%= occupancyRate %>%;"></div>
                    </div>
                </div>
                
                <div style="margin-top: 15px; padding: 10px; background: <%= available > 0 ? "#d4edda" : "#f8d7da" %>; border-radius: 5px; text-align: center; font-weight: 500; color: <%= available > 0 ? "#155724" : "#721c24" %>;">
                    <% if (available > 0) { %>
                        ✓ <%= available %> room(s) available for booking
                    <% } else { %>
                        ✗ No rooms available
                    <% } %>
                </div>
            </div>
            <% } %>
        </div>

                <div style="background: #fff3cd; border-left: 4px solid #ffc107; padding: 15px; border-radius: 5px; margin-top: 30px;">
                    <strong>⚠️ Note:</strong> Room availability is calculated based on current check-in status. To book new reservations or modify existing ones, guests must use the booking system or contact the hotel manager.
                </div>

                <!-- Detailed Room List -->
                <h3 class="section-title">&#127968; All Rooms in Database</h3>
                
                <%
                if (allRooms.isEmpty()) {
                %>
                    <div class="no-rooms">
                        <p>&#128680; No rooms found in the database.</p>
                        <p style="font-size: 14px; color: #666;">Please run the database setup script to add rooms.</p>
                    </div>
                <%
                } else {
                    // Group rooms by type for better organization
                    java.util.Map<String, java.util.List<Room>> roomsByType = new java.util.HashMap<>();
                    for (Room room : allRooms) {
                        String type = room.getRoomType().toLowerCase();
                        if (filterRoomType == null || "all".equals(filterRoomType) || type.equals(filterRoomType)) {
                            if (!roomsByType.containsKey(type)) {
                                roomsByType.put(type, new java.util.ArrayList<>());
                            }
                            roomsByType.get(type).add(room);
                        }
                    }
                    
                    // Display rooms by type
                    String[] types = {"standard", "deluxe", "suite", "presidential"};
                    for (String type : types) {
                        java.util.List<Room> roomsOfType = roomsByType.get(type);
                        if (roomsOfType != null && !roomsOfType.isEmpty()) {
                %>
                            <h4 style="font-size: 18px; color: #667eea; margin-top: 25px; margin-bottom: 15px; text-transform: capitalize;">
                                <%= type %> Rooms (<%= roomsOfType.size() %> total)
                            </h4>
                            
                            <%
                            for (Room room : roomsOfType) {
                                String status = room.getStatus() != null ? room.getStatus().toLowerCase() : "available";
                                String statusClass = "";
                                String statusDisplay = "";
                                
                                if ("available".equals(status)) {
                                    statusClass = "status-available";
                                    statusDisplay = "&#10004; Available";
                                } else if ("occupied".equals(status)) {
                                    statusClass = "status-occupied";
                                    statusDisplay = "&#10060; Occupied";
                                } else {
                                    statusClass = "status-maintenance";
                                    statusDisplay = "&#128736; Maintenance";
                                }
                            %>
                                <div class="room-detail-card <%= status %>">
                                    <div class="room-detail-left">
                                        <div class="room-detail-number">&#128682; Room <%= room.getRoomNumber() %></div>
                                        <div class="room-detail-type"><%= room.getRoomType() %> Room - Floor <%= room.getFloor() %></div>
                                        <div class="room-detail-info">&#128101; Max Occupancy: <%= room.getMaxOccupancy() %> guests</div>
                                        <% if (room.getDescription() != null && !room.getDescription().isEmpty()) { %>
                                            <div class="room-detail-info">&#128221; <%= room.getDescription() %></div>
                                        <% } %>
                                        <% if (room.getAmenities() != null && !room.getAmenities().isEmpty()) { %>
                                            <div class="room-detail-amenities">&#11088; <%= room.getAmenities() %></div>
                                        <% } %>
                                    </div>
                                    <div class="room-detail-right">
                                        <div class="room-detail-price">LKR <%= String.format("%,.2f", room.getPricePerNight()) %></div>
                                        <div style="font-size: 11px; color: #888; margin-bottom: 10px;">per night</div>
                                        <span class="room-detail-status <%= statusClass %>"><%= statusDisplay %></span>
                                    </div>
                                </div>
                            <%
                            }
                            %>
                <%
                        }
                    }
                }
                %>

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
