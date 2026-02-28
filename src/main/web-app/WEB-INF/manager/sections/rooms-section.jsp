<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="model.Room" %>

<%
    List<Room> allRooms = (List<Room>) request.getAttribute("allRooms");
    Map<String, Object> roomData = (Map<String, Object>) request.getAttribute("roomData");
    String filterRoomType = (String) request.getAttribute("filterRoomType");
    
    Map<String, Integer> roomCapacity = roomData != null ? 
        (Map<String, Integer>) roomData.get("roomCapacity") : null;
    Map<String, Integer> occupiedByType = roomData != null ? 
        (Map<String, Integer>) roomData.get("occupiedByType") : null;
%>

<div class="section-header">
    <h2 class="section-title">Room Availability</h2>
</div>

<!-- Room Statistics -->
<% if (roomCapacity != null && occupiedByType != null) { %>
<div class="stats-grid">
    <div class="stat-card">
        <div class="stat-value">
            <%= roomCapacity.getOrDefault("standard", 0) - occupiedByType.getOrDefault("standard", 0) %>
            / <%= roomCapacity.getOrDefault("standard", 0) %>
        </div>
        <div class="stat-label">Standard Rooms</div>
    </div>
    <div class="stat-card">
        <div class="stat-value">
            <%= roomCapacity.getOrDefault("deluxe", 0) - occupiedByType.getOrDefault("deluxe", 0) %>
            / <%= roomCapacity.getOrDefault("deluxe", 0) %>
        </div>
        <div class="stat-label">Deluxe Rooms</div>
    </div>
    <div class="stat-card">
        <div class="stat-value">
            <%= roomCapacity.getOrDefault("suite", 0) - occupiedByType.getOrDefault("suite", 0) %>
            / <%= roomCapacity.getOrDefault("suite", 0) %>
        </div>
        <div class="stat-label">Suites</div>
    </div>
    <div class="stat-card">
        <div class="stat-value">
            <%= roomCapacity.getOrDefault("presidential", 0) - occupiedByType.getOrDefault("presidential", 0) %>
            / <%= roomCapacity.getOrDefault("presidential", 0) %>
        </div>
        <div class="stat-label">Presidential</div>
    </div>
</div>
<% } %>

<!-- Filter Section -->
<div class="search-section">
    <form action="<%= request.getContextPath() %>/manager" method="post" class="search-form">
        <input type="hidden" name="action" value="filterRooms">
        <div class="form-group">
            <label>Filter by Room Type</label>
            <select name="roomType">
                <option value="all" <%= "all".equals(filterRoomType) ? "selected" : "" %>>All Rooms</option>
                <option value="standard" <%= "standard".equals(filterRoomType) ? "selected" : "" %>>Standard</option>
                <option value="deluxe" <%= "deluxe".equals(filterRoomType) ? "selected" : "" %>>Deluxe</option>
                <option value="suite" <%= "suite".equals(filterRoomType) ? "selected" : "" %>>Suite</option>
                <option value="presidential" <%= "presidential".equals(filterRoomType) ? "selected" : "" %>>Presidential</option>
            </select>
        </div>
        <button type="submit" class="btn btn-primary">Filter</button>
        <% if (filterRoomType != null && !"all".equals(filterRoomType)) { %>
            <a href="<%= request.getContextPath() %>/manager/rooms" class="btn btn-secondary">Clear</a>
        <% } %>
    </form>
</div>

<!-- Rooms Table -->
<div class="data-table">
    <table>
        <thead>
            <tr>
                <th>Room Number</th>
                <th>Floor</th>
                <th>Room Type</th>
                <th>Capacity</th>
                <th>Rate (per night)</th>
                <th>Status</th>
                <th>Cleaning Status</th>
            </tr>
        </thead>
        <tbody>
            <% 
            if (allRooms != null && !allRooms.isEmpty()) {
                for (Room room : allRooms) {
                    String status = room.getStatus() != null ? 
                        room.getStatus() : "available";
                    String cleaningStatus = room.getCleaningStatus() != null ? 
                        room.getCleaningStatus() : "clean";
            %>
            <tr>
                <td><strong><%= room.getRoomNumber() %></strong></td>
                <td><%= room.getFloor() %></td>
                <td><%= room.getRoomType() %></td>
                <td><%= room.getMaxOccupancy() %> guests</td>
                <td>LKR <%= String.format("%,.2f", room.getPricePerNight()) %></td>
                <td>
                    <span class="status-badge <%= "available".equals(status) ? "status-clean" : "status-checked-in" %>">
                        <%= status.toUpperCase() %>
                    </span>
                </td>
                <td>
                    <span class="status-badge status-<%= cleaningStatus %>">
                        <%= cleaningStatus.toUpperCase() %>
                    </span>
                </td>
            </tr>
            <% 
                }
            } else {
            %>
            <tr>
                <td colspan="8" style="text-align: center; padding: 20px;">No rooms found</td>
            </tr>
            <% } %>
        </tbody>
    </table>
</div>
