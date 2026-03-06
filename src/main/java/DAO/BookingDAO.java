package DAO;

import model.Booking;
import util.DBConnection;

import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class BookingDAO {

    // Create a new booking
    public boolean createBooking(Booking booking) {
        String sql = "INSERT INTO bookings (guest_id, room_id, room_type, num_guests, check_in, check_out, special_requests, booking_status) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            pstmt.setInt(1, booking.getGuestId());
            if (booking.getRoomId() != null) {
                pstmt.setInt(2, booking.getRoomId());
            } else {
                pstmt.setNull(2, java.sql.Types.INTEGER);
            }
            pstmt.setString(3, booking.getRoomType());
            pstmt.setInt(4, booking.getNumGuests());
            pstmt.setDate(5, Date.valueOf(booking.getCheckIn()));
            pstmt.setDate(6, Date.valueOf(booking.getCheckOut()));
            pstmt.setString(7, booking.getSpecialRequests());
            
            // Set booking status, default to 'pending' if null
            String status = booking.getBookingStatus();
            pstmt.setString(8, status != null ? status : "pending");

            int rowsAffected = pstmt.executeUpdate();

            if (rowsAffected > 0) {
                ResultSet generatedKeys = pstmt.getGeneratedKeys();
                if (generatedKeys.next()) {
                    booking.setId(generatedKeys.getInt(1));
                }
                return true;
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    // Get booking by ID
    public Booking getBookingById(int bookingId) {
        String sql = "SELECT * FROM bookings WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, bookingId);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                return mapResultSetToBooking(rs);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    // Get all bookings for a guest
    public List<Booking> getBookingsByGuestId(int guestId) {
        String sql = "SELECT * FROM bookings WHERE guest_id = ? ORDER BY check_in DESC";
        List<Booking> bookings = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, guestId);
            ResultSet rs = pstmt.executeQuery();

            while (rs.next()) {
                bookings.add(mapResultSetToBooking(rs));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return bookings;
    }

    // Get all bookings
    public List<Booking> getAllBookings() {
        String sql = "SELECT * FROM bookings ORDER BY check_in DESC";
        List<Booking> bookings = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            ResultSet rs = pstmt.executeQuery();

            while (rs.next()) {
                bookings.add(mapResultSetToBooking(rs));
            }
            
            System.out.println("DEBUG: Successfully retrieved " + bookings.size() + " bookings from database");

        } catch (SQLException e) {
            System.err.println("ERROR: Failed to retrieve bookings from database");
            e.printStackTrace();
        }

        return bookings;
    }

    // Delete booking
    public boolean deleteBooking(int bookingId) {
        String sql = "DELETE FROM bookings WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, bookingId);
            return pstmt.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    // Check room availability
    public boolean isRoomAvailable(String roomType, LocalDate checkIn, LocalDate checkOut) {
        String sql = "SELECT COUNT(*) FROM bookings " +
                     "WHERE room_type = ? " +
                     "AND booking_status != 'cancelled' " +
                     "AND ((check_in < ? AND check_out > ?) " +
                     "OR (check_in >= ? AND check_in < ?))";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, roomType);
            pstmt.setDate(2, Date.valueOf(checkOut));
            pstmt.setDate(3, Date.valueOf(checkIn));
            pstmt.setDate(4, Date.valueOf(checkIn));
            pstmt.setDate(5, Date.valueOf(checkOut));

            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                return rs.getInt(1) == 0;
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    // Update booking status (for check-in/check-out)
    public boolean updateBookingStatus(int bookingId, String status) {
        String sql = "UPDATE bookings SET booking_status = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, status);
            pstmt.setInt(2, bookingId);

            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    // Update full booking details
    public boolean updateBooking(Booking booking) {
        String sql = "UPDATE bookings SET room_id = ?, room_type = ?, num_guests = ?, check_in = ?, check_out = ?, " +
                     "special_requests = ?, booking_status = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            if (booking.getRoomId() != null) {
                pstmt.setInt(1, booking.getRoomId());
            } else {
                pstmt.setNull(1, java.sql.Types.INTEGER);
            }
            pstmt.setString(2, booking.getRoomType());
            pstmt.setInt(3, booking.getNumGuests());
            pstmt.setDate(4, Date.valueOf(booking.getCheckIn()));
            pstmt.setDate(5, Date.valueOf(booking.getCheckOut()));
            pstmt.setString(6, booking.getSpecialRequests());
            pstmt.setString(7, booking.getBookingStatus());
            pstmt.setInt(8, booking.getId());

            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    // Helper method to map ResultSet to Booking object
    private Booking mapResultSetToBooking(ResultSet rs) throws SQLException {
        Booking booking = new Booking();
        booking.setId(rs.getInt("id"));
        booking.setGuestId(rs.getInt("guest_id"));
        
        // Handle room_id which can be null
        int roomId = rs.getInt("room_id");
        if (!rs.wasNull()) {
            booking.setRoomId(roomId);
        }
        
        booking.setRoomType(rs.getString("room_type"));
        booking.setNumGuests(rs.getInt("num_guests"));
        // guard against null dates
        java.sql.Date ciDate = rs.getDate("check_in");
        java.sql.Date coDate = rs.getDate("check_out");
        if (ciDate != null) booking.setCheckIn(ciDate.toLocalDate());
        if (coDate != null) booking.setCheckOut(coDate.toLocalDate());
        booking.setSpecialRequests(rs.getString("special_requests"));
        booking.setBookingStatus(rs.getString("booking_status"));
        booking.setCreatedAt(rs.getString("created_at"));
        booking.setUpdatedAt(rs.getString("updated_at"));
        return booking;
    }

    /**
     * Returns all bookings that OVERLAP with [start, end] together with
     * guest and room data, ready for the monthly-report view.
     * A booking overlaps when: check_in <= end  AND  check_out >= start
     */
    public List<Map<String, Object>> getMonthlyBookingsWithGuests(LocalDate start, LocalDate end) {
        String sql =
            "SELECT b.id AS booking_id, b.guest_id, b.room_id, " +
            "       COALESCE(b.room_type,'standard') AS room_type, " +
            "       b.num_guests, b.check_in, b.check_out, " +
            "       COALESCE(b.special_requests,'-') AS special_requests, " +
            "       COALESCE(b.booking_status,'pending') AS booking_status, " +
            "       b.created_at, " +
            "       COALESCE(g.first_name,'') AS first_name, " +
            "       COALESCE(g.last_name,'')  AS last_name, " +
            "       COALESCE(g.email,'-')     AS email, " +
            "       COALESCE(g.contact,'-')   AS contact, " +
            "       COALESCE(g.nic,'-')       AS nic, " +
            "       COALESCE(r.room_number,'-') AS room_number " +
            "FROM bookings b " +
            "LEFT JOIN guests g ON b.guest_id = g.id " +
            "LEFT JOIN rooms  r ON b.room_id  = r.id " +
            "WHERE b.check_in <= ? AND b.check_out >= ? " +
            "ORDER BY b.check_in ASC";

        List<Map<String, Object>> rows = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setDate(1, java.sql.Date.valueOf(end));
            ps.setDate(2, java.sql.Date.valueOf(start));

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("bookingId",       rs.getInt("booking_id"));
                row.put("guestId",         rs.getInt("guest_id"));

                int rid = rs.getInt("room_id");
                row.put("roomId", rs.wasNull() ? 0 : rid);

                row.put("roomType",        rs.getString("room_type").toLowerCase());
                row.put("numGuests",       rs.getInt("num_guests"));

                java.sql.Date ci = rs.getDate("check_in");
                java.sql.Date co = rs.getDate("check_out");
                row.put("checkIn",  ci != null ? ci.toLocalDate() : start);
                row.put("checkOut", co != null ? co.toLocalDate() : end);

                row.put("specialRequests", rs.getString("special_requests"));
                row.put("bookingStatus",   rs.getString("booking_status"));
                row.put("createdAt",       rs.getString("created_at"));

                String fn = rs.getString("first_name");
                String ln = rs.getString("last_name");
                String fullName = (fn + " " + ln).trim();
                if (fullName.isEmpty()) fullName = "Guest #" + rs.getInt("guest_id");
                row.put("guestName",    fullName);
                row.put("guestEmail",   rs.getString("email"));
                row.put("guestContact", rs.getString("contact"));
                row.put("guestNic",     rs.getString("nic"));
                row.put("roomNumber",   rs.getString("room_number"));

                rows.add(row);
            }
            System.out.println("DEBUG getMonthlyBookingsWithGuests [" + start + " to " + end + "]: " + rows.size() + " rows");

        } catch (SQLException e) {
            System.err.println("ERROR getMonthlyBookingsWithGuests: " + e.getMessage());
            e.printStackTrace();
        }
        return rows;
    }
}

