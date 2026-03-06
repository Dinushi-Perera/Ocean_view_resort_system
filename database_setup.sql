-- Ocean View Resort System Database Setup
-- This script creates the database and the guests table

-- Create database
CREATE DATABASE IF NOT EXISTS ocean_view_resort;

-- Use the database
USE ocean_view_resort;

-- Create guests table
CREATE TABLE IF NOT EXISTS guests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    contact VARCHAR(20) NOT NULL,
    nic VARCHAR(20) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_nic (nic)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert a demo guest account for testing
-- Password: guest123 (hashed using BCrypt)
INSERT INTO guests (first_name, last_name, email, password, contact, nic)
VALUES ('John', 'Smith', 'guest@email.com', '$2a$12$LQv3c1yqBWVHxkd0LHAkCOYz6TtxMQJqhN8/LewY5GyYXxPLzxKqW', '+94 77 123 4567', 'NIC123456789')
ON DUPLICATE KEY UPDATE email = email;

-- Create bookings table
CREATE TABLE IF NOT EXISTS bookings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    guest_id INT NOT NULL,
    room_type VARCHAR(50) NOT NULL,
    num_guests INT NOT NULL,
    check_in DATE NOT NULL,
    check_out DATE NOT NULL,
    special_requests LONGTEXT,
    booking_status VARCHAR(20) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (guest_id) REFERENCES guests(id) ON DELETE CASCADE,
    INDEX idx_guest_id (guest_id),
    INDEX idx_check_in (check_in),
    INDEX idx_check_out (check_out),
    INDEX idx_status (booking_status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create staff table for employees
CREATE TABLE IF NOT EXISTS staff (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    staff_role VARCHAR(20) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    contact VARCHAR(20),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_username (username),
    INDEX idx_role (staff_role),
    INDEX idx_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert demo staff accounts
-- Passwords are plain text for demo (in production, use bcrypt hashing)
INSERT INTO staff (username, password, staff_role, first_name, last_name, email, contact)
VALUES 
    ('receptionist', 'reception123', 'receptionist', 'Sarah', 'Johnson', 'receptionist@oceanview.com', '+94 77 234 5678'),
    ('manager', 'manager123', 'manager', 'Michael', 'Anderson', 'manager@oceanview.com', '+94 77 345 6789')
ON DUPLICATE KEY UPDATE username = username;

-- Insert some sample bookings for testing
INSERT INTO bookings (guest_id, room_type, num_guests, check_in, check_out, special_requests, booking_status)
VALUES 
    (1, 'deluxe', 2, '2026-02-15', '2026-02-20', 'Ocean view preferred', 'confirmed'),
    (1, 'suite', 3, '2026-03-01', '2026-03-05', 'Early check-in requested', 'pending'),
    (1, 'standard', 2, '2026-02-10', '2026-02-12', NULL, 'checked-in')
ON DUPLICATE KEY UPDATE id = id;

-- Display success message
SELECT 'Database and tables created successfully!' AS message;

-- Show table structure
DESCRIBE guests;
DESCRIBE bookings;
DESCRIBE staff;

-- Show demo accounts
SELECT id, first_name, last_name, email, contact, nic, created_at FROM guests;
SELECT id, username, staff_role, first_name, last_name, email, contact, is_active FROM staff;

