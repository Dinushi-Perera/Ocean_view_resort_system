<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Help & Guide - Ocean View Resort</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/style/styles.css">
    <style>
        .help-section { background: white; padding: 30px; border-radius: 10px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); margin-bottom: 20px; }
        .help-section h3 { color: #667eea; margin-top: 0; font-size: 22px; border-bottom: 2px solid #e9ecef; padding-bottom: 10px; }
        .help-section p { line-height: 1.8; color: #555; }
        .help-section ul { line-height: 2; color: #555; }
        .help-section strong { color: #333; }
        .feature-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; margin-top: 20px; }
        .feature-card { background: #f8f9fa; padding: 20px; border-radius: 8px; border-left: 4px solid #667eea; }
        .feature-card h4 { margin-top: 0; color: #667eea; }
        .feature-card p { margin-bottom: 0; font-size: 14px; color: #666; }
        .contact-box { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 25px; border-radius: 10px; text-align: center; }
        .contact-box h3 { margin-top: 0; }
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
                    <a href="<%= request.getContextPath() %>/receptionist/rooms" class="nav-link">
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
                    <a href="<%= request.getContextPath() %>/receptionist/help" class="nav-link active">
                        <span class="nav-icon">&#10067;</span>
                        Help & Guide
                    </a>
                </li>
            </ul>
        </nav>

        <main class="main-content">
            <section class="page-section active">
                <div class="page-header">
                    <h2 class="page-title">&#10067; Receptionist Help & User Guide</h2>
                </div>

        <div class="help-section">
            <h3>&#128202; Dashboard Overview</h3>
            <p>The dashboard provides a quick overview of the hotel's current status. You can see:</p>
            <ul>
                <li><strong>Total Rooms:</strong> The total number of rooms in the hotel</li>
                <li><strong>Available Rooms:</strong> Rooms that are currently available for booking</li>
                <li><strong>Occupied Rooms:</strong> Rooms with guests currently checked in</li>
                <li><strong>Pending Checkouts:</strong> Number of guests scheduled to check out today</li>
            </ul>
            <p>The dashboard also shows a list of recent reservations for quick reference.</p>
        </div>

        <div class="help-section">
            <h3>&#128203; Managing Reservations</h3>
            <p>The Reservations section allows you to view all guest reservations in the system. Here's what you can do:</p>
            <ul>
                <li><strong>View All Reservations:</strong> See a complete list of all bookings with guest details</li>
                <li><strong>Search Reservations:</strong> Use the search box to find specific reservations by ID or guest name</li>
                <li><strong>View Booking Details:</strong> See check-in/check-out dates, room type, and booking status</li>
            </ul>
            <p><strong>Important Note:</strong> As a receptionist, you have view-only access to reservations. You cannot modify or cancel bookings. For any changes, please contact the hotel manager.</p>
        </div>

        <div class="help-section">
            <h3>&#128716; Room Availability</h3>
            <p>The Room Availability section shows real-time room status by type:</p>
            <ul>
                <li><strong>View by Room Type:</strong> See availability for Standard, Deluxe, Suite, and Presidential rooms</li>
                <li><strong>Filter Rooms:</strong> Use the filter dropdown to view specific room types</li>
                <li><strong>Occupancy Rates:</strong> Visual indicators show how many rooms of each type are occupied</li>
                <li><strong>Real-time Updates:</strong> Room status is calculated based on current check-in data</li>
            </ul>
        </div>

        <div class="help-section">
            <h3>&#9989; Check-in/Check-out Process</h3>
            <p><strong>Checking In a Guest:</strong></p>
            <ol style="line-height: 2;">
                <li>Navigate to the Check-in/Check-out section</li>
                <li>Look for the guest's reservation in "Today's Check-ins" or the full booking list</li>
                <li>Click the "Check In Guest" button next to their booking</li>
                <li>The booking status will update to "CHECKED-IN"</li>
            </ol>
            
            <p><strong>Checking Out a Guest:</strong></p>
            <ol style="line-height: 2;">
                <li>Find the guest's booking in "Today's Check-outs" or the full booking list</li>
                <li>Click the "Check Out Guest" button</li>
                <li>The booking status will update to "CHECKED-OUT"</li>
                <li>The room will become available for new bookings</li>
            </ol>
        </div>

        <div class="help-section">
            <h3>&#128176; Billing & Invoices</h3>
            <p><strong>Generating a Bill:</strong></p>
            <ol style="line-height: 2;">
                <li>Go to the Billing section</li>
                <li>Select the guest's reservation from the dropdown menu</li>
                <li>Click "Generate Bill"</li>
                <li>Review the invoice details including room charges, service charge, and taxes</li>
                <li>Click "Print Invoice" to print a copy for the guest</li>
            </ol>
            
            <p><strong>Bill Components:</strong></p>
            <ul>
                <li><strong>Room Rate:</strong> Base rate per night based on room type</li>
                <li><strong>Service Charge:</strong> 10% of the subtotal</li>
                <li><strong>VAT/Tax:</strong> 12% of the subtotal</li>
                <li><strong>Total Amount:</strong> Final amount payable by the guest</li>
            </ul>
        </div>

        <div class="help-section">
            <h3>&#128221; Your Access Permissions</h3>
            <p>As a receptionist, you have the following permissions:</p>
            
            <div class="feature-grid">
                <div class="feature-card">
                    <h4>✓ Allowed Actions</h4>
                    <p>• View all reservations<br>
                    • Check room availability<br>
                    • Perform check-ins<br>
                    • Perform check-outs<br>
                    • Generate guest bills<br>
                    • Print invoices</p>
                </div>
                <div class="feature-card">
                    <h4>✗ Restricted Actions</h4>
                    <p>• Modify reservations<br>
                    • Cancel bookings<br>
                    • Access cleaning services<br>
                    • Manage staff<br>
                    • Change system settings<br>
                    • Create new bookings</p>
                </div>
            </div>
        </div>

        <div class="help-section">
            <h3>&#128680; Navigation Tips</h3>
            <p>Use the navigation menu at the top to quickly move between sections:</p>
            <ul>
                <li>Click any menu item to navigate to that section</li>
                <li>The current section is highlighted in bold</li>
                <li>All navigation works without JavaScript - just click links and submit forms</li>
                <li>Use your browser's back button if needed</li>
            </ul>
        </div>

        <div class="help-section">
            <h3>&#9888; Common Issues & Solutions</h3>
            <p><strong>Q: I can't check in a guest</strong><br>
            A: Make sure the booking status shows as "PENDING" or "CONFIRMED". Already checked-in bookings cannot be checked in again.</p>
            
            <p><strong>Q: The room availability doesn't update</strong><br>
            A: Room availability is calculated from the bookings database. Make sure check-ins and check-outs are processed correctly.</p>
            
            <p><strong>Q: I need to modify a reservation</strong><br>
            A: Contact the hotel manager or system administrator. Receptionists do not have permission to modify bookings.</p>
            
            <p><strong>Q: How do I handle a guest complaint?</strong><br>
            A: Escalate to the hotel manager. Document the issue and inform your supervisor immediately.</p>
        </div>

        <div class="contact-box">
            <h3>&#128222; Need Additional Help?</h3>
            <p style="margin-bottom: 15px;">If you encounter any issues or need assistance beyond this guide:</p>
            <p><strong>Hotel Manager:</strong> Contact your supervisor during business hours<br>
            <strong>System Administrator:</strong> For technical issues, contact IT support<br>
            <strong>Emergency:</strong> Follow the hotel's emergency protocols</p>
        </div>

        <div style="background: #e7f3ff; border-left: 4px solid #2196F3; padding: 15px; border-radius: 5px; margin-top: 20px;">
            <strong>ℹ️ System Version:</strong> Ocean View Resort Management System v1.0<br>
            <strong>Last Updated:</strong> <%= java.time.LocalDate.now() %><br>
            <strong>Your Role:</strong> Receptionist
        </div>
            </section>
        </main>
    </div>

    <script>
        const menuToggle = document.querySelector('.menu-toggle');
        const sidebar = document.getElementById('receptionistSidebar');
        
        menuToggle.addEventListener('click', () => {
            sidebar.classList.toggle('active');
        });
    </script>
</body>
</html>
