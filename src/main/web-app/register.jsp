<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Guest Registration - Ocean View Resort</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Playfair+Display:wght@400;500;600;700&family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="style/styles.css">


    <style>
        .back-to-home-btn {
            position: fixed;
            top: 20px;
            left: 20px;
            display: flex;
            align-items: center;
            gap: 8px;
            padding: 12px 16px;
            background: rgba(255, 255, 255, 0.95);
            color: var(--primary, #0C4A6E);
            text-decoration: none;
            border-radius: 50px;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
            font-family: 'Inter', sans-serif;
            font-weight: 500;
            font-size: 0.9rem;
            backdrop-filter: blur(10px);
            border: 1px solid rgba(12, 74, 110, 0.1);
            transition: all 0.3s ease;
            z-index: 1000;
        }

        .back-to-home-btn:hover {
            background: var(--primary, #0C4A6E);
            color: white;
            transform: translateY(-1px);
            box-shadow: 0 6px 25px rgba(12, 74, 110, 0.25);
        }

        .back-icon {
            font-size: 1.1rem;
            transition: transform 0.3s ease;
        }

        .back-to-home-btn:hover .back-icon {
            transform: scale(1.1);
        }

        .back-text {
            font-weight: 500;
        }

        @media (max-width: 768px) {
            .back-to-home-btn {
                top: 15px;
                left: 15px;
                padding: 10px 14px;
                font-size: 0.85rem;
            }

            .back-text {
                display: none;
            }
        }
    </style>
</head>
<body>
    <!-- Toast Container -->
    <div class="toast-container" id="toastContainer"></div>

    <!-- Back to Home Button -->
    <a href="index.jsp" class="back-to-home-btn" title="Back to Home">
        <span class="back-icon">🏠</span>
        <span class="back-text">Back to Home</span>
    </a>

    <!-- ============================================
         GUEST REGISTRATION PAGE
    ============================================ -->
    <div id="guest-registration-page">
        <div class="login-container">
            <div class="login-image-side">
                <div class="login-image-content">
                    <h2>Join Ocean View Resort</h2>
                    <p>Create your account to enjoy exclusive benefits, manage reservations, and experience luxury hospitality at its finest.</p>
                    <div style="margin-top: 30px;">
                        <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 15px;">
                            <span style="color: var(--primary); font-size: 1.2rem;">✓</span>
                            <span>Priority booking for premium rooms</span>
                        </div>
                        <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 15px;">
                            <span style="color: var(--primary); font-size: 1.2rem;">✓</span>
                            <span>Exclusive member discounts</span>
                        </div>
                        <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 15px;">
                            <span style="color: var(--primary); font-size: 1.2rem;">✓</span>
                            <span>24/7 concierge support</span>
                        </div>
                        <div style="display: flex; align-items: center; gap: 10px;">
                            <span style="color: var(--primary); font-size: 1.2rem;">✓</span>
                            <span>Personalized travel experiences</span>
                        </div>
                    </div>
                </div>
            </div>
            <div class="login-form-side">
                <div class="login-form-content">
                    <div class="login-header">
                        <h1>Create Your Account</h1>
                        <p>Join the Ocean View Resort family and unlock exclusive privileges</p>
                    </div>

                    <!-- Display Error/Success Messages -->
                    <% String error = (String) request.getAttribute("error"); %>
                    <% if (error != null) { %>
                        <div style="padding: 12px; background: #fee; border-left: 4px solid #f44; color: #c33; margin-bottom: 20px; border-radius: 4px;">
                            <%= error %>
                        </div>
                    <% } %>

                    <!-- Registration Form -->
                    <form id="guestRegistrationForm" method="post" action="register">
                        <div class="modal-form-row">
                            <div class="form-group">
                                <label for="firstName">First Name *</label>
                                <input type="text" id="firstName" name="firstName" required placeholder="Your first name">
                            </div>
                            <div class="form-group">
                                <label for="lastName">Last Name *</label>
                                <input type="text" id="lastName" name="lastName" required placeholder="Your last name">
                            </div>
                        </div>
                        <div class="modal-form-row">
                            <div class="form-group">
                                <label for="contact">Contact Number *</label>
                                <input type="tel" id="contact" name="contact" required placeholder="+94 XX XXX XXXX">
                            </div>
                            <div class="form-group">
                                <label for="nic">NIC / Passport Number *</label>
                                <input type="text" id="nic" name="nic" required placeholder="ID number">
                            </div>
                        </div>
                        <div class="form-group">
                            <label for="email">Email Address *</label>
                            <input type="email" id="email" name="email" required placeholder="your@email.com">
                        </div>
                        <div class="modal-form-row">
                            <div class="form-group">
                                <label for="password">Password *</label>
                                <input type="password" id="password" name="password" required minlength="6" placeholder="Create a secure password">
                            </div>
                            <div class="form-group">
                                <label for="confirmPassword">Confirm Password *</label>
                                <input type="password" id="confirmPassword" name="confirmPassword" required placeholder="Confirm your password">
                            </div>
                        </div>

                        <button type="submit" class="btn btn-primary">Create Account</button>
                    </form>

                    <div style="margin-top: 20px; text-align: center;">
                        <p style="color: var(--gray); font-size: 0.9rem;">
                            Already have an account?
                            <a href="login.jsp" style="color: var(--primary);">Sign In</a>
                        </p>
                    </div>
                </div>
            </div>
        </div>
    </div>


</body>
</html>
