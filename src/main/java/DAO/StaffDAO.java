package DAO;

import model.Staff;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class StaffDAO {

    // ─── Authentication ───────────────────────────────────────────────────────

    public boolean authenticateStaff(String username, String password, String role) {
        String sql = "SELECT * FROM staff WHERE username = ? AND password = ? AND staff_role = ? AND is_active = TRUE";
        try (Connection conn = util.DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, username);
            pstmt.setString(2, password);
            pstmt.setString(3, role);
            ResultSet rs = pstmt.executeQuery();
            boolean authenticated = rs.next();
            System.out.println("DEBUG: Staff auth for '" + username + "' role '" + role + "': " + (authenticated ? "OK" : "FAIL"));
            return authenticated;
        } catch (SQLException e) {
            System.err.println("ERROR: Staff authentication – " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }

    public boolean authenticateAdmin(String username, String password) {
        String sql = "SELECT * FROM staff WHERE username = ? AND password = ? AND staff_role = 'admin' AND is_active = TRUE";
        try (Connection conn = util.DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, username);
            pstmt.setString(2, password);
            ResultSet rs = pstmt.executeQuery();
            return rs.next();
        } catch (SQLException e) {
            System.err.println("ERROR: Admin authentication – " + e.getMessage());
            return false;
        }
    }

    // ─── Read ─────────────────────────────────────────────────────────────────

    public String[] getStaffByUsername(String username) {
        String sql = "SELECT id, username, staff_role, first_name, last_name, email FROM staff WHERE username = ? AND is_active = TRUE";
        try (Connection conn = util.DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, username);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) {
                return new String[]{
                    String.valueOf(rs.getInt("id")),
                    rs.getString("username"),
                    rs.getString("staff_role"),
                    rs.getString("first_name"),
                    rs.getString("last_name"),
                    rs.getString("email")
                };
            }
        } catch (SQLException e) {
            System.err.println("ERROR: getStaffByUsername – " + e.getMessage());
        }
        return null;
    }

    public List<Staff> getAllStaff() {
        String sql = "SELECT * FROM staff ORDER BY staff_role, first_name";
        List<Staff> list = new ArrayList<>();
        try (Connection conn = util.DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            ResultSet rs = pstmt.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (SQLException e) {
            System.err.println("ERROR: getAllStaff – " + e.getMessage());
        }
        return list;
    }

    public Staff getStaffById(int id) {
        String sql = "SELECT * FROM staff WHERE id = ?";
        try (Connection conn = util.DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) return mapRow(rs);
        } catch (SQLException e) {
            System.err.println("ERROR: getStaffById – " + e.getMessage());
        }
        return null;
    }

    // ─── Create ───────────────────────────────────────────────────────────────

    public boolean createStaff(Staff staff) {
        String sql = "INSERT INTO staff (username, password, staff_role, first_name, last_name, email, contact, is_active) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, TRUE)";
        try (Connection conn = util.DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            pstmt.setString(1, staff.getUsername());
            pstmt.setString(2, staff.getPassword());
            pstmt.setString(3, staff.getStaffRole());
            pstmt.setString(4, staff.getFirstName());
            pstmt.setString(5, staff.getLastName());
            pstmt.setString(6, staff.getEmail());
            pstmt.setString(7, staff.getContact());
            int rows = pstmt.executeUpdate();
            if (rows > 0) {
                ResultSet keys = pstmt.getGeneratedKeys();
                if (keys.next()) staff.setId(keys.getInt(1));
                return true;
            }
        } catch (SQLException e) {
            System.err.println("ERROR: createStaff – " + e.getMessage());
        }
        return false;
    }

    // ─── Update ───────────────────────────────────────────────────────────────

    public boolean updateStaff(Staff staff) {
        String sql = "UPDATE staff SET first_name=?, last_name=?, email=?, contact=?, staff_role=?, is_active=? WHERE id=?";
        try (Connection conn = util.DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, staff.getFirstName());
            pstmt.setString(2, staff.getLastName());
            pstmt.setString(3, staff.getEmail());
            pstmt.setString(4, staff.getContact());
            pstmt.setString(5, staff.getStaffRole());
            pstmt.setBoolean(6, staff.isActive());
            pstmt.setInt(7, staff.getId());
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("ERROR: updateStaff – " + e.getMessage());
            return false;
        }
    }

    public boolean toggleStaffStatus(int id) {
        String sql = "UPDATE staff SET is_active = NOT is_active WHERE id = ?";
        try (Connection conn = util.DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("ERROR: toggleStaffStatus – " + e.getMessage());
            return false;
        }
    }

    // ─── Delete ───────────────────────────────────────────────────────────────

    public boolean deleteStaff(int id) {
        String sql = "DELETE FROM staff WHERE id = ?";
        try (Connection conn = util.DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, id);
            return pstmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("ERROR: deleteStaff – " + e.getMessage());
            return false;
        }
    }

    // ─── Helpers ─────────────────────────────────────────────────────────────

    public boolean usernameExists(String username) {
        String sql = "SELECT COUNT(*) FROM staff WHERE username = ?";
        try (Connection conn = util.DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, username);
            ResultSet rs = pstmt.executeQuery();
            if (rs.next()) return rs.getInt(1) > 0;
        } catch (SQLException e) {
            System.err.println("ERROR: usernameExists – " + e.getMessage());
        }
        return false;
    }

    private Staff mapRow(ResultSet rs) throws SQLException {
        Staff s = new Staff();
        s.setId(rs.getInt("id"));
        s.setUsername(rs.getString("username"));
        s.setPassword(rs.getString("password"));
        s.setStaffRole(rs.getString("staff_role"));
        s.setFirstName(rs.getString("first_name"));
        s.setLastName(rs.getString("last_name"));
        s.setEmail(rs.getString("email"));
        s.setContact(rs.getString("contact"));
        s.setActive(rs.getBoolean("is_active"));
        s.setCreatedAt(rs.getString("created_at"));
        return s;
    }
}
