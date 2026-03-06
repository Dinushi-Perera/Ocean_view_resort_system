-- Quick Fix Script for Ocean View Resort Database
-- Run this script to add missing tables to existing database

USE ocean_view_resort;

-- Create staff table if it doesn't exist
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

-- Create rooms table to store actual room inventory
CREATE TABLE IF NOT EXISTS rooms (
    id INT AUTO_INCREMENT PRIMARY KEY,
    room_number VARCHAR(10) NOT NULL UNIQUE,
    room_type VARCHAR(50) NOT NULL,
    floor INT NOT NULL,
    price_per_night DECIMAL(10, 2) NOT NULL,
    max_occupancy INT NOT NULL DEFAULT 2,
    status VARCHAR(20) NOT NULL DEFAULT 'available',
    description TEXT,
    amenities TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_room_number (room_number),
    INDEX idx_room_type (room_type),
    INDEX idx_status (status),
    INDEX idx_floor (floor)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert demo staff accounts (will skip if already exist)
INSERT IGNORE INTO staff (username, password, staff_role, first_name, last_name, email, contact)
VALUES 
    ('receptionist', 'reception123', 'receptionist', 'Sarah', 'Johnson', 'receptionist@oceanview.com', '+94 77 234 5678'),
    ('manager', 'manager123', 'manager', 'Michael', 'Anderson', 'manager@oceanview.com', '+94 77 345 6789');

-- Insert room inventory (Standard Rooms - Floor 1)
INSERT IGNORE INTO rooms (room_number, room_type, floor, price_per_night, max_occupancy, status, description, amenities)
VALUES 
    ('101', 'standard', 1, 5000.00, 2, 'available', 'Cozy standard room with garden view', 'WiFi, TV, AC, Mini Fridge'),
    ('102', 'standard', 1, 5000.00, 2, 'available', 'Comfortable standard room', 'WiFi, TV, AC, Mini Fridge'),
    ('103', 'standard', 1, 5000.00, 2, 'available', 'Standard room near reception', 'WiFi, TV, AC, Mini Fridge'),
    ('104', 'standard', 1, 5000.00, 2, 'available', 'Standard room with balcony', 'WiFi, TV, AC, Mini Fridge, Balcony'),
    ('105', 'standard', 1, 5000.00, 2, 'available', 'Spacious standard room', 'WiFi, TV, AC, Mini Fridge'),
    ('106', 'standard', 1, 5000.00, 2, 'available', 'Standard room with extra bed option', 'WiFi, TV, AC, Mini Fridge'),
    ('107', 'standard', 1, 5000.00, 2, 'available', 'Standard room', 'WiFi, TV, AC, Mini Fridge'),
    ('108', 'standard', 1, 5000.00, 2, 'available', 'Standard room', 'WiFi, TV, AC, Mini Fridge'),
    ('109', 'standard', 1, 5000.00, 2, 'available', 'Standard room', 'WiFi, TV, AC, Mini Fridge'),
    ('110', 'standard', 1, 5000.00, 2, 'available', 'Standard room', 'WiFi, TV, AC, Mini Fridge'),

-- Deluxe Rooms - Floor 2
    ('201', 'deluxe', 2, 10000.00, 3, 'available', 'Deluxe room with ocean view', 'WiFi, Smart TV, AC, Mini Bar, Safe, Ocean View'),
    ('202', 'deluxe', 2, 10000.00, 3, 'available', 'Premium deluxe room', 'WiFi, Smart TV, AC, Mini Bar, Safe, Balcony'),
    ('203', 'deluxe', 2, 10000.00, 3, 'available', 'Deluxe room with king bed', 'WiFi, Smart TV, AC, Mini Bar, Safe'),
    ('204', 'deluxe', 2, 10000.00, 3, 'available', 'Deluxe room', 'WiFi, Smart TV, AC, Mini Bar, Safe'),
    ('205', 'deluxe', 2, 10000.00, 3, 'available', 'Deluxe room', 'WiFi, Smart TV, AC, Mini Bar, Safe'),
    ('206', 'deluxe', 2, 10000.00, 3, 'available', 'Corner deluxe room', 'WiFi, Smart TV, AC, Mini Bar, Safe, Large Windows'),
    ('207', 'deluxe', 2, 10000.00, 3, 'available', 'Deluxe room', 'WiFi, Smart TV, AC, Mini Bar, Safe'),
    ('208', 'deluxe', 2, 10000.00, 3, 'available', 'Deluxe room', 'WiFi, Smart TV, AC, Mini Bar, Safe'),

-- Suites - Floor 3
    ('301', 'suite', 3, 15000.00, 4, 'available', 'Luxury suite with separate living area', 'WiFi, Smart TV, AC, Mini Bar, Safe, Living Room, Dining Area, Ocean View'),
    ('302', 'suite', 3, 15000.00, 4, 'available', 'Executive suite', 'WiFi, Smart TV, AC, Mini Bar, Safe, Living Room, Dining Area'),
    ('303', 'suite', 3, 15000.00, 4, 'available', 'Family suite', 'WiFi, Smart TV, AC, Mini Bar, Safe, Living Room, 2 Bedrooms'),
    ('304', 'suite', 3, 15000.00, 4, 'available', 'Premium suite', 'WiFi, Smart TV, AC, Mini Bar, Safe, Living Room, Jacuzzi'),
    ('305', 'suite', 3, 15000.00, 4, 'available', 'Corner suite with panoramic view', 'WiFi, Smart TV, AC, Mini Bar, Safe, Living Room, Balcony, Ocean View'),

-- Presidential Suites - Floor 4
    ('401', 'presidential', 4, 20000.00, 6, 'available', 'Presidential suite with VIP amenities', 'WiFi, Smart TV, AC, Full Kitchen, Safe, Living Room, Dining Room, 2 Bedrooms, Jacuzzi, Terrace, Ocean View, Butler Service'),
    ('402', 'presidential', 4, 20000.00, 6, 'available', 'Royal presidential suite', 'WiFi, Smart TV, AC, Full Kitchen, Safe, Living Room, Dining Room, 2 Bedrooms, Jacuzzi, Terrace, Panoramic View, Butler Service');

-- Insert sample bookings if the table is empty (requires guest with id=1)
INSERT IGNORE INTO bookings (guest_id, room_type, num_guests, check_in, check_out, special_requests, booking_status)
VALUES 
    (1, 'deluxe', 2, '2026-02-15', '2026-02-20', 'Ocean view preferred', 'confirmed'),
    (1, 'suite', 3, '2026-03-01', '2026-03-05', 'Early check-in requested', 'pending'),
    (1, 'standard', 2, '2026-02-10', '2026-02-12', NULL, 'checked-in'),
    (1, 'standard', 2, '2026-02-05', '2026-02-08', NULL, 'checked-out');

-- Verify tables
SELECT 'Staff table created/verified!' AS status;
SELECT 'Rooms table created/verified!' AS status;
SELECT COUNT(*) AS staff_count FROM staff;
SELECT COUNT(*) AS room_count FROM rooms;
SELECT COUNT(*) AS booking_count FROM bookings;

-- Show staff accounts
SELECT id, username, staff_role, first_name, last_name, email FROM staff;

-- Show room inventory summary
SELECT room_type, COUNT(*) as total_rooms, 
       SUM(CASE WHEN status = 'available' THEN 1 ELSE 0 END) as available_rooms,
       MIN(price_per_night) as min_price, MAX(price_per_night) as max_price
FROM rooms 
GROUP BY room_type
ORDER BY min_price;
