<%@ page import="java.util.List" %>
<%@ page import="java.util.Map" %>
<%@ page import="model.Booking" %>
<%@ page import="model.Guest" %>
<%@ page import="model.Room" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manager Dashboard - Ocean View Resort</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/style/styles.css">
    <style>
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        .stat-card {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .stat-value {
            font-size: 32px;
            font-weight: bold;
            color: #01579b;
        }
        .stat-label {
            color: #666;
            margin-top: 5px;
        }
        .data-table {
            width: 100%;
            background: white;
            border-radius: 8px;
            overflow: hidden;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .data-table table {
            width: 100%;
            border-collapse: collapse;
        }
        .data-table th {
            background: #01579b;
            color: white;
            padding: 12px;
            text-align: left;
        }
        .data-table td {
            padding: 12px;
            border-bottom: 1px solid #eee;
        }
        .data-table tr:hover {
            background: #f5f5f5;
        }
        .btn {
            padding: 8px 16px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            text-decoration: none;
            display: inline-block;
            margin: 2px;
        }
        .btn-primary {
            background: #0288d1;
            color: white;
        }
        .btn-secondary {
            background: #0288d1;
            color: white;
        }
        .btn-success {
            background: #01579b;
            color: white;
        }
        .btn-warning {
            background: #f57c00;
            color: white;
        }
        .btn-danger {
            background: #d32f2f;
            color: white;
        }
        .form-section {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            margin-bottom: 20px;
        }
        .form-group {
            margin-bottom: 15px;
        }
        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: 500;
        }
        .form-group input,
        .form-group select,
        .form-group textarea {
            width: 100%;
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
        }
        .alert {
            padding: 12px 20px;
            border-radius: 4px;
            margin-bottom: 20px;
        }
        .alert-success {
            background: #c8e6c9;
            color: #01579b;
            border: 1px solid #90a2e8;
        }
        .alert-error {
            background: #ffcdd2;
            color: #c62828;
            border: 1px solid #f44336;
        }
        .status-badge {
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 12px;
            font-weight: bold;
        }
        .status-confirmed {
            background: #c8e6c9;
            color: #01579b;
        }
        .status-checked-in {
            background: #b3e5fc;
            color: #01579b;
        }
        .status-checked-out {
            background: #f0f4c3;
            color: #827717;
        }
        .status-cancelled {
            background: #ffcdd2;
            color: #c62828;
        }
        .status-clean {
            background: #c8e6c9;
            color: #0288d1;
        }
        .status-dirty {
            background: #ffcdd2;
            color: #c62828;
        }
        .status-cleaning {
            background: #fff9c4;
            color: #f57f17;
        }
        .section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        .section-title {
            font-size: 24px;
            font-weight: bold;
            color: #0288d1;
        }
        .search-section {
            background: white;
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .search-form {
            display: flex;
            gap: 10px;
            align-items: flex-end;
        }
        .search-form .form-group {
            margin-bottom: 0;
            flex: 1;
        }
        .bill-details {
            background: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            margin-bottom: 20px;
        }
        .bill-row {
            display: flex;
            justify-content: space-between;
            padding: 10px 0;
            border-bottom: 1px solid #eee;
        }
        .bill-total {
            font-size: 20px;
            font-weight: bold;
            color: #3a3cc6;
            border-top: 2px solid #0288d1;
            padding-top: 10px;
        }
    </style>
</head>
<body>
    <%
        String currentPage = (String) request.getAttribute("currentPage");
        if (currentPage == null) currentPage = "dashboard";
        
        String staffName = (String) request.getAttribute("staffName");
        if (staffName == null) staffName = "Manager";
        
        String successMessage = (String) request.getAttribute("successMessage");
        String errorMessage = (String) request.getAttribute("errorMessage");
    %>

    <div id="main-app">
        <!-- Header -->
        <header class="app-header">
            <div class="header-content">
                <div class="header-left">
                    <div class="app-logo">Ocean View Resort</div>
                </div>
                <div class="user-info">
                    <span class="user-badge">Manager</span>
                    <span>Welcome, <%= staffName %></span>
                    <form action="<%= request.getContextPath() %>/staff-logout" method="post" style="display: inline;">
                        <button type="submit" class="logout-btn">Logout</button>
                    </form>
                </div>
            </div>
        </header>

        <!-- Sidebar -->
        <nav class="sidebar">
            <ul class="nav-menu">
                <li class="nav-item">
                    <a href="<%= request.getContextPath() %>/manager/dashboard" 
                       class="nav-link <%= "dashboard".equals(currentPage) ? "active" : "" %>">
                        <span class="nav-icon">&#128202;</span>
                        Dashboard
                    </a>
                </li>
                <li class="nav-item">
                    <a href="<%= request.getContextPath() %>/manager/reservations" 
                       class="nav-link <%= "reservations".equals(currentPage) ? "active" : "" %>">
                        <span class="nav-icon">&#128203;</span>
                        Reservations
                    </a>
                </li>
                <li class="nav-item">
                    <a href="<%= request.getContextPath() %>/manager/rooms" 
                       class="nav-link <%= "rooms".equals(currentPage) ? "active" : "" %>">
                        <span class="nav-icon">&#128716;</span>
                        Room Availability
                    </a>
                </li>
                <li class="nav-item">
                    <a href="<%= request.getContextPath() %>/manager/checkin" 
                       class="nav-link <%= "checkin".equals(currentPage) ? "active" : "" %>">
                        <span class="nav-icon">&#9989;</span>
                        Check-in / Check-out
                    </a>
                </li>
                <li class="nav-item">
                    <a href="<%= request.getContextPath() %>/manager/cleaning" 
                       class="nav-link <%= "cleaning".equals(currentPage) ? "active" : "" %>">
                        <span class="nav-icon">&#129529;</span>
                        Cleaning Service
                    </a>
                </li>
                <li class="nav-item">
                    <a href="<%= request.getContextPath() %>/manager/billing" 
                       class="nav-link <%= "billing".equals(currentPage) ? "active" : "" %>">
                        <span class="nav-icon">&#128176;</span>
                        Billing
                    </a>
                </li>
                <li class="nav-item">
                    <a href="<%= request.getContextPath() %>/manager/monthly-report" 
                       class="nav-link <%= "monthly-report".equals(currentPage) ? "active" : "" %>">
                        <span class="nav-icon">&#128200;</span>
                        Monthly Report
                    </a>
                </li>
                <li class="nav-item">
                    <a href="<%= request.getContextPath() %>/manager/help" 
                       class="nav-link <%= "help".equals(currentPage) ? "active" : "" %>">
                        <span class="nav-icon">&#10067;</span>
                        Help & Guide
                    </a>
                </li>
                <!-- <li class="nav-item">
                    <form action="<%= request.getContextPath() %>/staff-logout" method="post">
                        <button type="submit" class="nav-link" style="width: 100%; text-align: left; background: none; border: none; cursor: pointer;">
                            <span class="nav-icon">&#128682;</span>
                            Exit System
                        </button>
                    </form>
                </li> -->
            </ul>
        </nav>

        <!-- Main Content -->
        <main class="main-content">
            <% if (successMessage != null) { %>
                <div class="alert alert-success"><%= successMessage %></div>
            <% } %>
            
            <% if (errorMessage != null) { %>
                <div class="alert alert-error"><%= errorMessage %></div>
            <% } %>

            <% if ("dashboard".equals(currentPage)) { %>
                <jsp:include page="/WEB-INF/manager/sections/dashboard-section.jsp" />
            <% } else if ("reservations".equals(currentPage)) { %>
                <jsp:include page="/WEB-INF/manager/sections/reservations-section.jsp" />
            <% } else if ("rooms".equals(currentPage)) { %>
                <jsp:include page="/WEB-INF/manager/sections/rooms-section.jsp" />
            <% } else if ("checkin".equals(currentPage)) { %>
                <jsp:include page="/WEB-INF/manager/sections/checkin-section.jsp" />
            <% } else if ("cleaning".equals(currentPage)) { %>
                <jsp:include page="/WEB-INF/manager/sections/cleaning-section.jsp" />
            <% } else if ("billing".equals(currentPage)) { %>
                <jsp:include page="/WEB-INF/manager/sections/billing-section.jsp" />
            <% } else if ("help".equals(currentPage)) { %>
                <jsp:include page="/WEB-INF/manager/sections/help-section.jsp" />
            <% } %>
        </main>
    </div>
</body>
</html>