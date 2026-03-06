package dao;

import DAO.CleaningRequestDAO;
import model.CleaningRequest;
import org.junit.jupiter.api.*;
import org.mockito.*;
import util.DBConnection;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

/**
 * Unit tests for {@link CleaningRequestDAO}.
 *
 * All database interactions are mocked via Mockito static-method mocking –
 * no live database connection is required.
 */
@TestMethodOrder(MethodOrderer.DisplayName.class)
class CleaningRequestDAOTest {

    private CleaningRequestDAO dao;
    private Connection        mockConn;
    private PreparedStatement mockPstmt;
    private ResultSet         mockRs;
    private MockedStatic<DBConnection> mockedDB;

    // ─── Setup / Teardown ─────────────────────────────────────────────────────

    @BeforeEach
    void setUp() throws Exception {
        dao       = new CleaningRequestDAO();
        mockConn  = mock(Connection.class);
        mockPstmt = mock(PreparedStatement.class);
        mockRs    = mock(ResultSet.class);

        mockedDB = mockStatic(DBConnection.class);
        mockedDB.when(DBConnection::getConnection).thenReturn(mockConn);

        when(mockConn.prepareStatement(anyString())).thenReturn(mockPstmt);
        when(mockConn.prepareStatement(anyString(), anyInt())).thenReturn(mockPstmt);
        when(mockPstmt.executeQuery()).thenReturn(mockRs);
    }

    @AfterEach
    void tearDown() {
        mockedDB.close();
    }

    // ─── createRequest ────────────────────────────────────────────────────────

    @Test
    @DisplayName("createRequest – with bookingId, success returns true and sets generated id")
    void testCreateRequest_withBookingId_success_returnsTrueAndSetsId() throws Exception {
        ResultSet mockKeys = mock(ResultSet.class);
        when(mockPstmt.executeUpdate()).thenReturn(1);
        when(mockPstmt.getGeneratedKeys()).thenReturn(mockKeys);
        when(mockKeys.next()).thenReturn(true);
        when(mockKeys.getInt(1)).thenReturn(7);

        CleaningRequest req = buildRequest(0, 1, 10);
        assertTrue(dao.createRequest(req));
        assertEquals(7, req.getId());

        verify(mockPstmt).setInt(1, req.getGuestId());
        verify(mockPstmt).setInt(2, 10);
        verify(mockPstmt).setString(3, req.getRoomNumber());
        verify(mockPstmt).setString(4, req.getRequestType());
        verify(mockPstmt).setString(5, req.getPriority());
        verify(mockPstmt).setString(6, req.getSpecialInstructions());
        verify(mockPstmt).setString(7, req.getRequestStatus());
    }

    @Test
    @DisplayName("createRequest – null bookingId sets SQL NULL")
    void testCreateRequest_nullBookingId_setsNullAndReturnsTrue() throws Exception {
        ResultSet mockKeys = mock(ResultSet.class);
        when(mockPstmt.executeUpdate()).thenReturn(1);
        when(mockPstmt.getGeneratedKeys()).thenReturn(mockKeys);
        when(mockKeys.next()).thenReturn(true);
        when(mockKeys.getInt(1)).thenReturn(8);

        CleaningRequest req = buildRequest(0, 1, null);
        assertTrue(dao.createRequest(req));

        verify(mockPstmt).setNull(2, Types.INTEGER);
    }

    @Test
    @DisplayName("createRequest – zero rows affected returns false")
    void testCreateRequest_noRowsAffected_returnsFalse() throws Exception {
        when(mockPstmt.executeUpdate()).thenReturn(0);

        assertFalse(dao.createRequest(buildRequest(0, 1, 10)));
    }

    @Test
    @DisplayName("createRequest – SQL exception returns false")
    void testCreateRequest_sqlException_returnsFalse() throws Exception {
        when(mockConn.prepareStatement(anyString(), anyInt())).thenThrow(new SQLException("DB error"));

        assertFalse(dao.createRequest(buildRequest(0, 1, 10)));
    }

    // ─── getRequestsByGuestId ─────────────────────────────────────────────────

    @Test
    @DisplayName("getRequestsByGuestId – two rows returns list of size 2")
    void testGetRequestsByGuestId_multipleRows_returnsCorrectSize() throws Exception {
        when(mockRs.next()).thenReturn(true, true, false);
        stubRequestRow(1, 1, 10, false, false);

        List<CleaningRequest> result = dao.getRequestsByGuestId(1);

        assertNotNull(result);
        assertEquals(2, result.size());
        verify(mockPstmt).setInt(1, 1);
    }

    @Test
    @DisplayName("getRequestsByGuestId – no requests returns empty list")
    void testGetRequestsByGuestId_noRequests_returnsEmptyList() throws Exception {
        when(mockRs.next()).thenReturn(false);

        List<CleaningRequest> result = dao.getRequestsByGuestId(1);

        assertNotNull(result);
        assertTrue(result.isEmpty());
    }

    @Test
    @DisplayName("getRequestsByGuestId – SQL exception returns empty list")
    void testGetRequestsByGuestId_sqlException_returnsEmptyList() throws Exception {
        when(mockConn.prepareStatement(anyString())).thenThrow(new SQLException("DB error"));

        List<CleaningRequest> result = dao.getRequestsByGuestId(1);

        assertNotNull(result);
        assertTrue(result.isEmpty());
    }

    // ─── getAllRequests ────────────────────────────────────────────────────────

    @Test
    @DisplayName("getAllRequests – three rows returns list of size 3")
    void testGetAllRequests_multipleRows_returnsCorrectSize() throws Exception {
        when(mockRs.next()).thenReturn(true, true, true, false);
        stubRequestRow(1, 1, 10, false, false);

        List<CleaningRequest> result = dao.getAllRequests();

        assertNotNull(result);
        assertEquals(3, result.size());
    }

    @Test
    @DisplayName("getAllRequests – empty table returns empty list")
    void testGetAllRequests_emptyTable_returnsEmptyList() throws Exception {
        when(mockRs.next()).thenReturn(false);

        List<CleaningRequest> result = dao.getAllRequests();

        assertNotNull(result);
        assertTrue(result.isEmpty());
    }

    @Test
    @DisplayName("getAllRequests – SQL exception returns empty list")
    void testGetAllRequests_sqlException_returnsEmptyList() throws Exception {
        when(mockConn.prepareStatement(anyString())).thenThrow(new SQLException("DB error"));

        List<CleaningRequest> result = dao.getAllRequests();

        assertNotNull(result);
        assertTrue(result.isEmpty());
    }

    // ─── getRequestById ───────────────────────────────────────────────────────

    @Test
    @DisplayName("getRequestById – found returns populated CleaningRequest with bookingId and assignedTo")
    void testGetRequestById_found_returnsRequest() throws Exception {
        when(mockRs.next()).thenReturn(true);
        stubRequestRow(3, 1, 10, false, false);

        CleaningRequest result = dao.getRequestById(3);

        assertNotNull(result);
        assertEquals(3,          result.getId());
        assertEquals(1,          result.getGuestId());
        assertEquals(10,         result.getBookingId());
        assertEquals("101",      result.getRoomNumber());
        assertEquals("cleaning", result.getRequestType());
        assertEquals("high",     result.getPriority());
        assertEquals("pending",  result.getRequestStatus());
        assertEquals(5,          result.getAssignedTo());
        verify(mockPstmt).setInt(1, 3);
    }

    @Test
    @DisplayName("getRequestById – null bookingId and null assignedTo mapped correctly")
    void testGetRequestById_nullOptionalFields_mapsCorrectly() throws Exception {
        when(mockRs.next()).thenReturn(true);
        stubRequestRow(3, 1, 0, true, true); // both wasNull = true

        CleaningRequest result = dao.getRequestById(3);

        assertNotNull(result);
        assertNull(result.getBookingId());
        assertNull(result.getAssignedTo());
    }

    @Test
    @DisplayName("getRequestById – not found returns null")
    void testGetRequestById_notFound_returnsNull() throws Exception {
        when(mockRs.next()).thenReturn(false);

        assertNull(dao.getRequestById(999));
    }

    @Test
    @DisplayName("getRequestById – SQL exception returns null")
    void testGetRequestById_sqlException_returnsNull() throws Exception {
        when(mockConn.prepareStatement(anyString())).thenThrow(new SQLException("DB error"));

        assertNull(dao.getRequestById(1));
    }

    // ─── updateRequestStatus ──────────────────────────────────────────────────

    @Test
    @DisplayName("updateRequestStatus – 'completed' sets completed_at timestamp and returns true")
    void testUpdateRequestStatus_completed_setsTimestampAndReturnsTrue() throws Exception {
        when(mockPstmt.executeUpdate()).thenReturn(1);

        assertTrue(dao.updateRequestStatus(1, "completed"));
        verify(mockPstmt).setString(1, "completed");
        // completed_at should be set with a Timestamp (not null) for completed status
        verify(mockPstmt, never()).setNull(eq(2), anyInt());
        verify(mockPstmt).setInt(3, 1);
    }

    @Test
    @DisplayName("updateRequestStatus – 'cancelled' sets completed_at timestamp and returns true")
    void testUpdateRequestStatus_cancelled_setsTimestampAndReturnsTrue() throws Exception {
        when(mockPstmt.executeUpdate()).thenReturn(1);

        assertTrue(dao.updateRequestStatus(1, "cancelled"));
        verify(mockPstmt).setString(1, "cancelled");
        verify(mockPstmt, never()).setNull(eq(2), anyInt());
        verify(mockPstmt).setInt(3, 1);
    }

    @Test
    @DisplayName("updateRequestStatus – 'in_progress' sets completed_at to NULL")
    void testUpdateRequestStatus_inProgress_setsNullCompletedAt() throws Exception {
        when(mockPstmt.executeUpdate()).thenReturn(1);

        assertTrue(dao.updateRequestStatus(2, "in_progress"));
        verify(mockPstmt).setString(1, "in_progress");
        verify(mockPstmt).setNull(2, Types.TIMESTAMP);
        verify(mockPstmt).setInt(3, 2);
    }

    @Test
    @DisplayName("updateRequestStatus – id not found returns false")
    void testUpdateRequestStatus_notFound_returnsFalse() throws Exception {
        when(mockPstmt.executeUpdate()).thenReturn(0);

        assertFalse(dao.updateRequestStatus(999, "completed"));
    }

    @Test
    @DisplayName("updateRequestStatus – SQL exception returns false")
    void testUpdateRequestStatus_sqlException_returnsFalse() throws Exception {
        when(mockConn.prepareStatement(anyString())).thenThrow(new SQLException("DB error"));

        assertFalse(dao.updateRequestStatus(1, "completed"));
    }

    // ─── updateRequest ────────────────────────────────────────────────────────

    @Test
    @DisplayName("updateRequest – with assignedTo and completedAt, success returns true")
    void testUpdateRequest_withAllFields_returnsTrue() throws Exception {
        when(mockPstmt.executeUpdate()).thenReturn(1);

        CleaningRequest req = buildRequest(1, 1, 10);
        req.setAssignedTo(5);
        req.setCompletedAt(LocalDateTime.of(2026, 3, 1, 10, 0));
        req.setNotes("Done");

        assertTrue(dao.updateRequest(req));

        verify(mockPstmt).setString(1, req.getRequestStatus());
        verify(mockPstmt).setInt(2, 5);
        verify(mockPstmt).setString(3, "Done");
        verify(mockPstmt).setTimestamp(eq(4), any(Timestamp.class));
        verify(mockPstmt).setInt(5, 1);
    }

    @Test
    @DisplayName("updateRequest – null assignedTo and null completedAt sets SQL NULLs")
    void testUpdateRequest_nullOptionalFields_setsNulls() throws Exception {
        when(mockPstmt.executeUpdate()).thenReturn(1);

        CleaningRequest req = buildRequest(1, 1, null);
        req.setAssignedTo(null);
        req.setCompletedAt(null);

        assertTrue(dao.updateRequest(req));

        verify(mockPstmt).setNull(2, Types.INTEGER);
        verify(mockPstmt).setNull(4, Types.TIMESTAMP);
    }

    @Test
    @DisplayName("updateRequest – no rows affected returns false")
    void testUpdateRequest_noRowsAffected_returnsFalse() throws Exception {
        when(mockPstmt.executeUpdate()).thenReturn(0);

        assertFalse(dao.updateRequest(buildRequest(999, 1, null)));
    }

    @Test
    @DisplayName("updateRequest – SQL exception returns false")
    void testUpdateRequest_sqlException_returnsFalse() throws Exception {
        when(mockConn.prepareStatement(anyString())).thenThrow(new SQLException("DB error"));

        assertFalse(dao.updateRequest(buildRequest(1, 1, null)));
    }

    // ─── deleteRequest ────────────────────────────────────────────────────────

    @Test
    @DisplayName("deleteRequest – success returns true")
    void testDeleteRequest_success_returnsTrue() throws Exception {
        when(mockPstmt.executeUpdate()).thenReturn(1);

        assertTrue(dao.deleteRequest(1));
        verify(mockPstmt).setInt(1, 1);
    }

    @Test
    @DisplayName("deleteRequest – id not found returns false")
    void testDeleteRequest_idNotFound_returnsFalse() throws Exception {
        when(mockPstmt.executeUpdate()).thenReturn(0);

        assertFalse(dao.deleteRequest(999));
    }

    @Test
    @DisplayName("deleteRequest – SQL exception returns false")
    void testDeleteRequest_sqlException_returnsFalse() throws Exception {
        when(mockConn.prepareStatement(anyString())).thenThrow(new SQLException("DB error"));

        assertFalse(dao.deleteRequest(1));
    }

    // ─── getPendingRequests ───────────────────────────────────────────────────

    @Test
    @DisplayName("getPendingRequests – two pending rows returns list of size 2")
    void testGetPendingRequests_multipleRows_returnsCorrectSize() throws Exception {
        when(mockRs.next()).thenReturn(true, true, false);
        stubRequestRow(1, 1, 10, false, false);

        List<CleaningRequest> result = dao.getPendingRequests();

        assertNotNull(result);
        assertEquals(2, result.size());
    }

    @Test
    @DisplayName("getPendingRequests – no pending requests returns empty list")
    void testGetPendingRequests_noPendingRequests_returnsEmptyList() throws Exception {
        when(mockRs.next()).thenReturn(false);

        List<CleaningRequest> result = dao.getPendingRequests();

        assertNotNull(result);
        assertTrue(result.isEmpty());
    }

    @Test
    @DisplayName("getPendingRequests – SQL exception returns empty list")
    void testGetPendingRequests_sqlException_returnsEmptyList() throws Exception {
        when(mockConn.prepareStatement(anyString())).thenThrow(new SQLException("DB error"));

        List<CleaningRequest> result = dao.getPendingRequests();

        assertNotNull(result);
        assertTrue(result.isEmpty());
    }

    // ─── Private Helpers ─────────────────────────────────────────────────────

    /**
     * Stubs all ResultSet columns read by {@code mapResultSetToCleaningRequest()}.
     *
     * @param id              request id
     * @param guestId         guest id
     * @param bookingId       booking id value (ignored when bookingIdNull=true)
     * @param bookingIdNull   whether booking_id wasNull()
     * @param assignedToNull  whether assigned_to wasNull()
     */
    private void stubRequestRow(int id, int guestId, int bookingId,
                                boolean bookingIdNull, boolean assignedToNull) throws Exception {
        Timestamp ts = Timestamp.valueOf(LocalDateTime.of(2026, 3, 1, 9, 0));

        when(mockRs.getInt("id")).thenReturn(id);
        when(mockRs.getInt("guest_id")).thenReturn(guestId);
        when(mockRs.getInt("booking_id")).thenReturn(bookingId);
        // wasNull() is called twice: once after booking_id, once after assigned_to
        when(mockRs.wasNull()).thenReturn(bookingIdNull, assignedToNull);
        when(mockRs.getString("room_number")).thenReturn("101");
        when(mockRs.getString("request_type")).thenReturn("cleaning");
        when(mockRs.getString("priority")).thenReturn("high");
        when(mockRs.getString("special_instructions")).thenReturn("Please clean the bathroom");
        when(mockRs.getString("request_status")).thenReturn("pending");
        when(mockRs.getTimestamp("requested_at")).thenReturn(ts);
        when(mockRs.getTimestamp("completed_at")).thenReturn(null);
        when(mockRs.getInt("assigned_to")).thenReturn(5);
        when(mockRs.getString("notes")).thenReturn("No notes");
    }

    /** Builds a fully-populated {@link CleaningRequest} for create/update/delete tests. */
    private CleaningRequest buildRequest(int id, int guestId, Integer bookingId) {
        CleaningRequest r = new CleaningRequest();
        r.setId(id);
        r.setGuestId(guestId);
        r.setBookingId(bookingId);
        r.setRoomNumber("101");
        r.setRequestType("cleaning");
        r.setPriority("high");
        r.setSpecialInstructions("Please clean the bathroom");
        r.setRequestStatus("pending");
        return r;
    }
}
