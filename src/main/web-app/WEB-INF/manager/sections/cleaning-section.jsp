<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.HashMap" %>
<%@ page import="model.Room" %>
<%@ page import="model.CleaningRequest" %>
<%@ page import="model.Guest" %>
<%@ page import="java.time.format.DateTimeFormatter" %>

<%
    List<Room> allRooms = (List<Room>) request.getAttribute("allRooms");
    List<CleaningRequest> cleaningRequests = (List<CleaningRequest>) request.getAttribute("cleaningRequests");
    List<Guest> allGuests = (List<Guest>) request.getAttribute("allGuests");
    
    // Create a map for quick guest lookup
    Map<Integer, Guest> guestMap = new HashMap<>();
    if (allGuests != null) {
        for (Guest g : allGuests) {
            guestMap.put(g.getId(), g);
        }
    }
    
    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("MMM dd, yyyy hh:mm a");
%>

<div class="section-header">
    <h2 class="section-title">Cleaning Service Management</h2>
</div>

<!-- Cleaning Statistics -->
<%
    int cleanRooms = 0;
    int dirtyRooms = 0;
    int cleaningRooms = 0;
    
    if (allRooms != null) {
        for (Room room : allRooms) {
            String status = room.getCleaningStatus() != null ? room.getCleaningStatus() : "clean";
            if ("clean".equals(status)) cleanRooms++;
            else if ("dirty".equals(status)) dirtyRooms++;
            else if ("cleaning".equals(status)) cleaningRooms++;
        }
    }
%>

<div class="stats-grid">
    <div class="stat-card">
        <div class="stat-value" style="color: #388e3c;"><%= cleanRooms %></div>
        <div class="stat-label">Clean Rooms</div>
    </div>
    <div class="stat-card">
        <div class="stat-value" style="color: #f57c00;"><%= cleaningRooms %></div>
        <div class="stat-label">Currently Cleaning</div>
    </div>
    <div class="stat-card">
        <div class="stat-value" style="color: #d32f2f;"><%= dirtyRooms %></div>
        <div class="stat-label">Needs Cleaning</div>
    </div>
    <div class="stat-card">
        <div class="stat-value"><%= allRooms != null ? allRooms.size() : 0 %></div>
        <div class="stat-label">Total Rooms</div>
    </div>
</div>

<!-- Rooms By Cleaning Status -->
<div class="data-table">
    <table>
        <thead>
            <tr>
                <th>Room Number</th>
                <th>Floor</th>
                <th>Room Type</th>
                <th>Availability</th>
                <th>Cleaning Status</th>
                <th>Update Status</th>
            </tr>
        </thead>
        <tbody>
            <% 
            if (allRooms != null && !allRooms.isEmpty()) {
                for (Room room : allRooms) {
                    String cleaningStatus = room.getCleaningStatus() != null ? 
                        room.getCleaningStatus() : "clean";
                    String availabilityStatus = room.getStatus() != null ? 
                        room.getStatus() : "available";
            %>
            <tr>
                <td><strong><%= room.getRoomNumber() %></strong></td>
                <td><%= room.getFloor() %></td>
                <td><%= room.getRoomType() %></td>
                <td>
                    <span class="status-badge <%= "available".equals(availabilityStatus) ? "status-clean" : "status-checked-in" %>">
                        <%= availabilityStatus.toUpperCase() %>
                    </span>
                </td>
                <td>
                    <span class="status-badge status-<%= cleaningStatus %>">
                        <%= cleaningStatus.toUpperCase() %>
                    </span>
                </td>
                <td>
                    <form action="<%= request.getContextPath() %>/manager" method="post" style="display: inline;">
                        <input type="hidden" name="action" value="updateCleaningStatus">
                        <input type="hidden" name="roomId" value="<%= room.getId() %>">
                        <select name="status" onchange="this.form.submit()" style="padding: 6px; border: 1px solid #ddd; border-radius: 4px;">
                            <option value="">-- Update --</option>
                            <option value="clean">Clean</option>
                            <option value="cleaning">Cleaning</option>
                            <option value="dirty">Dirty</option>
                        </select>
                    </form>
                    
                    <!-- Alternative buttons for no-JS -->
                    <details style="display: inline;">
                        <summary class="btn btn-primary" style="list-style: none; cursor: pointer;">Update</summary>
                        <div style="position: absolute; background: white; border: 1px solid #ddd; padding: 10px; border-radius: 4px; z-index: 10; margin-top: 5px;">
                            <form action="<%= request.getContextPath() %>/manager" method="post">
                                <input type="hidden" name="action" value="updateCleaningStatus">
                                <input type="hidden" name="roomId" value="<%= room.getId() %>">
                                <input type="hidden" name="status" value="clean">
                                <button type="submit" class="btn btn-success" style="display: block; width: 100%; margin: 2px;">Mark Clean</button>
                            </form>
                            <form action="<%= request.getContextPath() %>/manager" method="post">
                                <input type="hidden" name="action" value="updateCleaningStatus">
                                <input type="hidden" name="roomId" value="<%= room.getId() %>">
                                <input type="hidden" name="status" value="cleaning">
                                <button type="submit" class="btn btn-warning" style="display: block; width: 100%; margin: 2px;">Set Cleaning</button>
                            </form>
                            <form action="<%= request.getContextPath() %>/manager" method="post">
                                <input type="hidden" name="action" value="updateCleaningStatus">
                                <input type="hidden" name="roomId" value="<%= room.getId() %>">
                                <input type="hidden" name="status" value="dirty">
                                <button type="submit" class="btn btn-danger" style="display: block; width: 100%; margin: 2px;">Mark Dirty</button>
                            </form>
                        </div>
                    </details>
                </td>
            </tr>
            <% 
                }
            } else {
            %>
            <tr>
                <td colspan="6" style="text-align: center; padding: 20px;">No rooms found</td>
            </tr>
            <% } %>
        </tbody>
    </table>
</div>

<!-- Guest Cleaning Requests -->
<div class="section-header" style="margin-top: 40px;">
    <h2 class="section-title">Guest Cleaning Requests</h2>
</div>

<%
    int pendingRequests = 0;
    int inProgressRequests = 0;
    int completedRequests = 0;
    
    if (cleaningRequests != null) {
        for (CleaningRequest req : cleaningRequests) {
            if ("pending".equals(req.getRequestStatus())) pendingRequests++;
            else if ("in-progress".equals(req.getRequestStatus())) inProgressRequests++;
            else if ("completed".equals(req.getRequestStatus())) completedRequests++;
        }
    }
%>

<div class="stats-grid">
    <div class="stat-card">
        <div class="stat-value" style="color: #f57c00;"><%= pendingRequests %></div>
        <div class="stat-label">Pending Requests</div>
    </div>
    <div class="stat-card">
        <div class="stat-value" style="color: #1976d2;"><%= inProgressRequests %></div>
        <div class="stat-label">In Progress</div>
    </div>
    <div class="stat-card">
        <div class="stat-value" style="color: #388e3c;"><%= completedRequests %></div>
        <div class="stat-label">Completed</div>
    </div>
    <div class="stat-card">
        <div class="stat-value"><%= cleaningRequests != null ? cleaningRequests.size() : 0 %></div>
        <div class="stat-label">Total Requests</div>
    </div>
</div>

<div class="data-table">
    <table>
        <thead>
            <tr>
                <th>Request ID</th>
                <th>Guest Name</th>
                <th>Room</th>
                <th>Type</th>
                <th>Priority</th>
                <th>Status</th>
                <th>Requested At</th>
                <th>Instructions</th>
                <th>Actions</th>
            </tr>
        </thead>
        <tbody>
            <% 
            if (cleaningRequests != null && !cleaningRequests.isEmpty()) {
                for (CleaningRequest req : cleaningRequests) {
                    Guest requestGuest = guestMap.get(req.getGuestId());
                    String guestName = requestGuest != null ? requestGuest.getFullName() : "Unknown";
                    String statusColor = "pending".equals(req.getRequestStatus()) ? "status-dirty" : 
                                       "in-progress".equals(req.getRequestStatus()) ? "status-cleaning" :
                                       "completed".equals(req.getRequestStatus()) ? "status-clean" : "";
            %>
            <tr>
                <td><strong>#<%= req.getId() %></strong></td>
                <td><%= guestName %></td>
                <td><strong><%= req.getRoomNumber() %></strong></td>
                <td><%= req.getRequestType() %></td>
                <td>
                    <% if ("urgent".equals(req.getPriority())) { %>
                    <span style="color: #d32f2f; font-weight: bold;">⚠ URGENT</span>
                    <% } else { %>
                    <%= req.getPriority() %>
                    <% } %>
                </td>
                <td>
                    <span class="status-badge <%= statusColor %>">
                        <%= req.getRequestStatus().toUpperCase() %>
                    </span>
                </td>
                <td><%= req.getRequestedAt() != null ? req.getRequestedAt().format(formatter) : "N/A" %></td>
                <td>
                    <% if (req.getSpecialInstructions() != null && !req.getSpecialInstructions().trim().isEmpty()) { %>
                    <details style="cursor: pointer;">
                        <summary style="color: #1976d2;">View</summary>
                        <div style="margin-top: 5px; padding: 8px; background: #f5f5f5; border-radius: 4px; font-size: 13px;">
                            <%= req.getSpecialInstructions() %>
                        </div>
                    </details>
                    <% } else { %>
                    <span style="color: #999;">-</span>
                    <% } %>
                </td>
                <td>
                    <% if (!"completed".equals(req.getRequestStatus()) && !"cancelled".equals(req.getRequestStatus())) { %>
                    <form action="<%= request.getContextPath() %>/manager" method="post" style="display: inline;">
                        <input type="hidden" name="action" value="updateCleaningRequest">
                        <input type="hidden" name="requestId" value="<%= req.getId() %>">
                        <select name="newStatus" onchange="this.form.submit()" style="padding: 4px; border: 1px solid #ddd; border-radius: 4px; font-size: 13px;">
                            <option value="">-- Update --</option>
                            <option value="pending" <%= "pending".equals(req.getRequestStatus()) ? "selected" : "" %>>Pending</option>
                            <option value="in-progress" <%= "in-progress".equals(req.getRequestStatus()) ? "selected" : "" %>>In Progress</option>
                            <option value="completed">Completed</option>
                            <option value="cancelled">Cancelled</option>
                        </select>
                    </form>
                    <% } else { %>
                    <span style="color: #999;">-</span>
                    <% } %>
                </td>
            </tr>
            <% 
                }
            } else {
            %>
            <tr>
                <td colspan="9" style="text-align: center; padding: 20px; color: #666;">
                    No cleaning requests from guests yet.
                </td>
            </tr>
            <% } %>
        </tbody>
    </table>
</div>

<!-- Quick Actions -->
<div class="form-section">
    <h3>Quick Actions</h3>
    <p>Use the buttons next to each room to update cleaning status. The cleaning service team can mark rooms as:</p>
    <ul>
        <li><strong>Clean:</strong> Room has been cleaned and is ready for guests</li>
        <li><strong>Cleaning:</strong> Room is currently being cleaned</li>
        <li><strong>Dirty:</strong> Room needs to be cleaned</li>
    </ul>
</div>
