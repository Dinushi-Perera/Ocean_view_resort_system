<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.time.*, java.time.format.*" %>
<%@ page import="model.Booking, model.Guest, model.Room, model.Staff, model.CleaningRequest" %>
<%
    String currentPage  = (String) request.getAttribute("currentPage");
    if (currentPage == null) currentPage = "dashboard";
    String staffName    = (String) request.getAttribute("staffName");
    if (staffName == null) staffName = "Admin";
    String successMsg   = (String) request.getAttribute("successMessage");
    String errorMsg     = (String) request.getAttribute("errorMessage");
    Map<String,Integer> stats    = (Map<String,Integer>) request.getAttribute("stats");
    List<Booking>  allBookings   = (List<Booking>)  request.getAttribute("allBookings");
    List<Booking>  recentBookings= (List<Booking>)  request.getAttribute("recentBookings");
    List<Guest>    allGuests     = (List<Guest>)    request.getAttribute("allGuests");
    List<Room>     allRooms      = (List<Room>)     request.getAttribute("allRooms");
    List<Staff>    allStaff      = (List<Staff>)    request.getAttribute("allStaff");
    List<CleaningRequest> cleaningRequests = (List<CleaningRequest>) request.getAttribute("cleaningRequests");
    DateTimeFormatter fmt = DateTimeFormatter.ofPattern("MMM dd, yyyy");
    String ctx = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard – Ocean View Resort</title>
    <link rel="stylesheet" href="<%= ctx %>/style/styles.css">
<style>
*{box-sizing:border-box}
body{font-family:'Segoe UI',sans-serif;background:#f0f2f5;color:#333;margin:0}
.app-header{position:fixed;top:0;left:0;right:0;height:60px;background:#00695c;color:#fff;
    display:flex;align-items:center;justify-content:space-between;padding:0 20px;z-index:1000;
    box-shadow:0 2px 6px rgba(0,0,0,.25)}
.app-logo{font-size:20px;font-weight:700}
.user-info{display:flex;align-items:center;gap:14px}
.user-badge{background:#004d40;padding:3px 10px;border-radius:20px;font-size:12px;font-weight:600}
.logout-btn{background:#d32f2f;color:#fff;border:none;padding:6px 14px;border-radius:4px;cursor:pointer;font-size:13px}
.logout-btn:hover{background:#b71c1c}
.sidebar{position:fixed;top:60px;left:0;width:230px;bottom:0;background:#00695c;overflow-y:auto;padding:10px 0;z-index:800}
.nav-menu{list-style:none;margin:0;padding:0}
.nav-link{display:flex;align-items:center;gap:10px;padding:12px 20px;color:#b2dfdb;text-decoration:none;font-size:14px;transition:.2s}
.nav-link:hover,.nav-link.active{background:#00897b;color:#fff}
.nav-icon{font-size:17px;width:22px;text-align:center}
.main-content{margin-left:230px;margin-top:60px;padding:24px;min-height:calc(100vh - 60px)}
.alert{padding:12px 18px;border-radius:5px;margin-bottom:18px;font-size:14px}
.alert-success{background:#c8e6c9;color:#1b5e20;border:1px solid #4caf50}
.alert-error{background:#ffcdd2;color:#b71c1c;border:1px solid #ef9a9a}
.section-header{display:flex;justify-content:space-between;align-items:center;margin-bottom:22px;flex-wrap:wrap;gap:10px}
.section-title{font-size:22px;font-weight:700;color:#00695c}
.stats-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(160px,1fr));gap:16px;margin-bottom:26px}
.stat-card{background:#fff;padding:20px;border-radius:10px;box-shadow:0 2px 6px rgba(0,0,0,.08);text-align:center}
.stat-value{font-size:34px;font-weight:700;color:#00796b}
.stat-label{color:#777;margin-top:5px;font-size:13px}
.data-table{background:#fff;border-radius:10px;overflow:hidden;box-shadow:0 2px 6px rgba(0,0,0,.08);margin-bottom:22px;overflow-x:auto}
.data-table table{width:100%;border-collapse:collapse;min-width:600px}
.data-table th{background:#00796b;color:#fff;padding:11px 14px;text-align:left;font-size:13px;white-space:nowrap}
.data-table td{padding:11px 14px;border-bottom:1px solid #f0f0f0;font-size:13px;vertical-align:middle}
.data-table tr:last-child td{border-bottom:none}
.data-table tr:hover td{background:#f5faf9}
.badge{padding:3px 9px;border-radius:12px;font-size:11px;font-weight:600;white-space:nowrap;display:inline-block}
.badge-confirmed{background:#c8e6c9;color:#1b5e20}
.badge-checked-in{background:#b3e5fc;color:#01579b}
.badge-checked-out{background:#f0f4c3;color:#827717}
.badge-cancelled{background:#ffcdd2;color:#c62828}
.badge-pending{background:#fff3e0;color:#e65100}
.badge-available{background:#c8e6c9;color:#1b5e20}
.badge-occupied{background:#ffcdd2;color:#c62828}
.badge-admin{background:#e1bee7;color:#4a148c}
.badge-manager{background:#bbdefb;color:#0d47a1}
.badge-receptionist{background:#dcedc8;color:#33691e}
.badge-active{background:#c8e6c9;color:#1b5e20}
.badge-inactive{background:#ffcdd2;color:#b71c1c}
.btn{display:inline-block;padding:7px 15px;border:none;border-radius:5px;cursor:pointer;font-size:13px;text-decoration:none;margin:2px;transition:.15s}
.btn:hover{opacity:.87}
.btn-primary{background:#00796b;color:#fff}
.btn-secondary{background:#0288d1;color:#fff}
.btn-success{background:#388e3c;color:#fff}
.btn-warning{background:#f57c00;color:#fff}
.btn-danger{background:#c62828;color:#fff}
.btn-sm{padding:5px 10px;font-size:12px}
.form-section{background:#fff;padding:22px;border-radius:10px;box-shadow:0 2px 6px rgba(0,0,0,.08);margin-bottom:22px}
.form-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(210px,1fr));gap:14px}
.form-group{display:flex;flex-direction:column;gap:5px}
.form-group label{font-size:13px;font-weight:600;color:#555}
.form-group input,.form-group select,.form-group textarea{padding:8px 10px;border:1px solid #ccc;border-radius:5px;font-size:13px;font-family:inherit}
.form-group input:focus,.form-group select:focus,.form-group textarea:focus{outline:none;border-color:#00796b;box-shadow:0 0 0 2px rgba(0,121,107,.15)}
.bill-details{background:#fff;padding:22px;border-radius:10px;box-shadow:0 2px 6px rgba(0,0,0,.08);margin-bottom:22px}
.bill-row{display:flex;justify-content:space-between;padding:9px 0;border-bottom:1px solid #f0f0f0;font-size:14px}
.bill-row.total{font-weight:700;font-size:16px;border-bottom:none;color:#00695c}
.modal-overlay{display:none;position:fixed;inset:0;background:rgba(0,0,0,.45);z-index:2000;align-items:center;justify-content:center}
.modal-overlay.open{display:flex}
.modal{background:#fff;border-radius:12px;padding:28px;max-width:560px;width:95%;max-height:90vh;overflow-y:auto;box-shadow:0 8px 30px rgba(0,0,0,.2)}
.modal h3{font-size:18px;color:#00695c;margin-bottom:18px}
.modal-footer{display:flex;justify-content:flex-end;gap:10px;margin-top:16px}
@media(max-width:768px){.sidebar{transform:translateX(-100%);transition:.3s}.sidebar.open{transform:translateX(0)}.main-content{margin-left:0}}
</style>
</head>
<body>
<!-- Header -->
<header class="app-header">
    <div style="display:flex;align-items:center;gap:14px">
        <button onclick="document.getElementById('sidebar').classList.toggle('open')"
            style="background:none;border:none;color:#fff;font-size:22px;cursor:pointer">&#9776;</button>
        <div class="app-logo">Ocean View Resort</div>
    </div>
    <div class="user-info">
        <span class="user-badge">Administrator</span>
        <span style="font-size:14px">Welcome, <%= staffName %></span>
        <form action="<%= ctx %>/staff-logout" method="post" style="display:inline">
            <button type="submit" class="logout-btn">Logout</button>
        </form>
    </div>
</header>

<!-- Sidebar -->
<nav class="sidebar" id="sidebar">
    <ul class="nav-menu">
        <li><a href="<%= ctx %>/admin/dashboard"    class="nav-link <%= "dashboard".equals(currentPage)    ? "active":"" %>"><span class="nav-icon">&#128202;</span> Dashboard</a></li>
        <li><a href="<%= ctx %>/admin/reservations" class="nav-link <%= "reservations".equals(currentPage) ? "active":"" %>"><span class="nav-icon">&#128203;</span> Reservations</a></li>
        <li><a href="<%= ctx %>/admin/rooms"        class="nav-link <%= "rooms".equals(currentPage)        ? "active":"" %>"><span class="nav-icon">&#128716;</span> Room Availability</a></li>
        <li><a href="<%= ctx %>/admin/checkin"      class="nav-link <%= "checkin".equals(currentPage)      ? "active":"" %>"><span class="nav-icon">&#9989;</span> Check-in / Check-out</a></li>
        <li><a href="<%= ctx %>/admin/cleaning"     class="nav-link <%= "cleaning".equals(currentPage)     ? "active":"" %>"><span class="nav-icon">&#129529;</span> Cleaning Service</a></li>
        <li><a href="<%= ctx %>/admin/billing"      class="nav-link <%= "billing".equals(currentPage)      ? "active":"" %>"><span class="nav-icon">&#128176;</span> Billing</a></li>
        <li><a href="<%= ctx %>/admin/staff"        class="nav-link <%= "staff".equals(currentPage)        ? "active":"" %>"><span class="nav-icon">&#128101;</span> Staff Management</a></li>
        <li><a href="<%= ctx %>/admin/help"         class="nav-link <%= "help".equals(currentPage)         ? "active":"" %>"><span class="nav-icon">&#10067;</span> Help &amp; Guide</a></li>
        <li><a href="<%= ctx %>/"                   class="nav-link"><span class="nav-icon">&#128682;</span> Exit System</a></li>
    </ul>
</nav>

<!-- Main Content -->
<main class="main-content">
<% if (successMsg != null) { %><div class="alert alert-success">&#10004; <%= successMsg %></div><% } %>
<% if (errorMsg   != null) { %><div class="alert alert-error">&#9888; <%= errorMsg %></div><% } %>

<%-- ═══════════════════ DASHBOARD ══════════════════════════════════════════ --%>
<% if ("dashboard".equals(currentPage)) { %>
<div class="section-header">
    <h2 class="section-title">&#128202; Dashboard Overview</h2>
    <small style="color:#777">Today: <%= LocalDate.now().format(fmt) %></small>
</div>
<div class="stats-grid">
    <div class="stat-card"><div class="stat-value"><%= stats!=null?stats.getOrDefault("totalRooms",0):0 %></div><div class="stat-label">Total Rooms</div></div>
    <div class="stat-card"><div class="stat-value"><%= stats!=null?stats.getOrDefault("occupiedRooms",0):0 %></div><div class="stat-label">Occupied</div></div>
    <div class="stat-card"><div class="stat-value"><%= stats!=null?stats.getOrDefault("availableRooms",0):0 %></div><div class="stat-label">Available</div></div>
    <div class="stat-card"><div class="stat-value"><%= stats!=null?stats.getOrDefault("todayCheckins",0):0 %></div><div class="stat-label">Today Check-ins</div></div>
    <div class="stat-card"><div class="stat-value"><%= stats!=null?stats.getOrDefault("pendingCheckouts",0):0 %></div><div class="stat-label">Pending Checkouts</div></div>
    <div class="stat-card"><div class="stat-value"><%= stats!=null?stats.getOrDefault("totalBookings",0):0 %></div><div class="stat-label">Total Bookings</div></div>
    <div class="stat-card"><div class="stat-value"><%= stats!=null?stats.getOrDefault("totalStaff",0):0 %></div><div class="stat-label">Active Staff</div></div>
</div>
<h3 style="margin-bottom:12px;color:#00695c">Recent Reservations</h3>
<div class="data-table"><table>
    <thead><tr><th>#</th><th>Guest</th><th>Room Type</th><th>Check-in</th><th>Check-out</th><th>Status</th></tr></thead>
    <tbody>
    <% if (recentBookings!=null && !recentBookings.isEmpty()) {
        for (Booking b : recentBookings) {
            Guest g=null; if(allGuests!=null) for(Guest gg:allGuests){if(gg.getId()==b.getGuestId()){g=gg;break;}}
            String st=b.getBookingStatus()!=null?b.getBookingStatus():"pending"; %>
    <tr>
        <td>#<%= b.getId() %></td>
        <td><%= g!=null?g.getFullName():"Guest #"+b.getGuestId() %></td>
        <td style="text-transform:capitalize"><%= b.getRoomType() %></td>
        <td><%= b.getCheckIn().format(fmt) %></td>
        <td><%= b.getCheckOut().format(fmt) %></td>
        <td><span class="badge badge-<%= st.replace(" ","-") %>"><%= st.toUpperCase() %></span></td>
    </tr>
    <% }} else { %><tr><td colspan="6" style="text-align:center;color:#999">No bookings yet</td></tr><% } %>
    </tbody>
</table></div>

<%-- ═══════════════════ RESERVATIONS ═══════════════════════════════════════ --%>
<% } else if ("reservations".equals(currentPage)) { %>
<div class="section-header">
    <h2 class="section-title">&#128203; Reservations</h2>
    <button class="btn btn-primary" onclick="document.getElementById('newResModal').classList.add('open')">+ New Reservation</button>
</div>
<div class="form-section" style="padding:14px">
    <form method="post" action="<%= ctx %>/admin/reservations" style="display:flex;gap:10px;flex-wrap:wrap;align-items:flex-end">
        <input type="hidden" name="action" value="searchReservations">
        <div class="form-group" style="flex:1;min-width:200px">
            <label>Search (ID / name / contact)</label>
            <input type="text" name="searchQuery" value="<%= request.getAttribute("searchQuery")!=null?request.getAttribute("searchQuery"):"" %>">
        </div>
        <button type="submit" class="btn btn-primary">Search</button>
        <a href="<%= ctx %>/admin/reservations" class="btn btn-secondary">Clear</a>
    </form>
</div>
<div class="data-table"><table>
    <thead><tr><th>#</th><th>Guest</th><th>Contact</th><th>Type</th><th>Guests</th><th>Check-in</th><th>Check-out</th><th>Status</th><th>Action</th></tr></thead>
    <tbody>
    <% if (allBookings!=null && !allBookings.isEmpty()) {
        for (Booking b : allBookings) {
            Guest g=null; if(allGuests!=null) for(Guest gg:allGuests){if(gg.getId()==b.getGuestId()){g=gg;break;}}
            String st=b.getBookingStatus()!=null?b.getBookingStatus():"pending"; %>
    <tr>
        <td>#<%= b.getId() %></td>
        <td><%= g!=null?g.getFullName():"Guest #"+b.getGuestId() %></td>
        <td><%= g!=null?g.getContact():"-" %></td>
        <td style="text-transform:capitalize"><%= b.getRoomType() %></td>
        <td><%= b.getNumGuests() %></td>
        <td><%= b.getCheckIn().format(fmt) %></td>
        <td><%= b.getCheckOut().format(fmt) %></td>
        <td><span class="badge badge-<%= st.replace(" ","-") %>"><%= st.toUpperCase() %></span></td>
        <td>
            <% if(!"cancelled".equals(st) && !"checked-out".equals(st)) { %>
            <form method="post" action="<%= ctx %>/admin/reservations" style="display:inline">
                <input type="hidden" name="action" value="cancelReservation">
                <input type="hidden" name="bookingId" value="<%= b.getId() %>">
                <button type="submit" class="btn btn-danger btn-sm" onclick="return confirm('Cancel booking #<%= b.getId() %>?')">Cancel</button>
            </form>
            <% } %>
        </td>
    </tr>
    <% }} else { %><tr><td colspan="9" style="text-align:center;color:#999">No reservations found</td></tr><% } %>
    </tbody>
</table></div>

<!-- New Reservation Modal -->
<div class="modal-overlay" id="newResModal">
<div class="modal">
    <h3>&#128203; New Reservation</h3>
    <form method="post" action="<%= ctx %>/admin/reservations">
        <input type="hidden" name="action" value="createReservation">
        <div class="form-grid">
            <div class="form-group"><label>Guest Full Name *</label><input type="text" name="guestName" required></div>
            <div class="form-group"><label>Contact *</label><input type="text" name="guestContact" required></div>
            <div class="form-group"><label>Email *</label><input type="email" name="guestEmail" required></div>
            <div class="form-group"><label>NIC</label><input type="text" name="guestNic"></div>
            <div class="form-group"><label>Room Type *</label>
                <select name="roomType" required>
                    <option value="standard">Standard</option>
                    <option value="deluxe">Deluxe</option>
                    <option value="suite">Suite</option>
                    <option value="presidential">Presidential</option>
                </select>
            </div>
            <div class="form-group"><label>No. of Guests *</label><input type="number" name="numGuests" min="1" max="6" value="1" required></div>
            <div class="form-group"><label>Check-in *</label><input type="date" name="checkinDate" required></div>
            <div class="form-group"><label>Check-out *</label><input type="date" name="checkoutDate" required></div>
            <div class="form-group" style="grid-column:1/-1"><label>Special Requests</label><textarea name="specialRequests" rows="2"></textarea></div>
            <div class="form-group" style="grid-column:1/-1; display: flex; align-items: center; gap: 10px;">
                <input type="checkbox" name="sendEmail" id="sendEmailAdmin" value="true" checked style="width: auto;">
                <label for="sendEmailAdmin" style="margin: 0; font-weight: 500; cursor: pointer;">&#9993; Send confirmation email to guest</label>
            </div>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn btn-secondary" onclick="document.getElementById('newResModal').classList.remove('open')">Cancel</button>
            <button type="submit" class="btn btn-primary">Create</button>
        </div>
    </form>
</div>
</div>

<%-- ═══════════════════ ROOMS ════════════════════════════════════════════════ --%>
<% } else if ("rooms".equals(currentPage)) { %>
<div class="section-header">
    <h2 class="section-title">&#128716; Room Availability</h2>
    <form method="post" action="<%= ctx %>/admin/rooms" style="display:flex;gap:8px">
        <input type="hidden" name="action" value="filterRooms">
        <select name="roomType" style="padding:7px 10px;border:1px solid #ccc;border-radius:5px;font-size:13px">
            <option value="all">All Types</option>
            <option value="standard">Standard</option>
            <option value="deluxe">Deluxe</option>
            <option value="suite">Suite</option>
            <option value="presidential">Presidential</option>
        </select>
        <button type="submit" class="btn btn-primary">Filter</button>
    </form>
</div>
<div class="data-table"><table>
    <thead><tr><th>Room No.</th><th>Type</th><th>Floor</th><th>Capacity</th><th>Price/Night</th><th>Status</th><th>Cleaning</th></tr></thead>
    <tbody>
    <% if (allRooms!=null && !allRooms.isEmpty()) {
        for (Room r : allRooms) {
            String rs=r.getStatus()!=null?r.getStatus():"available";
            String cs=r.getCleaningStatus()!=null?r.getCleaningStatus():"clean"; %>
    <tr>
        <td><strong><%= r.getRoomNumber() %></strong></td>
        <td style="text-transform:capitalize"><%= r.getRoomType() %></td>
        <td>Floor <%= r.getFloor() %></td>
        <td><%= r.getMaxOccupancy() %> pax</td>
        <td>LKR<%= r.getPricePerNight() %></td>
        <td><span class="badge badge-<%= rs %>"><%= rs.toUpperCase() %></span></td>
        <td><span class="badge" style="background:<%= "clean".equals(cs)?"#c8e6c9":"dirty".equals(cs)?"#ffcdd2":"#fff9c4" %>;color:<%= "clean".equals(cs)?"#1b5e20":"dirty".equals(cs)?"#b71c1c":"#f57f17" %>"><%= cs.toUpperCase() %></span></td>
    </tr>
    <% }} else { %><tr><td colspan="7" style="text-align:center;color:#999">No rooms found</td></tr><% } %>
    </tbody>
</table></div>

<%-- ═══════════════════ CHECK-IN / CHECK-OUT ══════════════════════════════════ --%>
<% } else if ("checkin".equals(currentPage)) {
    List<Booking> todayCheckins  = (List<Booking>) request.getAttribute("todayCheckins");
    List<Booking> todayCheckouts = (List<Booking>) request.getAttribute("todayCheckouts"); %>
<div class="section-header"><h2 class="section-title">&#9989; Check-in / Check-out</h2></div>

<h3 style="margin-bottom:10px;color:#2e7d32">Today's Check-ins (<%= todayCheckins!=null?todayCheckins.size():0 %>)</h3>
<div class="data-table" style="margin-bottom:26px"><table>
    <thead><tr><th>#</th><th>Guest</th><th>Room Type</th><th>Guests</th><th>Check-out</th><th>Action</th></tr></thead>
    <tbody>
    <% if (todayCheckins!=null && !todayCheckins.isEmpty()) {
        for (Booking b : todayCheckins) {
            Guest g=null; if(allGuests!=null) for(Guest gg:allGuests){if(gg.getId()==b.getGuestId()){g=gg;break;}} %>
    <tr>
        <td>#<%= b.getId() %></td><td><%= g!=null?g.getFullName():"Guest #"+b.getGuestId() %></td>
        <td style="text-transform:capitalize"><%= b.getRoomType() %></td><td><%= b.getNumGuests() %></td>
        <td><%= b.getCheckOut().format(fmt) %></td>
        <td>
            <form method="post" action="<%= ctx %>/admin/checkin" style="display:inline">
                <input type="hidden" name="action" value="checkin">
                <input type="hidden" name="bookingId" value="<%= b.getId() %>">
                <button type="submit" class="btn btn-success btn-sm">Check In</button>
            </form>
        </td>
    </tr>
    <% }} else { %><tr><td colspan="6" style="text-align:center;color:#999">No check-ins for today</td></tr><% } %>
    </tbody>
</table></div>

<h3 style="margin-bottom:10px;color:#e65100">Today's Check-outs (<%= todayCheckouts!=null?todayCheckouts.size():0 %>)</h3>
<div class="data-table"><table>
    <thead><tr><th>#</th><th>Guest</th><th>Room Type</th><th>Check-in</th><th>Action</th></tr></thead>
    <tbody>
    <% if (todayCheckouts!=null && !todayCheckouts.isEmpty()) {
        for (Booking b : todayCheckouts) {
            Guest g=null; if(allGuests!=null) for(Guest gg:allGuests){if(gg.getId()==b.getGuestId()){g=gg;break;}} %>
    <tr>
        <td>#<%= b.getId() %></td><td><%= g!=null?g.getFullName():"Guest #"+b.getGuestId() %></td>
        <td style="text-transform:capitalize"><%= b.getRoomType() %></td><td><%= b.getCheckIn().format(fmt) %></td>
        <td>
            <form method="post" action="<%= ctx %>/admin/checkin" style="display:inline">
                <input type="hidden" name="action" value="checkout">
                <input type="hidden" name="bookingId" value="<%= b.getId() %>">
                <button type="submit" class="btn btn-warning btn-sm">Check Out</button>
            </form>
        </td>
    </tr>
    <% }} else { %><tr><td colspan="5" style="text-align:center;color:#999">No check-outs for today</td></tr><% } %>
    </tbody>
</table></div>

<%-- ═══════════════════ CLEANING ══════════════════════════════════════════════ --%>
<% } else if ("cleaning".equals(currentPage)) { %>
<div class="section-header"><h2 class="section-title">&#129529; Cleaning Service</h2></div>

<h3 style="margin-bottom:10px;color:#00695c">Room Cleaning Status</h3>
<div class="data-table" style="margin-bottom:26px"><table>
    <thead><tr><th>Room No.</th><th>Type</th><th>Room Status</th><th>Cleaning Status</th><th>Update</th></tr></thead>
    <tbody>
    <% if (allRooms!=null) for (Room r : allRooms) {
        String cs=r.getCleaningStatus()!=null?r.getCleaningStatus():"clean"; %>
    <tr>
        <td><%= r.getRoomNumber() %></td>
        <td style="text-transform:capitalize"><%= r.getRoomType() %></td>
        <td><span class="badge badge-<%= r.getStatus()!=null?r.getStatus():"available" %>"><%= (r.getStatus()!=null?r.getStatus():"available").toUpperCase() %></span></td>
        <td><span class="badge" style="background:<%= "clean".equals(cs)?"#c8e6c9":"dirty".equals(cs)?"#ffcdd2":"#fff9c4" %>;color:<%= "clean".equals(cs)?"#1b5e20":"dirty".equals(cs)?"#b71c1c":"#f57f17" %>"><%= cs.toUpperCase() %></span></td>
        <td>
            <form method="post" action="<%= ctx %>/admin/cleaning" style="display:flex;gap:6px;align-items:center">
                <input type="hidden" name="action" value="updateCleaningStatus">
                <input type="hidden" name="roomId" value="<%= r.getId() %>">
                <select name="status" style="padding:5px;border:1px solid #ccc;border-radius:4px;font-size:12px">
                    <option value="clean"    <%= "clean".equals(cs)?"selected":"" %>>Clean</option>
                    <option value="dirty"    <%= "dirty".equals(cs)?"selected":"" %>>Dirty</option>
                    <option value="cleaning" <%= "cleaning".equals(cs)?"selected":"" %>>Cleaning</option>
                </select>
                <button type="submit" class="btn btn-primary btn-sm">Update</button>
            </form>
        </td>
    </tr>
    <% } %>
    </tbody>
</table></div>

<h3 style="margin-bottom:10px;color:#00695c">Guest Cleaning Requests</h3>
<div class="data-table"><table>
    <thead><tr><th>#</th><th>Room</th><th>Guest</th><th>Requested</th><th>Status</th><th>Update</th></tr></thead>
    <tbody>
    <% if (cleaningRequests!=null && !cleaningRequests.isEmpty()) {
        for (CleaningRequest cr : cleaningRequests) {
            Guest g=null; if(allGuests!=null) for(Guest gg:allGuests){if(gg.getId()==cr.getGuestId()){g=gg;break;}}
            String crs=cr.getRequestStatus()!=null?cr.getRequestStatus():"pending";
            String reqAt=cr.getRequestedAt()!=null?cr.getRequestedAt().format(java.time.format.DateTimeFormatter.ofPattern("MMM dd, yyyy HH:mm")):"--"; %>
    <tr>
        <td>#<%= cr.getId() %></td>
        <td><%= cr.getRoomNumber()!=null?cr.getRoomNumber():"-" %></td>
        <td><%= g!=null?g.getFullName():"Guest #"+cr.getGuestId() %></td>
        <td style="font-size:12px"><%= reqAt %></td>
        <td><span class="badge badge-<%= crs.replace(" ","-") %>"><%= crs.toUpperCase() %></span></td>
        <td>
            <form method="post" action="<%= ctx %>/admin/cleaning" style="display:flex;gap:6px;align-items:center">
                <input type="hidden" name="action" value="updateCleaningRequest">
                <input type="hidden" name="requestId" value="<%= cr.getId() %>">
                <select name="newStatus" style="padding:5px;border:1px solid #ccc;border-radius:4px;font-size:12px">
                    <option value="pending"     <%= "pending".equals(crs)?"selected":"" %>>Pending</option>
                    <option value="in-progress" <%= "in-progress".equals(crs)?"selected":"" %>>In Progress</option>
                    <option value="completed"   <%= "completed".equals(crs)?"selected":"" %>>Completed</option>
                </select>
                <button type="submit" class="btn btn-primary btn-sm">Update</button>
            </form>
        </td>
    </tr>
    <% }} else { %><tr><td colspan="6" style="text-align:center;color:#999">No cleaning requests</td></tr><% } %>
    </tbody>
</table></div>

<%-- ═══════════════════ BILLING ════════════════════════════════════════════════ --%>
<% } else if ("billing".equals(currentPage)) {
    Boolean showBill=(Boolean) request.getAttribute("showBill");
    Booking billBooking=(Booking) request.getAttribute("booking");
    Guest billGuest=(Guest) request.getAttribute("guest");
    Map<String,Object> billDetails=(Map<String,Object>) request.getAttribute("billDetails"); %>
<div class="section-header"><h2 class="section-title">&#128176; Billing</h2></div>

<% if (Boolean.TRUE.equals(showBill) && billBooking!=null && billDetails!=null) { %>
<div class="bill-details">
    <h3 style="color:#00695c;margin-bottom:16px">Bill Booking #<%= billBooking.getId() %></h3>
    <% if (billGuest!=null) { %><p style="margin-bottom:10px"><strong>Guest:</strong> <%= billGuest.getFullName() %> &nbsp;|&nbsp; <strong>Contact:</strong> <%= billGuest.getContact() %></p><% } %>
    <div class="bill-row"><span>Room Type</span><span style="text-transform:capitalize"><strong><%= billBooking.getRoomType() %></strong></span></div>
    <div class="bill-row"><span>Rate / Night</span><span>LKR<%= String.format("%.2f",(Double)billDetails.get("roomRate")) %></span></div>
    <div class="bill-row"><span>Nights</span><span><%= billDetails.get("nights") %></span></div>
    <div class="bill-row"><span>Subtotal</span><span>LKR<%= String.format("%.2f",(Double)billDetails.get("subtotal")) %></span></div>
    <div class="bill-row"><span>Service Charge (10%)</span><span>LKR<%= String.format("%.2f",(Double)billDetails.get("serviceCharge")) %></span></div>
    <div class="bill-row"><span>Tax (12%)</span><span>LKR<%= String.format("%.2f",(Double)billDetails.get("tax")) %></span></div>
    <div class="bill-row total"><span>TOTAL</span><span>LKR<%= String.format("%.2f",(Double)billDetails.get("total")) %></span></div>
    <div style="margin-top:14px">
        <button class="btn btn-primary" onclick="window.print()">&#128424; Print Bill</button>
        <a href="<%= ctx %>/admin/billing" class="btn btn-secondary">Back</a>
    </div>
</div>
<% } %>

<div class="data-table"><table>
    <thead><tr><th>#</th><th>Guest</th><th>Room Type</th><th>Check-in</th><th>Check-out</th><th>Status</th><th>Action</th></tr></thead>
    <tbody>
    <% if (allBookings!=null && !allBookings.isEmpty()) {
        for (Booking b : allBookings) {
            Guest g=null; if(allGuests!=null) for(Guest gg:allGuests){if(gg.getId()==b.getGuestId()){g=gg;break;}}
            String st=b.getBookingStatus()!=null?b.getBookingStatus():"pending"; %>
    <tr>
        <td>#<%= b.getId() %></td>
        <td><%= g!=null?g.getFullName():"Guest #"+b.getGuestId() %></td>
        <td style="text-transform:capitalize"><%= b.getRoomType() %></td>
        <td><%= b.getCheckIn().format(fmt) %></td>
        <td><%= b.getCheckOut().format(fmt) %></td>
        <td><span class="badge badge-<%= st.replace(" ","-") %>"><%= st.toUpperCase() %></span></td>
        <td>
            <form method="post" action="<%= ctx %>/admin/billing" style="display:inline">
                <input type="hidden" name="action" value="generateBill">
                <input type="hidden" name="bookingId" value="<%= b.getId() %>">
                <button type="submit" class="btn btn-primary btn-sm">Generate Bill</button>
            </form>
        </td>
    </tr>
    <% }} else { %><tr><td colspan="7" style="text-align:center;color:#999">No billable bookings</td></tr><% } %>
    </tbody>
</table></div>

<%-- ═══════════════════ STAFF MANAGEMENT ══════════════════════════════════════ --%>
<% } else if ("staff".equals(currentPage)) { %>
<div class="section-header">
    <h2 class="section-title">&#128101; Staff Management</h2>
    <button class="btn btn-primary" onclick="document.getElementById('createStaffModal').classList.add('open')">+ Add Staff Member</button>
</div>

<div class="data-table"><table>
    <thead><tr><th>ID</th><th>Name</th><th>Username</th><th>Role</th><th>Email</th><th>Contact</th><th>Status</th><th>Joined</th><th>Actions</th></tr></thead>
    <tbody>
    <% if (allStaff!=null && !allStaff.isEmpty()) {
        for (Staff s : allStaff) { %>
    <tr>
        <td>#<%= s.getId() %></td>
        <td><%= s.getFullName() %></td>
        <td><code><%= s.getUsername() %></code></td>
        <td><span class="badge badge-<%= s.getStaffRole() %>"><%= s.getStaffRole().toUpperCase() %></span></td>
        <td><%= s.getEmail()!=null?s.getEmail():"-" %></td>
        <td><%= s.getContact()!=null?s.getContact():"-" %></td>
        <td><span class="badge <%= s.isActive()?"badge-active":"badge-inactive" %>"><%= s.isActive()?"ACTIVE":"INACTIVE" %></span></td>
        <td style="font-size:12px;color:#777"><%= s.getCreatedAt()!=null&&s.getCreatedAt().length()>=10?s.getCreatedAt().substring(0,10):"-" %></td>
        <td>
            <form method="post" action="<%= ctx %>/admin/staff" style="display:inline">
                <input type="hidden" name="action" value="toggleStaff">
                <input type="hidden" name="staffId" value="<%= s.getId() %>">
                <button type="submit" class="btn btn-warning btn-sm"><%= s.isActive()?"Disable":"Enable" %></button>
            </form>
            <form method="post" action="<%= ctx %>/admin/staff" style="display:inline"
                onsubmit="return confirm('Permanently delete <%= s.getUsername() %>?')">
                <input type="hidden" name="action" value="deleteStaff">
                <input type="hidden" name="staffId" value="<%= s.getId() %>">
                <button type="submit" class="btn btn-danger btn-sm">Delete</button>
            </form>
        </td>
    </tr>
    <% }} else { %><tr><td colspan="9" style="text-align:center;color:#999">No staff members found</td></tr><% } %>
    </tbody>
</table></div>

<!-- Create Staff Modal -->
<div class="modal-overlay" id="createStaffModal">
<div class="modal">
    <h3>&#128101; New Staff Member</h3>
    <form method="post" action="<%= ctx %>/admin/staff">
        <input type="hidden" name="action" value="createStaff">
        <div class="form-grid">
            <div class="form-group"><label>First Name *</label><input type="text" name="firstName" required></div>
            <div class="form-group"><label>Last Name *</label><input type="text" name="lastName" required></div>
            <div class="form-group"><label>Username *</label><input type="text" name="username" required autocomplete="off"></div>
            <div class="form-group"><label>Password *</label><input type="password" name="password" required autocomplete="new-password"></div>
            <div class="form-group"><label>Role *</label>
                <select name="staffRole" required>
                    <option value="receptionist">Receptionist</option>
                    <option value="manager">Manager</option>
                    <option value="admin">Admin</option>
                </select>
            </div>
            <div class="form-group"><label>Email *</label><input type="email" name="email" required></div>
            <div class="form-group" style="grid-column:1/-1"><label>Contact</label><input type="text" name="contact"></div>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn btn-secondary" onclick="document.getElementById('createStaffModal').classList.remove('open')">Cancel</button>
            <button type="submit" class="btn btn-primary">Create Staff</button>
        </div>
    </form>
</div>
</div>

<%-- ═══════════════════ HELP ════════════════════════════════════════════════ --%>
<% } else if ("help".equals(currentPage)) { %>
<div class="section-header"><h2 class="section-title">&#10067; Help &amp; Guide</h2></div>
<div class="form-section">
    <h3 style="color:#00695c;margin-bottom:12px">Admin Dashboard Guide</h3>
    <ul style="line-height:2.2;padding-left:20px;font-size:14px">
        <li><strong>Dashboard</strong> – Live overview: room occupancy, bookings, check-in/out summary, and active staff count.</li>
        <li><strong>Reservations</strong> – View all bookings, create new reservations, or cancel existing ones.</li>
        <li><strong>Room Availability</strong> – Browse all rooms with type, floor, capacity, price and real-time status.</li>
        <li><strong>Check-in / Check-out</strong> – Process today's guest arrivals and departures.</li>
        <li><strong>Cleaning Service</strong> – Update room cleaning statuses; manage guest cleaning requests.</li>
        <li><strong>Billing</strong> – Generate itemised bills (room rate + 10% service charge + 12% tax) for any booking.</li>
        <li><strong>Staff Management</strong> – Create staff accounts, enable/disable access, or permanently delete records.</li>
    </ul>
    <hr style="margin:18px 0;border:none;border-top:1px solid #eee">
    <h4 style="margin-bottom:8px;color:#555">Default Login Credentials</h4>
    <table style="font-size:13px;border-collapse:collapse">
        <tr style="background:#f5f5f5"><th style="padding:8px 20px 8px 8px;text-align:left">Role</th><th style="padding:8px 20px 8px 8px;text-align:left">Username</th><th style="padding:8px;text-align:left">Password</th></tr>
        <tr><td style="padding:6px 20px 6px 8px">Admin</td><td style="padding:6px 20px 6px 8px">admin</td><td style="padding:6px 8px">admin123</td></tr>
        <tr style="background:#f9f9f9"><td style="padding:6px 20px 6px 8px">Manager</td><td style="padding:6px 20px 6px 8px">manager</td><td style="padding:6px 8px">manager123</td></tr>
        <tr><td style="padding:6px 20px 6px 8px">Receptionist</td><td style="padding:6px 20px 6px 8px">receptionist</td><td style="padding:6px 8px">reception123</td></tr>
    </table>
</div>
<% } %>
</main>

<script>
document.querySelectorAll('.modal-overlay').forEach(function(o){
    o.addEventListener('click',function(e){ if(e.target===o) o.classList.remove('open'); });
});
setTimeout(function(){
    document.querySelectorAll('.alert').forEach(function(el){
        el.style.transition='opacity .5s'; el.style.opacity='0';
        setTimeout(function(){el.remove();},500);
    });
},5000);
</script>
</body>
</html>