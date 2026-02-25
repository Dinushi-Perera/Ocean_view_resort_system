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
    <title>Book a Room - Ocean View Resort</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="style/styles.css">

    <style>
        .booking-container {
            padding: 20px;
            max-width: 800px;
            margin: 0 auto;
        }

        .booking-card {
            background: white;
            border-radius: 12px;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
            padding: 40px;
            margin-top: 20px;
        }

        .booking-header {
            text-align: center;
            margin-bottom: 30px;
        }

        .booking-header h1 {
            font-size: 2.5rem;
            color: var(--primary);
            margin-bottom: 10px;
        }

        .booking-header p {
            color: var(--gray);
            font-size: 1rem;
        }

        .form-group {
            margin-bottom: 20px;
        }

        label {
            display: block;
            margin-bottom: 8px;
            font-weight: 600;
            color: var(--dark);
            font-size: 0.95rem;
        }

        input[type="text"],
        input[type="email"],
        input[type="number"],
        input[type="date"],
        select,
        textarea {
            width: 100%;
            padding: 12px 16px;
            border: 1px solid #e0e7ff;
            border-radius: 8px;
            font-family: 'Inter', sans-serif;
            font-size: 1rem;
            transition: all 0.3s ease;
            background: #f8fafc;
        }

        select {
            cursor: pointer;
        }

        input[type="text"]:focus,
        input[type="email"]:focus,
        input[type="number"]:focus,
        input[type="date"]:focus,
        select:focus,
        textarea:focus {
            background: white;
            border-color: var(--primary);
            outline: none;
            box-shadow: 0 0 0 3px rgba(2, 132, 199, 0.1);
        }

        textarea {
            resize: vertical;
            min-height: 100px;
        }

        .form-row {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
        }

        .alert {
            padding: 15px 20px;
            border-radius: 8px;
            margin-bottom: 25px;
            font-size: 0.95rem;
        }

        .alert-danger {
            background-color: #fee2e2;
            color: #991b1b;
            border: 1px solid #fecaca;
        }

        .alert-success {
            background-color: #dcfce7;
            color: #166534;
            border: 1px solid #bbf7d0;
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
        }

        .btn-primary {
            background: linear-gradient(135deg, #0c4a6e 0%, #0284c7 100%);
            color: white;
            border: none;
        }

        .btn-primary:hover {
            box-shadow: 0 10px 30px rgba(12, 74, 110, 0.3);
            transform: translateY(-2px);
        }

        .btn-secondary {
            background: var(--gray-light);
            color: var(--primary);
            margin-top: 10px;
        }

        .btn-secondary:hover {
            background: #e0f2fe;
        }

        .room-info {
            background: #f0f9ff;
            padding: 20px;
            border-radius: 8px;
            margin-top: 25px;
            border-left: 4px solid var(--primary);
        }

        .room-info h3 {
            color: var(--primary);
            margin-bottom: 12px;
            font-size: 1.1rem;
        }

        .room-option {
            margin-bottom: 12px;
            padding: 12px;
            background: white;
            border-radius: 6px;
            border: 1px solid #e0e7ff;
        }

        .room-option label {
            margin: 0;
            display: flex;
            align-items: center;
            cursor: pointer;
            font-weight: 500;
        }

        .room-option input[type="radio"] {
            margin-right: 10px;
            cursor: pointer;
            width: auto;
        }

        @media (max-width: 768px) {
            .booking-card {
                padding: 30px 20px;
            }

            .booking-header h1 {
                font-size: 1.8rem;
            }

            .form-row {
                grid-template-columns: 1fr;
                gap: 15px;
            }
        }
    </style>
</head>
<body>
    <!-- ============================================
         GUEST DASHBOARD WITH BOOKING FORM
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
                    <a href="book_room.jsp" class="nav-link active">
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
                    <a href="help.jsp" class="nav-link">
                        <span class="nav-icon">&#10067;</span>
                        Help & Support
                    </a>
                </li>
            </ul>
        </nav>

        <!-- Main Content -->
        <main class="main-content">

    <div class="booking-container">
        <div class="page-header">
            <h2 class="page-title">&#128716; Book Your Room</h2>
        </div>

        <div class="booking-card">
            <div class="booking-header">
                <h1>Book Your Room</h1>
                <p>Experience luxury at Ocean View Resort</p>
            </div>

            <%
                String error = (String) request.getAttribute("error");
                String success = (String) request.getAttribute("success");
            %>

            <% if (error != null) { %>
                <div class="alert alert-danger">
                    <strong>Error:</strong> <%= error %>
                </div>
            <% } %>

            <% if (success != null) { %>
                <div class="alert alert-success">
                    <strong>Success:</strong> <%= success %>
                </div>
            <% } %>

            <form method="POST" action="<%= request.getContextPath() %>/book">

                <!-- Room Type Selection -->
                <div class="form-group">
                    <label>Room Type *</label>
                    <div class="room-info">
                        <div class="room-option">
                            <label>
                                <input type="radio" name="roomType" value="standard" required onchange="loadAvailableRooms()">
                                Standard Room - LKR 5000/night
                            </label>
                        </div>
                        <div class="room-option">
                            <label>
                                <input type="radio" name="roomType" value="deluxe" required onchange="loadAvailableRooms()">
                                Deluxe Room - LKR 10000/night
                            </label>
                        </div>
                        <div class="room-option">
                            <label>
                                <input type="radio" name="roomType" value="suite" required onchange="loadAvailableRooms()">
                                Suite - LKR 15000/night
                            </label>
                        </div>
                        <div class="room-option">
                            <label>
                                <input type="radio" name="roomType" value="presidential" required onchange="loadAvailableRooms()">
                                Presidential Suite - LKR 20000/night
                            </label>
                        </div>
                    </div>
                </div>

                <!-- Room Number Selection -->
                <div class="form-group" id="roomNumberGroup" style="display: none;">
                    <label for="roomId">Available Rooms *</label>
                    <select name="roomId" id="roomId" class="form-control" required>
                        <option value="">-- Select check-in/check-out dates and room type first --</option>
                    </select>
                    <div id="roomLoadingMessage" style="display: none; margin-top: 8px; color: #0284c7; font-size: 13px;">
                        ⏳ Loading available rooms...
                    </div>
                    <div id="noRoomsMessage" style="display: none; margin-top: 8px; color: #991b1b; font-size: 13px;">
                        ❌ No available rooms for selected dates and type. Please try different dates.
                    </div>
                </div>

                <!-- Number of Guests -->
                <div class="form-group">
                    <label for="numGuests">Number of Guests *</label>
                    <input type="number" id="numGuests" name="numGuests" min="1" max="10" placeholder="Enter number of guests" required>
                </div>

                <!-- Check-in and Check-out Dates -->
                <div class="form-row">
                    <div class="form-group">
                        <label for="checkIn">Check-in Date *</label>
                        <input type="date" id="checkIn" name="checkIn" required>
                    </div>
                    <div class="form-group">
                        <label for="checkOut">Check-out Date *</label>
                        <input type="date" id="checkOut" name="checkOut" required>
                    </div>
                </div>

                <!-- Special Requests -->
                <div class="form-group">
                    <label for="specialRequests">Special Requests</label>
                    <textarea id="specialRequests" name="specialRequests" placeholder="Any special requests or requirements? (Optional)"></textarea>
                </div>

                <!-- Submit Button -->
                <button type="submit" class="btn btn-primary">Complete Booking</button>
                <a href="guest.jsp" style="text-decoration: none;">
                    <button type="button" class="btn btn-secondary">Cancel</button>
                </a>
            </form>
        </div>
    </div>
        </main>
    </div>

    <script>
        // Sidebar toggle functionality
        document.querySelector('.menu-toggle').addEventListener('click', function() {
            document.getElementById('guestSidebar').classList.toggle('active');
        });

        // Set minimum date to today
        const today = new Date().toISOString().split('T')[0];
        document.getElementById('checkIn').min = today;

        // Update checkout minimum date when checkin changes
        document.getElementById('checkIn').addEventListener('change', function() {
            const checkInDate = new Date(this.value);
            checkInDate.setDate(checkInDate.getDate() + 1);
            document.getElementById('checkOut').min = checkInDate.toISOString().split('T')[0];
            loadAvailableRooms(); // Reload rooms when dates change
        });

        // Load rooms when checkout date changes
        document.getElementById('checkOut').addEventListener('change', function() {
            loadAvailableRooms();
        });

        // Load available rooms based on room type and dates
        function loadAvailableRooms() {
            const roomTypeRadio = document.querySelector('input[name="roomType"]:checked');
            const checkIn = document.getElementById('checkIn').value;
            const checkOut = document.getElementById('checkOut').value;
            const roomNumberGroup = document.getElementById('roomNumberGroup');
            const roomIdSelect = document.getElementById('roomId');
            const loadingMessage = document.getElementById('roomLoadingMessage');
            const noRoomsMessage = document.getElementById('noRoomsMessage');

            // Hide messages
            loadingMessage.style.display = 'none';
            noRoomsMessage.style.display = 'none';

            if (!roomTypeRadio) {
                roomNumberGroup.style.display = 'none';
                return;
            }

            const roomType = roomTypeRadio.value;

            // Show room selection group
            roomNumberGroup.style.display = 'block';

            if (!checkIn || !checkOut) {
                roomIdSelect.innerHTML = '<option value="">-- Please select check-in and check-out dates first --</option>';
                roomIdSelect.disabled = true;
                return;
            }

            // Show loading message
            loadingMessage.style.display = 'block';
            roomIdSelect.disabled = true;
            roomIdSelect.innerHTML = '<option value="">Loading...</option>';

            // Fetch available rooms via AJAX
            const url = '<%= request.getContextPath() %>/book?action=getAvailableRooms&roomType=' + 
                        encodeURIComponent(roomType) + '&checkIn=' + checkIn + '&checkOut=' + checkOut;

            fetch(url)
                .then(response => response.json())
                .then(data => {
                    loadingMessage.style.display = 'none';
                    roomIdSelect.innerHTML = '<option value="">-- Select a room --</option>';
                    
                    if (data.rooms && data.rooms.length > 0) {
                        data.rooms.forEach(room => {
                            const option = document.createElement('option');
                            option.value = room.id;
                            option.textContent = 'Room ' + room.roomNumber + ' - Floor ' + room.floor + 
                                               ' (LKR ' + room.pricePerNight + '/night)';
                            roomIdSelect.appendChild(option);
                        });
                        roomIdSelect.disabled = false;
                    } else {
                        roomIdSelect.innerHTML = '<option value="">No rooms available</option>';
                        noRoomsMessage.style.display = 'block';
                    }
                })
                .catch(error => {
                    console.error('Error loading rooms:', error);
                    loadingMessage.style.display = 'none';
                    roomIdSelect.innerHTML = '<option value="">Error loading rooms</option>';
                    alert('Failed to load available rooms. Please try again.');
                });
        }

        // Form validation
        document.querySelector('form').addEventListener('submit', function(e) {
            const roomType = document.querySelector('input[name="roomType"]:checked');
            const roomId = document.getElementById('roomId').value;
            const numGuests = document.getElementById('numGuests').value;
            const checkIn = document.getElementById('checkIn').value;
            const checkOut = document.getElementById('checkOut').value;

            if (!roomType) {
                e.preventDefault();
                alert('Please select a room type');
                return;
            }

            if (!roomId) {
                e.preventDefault();
                alert('Please select a room');
                return;
            }

            if (!numGuests || numGuests < 1 || numGuests > 10) {
                e.preventDefault();
                alert('Please enter a valid number of guests (1-10)');
                return;
            }

            if (!checkIn) {
                e.preventDefault();
                alert('Please select a check-in date');
                return;
            }

            if (!checkOut) {
                e.preventDefault();
                alert('Please select a check-out date');
                return;
            }

            const checkInDate = new Date(checkIn);
            const checkOutDate = new Date(checkOut);

            if (checkOutDate <= checkInDate) {
                e.preventDefault();
                alert('Check-out date must be after check-in date');
                return;
            }
        });
    </script>
</body>
</html>
