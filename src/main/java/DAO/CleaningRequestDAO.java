package DAO;

import model.CleaningRequest;
import util.DBConnection;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class CleaningRequestDAO {

    // Create a new cleaning request
    public boolean createRequest(CleaningRequest request) {
        String sql = "INSERT INTO cleaning_requests (guest_id, booking_id, room_number, " +
                    "request_type, priority, special_instructions, request_status) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?)";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            pstmt.setInt(1, request.getGuestId());
            if (request.getBookingId() != null) {
                pstmt.setInt(2, request.getBookingId());
            } else {
                pstmt.setNull(2, Types.INTEGER);
            }
            pstmt.setString(3, request.getRoomNumber());
            pstmt.setString(4, request.getRequestType());
            pstmt.setString(5, request.getPriority());
            pstmt.setString(6, request.getSpecialInstructions());
            pstmt.setString(7, request.getRequestStatus());

            int rowsAffected = pstmt.executeUpdate();
            
            if (rowsAffected > 0) {
                ResultSet rs = pstmt.getGeneratedKeys();
                if (rs.next()) {
                    request.setId(rs.getInt(1));
                }
                System.out.println("DEBUG: Cleaning request created successfully with ID: " + request.getId());
                return true;
            }

        } catch (SQLException e) {
            System.err.println("ERROR: Failed to create cleaning request");
            e.printStackTrace();
        }

        return false;
    }

    // Get all cleaning requests for a specific guest
    public List<CleaningRequest> getRequestsByGuestId(int guestId) {
        String sql = "SELECT * FROM cleaning_requests WHERE guest_id = ? ORDER BY requested_at DESC";
        List<CleaningRequest> requests = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, guestId);
            ResultSet rs = pstmt.executeQuery();

            while (rs.next()) {
                requests.add(mapResultSetToCleaningRequest(rs));
            }

        } catch (SQLException e) {
            System.err.println("ERROR: Failed to retrieve cleaning requests for guest ID: " + guestId);
            e.printStackTrace();
        }

        return requests;
    }

    // Get all cleaning requests
    public List<CleaningRequest> getAllRequests() {
        String sql = "SELECT * FROM cleaning_requests ORDER BY requested_at DESC";
        List<CleaningRequest> requests = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            ResultSet rs = pstmt.executeQuery();

            while (rs.next()) {
                requests.add(mapResultSetToCleaningRequest(rs));
            }

        } catch (SQLException e) {
            System.err.println("ERROR: Failed to retrieve all cleaning requests");
            e.printStackTrace();
        }

        return requests;
    }

    // Get cleaning request by ID
    public CleaningRequest getRequestById(int id) {
        String sql = "SELECT * FROM cleaning_requests WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, id);
            ResultSet rs = pstmt.executeQuery();

            if (rs.next()) {
                return mapResultSetToCleaningRequest(rs);
            }

        } catch (SQLException e) {
            System.err.println("ERROR: Failed to retrieve cleaning request with ID: " + id);
            e.printStackTrace();
        }

        return null;
    }

    // Update cleaning request status
    public boolean updateRequestStatus(int id, String status) {
        String sql = "UPDATE cleaning_requests SET request_status = ?, " +
                    "completed_at = ? WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, status);
            
            if ("completed".equals(status) || "cancelled".equals(status)) {
                pstmt.setTimestamp(2, Timestamp.valueOf(LocalDateTime.now()));
            } else {
                pstmt.setNull(2, Types.TIMESTAMP);
            }
            
            pstmt.setInt(3, id);

            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;

        } catch (SQLException e) {
            System.err.println("ERROR: Failed to update cleaning request status");
            e.printStackTrace();
        }

        return false;
    }

    // Update cleaning request
    public boolean updateRequest(CleaningRequest request) {
        String sql = "UPDATE cleaning_requests SET request_status = ?, assigned_to = ?, " +
                    "notes = ?, completed_at = ? WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, request.getRequestStatus());
            
            if (request.getAssignedTo() != null) {
                pstmt.setInt(2, request.getAssignedTo());
            } else {
                pstmt.setNull(2, Types.INTEGER);
            }
            
            pstmt.setString(3, request.getNotes());
            
            if (request.getCompletedAt() != null) {
                pstmt.setTimestamp(4, Timestamp.valueOf(request.getCompletedAt()));
            } else {
                pstmt.setNull(4, Types.TIMESTAMP);
            }
            
            pstmt.setInt(5, request.getId());

            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;

        } catch (SQLException e) {
            System.err.println("ERROR: Failed to update cleaning request");
            e.printStackTrace();
        }

        return false;
    }

    // Delete cleaning request
    public boolean deleteRequest(int id) {
        String sql = "DELETE FROM cleaning_requests WHERE id = ?";

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setInt(1, id);
            int rowsAffected = pstmt.executeUpdate();
            return rowsAffected > 0;

        } catch (SQLException e) {
            System.err.println("ERROR: Failed to delete cleaning request");
            e.printStackTrace();
        }

        return false;
    }

    // Get pending requests
    public List<CleaningRequest> getPendingRequests() {
        String sql = "SELECT * FROM cleaning_requests WHERE request_status = 'pending' " +
                    "ORDER BY priority DESC, requested_at ASC";
        List<CleaningRequest> requests = new ArrayList<>();

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            ResultSet rs = pstmt.executeQuery();

            while (rs.next()) {
                requests.add(mapResultSetToCleaningRequest(rs));
            }

        } catch (SQLException e) {
            System.err.println("ERROR: Failed to retrieve pending cleaning requests");
            e.printStackTrace();
        }

        return requests;
    }

    // Helper method to map ResultSet to CleaningRequest
    private CleaningRequest mapResultSetToCleaningRequest(ResultSet rs) throws SQLException {
        CleaningRequest request = new CleaningRequest();
        
        request.setId(rs.getInt("id"));
        request.setGuestId(rs.getInt("guest_id"));
        
        int bookingId = rs.getInt("booking_id");
        if (!rs.wasNull()) {
            request.setBookingId(bookingId);
        }
        
        request.setRoomNumber(rs.getString("room_number"));
        request.setRequestType(rs.getString("request_type"));
        request.setPriority(rs.getString("priority"));
        request.setSpecialInstructions(rs.getString("special_instructions"));
        request.setRequestStatus(rs.getString("request_status"));
        
        Timestamp requestedAt = rs.getTimestamp("requested_at");
        if (requestedAt != null) {
            request.setRequestedAt(requestedAt.toLocalDateTime());
        }
        
        Timestamp completedAt = rs.getTimestamp("completed_at");
        if (completedAt != null) {
            request.setCompletedAt(completedAt.toLocalDateTime());
        }
        
        int assignedTo = rs.getInt("assigned_to");
        if (!rs.wasNull()) {
            request.setAssignedTo(assignedTo);
        }
        
        request.setNotes(rs.getString("notes"));
        
        return request;
    }
}
