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
    String guestEmail = guest.getEmail();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Booking Confirmation - Ocean View Resort</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="style/styles.css">

    <style>
        .confirmation-container {
            padding: 20px;
            max-width: 800px;
            margin: 0 auto;
        }

        .confirmation-card {
            background: white;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
            padding: 40px;
            text-align: center;
            margin-top: 20px;
        }

        .confirmation-icon {
            width: 100px;
            height: 100px;
            background: linear-gradient(135deg, #10b981 0%, #059669 100%);
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            margin: 0 auto 30px;
            font-size: 3rem;
            color: white;
        }

        .confirmation-header h1 {
            font-size: 2.2rem;
            color: var(--primary);
            margin-bottom: 15px;
        }

        .confirmation-header p {
            color: var(--gray);
            font-size: 1rem;
            margin-bottom: 20px;
        }

        .booking-details {
            background: #f0f9ff;
            padding: 25px;
            border-radius: 8px;
            margin: 30px 0;
            text-align: left;
        }

        .detail-row {
            display: flex;
            justify-content: space-between;
            padding: 12px 0;
            border-bottom: 1px solid #e0f2fe;
            font-size: 0.95rem;
        }

        .detail-row:last-child {
            border-bottom: none;
        }

        .detail-label {
            font-weight: 600;
            color: var(--primary);
        }

        .detail-value {
            color: var(--dark);
        }

        .booking-id {
            font-size: 1.3rem;
            font-weight: 700;
            color: var(--primary);
            margin: 20px 0;
            font-family: 'Courier New', monospace;
            background: white;
            padding: 12px;
            border-radius: 6px;
            border: 2px solid var(--primary);
        }

        .btn {
            padding: 14px 32px;
            border: none;
            border-radius: 8px;
            font-family: 'Inter', sans-serif;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            width: 100%;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-top: 15px;
        }

        .btn-primary {
            background: linear-gradient(135deg, #0c4a6e 0%, #0284c7 100%);
            color: white;
            border: none;
            text-decoration: none;
            display: inline-block;
        }

        .btn-primary:hover {
            box-shadow: 0 10px 30px rgba(12, 74, 110, 0.3);
            transform: translateY(-2px);
        }

        .next-steps {
            background: #fef3c7;
            padding: 20px;
            border-radius: 8px;
            margin-top: 25px;
            border-left: 4px solid #f59e0b;
            text-align: left;
        }

        .next-steps h3 {
            color: #b45309;
            margin-bottom: 12px;
        }

        .next-steps ul {
            margin: 0;
            padding-left: 20px;
            color: #92400e;
        }

        .next-steps li {
            margin-bottom: 8px;
        }

        @media (max-width: 768px) {
            .confirmation-card {
                padding: 30px 20px;
            }

            .confirmation-header h1 {
                font-size: 1.8rem;
            }

            .booking-details {
                padding: 20px;
            }
        }
    </style>
</head>
<body>
    <!-- ============================================
         GUEST DASHBOARD WITH BOOKING CONFIRMATION
    ============================================ -->
    <div id="guest-dashboard">
        <!-- Header -->
        <header class="app-header">
            <div class="header-content">
                <div class="header-left">
                    <button class="menu-toggle">&#9776;</button>
                    <div class="app-logo">Ocean View Resort - Guest Portal</div>
                </div>
                <div class="user-info">
                    <span class="user-badge" id="guestRoleBadge">Guest</span>
                    <span id="currentGuest">Welcome, <%= guestName %></span>
                    <button class="logout-btn" onclick="window.location.href='<%= request.getContextPath() %>/logout'">Logout</button>
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
                    <a href="#" class="nav-link">
                        <span class="nav-icon">&#128203;</span>
                        My Reservations
                    </a>
                </li>
                <li class="nav-item">
                    <a href="#" class="nav-link">
                        <span class="nav-icon">&#129529;</span>
                        Cleaning Requests
                    </a>
                </li>
                <li class="nav-item">
                    <a href="#" class="nav-link">
                        <span class="nav-icon">&#128176;</span>
                        My Bills
                    </a>
                </li>
                <li class="nav-item">
                    <a href="#" class="nav-link">
                        <span class="nav-icon">&#10067;</span>
                        Help & Support
                    </a>
                </li>
            </ul>
        </nav>

        <!-- Main Content -->
        <main class="main-content">
    <div class="confirmation-container">
        <div class="page-header">
            <h2 class="page-title">✓ Booking Confirmation</h2>
        </div>

        <div class="confirmation-card">
            <div class="confirmation-icon">✓</div>

            <div class="confirmation-header">
                <h1>Booking Confirmed!</h1>
                <p>Your reservation has been successfully created</p>
            </div>

            <%
                String success = (String) request.getAttribute("success");
                Integer bookingId = (Integer) request.getAttribute("bookingId");
            %>

            <div class="booking-details">
                <div class="detail-row">
                    <span class="detail-label">Booking ID:</span>
                    <span class="detail-value">
                        <% if (bookingId != null) { %>
                            #<%= bookingId %>
                        <% } %>
                    </span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Guest Name:</span>
                    <span class="detail-value"><%= guestName != null ? guestName : "N/A" %></span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Status:</span>
                    <span class="detail-value"><strong style="color: #10b981;">Confirmed</strong></span>
                </div>
            </div>

            <div class="next-steps">
                <h3>📋 Next Steps</h3>
                <ul>
                    <li>A confirmation email has been sent to your registered email address</li>
                    <li>Check-in is from 3:00 PM onwards at the front desk</li>
                    <li>Please bring your booking ID and a valid ID during check-in</li>
                    <li>Contact the front desk for any special requests (ext. 0)</li>
                </ul>
            </div>

            <a href="guest.jsp" class="btn btn-primary">Return to Dashboard</a>
        </div>
    </div>
        </main>
    </div>

    <script>
        // Sidebar toggle functionality
        document.querySelector('.menu-toggle').addEventListener('click', function() {
            document.getElementById('guestSidebar').classList.toggle('active');
        });
    </script>
</body>
</html>

