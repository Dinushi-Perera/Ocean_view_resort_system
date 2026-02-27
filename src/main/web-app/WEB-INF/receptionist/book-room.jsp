<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.Guest" %>
<%@ page import="model.Room" %>
<%
    @SuppressWarnings("unchecked")
    List<Guest> allGuests = (List<Guest>) request.getAttribute("allGuests");
    @SuppressWarnings("unchecked")
    List<Room> allRooms = (List<Room>) request.getAttribute("allRooms");
    
    String error = (String) request.getAttribute("error");
    String message = (String) request.getAttribute("message");
    
    if (allGuests == null) allGuests = new java.util.ArrayList<>();
    if (allRooms == null) allRooms = new java.util.ArrayList<>();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Book Room - Ocean View Resort</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="<%= request.getContextPath() %>/style/styles.css">
    <style>
        .booking-form-container { max-width: 900px; margin: 0 auto; }
        .booking-card { background: white; padding: 35px; border-radius: 10px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); }
        .form-group { margin-bottom: 20px; }
        .form-group label { display: block; margin-bottom: 8px; font-weight: 600; color: #333; }
        .form-control { width: 100%; padding: 12px; border: 1px solid #ddd; border-radius: 5px; font-size: 14px; font-family: 'Inter', sans-serif; }
        .form-control:focus { border-color: #667eea; outline: none; box-shadow: 0 0 0 3px rgba(102,126,234,0.1); }
        .form-row { display: grid; grid-template-columns: 1fr 1fr; gap: 20px; }
        .btn { padding: 12px 25px; border: none; border-radius: 5px; cursor: pointer; font-size: 14px; font-weight: 600; transition: all 0.3s; }
        .btn-primary { background: #667eea; color: white; width: 100%; margin-top: 10px; }
        .btn-primary:hover { background: #5568d3; transform: translateY(-1px); }
        .btn-secondary { background: #6c757d; color: white; width: 100%; margin-top: 10px; }
        .btn-secondary:hover { background: #5a6268; }
        .alert { padding: 15px; border-radius: 5px; margin-bottom: 20px; font-weight: 500; }
        .alert-danger { background: #fee; color: #c33; border: 1px solid #fcc; }
        .alert-success { background: #dfd; color: #262; border: 1px solid #beb; }
        .room-type-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 10px; }
        .room-type-option { padding: 15px; background: #f8f9fa; border: 2px solid #e0e0e0; border-radius: 8px; cursor: pointer; transition: all 0.3s; }
        .room-type-option:hover { border-color: #667eea; background: #f0f4ff; }
        .room-type-option input[type="radio"] { display: none; }
        .room-type-option input[type="radio"]:checked + .room-info { border-left: 4px solid #667eea; }
        .room-type-option.selected { border-color: #667eea; background: #f0f4ff; }
        .room-info { padding-left: 10px; }
        .room-name { font-weight: bold; color: #333; margin-bottom: 5px; }
        .room-price { color: #667eea; font-size: 18px; font-weight: 600; }
        select.form-control { cursor: pointer; }
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
                    <a href="<%= request.getContextPath() %>/receptionist/help" class="nav-link">
                        <span class="nav-icon">&#10067;</span>
                        Help & Guide
                    </a>
                </li>
            </ul>
        </nav>

        <main class="main-content">
            <section class="page-section active">
                <div class="page-header">
                    <h2 class="page-title">&#128716; Create New Booking</h2>
                </div>

                <div class="booking-form-container">
                    <div class="booking-card">
                        <% if (error != null) { %>
                            <div class="alert alert-danger">&#10060; <%= error %></div>
                        <% } %>
                        
                        <% if (message != null) { %>
                            <div class="alert alert-success">&#9989; <%= message %></div>
                        <% } %>

                        <form action="<%= request.getContextPath() %>/receptionist/book-room" method="post">
                            <input type="hidden" name="action" value="createBooking">
                            
                            <!-- Guest Selection -->
                            <div class="form-group">
                                <label for="guestId">Select Guest *</label>
                                <select name="guestId" id="guestId" class="form-control" required>
                                    <option value="">-- Choose a Guest --</option>
                                    <% for (Guest guest : allGuests) { %>
                                        <option value="<%= guest.getId() %>">
                                            <%= guest.getFullName() %> - <%= guest.getEmail() %>
                                        </option>
                                    <% } %>
                                </select>
                            </div>

                            <!-- Room Type Selection -->
                            <div class="form-group">
                                <label>Select Room Type *</label>
                                <div class="room-type-grid">
                                    <label class="room-type-option" onclick="selectRoomType(this)">
                                        <input type="radio" name="roomType" value="standard" required onchange="loadAvailableRooms()">
                                        <div class="room-info">
                                            <div class="room-name">Standard Room</div>
                                            <div class="room-price">LKR 5,000/night</div>
                                            <div style="font-size: 12px; color: #666; margin-top: 5px;">Max 2 guests</div>
                                        </div>
                                    </label>
                                    
                                    <label class="room-type-option" onclick="selectRoomType(this)">
                                        <input type="radio" name="roomType" value="deluxe" required onchange="loadAvailableRooms()">
                                        <div class="room-info">
                                            <div class="room-name">Deluxe Room</div>
                                            <div class="room-price">LKR 10,000/night</div>
                                            <div style="font-size: 12px; color: #666; margin-top: 5px;">Max 3 guests</div>
                                        </div>
                                    </label>
                                    
                                    <label class="room-type-option" onclick="selectRoomType(this)">
                                        <input type="radio" name="roomType" value="suite" required onchange="loadAvailableRooms()">
                                        <div class="room-info">
                                            <div class="room-name">Suite</div>
                                            <div class="room-price">LKR 15,000/night</div>
                                            <div style="font-size: 12px; color: #666; margin-top: 5px;">Max 4 guests</div>
                                        </div>
                                    </label>
                                    
                                    <label class="room-type-option" onclick="selectRoomType(this)">
                                        <input type="radio" name="roomType" value="presidential" required onchange="loadAvailableRooms()">
                                        <div class="room-info">
                                            <div class="room-name">Presidential Suite</div>
                                            <div class="room-price">LKR 20,000/night</div>
                                            <div style="font-size: 12px; color: #666; margin-top: 5px;">Max 6 guests</div>
                                        </div>
                                    </label>
                                </div>
                            </div>

                            <!-- Room Number Selection -->
                            <div class="form-group" id="roomNumberGroup" style="display: none;">
                                <label for="roomId">Select Room Number *</label>
                                <select name="roomId" id="roomId" class="form-control" required>
                                    <option value="">-- Select a room --</option>
                                </select>
                                <div id="roomLoadingMessage" style="display: none; margin-top: 8px; color: #667eea; font-size: 13px;">
                                    Loading available rooms...
                                </div>
                                <div id="noRoomsMessage" style="display: none; margin-top: 8px; color: #c33; font-size: 13px;">
                                    No available rooms for selected dates and type.
                                </div>
                            </div>

                            <!-- Number of Guests -->
                            <div class="form-group">
                                <label for="numGuests">Number of Guests *</label>
                                <input type="number" name="numGuests" id="numGuests" class="form-control" min="1" max="10" required>
                            </div>

                            <!-- Check-in and Check-out Dates -->
                            <div class="form-row">
                                <div class="form-group">
                                    <label for="checkIn">Check-in Date *</label>
                                    <input type="date" name="checkIn" id="checkIn" class="form-control" required>
                                </div>
                                <div class="form-group">
                                    <label for="checkOut">Check-out Date *</label>
                                    <input type="date" name="checkOut" id="checkOut" class="form-control" required>
                                </div>
                            </div>

                            <!-- Special Requests -->
                            <div class="form-group">
                                <label for="specialRequests">Special Requests</label>
                                <textarea name="specialRequests" id="specialRequests" class="form-control" rows="4" placeholder="Enter any special requests or notes..."></textarea>
                            </div>

                            <!-- Submit Buttons -->
                            <button type="submit" class="btn btn-primary">Create Booking</button>
                            <a href="<%= request.getContextPath() %>/receptionist/reservations" style="text-decoration: none;">
                                <button type="button" class="btn btn-secondary">Cancel</button>
                            </a>
                        </form>
                    </div>
                </div>
            </section>
        </main>
    </div>

    <script>
        // Sidebar toggle
        const menuToggle = document.querySelector('.menu-toggle');
        if (menuToggle) {
            menuToggle.addEventListener('click', function() {
                document.getElementById('receptionistSidebar').classList.toggle('active');
            });
        }

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

        // Room type selection styling
        function selectRoomType(element) {
            document.querySelectorAll('.room-type-option').forEach(opt => {
                opt.classList.remove('selected');
            });
            element.classList.add('selected');
        }

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
            const url = '<%= request.getContextPath() %>/receptionist/book-room?action=getAvailableRooms&roomType=' + 
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
                            option.textContent = room.roomNumber + ' - Floor ' + room.floor + 
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
            const guestId = document.getElementById('guestId').value;
            const roomType = document.querySelector('input[name="roomType"]:checked');
            const roomId = document.getElementById('roomId').value;
            const numGuests = document.getElementById('numGuests').value;
            const checkIn = document.getElementById('checkIn').value;
            const checkOut = document.getElementById('checkOut').value;

            if (!guestId) {
                e.preventDefault();
                alert('Please select a guest');
                return;
            }

            if (!roomType) {
                e.preventDefault();
                alert('Please select a room type');
                return;
            }

            if (!roomId) {
                e.preventDefault();
                alert('Please select a room number');
                return;
            }

            if (!numGuests || numGuests < 1) {
                e.preventDefault();
                alert('Please enter a valid number of guests');
                return;
            }

            if (!checkIn || !checkOut) {
                e.preventDefault();
                alert('Please select check-in and check-out dates');
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
