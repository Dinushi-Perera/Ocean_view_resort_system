-- Add room_id column to bookings table for room assignment
-- This enables tracking which specific room is assigned to each booking

USE ocean_view_resort;

-- Add room_id column to bookings table
ALTER TABLE bookings 
ADD COLUMN room_id INT NULL AFTER guest_id,
ADD CONSTRAINT fk_bookings_room 
    FOREIGN KEY (room_id) REFERENCES rooms(id) 
    ON DELETE SET NULL 
    ON UPDATE CASCADE;

-- Add index for performance
ALTER TABLE bookings 
ADD INDEX idx_room_id (room_id);

-- Verify the change
DESCRIBE bookings;

SELECT 'Successfully added room_id column to bookings table!' AS status;
