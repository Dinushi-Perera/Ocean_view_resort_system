<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Staff Login - Ocean View Resort</title>
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
         STAFF LOGIN PAGE
    ============================================ -->
    <div id="staff-login-page">
        <div class="login-container">
            <div class="login-image-side">
                <div class="login-image-content">
                    <h2>Staff Portal</h2>
                    <p>Access the Ocean View Resort management system to handle reservations, room management, guest services, and administrative tasks.</p>
                    <div style="margin-top: 30px;">
                        <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 15px;">
                            <span style="color: var(--primary); font-size: 1.2rem;">👨‍💼</span>
                            <span>Staff Dashboard Access</span>
                        </div>
                        <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 15px;">
                            <span style="color: var(--primary); font-size: 1.2rem;">📋</span>
                            <span>Reservation Management</span>
                        </div>
                        <div style="display: flex; align-items: center; gap: 10px; margin-bottom: 15px;">
                            <span style="color: var(--primary); font-size: 1.2rem;">🏨</span>
                            <span>Room & Facility Control</span>
                        </div>
                        <div style="display: flex; align-items: center; gap: 10px;">
                            <span style="color: var(--primary); font-size: 1.2rem;">📊</span>
                            <span>Reports & Analytics</span>
                        </div>
                    </div>
                </div>
            </div>
            <div class="login-form-side">
                <div class="login-form-content">
                    <div class="login-header">
                        <h1>Staff Login</h1>
                        <p>Enter your staff credentials to access the system</p>
                    </div>

                    <% 
                        String error = (String) request.getAttribute("error");
                        if (error != null) {
                    %>
                        <div style="background: #fee; border: 1px solid #fcc; padding: 10px; border-radius: 5px; margin-bottom: 15px; color: #c00;">
                            <%= error %>
                        </div>
                    <% } %>

                    <!-- Staff Login Form -->
                    <form id="staffLoginForm" action="<%= request.getContextPath() %>/staff-login" method="POST">
                        <div class="form-group">
                            <label for="username">Username</label>
                            <input type="text" id="username" name="username" placeholder="Enter your username" required>
                        </div>
                        <div class="form-group">
                            <label for="password">Password</label>
                            <input type="password" id="password" name="password" placeholder="Enter your password" required>
                        </div>
                        <div class="form-group">
                            <label for="role">Select Role</label>
                            <select id="role" name="role" required>
                                <option value="">Choose your role</option>
                                <option value="admin">Administrator</option>
                                <option value="manager">Manager</option>
                                <option value="receptionist">Receptionist</option>
                            </select>
                        </div>

                        <button type="submit" class="btn btn-primary">Login to System</button>
                    </form>

                    <div style="margin-top: 15px; text-align: center; padding: 15px; background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%); border-radius: 8px;">
                        <p style="color: var(--gray); font-size: 0.85rem; margin: 0;">Demo Credentials</p>
                        <div style="color: var(--dark); font-size: 0.9rem; margin: 5px 0 0 0; font-weight: 500;">
                            <p style="margin: 2px 0;">Admin: admin / admin123</p>
                            <p style="margin: 2px 0;">Manager: manager / manager123</p>
                            <p style="margin: 2px 0;">Receptionist: receptionist / reception123</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

</body>
</html>