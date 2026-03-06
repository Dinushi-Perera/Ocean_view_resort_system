-- Migration Script: Add cleaning_status column to rooms table
-- Run this script to add cleaning status tracking to the rooms table

USE ocean_view_resort;

-- Add cleaning_status column if it doesn't exist
ALTER TABLE rooms 
ADD COLUMN IF NOT EXISTS cleaning_status VARCHAR(20) DEFAULT 'clean' 
COMMENT 'Tracks room cleaning status: clean, dirty, cleaning' 
AFTER status;

-- Update existing rows to have default cleaning status
UPDATE rooms SET cleaning_status = 'clean' WHERE cleaning_status IS NULL;

-- Add index for cleaning status queries
CREATE INDEX IF NOT EXISTS idx_cleaning_status ON rooms(cleaning_status);

-- Verify the change
SELECT 'Cleaning status column added successfully!' AS status;

-- Show updated table structure
DESCRIBE rooms;

-- Show current cleaning status distribution
SELECT cleaning_status, COUNT(*) as count 
FROM rooms 
GROUP BY cleaning_status;
