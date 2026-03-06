-- Add Cleaning Requests Feature
-- Run this script to add guest cleaning request functionality

USE ocean_view_resort;

-- Drop table if exists (for clean reinstall)
DROP TABLE IF EXISTS cleaning_requests;

-- Create cleaning_requests table
CREATE TABLE cleaning_requests (
    id INT AUTO_INCREMENT PRIMARY KEY,
    guest_id INT NOT NULL,
    booking_id INT,
    room_number VARCHAR(10),
    request_type VARCHAR(50) NOT NULL DEFAULT 'general',
    priority VARCHAR(20) NOT NULL DEFAULT 'normal',
    special_instructions TEXT,
    request_status VARCHAR(20) NOT NULL DEFAULT 'pending',
    requested_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP NULL,
    assigned_to INT,
    notes TEXT,
    FOREIGN KEY (guest_id) REFERENCES guests(id) ON DELETE CASCADE,
    INDEX idx_guest_id (guest_id),
    INDEX idx_booking_id (booking_id),
    INDEX idx_status (request_status),
    INDEX idx_requested_at (requested_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Verify the table was created
SELECT 'Cleaning requests table created successfully!' AS status;
DESCRIBE cleaning_requests;
