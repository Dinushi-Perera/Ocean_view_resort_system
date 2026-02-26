<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.Guest" %>
<%@ page import="model.Booking" %>
<%@ page import="DAO.BookingDAO" %>
<%@ page import="DAO.RoomDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%
    // Check if user is logged in
    Guest guest = (Guest) session.getAttribute("guest");
    if (guest == null) {
        response.sendRedirect("login.jsp");
        return;
    }

    String guestName = guest.getFullName();
    String guestEmail = guest.getEmail();
    String guestContact = guest.getContact();
    
    // Fetch all bookings for this guest
    BookingDAO bookingDAO = new BookingDAO();
    List<Booking> bookings = bookingDAO.getBookingsByGuestId(guest.getId());
    
    // Filter only confirmed or checked-out bookings
    List<Booking> billableBookings = new java.util.ArrayList<>();
    for (Booking booking : bookings) {
        if (booking.getBookingStatus().equalsIgnoreCase("confirmed") || 
            booking.getBookingStatus().equalsIgnoreCase("checked-in") ||
            booking.getBookingStatus().equalsIgnoreCase("checked-out")) {
            billableBookings.add(booking);
        }
    }
    
    // Date formatter
    DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("MMM dd, yyyy");
    NumberFormat currencyFormat = NumberFormat.getCurrencyInstance(new Locale("en", "LK"));
    
    // Fetch room prices from database
    RoomDAO roomDAO = new RoomDAO();
    java.util.Map<String, Double> roomPrices = new java.util.HashMap<>();
    roomPrices.put("standard", roomDAO.getRoomPriceByType("standard"));
    roomPrices.put("deluxe", roomDAO.getRoomPriceByType("deluxe"));
    roomPrices.put("suite", roomDAO.getRoomPriceByType("suite"));
    roomPrices.put("presidential", roomDAO.getRoomPriceByType("presidential"));
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Bills - Ocean View Resort</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="style/styles.css">
    <!-- PDF Generation Library -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/html2pdf.js/0.10.1/html2pdf.bundle.min.js"></script>
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
                    <a href="my_bills.jsp" class="nav-link active">
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
                    <h2 class="page-title">&#128176; My Bills & Invoices</h2>
                </div>

                <div class="card">
                    <div class="card-header">
                        <h3 class="card-title">Generate Bill</h3>
                    </div>
                    <div style="max-width: 500px; margin: 20px; padding: 20px;">
                        <div class="form-group">
                            <label>Select Reservation</label>
                            <select id="guestBillSelect" onchange="showBill(this.value)" class="form-control">
                                <option value="">Choose a reservation</option>
                                <%
                                if (!billableBookings.isEmpty()) {
                                    for (Booking booking : billableBookings) {
                                %>
                                    <option value="<%= booking.getId() %>">
                                        Booking #<%= booking.getId() %> - <%= booking.getRoomType().toUpperCase() %> - 
                                        <%= booking.getCheckIn().format(dateFormatter) %>
                                    </option>
                                <%
                                    }
                                } else {
                                %>
                                    <option value="" disabled>No billable reservations found</option>
                                <%
                                }
                                %>
                            </select>
                        </div>
                    </div>

                    <!-- Bill Display -->
                    <%
                    for (Booking booking : billableBookings) {
                        long nights = booking.getNumberOfNights();
                        double pricePerNight = roomPrices.getOrDefault(booking.getRoomType().toLowerCase(), 15000.0);
                        double subtotal = nights * pricePerNight;
                        double serviceCharge = subtotal * 0.10; // 10% service charge
                        double tax = subtotal * 0.12; // 12% tax
                        double total = subtotal + serviceCharge + tax;
                    %>
                    <div id="bill-<%= booking.getId() %>" class="guestBillOutput" style="display: none; padding: 20px;">
                        <div class="bill-container" id="printable-bill-<%= booking.getId() %>" style="background: white; font-family: Arial, sans-serif; color: #333;">
                            <div class="bill-header" style="text-align: center; border-bottom: 2px solid #4f46e5; padding-bottom: 20px; margin-bottom: 30px;">
                                <h2 style="color: #4f46e5; margin-bottom: 10px; font-size: 24px;">Ocean View Resort</h2>
                                <p style="margin: 5px 0; color: #666; font-size: 14px;">123 Lighthouse Street, Galle Fort, Galle 80000, Sri Lanka</p>
                                <p style="margin: 5px 0; color: #666; font-size: 14px;">Tel: +94 91 223 4567 | Email: info@oceanviewresort.lk</p>
                            </div>
                            
                            <h3 style="text-align: center; margin-bottom: 30px; color: #4f46e5; font-size: 20px;">GUEST INVOICE</h3>
                            
                            <div class="bill-details" style="margin-bottom: 30px;">
                                <table style="width: 100%; margin-bottom: 20px; border: none;">
                                    <tr>
                                        <td style="width: 50%; vertical-align: top; padding: 5px;">
                                            <p style="margin: 5px 0; font-size: 14px;"><strong>Invoice Number:</strong> INV-<%= booking.getId() %></p>
                                            <p style="margin: 5px 0; font-size: 14px;"><strong>Invoice Date:</strong> <%= LocalDate.now().format(dateFormatter) %></p>
                                            <p style="margin: 5px 0; font-size: 14px;"><strong>Booking ID:</strong> #<%= booking.getId() %></p>
                                        </td>
                                        <td style="width: 50%; vertical-align: top; padding: 5px;">
                                            <p style="margin: 5px 0; font-size: 14px;"><strong>Guest Name:</strong> <%= guestName %></p>
                                            <p style="margin: 5px 0; font-size: 14px;"><strong>Email:</strong> <%= guestEmail %></p>
                                            <p style="margin: 5px 0; font-size: 14px;"><strong>Contact:</strong> <%= guestContact %></p>
                                        </td>
                                    </tr>
                                </table>
                                
                                <div style="background: #f8f9fa; padding: 15px; border-radius: 8px; margin-top: 20px;">
                                    <h4 style="margin-bottom: 15px; color: #4f46e5; font-size: 16px;">Booking Details</h4>
                                    <table style="width: 100%; border: none;">
                                        <tr>
                                            <td style="width: 50%; padding: 3px;"><p style="margin: 5px 0; font-size: 14px;"><strong>Room Type:</strong> <%= booking.getRoomType().toUpperCase() %></p></td>
                                            <td style="width: 50%; padding: 3px;"><p style="margin: 5px 0; font-size: 14px;"><strong>Number of Guests:</strong> <%= booking.getNumGuests() %></p></td>
                                        </tr>
                                        <tr>
                                            <td style="padding: 3px;"><p style="margin: 5px 0; font-size: 14px;"><strong>Check-in:</strong> <%= booking.getCheckIn().format(dateFormatter) %></p></td>
                                            <td style="padding: 3px;"><p style="margin: 5px 0; font-size: 14px;"><strong>Check-out:</strong> <%= booking.getCheckOut().format(dateFormatter) %></p></td>
                                        </tr>
                                        <tr>
                                            <td style="padding: 3px;"><p style="margin: 5px 0; font-size: 14px;"><strong>Number of Nights:</strong> <%= nights %></p></td>
                                            <td style="padding: 3px;"><p style="margin: 5px 0; font-size: 14px;"><strong>Status:</strong> <%= booking.getBookingStatus().toUpperCase() %></p></td>
                                        </tr>
                                    </table>
                                    <% if (booking.getSpecialRequests() != null && !booking.getSpecialRequests().trim().isEmpty()) { %>
                                    <p style="margin-top: 10px;"><strong>Special Requests:</strong> <%= booking.getSpecialRequests() %></p>
                                    <% } %>
                                </div>
                            </div>
                            
                            <div class="bill-breakdown" style="margin: 30px 0;">
                                <h4 style="margin-bottom: 15px; color: #4f46e5; font-size: 16px;">Bill Breakdown</h4>
                                <table style="width: 100%; border-collapse: collapse; font-size: 14px;">
                                    <thead>
                                        <tr style="background: #4f46e5; color: white;">
                                            <th style="padding: 12px; text-align: left; border: 1px solid #ddd; font-size: 14px;">Description</th>
                                            <th style="padding: 12px; text-align: right; border: 1px solid #ddd; font-size: 14px;">Rate</th>
                                            <th style="padding: 12px; text-align: center; border: 1px solid #ddd; font-size: 14px;">Quantity</th>
                                            <th style="padding: 12px; text-align: right; border: 1px solid #ddd; font-size: 14px;">Amount (LKR)</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr>
                                            <td style="padding: 12px; border: 1px solid #ddd;"><%= booking.getRoomType().substring(0,1).toUpperCase() + booking.getRoomType().substring(1) %> Room</td>
                                            <td style="padding: 12px; text-align: right; border: 1px solid #ddd;"><%= String.format("%,.2f", pricePerNight) %></td>
                                            <td style="padding: 12px; text-align: center; border: 1px solid #ddd;"><%= nights %> night(s)</td>
                                            <td style="padding: 12px; text-align: right; border: 1px solid #ddd;"><%= String.format("%,.2f", subtotal) %></td>
                                        </tr>
                                        <tr>
                                            <td colspan="3" style="padding: 12px; text-align: right; border: 1px solid #ddd;"><strong>Subtotal:</strong></td>
                                            <td style="padding: 12px; text-align: right; border: 1px solid #ddd;"><%= String.format("%,.2f", subtotal) %></td>
                                        </tr>
                                        <tr>
                                            <td colspan="3" style="padding: 12px; text-align: right; border: 1px solid #ddd;">Service Charge (10%):</td>
                                            <td style="padding: 12px; text-align: right; border: 1px solid #ddd;"><%= String.format("%,.2f", serviceCharge) %></td>
                                        </tr>
                                        <tr>
                                            <td colspan="3" style="padding: 12px; text-align: right; border: 1px solid #ddd;">Tax (12%):</td>
                                            <td style="padding: 12px; text-align: right; border: 1px solid #ddd;"><%= String.format("%,.2f", tax) %></td>
                                        </tr>
                                        <tr style="background: #f8f9fa;">
                                            <td colspan="3" style="padding: 15px; text-align: right; border: 1px solid #ddd;"><h3 style="margin: 0; color: #4f46e5; font-size: 18px;">Total Amount:</h3></td>
                                            <td style="padding: 15px; text-align: right; border: 1px solid #ddd;"><h3 style="margin: 0; color: #4f46e5; font-size: 18px;">LKR <%= String.format("%,.2f", total) %></h3></td>
                                        </tr>
                                    </tbody>
                                </table>
                            </div>
                            
                            <div style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #ddd; text-align: center; color: #666;">
                                <p style="margin: 5px 0;">Thank you for choosing Ocean View Resort!</p>
                                <p style="margin: 5px 0; font-size: 0.9em;">For any inquiries, please contact us at info@oceanviewresort.lk or +94 91 223 4567</p>
                            </div>
                        </div>
                        
                        <div style="margin-top: 30px; text-align: center; display: flex; gap: 15px; justify-content: center;" class="no-print">
                            <button class="btn btn-primary" onclick="printBill('<%= booking.getId() %>')">
                                &#128424; Print Invoice
                            </button>
                            <button class="btn btn-primary" onclick="downloadBill('<%= booking.getId() %>')">
                                &#128190; Download PDF
                            </button>
                        </div>
                    </div>
                    <%
                    }
                    %>
                </div>
            </section>
        </main>
    </div>

    <style>
        @media print {
            .no-print {
                display: none !important;
            }
            .sidebar, .app-header {
                display: none !important;
            }
            .main-content {
                margin: 0 !important;
                padding: 20px !important;
            }
            body {
                background: white !important;
            }
        }
        
        .bill-container {
            background: white;
            padding: 40px;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        }
        
        select.form-control {
            width: 100%;
            padding: 12px 16px;
            border: 1px solid #e0e7ff;
            border-radius: 8px;
            font-family: 'Inter', sans-serif;
            font-size: 1rem;
            transition: all 0.3s ease;
        }
        
        select.form-control:focus {
            outline: none;
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.1);
        }
    </style>

    <script>
        // Show bill when reservation is selected
        function showBill(bookingId) {
            // Hide all bills
            document.querySelectorAll('.guestBillOutput').forEach(bill => {
                bill.style.display = 'none';
            });
            
            // Show selected bill
            if (bookingId) {
                const selectedBill = document.getElementById('bill-' + bookingId);
                if (selectedBill) {
                    selectedBill.style.display = 'block';
                    // Scroll to bill
                    selectedBill.scrollIntoView({ behavior: 'smooth', block: 'start' });
                }
            }
        }
        
        // Print bill function
        function printBill(bookingId) {
            const billContent = document.getElementById('printable-bill-' + bookingId);
            if (!billContent) {
                alert('Bill not found!');
                return;
            }
            
            // Create a new window for printing
            const printWindow = window.open('', '_blank');
            printWindow.document.write('<html><head><title>Invoice - Booking #' + bookingId + '</title>');
            printWindow.document.write('<style>');
            printWindow.document.write('body { font-family: Arial, sans-serif; padding: 20px; }');
            printWindow.document.write('table { width: 100%; border-collapse: collapse; margin: 20px 0; }');
            printWindow.document.write('th, td { padding: 12px; border: 1px solid #ddd; text-align: left; }');
            printWindow.document.write('th { background: #4f46e5; color: white; }');
            printWindow.document.write('h2, h3, h4 { color: #4f46e5; }');
            printWindow.document.write('.bill-header { text-align: center; border-bottom: 2px solid #4f46e5; padding-bottom: 20px; margin-bottom: 30px; }');
            printWindow.document.write('</style>');
            printWindow.document.write('</head><body>');
            printWindow.document.write(billContent.innerHTML);
            printWindow.document.write('</body></html>');
            printWindow.document.close();
            
            // Wait for content to load, then print
            printWindow.onload = function() {
                printWindow.print();
            };
        }
        
        // Download bill as PDF
        function downloadBill(bookingId) {
            const billContent = document.getElementById('printable-bill-' + bookingId);
            if (!billContent) {
                alert('Bill not found!');
                return;
            }
            
            // Clone the bill content to avoid modifying the original
            const clonedContent = billContent.cloneNode(true);
            
            // Create a temporary container
            const tempContainer = document.createElement('div');
            tempContainer.style.position = 'absolute';
            tempContainer.style.left = '-9999px';
            tempContainer.style.width = '800px';
            tempContainer.style.background = 'white';
            tempContainer.style.padding = '20px';
            tempContainer.appendChild(clonedContent);
            document.body.appendChild(tempContainer);
            
            // Show loading message
            const button = event.target;
            const originalText = button.textContent;
            button.textContent = 'Generating PDF...';
            button.disabled = true;
            
            // Wait a moment for rendering
            setTimeout(() => {
                // Configure PDF options
                const options = {
                    margin: 10,
                    filename: 'Invoice-Booking-' + bookingId + '.pdf',
                    image: { type: 'jpeg', quality: 0.95 },
                    html2canvas: { 
                        scale: 2,
                        useCORS: true,
                        logging: false,
                        backgroundColor: '#ffffff'
                    },
                    jsPDF: { 
                        unit: 'mm', 
                        format: 'a4', 
                        orientation: 'portrait',
                        compress: true
                    },
                    pagebreak: { mode: ['avoid-all', 'css', 'legacy'] }
                };
                
                // Generate and download PDF
                html2pdf()
                    .set(options)
                    .from(tempContainer)
                    .save()
                    .then(() => {
                        // Cleanup
                        document.body.removeChild(tempContainer);
                        button.textContent = originalText;
                        button.disabled = false;
                    })
                    .catch((error) => {
                        console.error('PDF generation error:', error);
                        document.body.removeChild(tempContainer);
                        button.textContent = originalText;
                        button.disabled = false;
                        alert('Error generating PDF. Please try using the Print option instead.');
                    });
            }, 100);
        }
        
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