-- ─────────────────────────────────────────────────────
-- Ocean View Resort – Add Admin Account
-- Run this script ONCE if the admin account does not exist
-- ─────────────────────────────────────────────────────

USE ocean_view_resort;

-- Insert admin staff account (plain-text password for demo; use bcrypt in production)
INSERT INTO staff (username, password, staff_role, first_name, last_name, email, contact, is_active)
VALUES ('admin', 'admin123', 'admin', 'System', 'Administrator', 'admin@oceanview.com', '+94 77 000 0000', TRUE)
ON DUPLICATE KEY UPDATE username = username;

-- Verify
SELECT id, username, staff_role, first_name, last_name, email, is_active, created_at
FROM staff
ORDER BY staff_role, username;
