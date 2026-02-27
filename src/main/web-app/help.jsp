<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Guest" %>
<%
    // Check if user is logged in
    Guest guest = (Guest) session.getAttribute("guest");
    if (guest == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String guestName = guest.getFullName();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Help & Support - Ocean View Resort</title>
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
                    <a href="help.jsp" class="nav-link active">
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
                    <h2 class="page-title">&#10067; Help & Support</h2>
                </div>

                <div class="help-grid">
                    <div class="help-section">
                        <h3 style="color: var(--primary); margin-bottom: 20px;">Booking & Reservations</h3>
                        <div class="help-item">
                            <strong>How do I book a room?</strong>
                            <p>Navigate to the "Book Room" section, select your preferred room type, choose your check-in and check-out dates, specify the number of guests, and submit the booking form. You'll receive a confirmation with your reservation number.</p>
                        </div>
                        <div class="help-item">
                            <strong>Can I modify my reservation?</strong>
                            <p>Yes, you can modify confirmed reservations from the "My Reservations" section. Click on your reservation and use the "Edit" option. Note that changes are subject to availability and may incur additional charges.</p>
                        </div>
                        <div class="help-item">
                            <strong>How do I cancel my booking?</strong>
                            <p>Go to "My Reservations" and click the "Cancel" button next to your booking. Please note our cancellation policy: cancellations made 24 hours before check-in are fully refundable.</p>
                        </div>
                    </div>

                    <div class="help-section">
                        <h3 style="color: var(--primary); margin-bottom: 20px;">Services & Requests</h3>
                        <div class="help-item">
                            <strong>How can I request room cleaning?</strong>
                            <p>Go to the "Cleaning Requests" section and click "Request Cleaning". Select your reservation and preferred time. Our housekeeping staff will be notified and will service your room accordingly.</p>
                        </div>
                        <div class="help-item">
                            <strong>How do I generate my bill?</strong>
                            <p>Visit the "My Bills" section, select your reservation from the dropdown, and click "Generate Bill". You can download and print your invoice for record-keeping.</p>
                        </div>
                    </div>

                    <div class="help-section">
                        <h3 style="color: var(--primary); margin-bottom: 20px;">Account & Support</h3>
                        <div class="help-item">
                            <strong>How do I update my information?</strong>
                            <p>Your account information can be updated by contacting our front desk at +94 91 223 4567 or info@oceanviewresort.lk. We'll be happy to update your details.</p>
                        </div>
                        <div class="help-item">
                            <strong>Need additional assistance?</strong>
                            <p>Contact our 24/7 front desk: +94 91 223 4567<br>
                            Email: info@oceanviewresort.lk<br>
                            WhatsApp: +94 77 123 4567</p>
                        </div>
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
