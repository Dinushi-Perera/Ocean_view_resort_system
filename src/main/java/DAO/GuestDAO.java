package DAO;

import model.Guest;
import util.DBConnection;
import util.PasswordUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class GuestDAO {

    // Register a new guest
    public boolean registerGuest(Guest guest) {
        String sql = "INSERT INTO guests (first_name, last_name, email, password, contact, nic) VALUES (?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, guest.getFirstName());
            pstmt.setString(2, guest.getLastName());
            pstmt.setString(3, guest.getEmail());
            pstmt.setString(4, guest.getPassword());
            pstmt.setString(5, guest.getContact());
            pstmt.setString(6, guest.getNic());

            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Validate guest login
    public Guest validateLogin(String email, String password) {
        String sql = "SELECT * FROM guests WHERE email = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, email);

            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                String hashedPassword = rs.getString("password");
                
                // Verify password using BCrypt
                if (PasswordUtil.verifyPassword(password, hashedPassword)) {
                    Guest guest = new Guest();
                    guest.setId(rs.getInt("id"));
                    guest.setFirstName(rs.getString("first_name"));
                    guest.setLastName(rs.getString("last_name"));
                    guest.setEmail(rs.getString("email"));
                    guest.setPassword(rs.getString("password"));
                    guest.setContact(rs.getString("contact"));
                    guest.setNic(rs.getString("nic"));
                    guest.setCreatedAt(rs.getString("created_at"));
                    return guest;
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    // Check if email already exists
    public boolean emailExists(String email) {
        String sql = "SELECT COUNT(*) FROM guests WHERE email = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, email);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                return rs.getInt(1) > 0;
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    // Get guest by ID
    public Guest getGuestById(int id) {
        String sql = "SELECT * FROM guests WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, id);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                Guest guest = new Guest();
                guest.setId(rs.getInt("id"));
                guest.setFirstName(rs.getString("first_name"));
                guest.setLastName(rs.getString("last_name"));
                guest.setEmail(rs.getString("email"));
                guest.setPassword(rs.getString("password"));
                guest.setContact(rs.getString("contact"));
                guest.setNic(rs.getString("nic"));
                guest.setCreatedAt(rs.getString("created_at"));
                return guest;
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    // Get guest by email
    public Guest getGuestByEmail(String email) {
        String sql = "SELECT * FROM guests WHERE email = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, email);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                Guest guest = new Guest();
                guest.setId(rs.getInt("id"));
                guest.setFirstName(rs.getString("first_name"));
                guest.setLastName(rs.getString("last_name"));
                guest.setEmail(rs.getString("email"));
                guest.setPassword(rs.getString("password"));
                guest.setContact(rs.getString("contact"));
                guest.setNic(rs.getString("nic"));
                guest.setCreatedAt(rs.getString("created_at"));
                return guest;
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    // Get guest by contact number
    public Guest getGuestByContact(String contact) {
        String sql = "SELECT * FROM guests WHERE contact = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, contact);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                Guest guest = new Guest();
                guest.setId(rs.getInt("id"));
                guest.setFirstName(rs.getString("first_name"));
                guest.setLastName(rs.getString("last_name"));
                guest.setEmail(rs.getString("email"));
                guest.setPassword(rs.getString("password"));
                guest.setContact(rs.getString("contact"));
                guest.setNic(rs.getString("nic"));
                guest.setCreatedAt(rs.getString("created_at"));
                return guest;
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    // Get all guests
    public List<Guest> getAllGuests() {
        List<Guest> guests = new ArrayList<>();
        String sql = "SELECT * FROM guests ORDER BY created_at DESC";

        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {

            while (rs.next()) {
                Guest guest = new Guest();
                guest.setId(rs.getInt("id"));
                guest.setFirstName(rs.getString("first_name"));
                guest.setLastName(rs.getString("last_name"));
                guest.setEmail(rs.getString("email"));
                guest.setPassword(rs.getString("password"));
                guest.setContact(rs.getString("contact"));
                guest.setNic(rs.getString("nic"));
                guest.setCreatedAt(rs.getString("created_at"));
                guests.add(guest);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return guests;
    }

    // Update guest information
    public boolean updateGuest(Guest guest) {
        String sql = "UPDATE guests SET first_name = ?, last_name = ?, contact = ?, nic = ? WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, guest.getFirstName());
            pstmt.setString(2, guest.getLastName());
            pstmt.setString(3, guest.getContact());
            pstmt.setString(4, guest.getNic());
            pstmt.setInt(5, guest.getId());

            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    // Delete guest
    public boolean deleteGuest(int id) {
        String sql = "DELETE FROM guests WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, id);
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }
}

