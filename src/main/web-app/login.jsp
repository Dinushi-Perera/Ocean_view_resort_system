<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Guest Login - Ocean View Resort</title>
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
         GUEST LOGIN PAGE
    ============================================ -->
    <div id="guest-login-page">
        <div class="login-container">
            <div class="login-image-side">
                <div class="login-image-content">
                    <h2>Welcome Back</h2>
                    <p>Sign in to your Ocean View Resort account to access your reservations, book new rooms, and manage your luxury stay experience.</p>
                    <div style="margin-top: 30px;">
                        <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 15px;">
                            <span style="color: var(--primary); font-size: 1.2rem;">💼</span>
                            <span>Manage your reservations</span>
                        </div>
                        <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 15px;">
                            <span style="color: var(--primary); font-size: 1.2rem;">🏨</span>
                            <span>Book premium rooms</span>
                        </div>
                        <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 15px;">
                            <span style="color: var(--primary); font-size: 1.2rem;">🍽️</span>
                            <span>Order room service</span>
                        </div>
                        <div style="display: flex; align-items: center; gap: 10px;">
                            <span style="color: var(--primary); font-size: 1.2rem;">✨</span>
                            <span>Exclusive member benefits</span>
                        </div>
                    </div>
                </div>
            </div>
            <div class="login-form-side">
                <div class="login-form-content">
                    <div class="login-header">
                        <h1>Guest Portal</h1>
                        <p>Sign in to access your account</p>
                    </div>

                    <!-- Display Error/Success Messages -->
                    <% String error = (String) request.getAttribute("error"); %>
                    <% if (error != null) { %>
                        <div style="padding: 12px; background: #fee; border-left: 4px solid #f44; color: #c33; margin-bottom: 20px; border-radius: 4px;">
                            <%= error %>
                        </div>
                    <% } %>

                    <% String success = (String) request.getAttribute("success"); %>
                    <% if (success != null) { %>
                        <div style="padding: 12px; background: #efe; border-left: 4px solid #4a4; color: #363; margin-bottom: 20px; border-radius: 4px;">
                            <%= success %>
                        </div>
                    <% } %>

                    <!-- Login Form -->
                    <form id="guestLoginForm" method="post" action="login">
                        <div class="form-group">
                            <label for="email">Email Address</label>
                            <input type="email" id="email" name="email" placeholder="Enter your email" required>
                        </div>
                        <div class="form-group">
                            <label for="password">Password</label>
                            <input type="password" id="password" name="password" placeholder="Enter your password" required>
                        </div>

                        <div style="display: flex; justify-content: space-between; align-items: center; margin: 15px 0;">
                            <label style="display: flex; align-items: center; gap: 8px; font-size: 0.9rem;">
                                <input type="checkbox" id="rememberMe" name="rememberMe" style="margin: 0;">
                                Remember me
                            </label>
                            <a href="#" style="color: var(--primary); font-size: 0.9rem; text-decoration: none;">Forgot password?</a>
                        </div>

                        <button type="submit" class="btn btn-primary">Sign In</button>
                    </form>

                    <div style="margin-top: 20px; text-align: center;">
                        <p style="color: var(--gray); font-size: 0.9rem;">
                            Don't have an account?
                            <a href="register.jsp" style="color: var(--primary);">Create Account</a>
                        </p>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>