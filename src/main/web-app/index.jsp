<%@ page contentType="text/html;charset=UTF-8" language="java" %>
    <!DOCTYPE html>
    <html lang="en">

    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Ocean View Resort - Galle, Sri Lanka</title>
        <link rel="preconnect" href="https://fonts.googleapis.com">
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
        <link
            href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Inter:wght@300;400;500;600;700&display=swap"
            rel="stylesheet">
        <link rel="stylesheet" href="style/styles.css">
    </head>

    <body>
        <!-- Toast Container -->
        <div class="toast-container" id="toastContainer"></div>

        <!-- ============================================
         LANDING PAGE - SCROLLABLE WEBSITE
    ============================================ -->
        <div id="landing-page">
            <!-- Navigation -->
            <nav class="main-nav" id="mainNav">
                <a href="#" class="nav-logo">Ocean View Resort</a>
                <ul class="nav-links">
                    <li><a href="#about">About</a></li>
                    <li><a href="#rooms">Rooms</a></li>
                    <li><a href="#amenities">Amenities</a></li>
                    <li><a href="#gallery">Gallery</a></li>
                    <li><a href="#contact">Contact</a></li>
                </ul>
                <a href="stafflogin.jsp" class="nav-btn">Staff Portal</a>
                <button class="mobile-menu-btn">&#9776;</button>
            </nav>

            <!-- Hero Section -->
            <section class="hero">
                <div class="hero-video">
                    <video autoplay muted loop id="heroVideo">
                        <source src="https://videos.pexels.com/video-files/1093662/1093662-hd_1920_1080_30fps.mp4"
                            type="video/mp4">
                        <!-- Fallback background image if video doesn't load -->
                        <div
                            style="background-image: url('assets/images/hero-resort.jpg'); background-size: cover; background-position: center; width: 100%; height: 100%;">
                        </div>
                    </video>
                </div>
                <div class="hero-overlay"></div>
                <div class="hero-content">
                    <span class="hero-subtitle">Welcome to Paradise</span>
                    <h1 class="hero-title">Ocean View Resort</h1>
                    <p class="hero-description">Experience the ultimate luxury escape on the pristine shores of Galle,
                        Sri Lanka. Where the Indian Ocean meets world-class hospitality.</p>
                    <div class="hero-buttons">
                        <a href="#rooms" class="btn-hero btn-hero-primary">Explore Rooms</a>
                        <a href="login.jsp" class="btn-hero btn-hero-secondary">Book Now</a>
                    </div>
                </div>
                <div class="scroll-indicator">
                    <div class="scroll-mouse"></div>
                </div>
                <div class="hero-waves">
                    <svg class="wave-svg" viewBox="0 0 1440 320" preserveAspectRatio="none">
                        <path fill="#ffffff" fill-opacity="0.4"
                            d="M0,192L48,176C96,160,192,128,288,133.3C384,139,480,181,576,186.7C672,192,768,160,864,154.7C960,149,1056,171,1152,165.3C1248,160,1344,128,1392,112L1440,96L1440,320L1392,320C1344,320,1248,320,1152,320C1056,320,960,320,864,320C768,320,672,320,576,320C480,320,384,320,288,320C192,320,96,320,48,320L0,320Z">
                        </path>
                    </svg>
                    <svg class="wave-svg" viewBox="0 0 1440 320" preserveAspectRatio="none">
                        <path fill="#ffffff" fill-opacity="0.3"
                            d="M0,224L48,213.3C96,203,192,181,288,181.3C384,181,480,203,576,218.7C672,235,768,245,864,234.7C960,224,1056,192,1152,181.3C1248,171,1344,181,1392,186.7L1440,192L1440,320L1392,320C1344,320,1248,320,1152,320C1056,320,960,320,864,320C768,320,672,320,576,320C480,320,384,320,288,320C192,320,96,320,48,320L0,320Z">
                        </path>
                    </svg>
                </div>
            </section>

            <!-- About Section -->
            <section class="section about-section" id="about">
                <div class="about-grid">
                    <div class="about-image">
                        <img src="assets/images/hero-resort.jpg" alt="Ocean View Resort aerial view">
                        <div class="about-image-accent"></div>
                    </div>
                    <div class="about-content">
                        <span class="section-label">Our Story</span>
                        <h2>A Haven of Luxury on Sri Lanka's Southern Coast</h2>
                        <p>Nestled along the breathtaking coastline of Galle, Ocean View Resort offers an unparalleled
                            escape where traditional Sri Lankan hospitality meets contemporary luxury.</p>
                        <p>Our resort features 25 exquisitely designed rooms and suites, each offering stunning views of
                            the Indian Ocean, world-class dining experiences, and personalized service that anticipates
                            your every need.</p>
                        <div class="about-features">
                            <div class="about-feature">
                                <div class="about-feature-icon">&#127965;</div>
                                <span>Beachfront Location</span>
                            </div>
                            <div class="about-feature">
                                <div class="about-feature-icon">&#127869;</div>
                                <span>Fine Dining</span>
                            </div>
                            <div class="about-feature">
                                <div class="about-feature-icon">&#128166;</div>
                                <span>Infinity Pool</span>
                            </div>
                            <div class="about-feature">
                                <div class="about-feature-icon">&#128134;</div>
                                <span>Ayurveda Spa</span>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <!-- Rooms Section -->
            <section class="section rooms-section" id="rooms">
                <div class="section-header">
                    <span class="section-label">Accommodations</span>
                    <h2 class="section-title">Our Rooms & Suites</h2>
                    <p class="section-subtitle">Each room is a sanctuary of comfort, designed to provide the perfect
                        balance of luxury and relaxation.</p>
                </div>
                <div class="rooms-grid">
                    <div class="room-card">
                        <div class="room-image">
                            <img src="assets/images/room-standard.jpg" alt="Standard Room">
                            <div class="room-price-tag">Rs. 15,000/night</div>
                        </div>
                        <div class="room-content">
                            <h3 class="room-type">Standard Room</h3>
                            <p class="room-description">Comfortable and elegant, perfect for solo travelers or couples
                                seeking a cozy retreat.</p>
                            <div class="room-amenities">
                                <span class="amenity">Ocean View</span>
                                <span class="amenity">King Bed</span>
                                <span class="amenity">AC</span>
                                <span class="amenity">WiFi</span>
                            </div>
                        </div>
                    </div>
                    <div class="room-card">
                        <div class="room-image">
                            <img src="assets/images/room-deluxe.jpg" alt="Deluxe Room">
                            <div class="room-price-tag">Rs. 25,000/night</div>
                        </div>
                        <div class="room-content">
                            <h3 class="room-type">Deluxe Room</h3>
                            <p class="room-description">Spacious elegance with premium amenities and breathtaking
                                panoramic ocean views.</p>
                            <div class="room-amenities">
                                <span class="amenity">Balcony</span>
                                <span class="amenity">Minibar</span>
                                <span class="amenity">Smart TV</span>
                                <span class="amenity">Bathtub</span>
                            </div>
                        </div>
                    </div>
                    <div class="room-card">
                        <div class="room-image">
                            <img src="assets/images/room-suite.jpg" alt="Suite">
                            <div class="room-price-tag">Rs. 45,000/night</div>
                        </div>
                        <div class="room-content">
                            <h3 class="room-type">Luxury Suite</h3>
                            <p class="room-description">Indulgent suite with separate living area, premium furnishings,
                                and exclusive services.</p>
                            <div class="room-amenities">
                                <span class="amenity">Living Room</span>
                                <span class="amenity">Private Terrace</span>
                                <span class="amenity">Butler Service</span>
                            </div>
                        </div>
                    </div>
                    <div class="room-card">
                        <div class="room-image">
                            <img src="assets/images/room-presidential.jpg" alt="Presidential Suite">
                            <div class="room-price-tag">Rs. 85,000/night</div>
                        </div>
                        <div class="room-content">
                            <h3 class="room-type">Presidential Suite</h3>
                            <p class="room-description">The pinnacle of luxury with private pool, personal chef, and
                                unmatched ocean vistas.</p>
                            <div class="room-amenities">
                                <span class="amenity">Private Pool</span>
                                <span class="amenity">Personal Chef</span>
                                <span class="amenity">Spa Room</span>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <!-- Amenities Section -->
            <section class="section amenities-section" id="amenities">
                <div class="section-header">
                    <span class="section-label">Resort Facilities</span>
                    <h2 class="section-title">World-Class Amenities</h2>
                    <p class="section-subtitle">Discover a world of exceptional experiences designed to rejuvenate your
                        body and soul.</p>
                </div>
                <div class="amenities-grid">
                    <div class="amenity-card">
                        <div class="amenity-icon">&#127754;</div>
                        <h3>Infinity Pool</h3>
                        <p>Our stunning infinity pool seamlessly blends with the ocean horizon, offering a unique
                            swimming experience.</p>
                    </div>
                    <div class="amenity-card">
                        <div class="amenity-icon">&#128134;</div>
                        <h3>Ayurveda Spa</h3>
                        <p>Traditional Sri Lankan treatments combined with modern wellness therapies for ultimate
                            relaxation.</p>
                    </div>
                    <div class="amenity-card">
                        <div class="amenity-icon">&#127860;</div>
                        <h3>Fine Dining</h3>
                        <p>Savor exquisite cuisine from our award-winning chefs, featuring fresh seafood and local
                            delicacies.</p>
                    </div>
                    <div class="amenity-card">
                        <div class="amenity-icon">&#127965;</div>
                        <h3>Private Beach</h3>
                        <p>Exclusive access to our pristine private beach with complimentary water sports and
                            activities.</p>
                    </div>
                    <div class="amenity-card">
                        <div class="amenity-icon">&#127947;</div>
                        <h3>Fitness Center</h3>
                        <p>State-of-the-art equipment with ocean views, personal trainers available on request.</p>
                    </div>
                    <div class="amenity-card">
                        <div class="amenity-icon">&#128663;</div>
                        <h3>Concierge</h3>
                        <p>24/7 concierge service to arrange excursions, transfers, and personalized experiences.</p>
                    </div>
                </div>
            </section>

            <!-- Gallery Section -->
            <section class="section gallery-section" id="gallery">
                <div class="section-header">
                    <span class="section-label">Photo Gallery</span>
                    <h2 class="section-title">Capture the Moments</h2>
                    <p class="section-subtitle">A glimpse into the extraordinary experiences awaiting you at Ocean View
                        Resort.</p>
                </div>
                <div class="gallery-grid">
                    <div class="gallery-item">
                        <img src="assets/images/hero-resort.jpg" alt="Resort Overview">
                        <div class="gallery-overlay">
                            <h4>Aerial View</h4>
                        </div>
                    </div>
                    <div class="gallery-item">
                        <img src="assets/images/infinity-pool.jpg" alt="Infinity Pool">
                        <div class="gallery-overlay">
                            <h4>Infinity Pool</h4>
                        </div>
                    </div>
                    <div class="gallery-item">
                        <img src="assets/images/spa.jpg" alt="Spa">
                        <div class="gallery-overlay">
                            <h4>Ayurveda Spa</h4>
                        </div>
                    </div>
                    <div class="gallery-item">
                        <img src="assets/images/restaurant.jpg" alt="Restaurant">
                        <div class="gallery-overlay">
                            <h4>Fine Dining</h4>
                        </div>
                    </div>
                    <div class="gallery-item">
                        <img src="assets/images/beach.jpg" alt="Beach">
                        <div class="gallery-overlay">
                            <h4>Private Beach</h4>
                        </div>
                    </div>
                </div>
            </section>

            <!-- Contact Section -->
            <section class="section contact-section" id="contact">
                <div class="section-header">
                    <span class="section-label">Get in Touch</span>
                    <h2 class="section-title">Contact Us</h2>
                    <p class="section-subtitle">We would love to hear from you. Reach out to plan your perfect getaway.
                    </p>
                </div>
                <div class="contact-grid">
                    <div class="contact-info">
                        <h3>Visit Our Resort</h3>
                        <div class="contact-item">
                            <div class="contact-icon">&#128205;</div>
                            <div>
                                <h4>Address</h4>
                                <p>123 Lighthouse Street<br>Galle Fort, Galle 80000<br>Sri Lanka</p>
                            </div>
                        </div>
                        <div class="contact-item">
                            <div class="contact-icon">&#128222;</div>
                            <div>
                                <h4>Phone</h4>
                                <p>+94 91 223 4567<br>+94 77 123 4567</p>
                            </div>
                        </div>
                        <div class="contact-item">
                            <div class="contact-icon">&#9993;</div>
                            <div>
                                <h4>Email</h4>
                                <p>reservations@oceanviewresort.lk<br>info@oceanviewresort.lk</p>
                            </div>
                        </div>
                        <div class="contact-item">
                            <div class="contact-icon">&#128336;</div>
                            <div>
                                <h4>Reception Hours</h4>
                                <p>24 Hours, 7 Days a Week</p>
                            </div>
                        </div>
                    </div>
                    <div class="contact-form">
                        <form onsubmit="handleContactForm(event)">
                            <div class="form-row">
                                <div class="form-group">
                                    <label>First Name</label>
                                    <input type="text" placeholder="First Name" required>
                                </div>
                                <div class="form-group">
                                    <label>Last Name</label>
                                    <input type="text" placeholder="Last Name" required>
                                </div>
                            </div>
                            <div class="form-group">
                                <label>Email Address</label>
                                <input type="email" placeholder="example@email.com" required>
                            </div>
                            <div class="form-group">
                                <label>Phone Number</label>
                                <input type="tel" placeholder="+94 XX XXX XXXX">
                            </div>
                            <div class="form-row">
                                <div class="form-group">
                                    <label>Check-in Date</label>
                                    <input type="date" required>
                                </div>
                                <div class="form-group">
                                    <label>Check-out Date</label>
                                    <input type="date" required>
                                </div>
                            </div>
                            <div class="form-group">
                                <label>Message</label>
                                <textarea placeholder="Tell us about your requirements..."></textarea>
                            </div>
                            <button type="submit" class="btn btn-primary">Send Inquiry</button>
                        </form>
                    </div>
                </div>
            </section>

            <!-- Footer -->
            <footer class="footer">
                <div class="footer-grid">
                    <div class="footer-brand">
                        <h3>Ocean View Resort</h3>
                        <p>Experience the ultimate luxury escape on the pristine shores of Galle, Sri Lanka. Where the
                            Indian Ocean meets world-class hospitality.</p>
                        <div class="social-links">
                            <a href="#" class="social-link">&#102;</a>
                            <a href="#" class="social-link">&#116;</a>
                            <a href="#" class="social-link">&#105;</a>
                            <a href="#" class="social-link">&#121;</a>
                        </div>
                    </div>
                    <div class="footer-links">
                        <h4>Quick Links</h4>
                        <ul>
                            <li><a href="#about">About Us</a></li>
                            <li><a href="#rooms">Accommodations</a></li>
                            <li><a href="#amenities">Amenities</a></li>
                            <li><a href="#gallery">Gallery</a></li>
                            <li><a href="#contact">Contact</a></li>
                        </ul>
                    </div>
                    <div class="footer-links">
                        <h4>Experiences</h4>
                        <ul>
                            <li><a href="#">Spa & Wellness</a></li>
                            <li><a href="#">Dining</a></li>
                            <li><a href="#">Water Sports</a></li>
                            <li><a href="#">Cultural Tours</a></li>
                            <li><a href="#">Wedding Packages</a></li>
                        </ul>
                    </div>
                    <div class="footer-links">
                        <h4>Policies</h4>
                        <ul>
                            <li><a href="#">Privacy Policy</a></li>
                            <li><a href="#">Terms of Service</a></li>
                            <li><a href="#">Cancellation Policy</a></li>
                            <li><a href="#">FAQ</a></li>
                        </ul>
                    </div>
                </div>
                <div class="footer-bottom">
                    <p>2026 Ocean View Resort. All rights reserved. | Designed with care in Sri Lanka</p>
                </div>
            </footer>
        </div>
        </div>

        <!-- Reservation Modal -->
        <div class="modal-overlay" id="reservationModal">
            <div class="modal">
                <div class="modal-header">
                    <h3 class="modal-title" id="reservationModalTitle">New Reservation</h3>
                    <button class="modal-close">&#10005;</button>
                </div>
                <form id="reservationForm">
                    <input type="hidden" id="reservationId">
                    <div class="modal-form-row">
                        <div class="form-group">
                            <label>Guest Name *</label>
                            <input type="text" id="guestName" required placeholder="Full name">
                        </div>
                        <div class="form-group">
                            <label>Contact Number *</label>
                            <input type="tel" id="guestContact" required placeholder="+94 XX XXX XXXX">
                        </div>
                    </div>
                    <div class="form-group">
                        <label>Email Address</label>
                        <input type="email" id="guestEmail" placeholder="guest@email.com">
                    </div>
                    <div class="form-group">
                        <label>NIC / Passport Number *</label>
                        <input type="text" id="guestNic" required placeholder="ID number">
                    </div>
                    <div class="modal-form-row">
                        <div class="form-group">
                            <label>Room Type *</label>
                            <select id="roomType" required>
                                <option value="">Select type</option>
                                <option value="standard">Standard - Rs. 15,000</option>
                                <option value="deluxe">Deluxe - Rs. 25,000</option>
                                <option value="suite">Suite - Rs. 45,000</option>
                                <option value="presidential">Presidential - Rs. 85,000</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label>Room Number *</label>
                            <select id="roomNumber" required>
                                <option value="">Select room type first</option>
                            </select>
                        </div>
                    </div>
                    <div class="modal-form-row">
                        <div class="form-group">
                            <label>Check-in Date *</label>
                            <input type="date" id="checkinDate" required>
                        </div>
                        <div class="form-group">
                            <label>Check-out Date *</label>
                            <input type="date" id="checkoutDate" required>
                        </div>
                    </div>
                    <div class="form-group">
                        <label>Number of Guests</label>
                        <select id="numGuests">
                            <option value="1">1 Guest</option>
                            <option value="2" selected>2 Guests</option>
                            <option value="3">3 Guests</option>
                            <option value="4">4 Guests</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label>Special Requests</label>
                        <textarea id="specialRequests" rows="3" placeholder="Any special requirements..."></textarea>
                    </div>
                    <button type="submit" class="btn btn-primary">Save Reservation</button>
                </form>
            </div>
        </div>

        <!-- User Modal -->
        <div class="modal-overlay" id="userModal">
            <div class="modal">
                <div class="modal-header">
                    <h3 class="modal-title">Add New Staff</h3>
                    <button class="modal-close">&#10005;</button>
                </div>
                <form id="userForm">
                    <div class="form-group">
                        <label>Full Name *</label>
                        <input type="text" id="newUserName" required placeholder="Staff name">
                    </div>
                    <div class="form-group">
                        <label>Username *</label>
                        <input type="text" id="newUsername" required placeholder="Login username">
                    </div>
                    <div class="form-group">
                        <label>Password *</label>
                        <input type="password" id="newPassword" required placeholder="Secure password">
                    </div>
                    <div class="form-group">
                        <label>Role *</label>
                        <select id="newUserRole" required>
                            <option value="">Select role</option>
                            <option value="admin">Administrator</option>
                            <option value="manager">Manager</option>
                            <option value="receptionist">Receptionist</option>
                        </select>
                    </div>
                    <button type="submit" class="btn btn-primary">Add User</button>
                </form>
            </div>
        </div>

        <!-- View Reservation Modal -->
        <div class="modal-overlay" id="viewReservationModal">
            <div class="modal">
                <div class="modal-header">
                    <h3 class="modal-title">Reservation Details</h3>
                    <button class="modal-close">&#10005;</button>
                </div>
                <div id="viewReservationContent"></div>
            </div>
        </div>
    </body>

    </html>