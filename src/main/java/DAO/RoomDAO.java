package DAO;

import model.Room;
import util.DBConnection;

import java.sql.*;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class RoomDAO {

    // Get all rooms
    public List<Room> getAllRooms() {
        String sql = "SELECT * FROM rooms ORDER BY floor, room_number";
        List<Room> rooms = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            ResultSet rs = pstmt.executeQuery();

            while (rs.next()) {
                rooms.add(mapResultSetToRoom(rs));
            }

            System.out.println("DEBUG: Successfully retrieved " + rooms.size() + " rooms from database");

        } catch (SQLException e) {
            System.err.println("ERROR: Failed to retrieve rooms from database");
            e.printStackTrace();
        }

        return rooms;
    }

    // Get room by ID
    public Room getRoomById(int roomId) {
        String sql = "SELECT * FROM rooms WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, roomId);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                return mapResultSetToRoom(rs);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    // Get room by room number
    public Room getRoomByNumber(String roomNumber) {
        String sql = "SELECT * FROM rooms WHERE room_number = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, roomNumber);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                return mapResultSetToRoom(rs);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return null;
    }

    // Get rooms by type
    public List<Room> getRoomsByType(String roomType) {
        String sql = "SELECT * FROM rooms WHERE room_type = ? ORDER BY room_number";
        List<Room> rooms = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, roomType);
            ResultSet rs = pstmt.executeQuery();

            while (rs.next()) {
                rooms.add(mapResultSetToRoom(rs));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return rooms;
    }

    // Get available rooms by type
    public List<Room> getAvailableRoomsByType(String roomType) {
        String sql = "SELECT * FROM rooms WHERE room_type = ? AND status = 'available' ORDER BY room_number";
        List<Room> rooms = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, roomType);
            ResultSet rs = pstmt.executeQuery();

            while (rs.next()) {
                rooms.add(mapResultSetToRoom(rs));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return rooms;
    }

    // Get available rooms for specific dates
    public List<Room> getAvailableRoomsForDates(String roomType, LocalDate checkIn, LocalDate checkOut) {
        String sql = "SELECT r.* FROM rooms r " +
                     "WHERE r.room_type = ? AND r.status = 'available' " +
                     "AND r.id NOT IN (" +
                     "    SELECT DISTINCT room_id FROM bookings b " +
                     "    WHERE b.room_id IS NOT NULL " +
                     "    AND b.booking_status IN ('confirmed', 'checked-in') " +
                     "    AND ((b.check_in < ? AND b.check_out > ?) " +
                     "    OR (b.check_in >= ? AND b.check_in < ?))" +
                     ") ORDER BY r.room_number";
        
        List<Room> rooms = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, roomType);
            pstmt.setDate(2, Date.valueOf(checkOut));
            pstmt.setDate(3, Date.valueOf(checkIn));
            pstmt.setDate(4, Date.valueOf(checkIn));
            pstmt.setDate(5, Date.valueOf(checkOut));

            ResultSet rs = pstmt.executeQuery();

            while (rs.next()) {
                rooms.add(mapResultSetToRoom(rs));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return rooms;
    }

    // Update room status
    public boolean updateRoomStatus(int roomId, String status) {
        String sql = "UPDATE rooms SET status = ?, updated_at = CURRENT_TIMESTAMP WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, status);
            pstmt.setInt(2, roomId);

            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    // Update room status by room number
    public boolean updateRoomStatusByNumber(String roomNumber, String status) {
        String sql = "UPDATE rooms SET status = ?, updated_at = CURRENT_TIMESTAMP WHERE room_number = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, status);
            pstmt.setString(2, roomNumber);

            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    // Create new room
    public boolean createRoom(Room room) {
        String sql = "INSERT INTO rooms (room_number, room_type, floor, price_per_night, " +
                     "max_occupancy, status, cleaning_status, description, amenities) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            pstmt.setString(1, room.getRoomNumber());
            pstmt.setString(2, room.getRoomType());
            pstmt.setInt(3, room.getFloor());
            pstmt.setBigDecimal(4, room.getPricePerNight());
            pstmt.setInt(5, room.getMaxOccupancy());
            pstmt.setString(6, room.getStatus());
            pstmt.setString(7, room.getCleaningStatus() != null ? room.getCleaningStatus() : "clean");
            pstmt.setString(8, room.getDescription());
            pstmt.setString(9, room.getAmenities());

            int rowsAffected = pstmt.executeUpdate();

            if (rowsAffected > 0) {
                ResultSet generatedKeys = pstmt.getGeneratedKeys();
                if (generatedKeys.next()) {
                    room.setId(generatedKeys.getInt(1));
                }
                return true;
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    // Update room details
    public boolean updateRoom(Room room) {
        String sql = "UPDATE rooms SET room_type = ?, floor = ?, price_per_night = ?, " +
                     "max_occupancy = ?, status = ?, cleaning_status = ?, description = ?, amenities = ?, " +
                     "updated_at = CURRENT_TIMESTAMP WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, room.getRoomType());
            pstmt.setInt(2, room.getFloor());
            pstmt.setBigDecimal(3, room.getPricePerNight());
            pstmt.setInt(4, room.getMaxOccupancy());
            pstmt.setString(5, room.getStatus());
            pstmt.setString(6, room.getCleaningStatus());
            pstmt.setString(7, room.getDescription());
            pstmt.setString(8, room.getAmenities());
            pstmt.setInt(9, room.getId());

            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    // Delete room
    public boolean deleteRoom(int roomId) {
        String sql = "DELETE FROM rooms WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, roomId);
            return pstmt.executeUpdate() > 0;

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return false;
    }

    // Get room count by type
    public int getRoomCountByType(String roomType) {
        String sql = "SELECT COUNT(*) FROM rooms WHERE room_type = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, roomType);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                return rs.getInt(1);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return 0;
    }

    // Get available room count by type
    public int getAvailableRoomCountByType(String roomType) {
        String sql = "SELECT COUNT(*) FROM rooms WHERE room_type = ? AND status = 'available'";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, roomType);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                return rs.getInt(1);
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        return 0;
    }

    // Get room price per night by room type
    public double getRoomPriceByType(String roomType) {
        String sql = "SELECT price_per_night FROM rooms WHERE room_type = ? LIMIT 1";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, roomType.toLowerCase());
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                return rs.getDouble("price_per_night");
            }

        } catch (SQLException e) {
            e.printStackTrace();
        }

        // Return default price if not found
        return 5000.0;
    }

    // Helper method to map ResultSet to Room object
    private Room mapResultSetToRoom(ResultSet rs) throws SQLException {
        Room room = new Room();
        room.setId(rs.getInt("id"));
        room.setRoomNumber(rs.getString("room_number"));
        room.setRoomType(rs.getString("room_type"));
        room.setFloor(rs.getInt("floor"));
        room.setPricePerNight(rs.getBigDecimal("price_per_night"));
        room.setMaxOccupancy(rs.getInt("max_occupancy"));
        room.setStatus(rs.getString("status"));
        // Set cleaning status if column exists, default to 'clean' if null
        String cleaningStatus = rs.getString("cleaning_status");
        room.setCleaningStatus(cleaningStatus != null ? cleaningStatus : "clean");
        room.setDescription(rs.getString("description"));
        room.setAmenities(rs.getString("amenities"));
        room.setCreatedAt(rs.getString("created_at"));
        room.setUpdatedAt(rs.getString("updated_at"));
        return room;
    }
}
