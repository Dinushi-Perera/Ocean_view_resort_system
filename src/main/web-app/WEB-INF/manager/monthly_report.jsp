<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="model.Booking" %>
<%@ page import="model.Guest" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.time.format.TextStyle" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.Month" %>

<%
    String staffName = (String) request.getAttribute("staffName");
    if (staffName == null) staffName = "Manager";

    String selectedMonth = (String) request.getAttribute("selectedMonth");
    String selectedYear  = (String) request.getAttribute("selectedYear");

    @SuppressWarnings("unchecked")
    List<Map<String, Object>> receiptRows = (List<Map<String, Object>>) request.getAttribute("receiptRows");
    @SuppressWarnings("unchecked")
    Map<String, Object> summary = (Map<String, Object>) request.getAttribute("summary");

    if (receiptRows == null) receiptRows = new ArrayList<>();
    if (summary     == null) summary     = new HashMap<>();

    // ── Financial figures ──
    double actualRevenue       = summary.containsKey("actualRevenue")       ? (Double)  summary.get("actualRevenue")       : 0.0;
    double actualSubtotal      = summary.containsKey("actualSubtotal")      ? (Double)  summary.get("actualSubtotal")      : 0.0;
    double actualServiceCharge = summary.containsKey("actualServiceCharge") ? (Double)  summary.get("actualServiceCharge") : 0.0;
    double actualTax           = summary.containsKey("actualTax")           ? (Double)  summary.get("actualTax")           : 0.0;
    double netIncome           = summary.containsKey("netIncome")           ? (Double)  summary.get("netIncome")           : 0.0;
    double projectedRevenue    = summary.containsKey("projectedRevenue")    ? (Double)  summary.get("projectedRevenue")    : 0.0;

    // ── Counts ──
    int totalBookings   = summary.containsKey("totalBookings")   ? (Integer) summary.get("totalBookings")   : 0;
    int totalNights     = summary.containsKey("totalNights")     ? (Integer) summary.get("totalNights")     : 0;
    int checkedOutCount = summary.containsKey("checkedOutCount") ? (Integer) summary.get("checkedOutCount") : 0;
    int checkedInCount  = summary.containsKey("checkedInCount")  ? (Integer) summary.get("checkedInCount")  : 0;
    int confirmedCount  = summary.containsKey("confirmedCount")  ? (Integer) summary.get("confirmedCount")  : 0;
    int pendingCount    = summary.containsKey("pendingCount")    ? (Integer) summary.get("pendingCount")    : 0;
    int cancelledCount  = summary.containsKey("cancelledCount")  ? (Integer) summary.get("cancelledCount")  : 0;

    // ── Per-type maps ──
    @SuppressWarnings("unchecked")
    Map<String, Double>  revenueByType = summary.containsKey("revenueByType") ? (Map<String,Double>)  summary.get("revenueByType") : new LinkedHashMap<>();
    @SuppressWarnings("unchecked")
    Map<String, Integer> countByType   = summary.containsKey("countByType")   ? (Map<String,Integer>) summary.get("countByType")   : new LinkedHashMap<>();
    @SuppressWarnings("unchecked")
    Map<String, Integer> nightsByType  = summary.containsKey("nightsByType")  ? (Map<String,Integer>) summary.get("nightsByType")  : new LinkedHashMap<>();

    String periodStart = summary.containsKey("periodStart") ? (String) summary.get("periodStart") : "";
    String periodEnd   = summary.containsKey("periodEnd")   ? (String) summary.get("periodEnd")   : "";

    // ── Period label ──
    String periodLabel = "";
    if (selectedMonth != null && selectedYear != null && !selectedMonth.isEmpty() && !selectedYear.isEmpty()) {
        try {
            int mon = Integer.parseInt(selectedMonth);
            int yr  = Integer.parseInt(selectedYear);
            periodLabel = Month.of(mon).getDisplayName(TextStyle.FULL, Locale.ENGLISH) + " " + yr;
        } catch (Exception ignored) {}
    }

    int currentYear = LocalDate.now().getYear();
    int currentMon  = LocalDate.now().getMonthValue();
    DateTimeFormatter displayFmt = DateTimeFormatter.ofPattern("MMM dd, yyyy");
    String[] roomTypeOrder = {"standard","deluxe","suite","presidential"};

    double totalExpenses = actualServiceCharge + actualTax;
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Monthly Report<%= !periodLabel.isEmpty() ? " — " + periodLabel : "" %> - Ocean View Resort</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/style/styles.css">
    <style>
        /* ── Cards ── */
        .stats-grid { display:grid; grid-template-columns:repeat(auto-fit,minmax(175px,1fr)); gap:14px; margin-bottom:24px; }
        .stat-card  { background:white; padding:16px 18px; border-radius:8px; box-shadow:0 2px 5px rgba(0,0,0,.08); border-left:4px solid #0284c7; }
        .stat-card.green  { border-color:#16a34a; }
        .stat-card.red    { border-color:#dc2626; }
        .stat-card.blue   { border-color:#0284c7; }
        .stat-card.purple { border-color:#7c3aed; }
        .stat-card.amber  { border-color:#d97706; }
        .stat-card.teal   { border-color:#0891b2; }
        .stat-value { font-size:22px; font-weight:800; }
        .stat-value.green  { color:#16a34a; }
        .stat-value.red    { color:#dc2626; }
        .stat-value.blue   { color:#0284c7; }
        .stat-value.purple { color:#7c3aed; }
        .stat-value.amber  { color:#d97706; }
        .stat-value.teal   { color:#0891b2; }
        .stat-label { color:#6b7280; margin-top:3px; font-size:11px; font-weight:700; text-transform:uppercase; letter-spacing:.4px; }

        /* ── Section header ── */
        .section-header { display:flex; justify-content:space-between; align-items:center; margin-bottom:18px; flex-wrap:wrap; gap:10px; }
        .section-title  { font-size:22px; font-weight:bold; color:#01579b; }

        /* ── Filter ── */
        .filter-card { background:white; padding:16px 20px; border-radius:8px; margin-bottom:20px; box-shadow:0 2px 5px rgba(0,0,0,.08); display:flex; gap:14px; align-items:flex-end; flex-wrap:wrap; }
        .filter-card .fg { display:flex; flex-direction:column; gap:4px; }
        .filter-card label { font-weight:700; font-size:12px; color:#374151; text-transform:uppercase; letter-spacing:.4px; }
        .filter-card select { padding:8px 12px; border:1.5px solid #d1d5db; border-radius:6px; font-size:14px; }

        /* ── Two-col grid ── */
        .two-col { display:grid; grid-template-columns:1fr 1fr; gap:18px; margin-bottom:24px; }
        @media(max-width:860px){ .two-col { grid-template-columns:1fr; } }

        /* ── Panel ── */
        .panel { background:white; border-radius:8px; box-shadow:0 2px 5px rgba(0,0,0,.08); padding:18px; }
        .panel h3 { color:#01579b; margin:0 0 13px 0; font-size:15px; border-bottom:2px solid #e0f2fe; padding-bottom:7px; }
        .br-row { display:flex; justify-content:space-between; padding:7px 0; border-bottom:1px solid #f3f4f6; font-size:13.5px; }
        .br-row:last-child { border-bottom:none; }
        .br-row.bold  { font-weight:700; }
        .br-row.total { font-weight:700; font-size:15px; color:#0284c7; border-top:2px solid #0284c7; padding-top:9px; margin-top:3px; }
        .br-row.net   { font-weight:700; font-size:15px; color:#16a34a; }
        .br-row.exp   { color:#dc2626; }
        .br-row.proj  { color:#d97706; font-style:italic; }

        /* ── Room-type badges ── */
        .rt { display:inline-block; padding:2px 8px; border-radius:10px; font-size:11px; font-weight:700; text-transform:capitalize; }
        .rt-standard     { background:#dbeafe; color:#1e40af; }
        .rt-deluxe       { background:#d1fae5; color:#065f46; }
        .rt-suite        { background:#ede9fe; color:#5b21b6; }
        .rt-presidential { background:#fef3c7; color:#92400e; }

        /* ── Status badges ── */
        .badge { padding:3px 8px; border-radius:4px; font-size:11px; font-weight:700; white-space:nowrap; }
        .b-out  { background:#dbeafe; color:#1e40af; }
        .b-in   { background:#dcfce7; color:#166534; }
        .b-conf { background:#fef9c3; color:#92400e; }
        .b-pend { background:#f3f4f6; color:#6b7280; }
        .b-canc { background:#fee2e2; color:#991b1b; }

        /* ── Main table ── */
        .tbl-card { background:white; border-radius:8px; box-shadow:0 2px 5px rgba(0,0,0,.08); margin-bottom:24px; overflow:hidden; }
        .tbl-hdr  { padding:14px 16px 8px; display:flex; justify-content:space-between; align-items:center; flex-wrap:wrap; gap:8px; }
        .tbl-hdr h3 { color:#01579b; margin:0; font-size:15px; }
        .tbl-wrap { overflow-x:auto; }
        table.main-tbl { width:100%; border-collapse:collapse; min-width:1200px; }
        table.main-tbl th { background:#01579b; color:white; padding:10px 9px; text-align:left; font-size:11.5px; white-space:nowrap; font-weight:700; }
        table.main-tbl td { padding:9px; border-bottom:1px solid #f3f4f6; font-size:12.5px; vertical-align:top; }
        table.main-tbl tr:hover td { background:#f0f9ff; }
        table.main-tbl tr.cancelled td { background:#fff5f5; color:#9ca3af; }
        .guest-info { line-height:1.6; }
        .guest-info .name { font-weight:700; color:#111827; }
        .guest-info .detail { font-size:11px; color:#6b7280; }
        .totals-row td { font-weight:700; background:#eff6ff !important; border-top:2px solid #0284c7; font-size:13px; }
        .income-row td { font-weight:700; background:#f0fdf4 !important; border-top:2px solid #16a34a; color:#16a34a; }

        /* ── Buttons ── */
        .btn         { padding:8px 18px; border:none; border-radius:6px; cursor:pointer; text-decoration:none; display:inline-block; font-size:13px; font-weight:700; }
        .btn-primary { background:#0c4a6e; color:white; }
        .btn-print   { background:#16a34a; color:white; }

        /* ── Alert ── */
        .alert      { padding:12px 18px; border-radius:6px; margin-bottom:18px; font-size:14px; }
        .alert-info { background:#e0f2fe; color:#0369a1; border:1px solid #bae6fd; }

        /* ── Print-only elements ── */
        .print-only { display:none; }

        /* ════════ PRINT ════════ */
        @media print {
            .sidebar, .app-header, .filter-card, .no-print, nav, button { display:none !important; }
            body { background:white !important; font-size:11px; }
            .main-content { margin-left:0 !important; padding:6px 10px !important; }
            .print-only { display:block !important; }
            .print-header { text-align:center; margin-bottom:14px; border-bottom:2px solid #01579b; padding-bottom:10px; }
            .print-header h1 { font-size:18px; color:#01579b; margin:0 0 3px 0; }
            .print-header p  { margin:2px 0; color:#555; font-size:11px; }
            .print-footer { text-align:center; margin-top:14px; border-top:1px solid #ccc; padding-top:8px; font-size:10px; color:#888; }
            .stats-grid { grid-template-columns:repeat(5,1fr) !important; }
            .two-col    { grid-template-columns:1fr 1fr !important; }
            .stat-value { font-size:15px; }
            .stat-label { font-size:10px; }
            table.main-tbl { min-width:unset; font-size:10px; }
            table.main-tbl th { padding:6px 5px; font-size:10px; -webkit-print-color-adjust:exact; print-color-adjust:exact; }
            table.main-tbl td { padding:5px; }
            .tbl-card, .panel, .stat-card { box-shadow:none; border:1px solid #e5e7eb; }
            .section-title { font-size:16px; }
        }
    </style>
</head>
<body>
<div id="main-app">

    <!-- Header -->
    <header class="app-header">
        <div class="header-content">
            <div class="header-left"><div class="app-logo">Ocean View Resort</div></div>
            <div class="user-info">
                <span class="user-badge">Manager</span>
                <span>Welcome, <%= staffName %></span>
                <form action="<%= request.getContextPath() %>/staff-logout" method="post" style="display:inline;">
                    <button type="submit" class="logout-btn">Logout</button>
                </form>
            </div>
        </div>
    </header>

    <!-- Sidebar -->
    <nav class="sidebar">
        <ul class="nav-menu">
            <li class="nav-item"><a href="<%= request.getContextPath() %>/manager/dashboard"      class="nav-link"><span class="nav-icon">&#128202;</span>Dashboard</a></li>
            <li class="nav-item"><a href="<%= request.getContextPath() %>/manager/reservations"   class="nav-link"><span class="nav-icon">&#128203;</span>Reservations</a></li>
            <li class="nav-item"><a href="<%= request.getContextPath() %>/manager/rooms"          class="nav-link"><span class="nav-icon">&#128716;</span>Room Availability</a></li>
            <li class="nav-item"><a href="<%= request.getContextPath() %>/manager/checkin"        class="nav-link"><span class="nav-icon">&#9989;</span>Check-in / Check-out</a></li>
            <li class="nav-item"><a href="<%= request.getContextPath() %>/manager/cleaning"       class="nav-link"><span class="nav-icon">&#129529;</span>Cleaning Service</a></li>
            <li class="nav-item"><a href="<%= request.getContextPath() %>/manager/billing"        class="nav-link"><span class="nav-icon">&#128176;</span>Billing</a></li>
            <li class="nav-item"><a href="<%= request.getContextPath() %>/manager/monthly-report" class="nav-link active"><span class="nav-icon">&#128200;</span>Monthly Report</a></li>
            <li class="nav-item"><a href="<%= request.getContextPath() %>/manager/help"           class="nav-link"><span class="nav-icon">&#10067;</span>Help &amp; Guide</a></li>
        </ul>
    </nav>

    <main class="main-content">

        <!-- ── Print-only header ── -->
        <div class="print-only print-header">
            <h1>&#127754; Ocean View Resort &mdash; Monthly Financial Report</h1>
            <% if (!periodLabel.isEmpty()) { %>
            <p>Period: <strong><%= periodLabel %></strong>
               &nbsp;(<%= periodStart %> to <%= periodEnd %>)</p>
            <% } %>
            <p>Generated: <%= LocalDate.now().format(displayFmt) %> &nbsp;|&nbsp; Prepared by: <strong><%= staffName %></strong></p>
        </div>

        <!-- ── Page header bar ── -->
        <div class="section-header no-print">
            <h2 class="section-title">&#128200; Monthly Financial Report
                <% if (!periodLabel.isEmpty()) { %>
                    <span style="font-size:16px; font-weight:400; color:#6b7280;">&mdash; <%= periodLabel %></span>
                <% } %>
            </h2>
            <% if (!receiptRows.isEmpty()) { %>
                <button onclick="window.print()" class="btn btn-print">&#128438; Print / Save PDF</button>
            <% } %>
        </div>

        <!-- ── Filter form ── -->
        <form action="<%= request.getContextPath() %>/manager/monthly-report" method="get" class="filter-card no-print">
            <div class="fg">
                <label>Month</label>
                <select name="month">
                    <% String[] months = {"January","February","March","April","May","June",
                                          "July","August","September","October","November","December"};
                       for (int i = 1; i <= 12; i++) {
                           String sel = (selectedMonth != null && selectedMonth.equals(String.valueOf(i))) ? " selected" : "";
                    %>
                    <option value="<%= i %>"<%= sel %>><%= months[i-1] %></option>
                    <% } %>
                </select>
            </div>
            <div class="fg">
                <label>Year</label>
                <select name="year">
                    <% for (int yr = currentYear + 1; yr >= currentYear - 4; yr--) {
                           String sel = (selectedYear != null && selectedYear.equals(String.valueOf(yr))) ? " selected" : "";
                    %>
                    <option value="<%= yr %>"<%= sel %>><%= yr %></option>
                    <% } %>
                </select>
            </div>
            <button type="submit" class="btn btn-primary">&#128269; Generate Report</button>
        </form>

        <% if (periodLabel.isEmpty()) { %>
            <div class="alert alert-info">
                &#9432; Select a <strong>Month</strong> and <strong>Year</strong>, then click <strong>Generate Report</strong> to view the complete financial summary.
            </div>

        <% } else { /* ══ REPORT BODY ══ */ %>

        <!-- ════════════════ SUMMARY CARDS ════════════════ -->
        <div class="stats-grid">
            <div class="stat-card green">
                <div class="stat-value green">LKR <%= String.format("%,.2f", actualRevenue) %></div>
                <div class="stat-label">&#9989; Actual Revenue</div>
            </div>
            <div class="stat-card red">
                <div class="stat-value red">LKR <%= String.format("%,.2f", totalExpenses) %></div>
                <div class="stat-label">&#128200; Total Expenses</div>
            </div>
            <div class="stat-card blue">
                <div class="stat-value blue">LKR <%= String.format("%,.2f", netIncome) %></div>
                <div class="stat-label">&#128181; Net Income</div>
            </div>
            <div class="stat-card amber">
                <div class="stat-value amber">LKR <%= String.format("%,.2f", projectedRevenue) %></div>
                <div class="stat-label">&#128336; Projected (Active)</div>
            </div>
            <div class="stat-card purple">
                <div class="stat-value purple"><%= totalBookings %></div>
                <div class="stat-label">&#128203; Total Bookings</div>
            </div>
            <div class="stat-card teal">
                <div class="stat-value teal"><%= totalNights %></div>
                <div class="stat-label">&#127761; Total Nights</div>
            </div>
            <div class="stat-card green">
                <div class="stat-value green"><%= checkedOutCount %></div>
                <div class="stat-label">&#9989; Checked-out</div>
            </div>
            <div class="stat-card blue">
                <div class="stat-value blue"><%= checkedInCount + confirmedCount %></div>
                <div class="stat-label">&#127979; Active (In + Confirmed)</div>
            </div>
        </div>

        <!-- ════════════════ BREAKDOWN PANELS ════════════════ -->
        <div class="two-col">

            <!-- Income / Expense breakdown -->
            <div class="panel">
                <h3>&#128200; Income &amp; Expense Breakdown</h3>
                <div class="br-row"><span>Room Revenue Subtotal</span><span>LKR <%= String.format("%,.2f", actualSubtotal) %></span></div>
                <div class="br-row exp"><span>&#8722; Service Charge (10%)</span><span>LKR <%= String.format("%,.2f", actualServiceCharge) %></span></div>
                <div class="br-row exp"><span>&#8722; Government Tax (12%)</span><span>LKR <%= String.format("%,.2f", actualTax) %></span></div>
                <div class="br-row exp bold"><span>Total Expenses</span><span>LKR <%= String.format("%,.2f", totalExpenses) %></span></div>
                <div class="br-row total"><span>Gross Revenue (Actual)</span><span>LKR <%= String.format("%,.2f", actualRevenue) %></span></div>
                <div class="br-row net"><span>&#9989; Net Income</span><span>LKR <%= String.format("%,.2f", netIncome) %></span></div>
                <div class="br-row proj"><span>&#128336; Projected Revenue (Active)</span><span>LKR <%= String.format("%,.2f", projectedRevenue) %></span></div>
                <div style="margin-top:12px; padding-top:10px; border-top:1px solid #e5e7eb; font-size:12px;">
                    <div class="br-row"><span>Tax Rate</span><span>12%</span></div>
                    <div class="br-row"><span>Service Charge Rate</span><span>10%</span></div>
                </div>
            </div>

            <!-- Revenue by room type + status counts -->
            <div class="panel">
                <h3>&#127979; Revenue by Room Type</h3>
                <%
                    boolean anyTypeData = false;
                    for (String rt : roomTypeOrder) {
                        double rtRevenue = revenueByType.getOrDefault(rt, 0.0);
                        int    rtCount   = countByType.getOrDefault(rt, 0);
                        int    rtNights  = nightsByType.getOrDefault(rt, 0);
                        if (rtCount == 0) continue;
                        anyTypeData = true;
                %>
                <div class="br-row">
                    <span>
                        <span class="rt rt-<%= rt %>"><%= rt %></span>
                        <span style="font-size:11px; color:#6b7280;">&nbsp;<%= rtCount %> booking<%= rtCount>1?"s":"" %>, <%= rtNights %> night<%= rtNights>1?"s":"" %></span>
                    </span>
                    <span style="font-weight:700;">LKR <%= String.format("%,.2f", rtRevenue) %></span>
                </div>
                <% } if (!anyTypeData) { %>
                <p style="color:#9ca3af; font-style:italic; font-size:13px;">No revenue data for this period.</p>
                <% } %>

                <!-- Status tally -->
                <div style="margin-top:12px; padding-top:10px; border-top:1px solid #e5e7eb;">
                    <div class="br-row">
                        <span><span class="badge b-out">checked-out</span></span>
                        <span><%= checkedOutCount %> booking<%= checkedOutCount!=1?"s":"" %></span>
                    </div>
                    <div class="br-row">
                        <span><span class="badge b-in">checked-in</span></span>
                        <span><%= checkedInCount %> booking<%= checkedInCount!=1?"s":"" %></span>
                    </div>
                    <div class="br-row">
                        <span><span class="badge b-conf">confirmed</span></span>
                        <span><%= confirmedCount %> booking<%= confirmedCount!=1?"s":"" %></span>
                    </div>
                    <div class="br-row">
                        <span><span class="badge b-pend">pending</span></span>
                        <span><%= pendingCount %> booking<%= pendingCount!=1?"s":"" %></span>
                    </div>
                    <div class="br-row">
                        <span><span class="badge b-canc">cancelled</span></span>
                        <span><%= cancelledCount %> booking<%= cancelledCount!=1?"s":"" %> <span style="font-size:11px;color:#9ca3af;">(excluded from financials)</span></span>
                    </div>
                </div>
            </div>
        </div>

        <!-- ════════════════ FULL BOOKING DETAILS TABLE ════════════════ -->
        <% if (receiptRows.isEmpty()) { %>
            <div class="alert alert-info">No bookings found for <strong><%= periodLabel %></strong>.</div>
        <% } else { %>

        <div class="tbl-card">
            <div class="tbl-hdr">
                <h3>All Booking Details &mdash; <%= periodLabel %>
                    <span style="font-size:13px; font-weight:400; color:#6b7280;">(<%= receiptRows.size() %> booking<%= receiptRows.size()!=1?"s":"" %>, period: <%= periodStart %> to <%= periodEnd %>)</span>
                </h3>
                <button onclick="window.print()" class="btn btn-print no-print">&#128438; Print</button>
            </div>
            <div class="tbl-wrap">
                <table class="main-tbl">
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Booking ID</th>
                            <th>Guest Details</th>
                            <th>Room</th>
                            <th>Guests</th>
                            <th>Check-in</th>
                            <th>Check-out</th>
                            <th>Nights</th>
                            <th>Rate/Night</th>
                            <th>Subtotal</th>
                            <th>Service<br>10%</th>
                            <th>Tax<br>12%</th>
                            <th>Total Bill</th>
                            <th>Status</th>
                            <th>Booked On</th>
                        </tr>
                    </thead>
                    <tbody>
                        <%
                            int rowNum = 1;
                            double runSubtotal = 0, runSvc = 0, runTax = 0, runTotal = 0;
                            double actSubtotal = 0, actSvc = 0, actTax  = 0, actTotal = 0;
                            for (Map<String, Object> row : receiptRows) {
                                String bStatus = (String) row.get("status");
                                boolean isCancelled = "cancelled".equals(bStatus);
                                String badgeCls = "b-pend";
                                if      ("checked-out".equals(bStatus)) badgeCls = "b-out";
                                else if ("checked-in".equals(bStatus))  badgeCls = "b-in";
                                else if ("confirmed".equals(bStatus))   badgeCls = "b-conf";
                                else if ("cancelled".equals(bStatus))   badgeCls = "b-canc";

                                double rSub   = (Double) row.get("subtotal");
                                double rSvc   = (Double) row.get("serviceCharge");
                                double rTax   = (Double) row.get("tax");
                                double rTotal = (Double) row.get("total");

                                if (!isCancelled) {
                                    runSubtotal += rSub; runSvc += rSvc; runTax += rTax; runTotal += rTotal;
                                }
                                if ("checked-out".equals(bStatus)) {
                                    actSubtotal += rSub; actSvc += rSvc; actTax += rTax; actTotal += rTotal;
                                }

                                String rt2 = row.get("roomType") != null ? ((String)row.get("roomType")).toLowerCase() : "standard";
                                String createdAt = (String) row.get("createdAt");
                                if (createdAt != null && createdAt.length() > 10) createdAt = createdAt.substring(0, 10);
                        %>
                        <tr class="<%= isCancelled ? "cancelled" : "" %>">
                            <td style="color:#9ca3af; font-size:11px;"><%= rowNum++ %></td>
                            <td><strong style="color:#0284c7;">#<%= row.get("bookingId") %></strong></td>
                            <td>
                                <div class="guest-info">
                                    <div class="name"><%= row.get("guestName") %></div>
                                    <div class="detail">&#128222; <%= row.get("guestContact") %></div>
                                    <div class="detail">&#9993; <%= row.get("guestEmail") %></div>
                                    <div class="detail">ID: <%= row.get("guestNic") %></div>
                                </div>
                            </td>
                            <td>
                                <span class="rt rt-<%= rt2 %>"><%= rt2 %></span>
                                <% if (!"-".equals(row.get("roomNumber"))) { %>
                                    <div style="font-size:11px; color:#6b7280; margin-top:2px;">Rm <%= row.get("roomNumber") %></div>
                                <% } %>
                            </td>
                            <td style="text-align:center;"><%= row.get("numGuests") %></td>
                            <td style="white-space:nowrap;"><%= row.get("checkIn") %></td>
                            <td style="white-space:nowrap;"><%= row.get("checkOut") %></td>
                            <td style="text-align:center; font-weight:700;"><%= row.get("nights") %></td>
                            <td style="white-space:nowrap;">LKR <%= String.format("%,.0f", (Double) row.get("roomRate")) %></td>
                            <td style="white-space:nowrap;<%= isCancelled ? "color:#9ca3af;" : "" %>">LKR <%= String.format("%,.2f", rSub) %></td>
                            <td style="white-space:nowrap; color:<%= isCancelled ? "#9ca3af" : "#dc2626" %>;">
                                <%= isCancelled ? "-" : "LKR " + String.format("%,.2f", rSvc) %>
                            </td>
                            <td style="white-space:nowrap; color:<%= isCancelled ? "#9ca3af" : "#dc2626" %>;">
                                <%= isCancelled ? "-" : "LKR " + String.format("%,.2f", rTax) %>
                            </td>
                            <td style="white-space:nowrap; font-weight:700; color:<%= isCancelled ? "#9ca3af" : "#0284c7" %>;">
                                <%= isCancelled ? "<span style='font-size:11px;'>Cancelled</span>" : "LKR " + String.format("%,.2f", rTotal) %>
                            </td>
                            <td><span class="badge <%= badgeCls %>"><%= bStatus %></span></td>
                            <td style="font-size:11px; color:#9ca3af; white-space:nowrap;"><%= createdAt %></td>
                        </tr>
                        <% } %>

                        <!-- All non-cancelled totals -->
                        <tr class="totals-row">
                            <td colspan="9" style="text-align:right; padding-right:10px; font-size:12px;">TOTAL (excl. cancelled)</td>
                            <td style="white-space:nowrap;">LKR <%= String.format("%,.2f", runSubtotal) %></td>
                            <td style="color:#dc2626; white-space:nowrap;">LKR <%= String.format("%,.2f", runSvc) %></td>
                            <td style="color:#dc2626; white-space:nowrap;">LKR <%= String.format("%,.2f", runTax) %></td>
                            <td style="color:#0284c7; white-space:nowrap;">LKR <%= String.format("%,.2f", runTotal) %></td>
                            <td colspan="2"></td>
                        </tr>
                        <!-- Checked-out (actual revenue) row -->
                        <tr class="income-row">
                            <td colspan="9" style="text-align:right; padding-right:10px; font-size:12px;">ACTUAL REVENUE (checked-out only)</td>
                            <td style="white-space:nowrap;">LKR <%= String.format("%,.2f", actSubtotal) %></td>
                            <td style="white-space:nowrap;">LKR <%= String.format("%,.2f", actSvc) %></td>
                            <td style="white-space:nowrap;">LKR <%= String.format("%,.2f", actTax) %></td>
                            <td style="white-space:nowrap; font-weight:700;">LKR <%= String.format("%,.2f", actTotal) %></td>
                            <td colspan="2"></td>
                        </tr>
                        <!-- Net income row -->
                        <tr>
                            <td colspan="12" style="text-align:right; padding-right:10px; font-weight:700; font-size:13px; background:#f0fdf4; color:#16a34a; border-top:2px solid #16a34a;">
                                NET INCOME &nbsp;=&nbsp; LKR <%= String.format("%,.2f", actTotal) %>
                                &nbsp;&minus;&nbsp; LKR <%= String.format("%,.2f", actSvc + actTax) %> (expenses)
                                &nbsp;=&nbsp; <strong>LKR <%= String.format("%,.2f", actTotal - actSvc - actTax) %></strong>
                            </td>
                            <td colspan="3" style="background:#f0fdf4;"></td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>

        <p style="font-size:11.5px; color:#6b7280; margin-top:-16px;" class="no-print">
            &#9432; <strong>Actual Revenue / Net Income</strong> = checked-out bookings only.
            <strong>Projected</strong> = confirmed + checked-in.
            Cancelled bookings are shown but excluded from all financial calculations.
        </p>

        <% } /* end if receiptRows not empty */ %>

        <!-- ── Print footer ── -->
        <div class="print-only print-footer">
            Service Charge: 10% | Government Tax: 12% | Net Income = Gross Revenue (checked-out) &minus; (Service + Tax) |
            Ocean View Resort &copy; <%= currentYear %> | Prepared by: <%= staffName %>
        </div>

        <% } /* end report body */ %>

    </main>
</div>
</body>
</html>
