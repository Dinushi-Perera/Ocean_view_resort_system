package dao;

import DAO.BookingDAO;
import model.Booking;
import org.junit.jupiter.api.*;
import org.mockito.*;
import util.DBConnection;

import java.sql.*;
import java.time.LocalDate;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

/**
 * Unit tests for {@link BookingDAO}.
 *
 * All database interactions are mocked via Mockito static-method mocking –
 * no live database connection is required.
 */
@TestMethodOrder(MethodOrderer.DisplayName.class)
class BookingDAOTest {

    private BookingDAO bookingDAO;
    private Connection   mockConn;
    private PreparedStatement mockPstmt;
    private ResultSet    mockRs;
    private MockedStatic<DBConnection> mockedDB;

    // Reusable test dates
    private static final LocalDate CHECK_IN  = LocalDate.of(2026, 3, 1);
    private static final LocalDate CHECK_OUT = LocalDate.of(2026, 3, 5);

    // ─── Setup / Teardown ─────────────────────────────────────────────────────

    @BeforeEach
    void setUp() throws Exception {
        bookingDAO = new BookingDAO();
        mockConn   = mock(Connection.class);
        mockPstmt  = mock(PreparedStatement.class);
        mockRs     = mock(ResultSet.class);

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

    // ─── createBooking ────────────────────────────────────────────────────────

    @Test
    @DisplayName("createBooking – with roomId, success returns true and sets generated id")
    void testCreateBooking_withRoomId_success_returnsTrueAndSetsId() throws Exception {
        ResultSet mockKeys = mock(ResultSet.class);
        when(mockPstmt.executeUpdate()).thenReturn(1);
        when(mockPstmt.getGeneratedKeys()).thenReturn(mockKeys);
        when(mockKeys.next()).thenReturn(true);
        when(mockKeys.getInt(1)).thenReturn(10);

        Booking booking = buildBooking(0, 1, 101, "deluxe", 2, CHECK_IN, CHECK_OUT, "pending");
        boolean result = bookingDAO.createBooking(booking);

        assertTrue(result);
        assertEquals(10, booking.getId());
        verify(mockPstmt).setInt(1, booking.getGuestId());
        verify(mockPstmt).setInt(2, 101);
        verify(mockPstmt).setString(3, "deluxe");
        verify(mockPstmt).setInt(4, 2);
        verify(mockPstmt).setString(8, "pending");
    }

    @Test
    @DisplayName("createBooking – null roomId sets SQL NULL for room column")
    void testCreateBooking_nullRoomId_setsNullAndReturnsTrue() throws Exception {
        ResultSet mockKeys = mock(ResultSet.class);
        when(mockPstmt.executeUpdate()).thenReturn(1);
        when(mockPstmt.getGeneratedKeys()).thenReturn(mockKeys);
        when(mockKeys.next()).thenReturn(true);
        when(mockKeys.getInt(1)).thenReturn(11);

        Booking booking = buildBooking(0, 1, null, "standard", 1, CHECK_IN, CHECK_OUT, null);
        boolean result = bookingDAO.createBooking(booking);

        assertTrue(result);
        verify(mockPstmt).setNull(2, Types.INTEGER);
        verify(mockPstmt).setString(8, "pending"); // default status
    }

    @Test
    @DisplayName("createBooking – zero rows affected returns false")
    void testCreateBooking_noRowsAffected_returnsFalse() throws Exception {
        when(mockPstmt.executeUpdate()).thenReturn(0);

        Booking booking = buildBooking(0, 1, 101, "deluxe", 2, CHECK_IN, CHECK_OUT, "pending");
        assertFalse(bookingDAO.createBooking(booking));
    }

    @Test
    @DisplayName("createBooking – SQL exception returns false")
    void testCreateBooking_sqlException_returnsFalse() throws Exception {
        when(mockConn.prepareStatement(anyString(), anyInt())).thenThrow(new SQLException("DB error"));

        Booking booking = buildBooking(0, 1, 101, "deluxe", 2, CHECK_IN, CHECK_OUT, "pending");
        assertFalse(bookingDAO.createBooking(booking));
    }

    // ─── getBookingById ───────────────────────────────────────────────────────

    @Test
    @DisplayName("getBookingById – found returns populated Booking")
    void testGetBookingById_found_returnsBooking() throws Exception {
        when(mockRs.next()).thenReturn(true);
        stubMapRow(5, 1, 101, false);

        Booking result = bookingDAO.getBookingById(5);

        assertNotNull(result);
        assertEquals(5,        result.getId());
        assertEquals(1,        result.getGuestId());
        assertEquals(101,      result.getRoomId());
        assertEquals("deluxe", result.getRoomType());
        assertEquals(2,        result.getNumGuests());
        assertEquals(CHECK_IN, result.getCheckIn());
        verify(mockPstmt).setInt(1, 5);
    }

    @Test
    @DisplayName("getBookingById – null room_id maps to null getRoomId()")
    void testGetBookingById_nullRoomId_setsNullRoomId() throws Exception {
        when(mockRs.next()).thenReturn(true);
        stubMapRow(5, 1, 0, true); // wasNull = true

        Booking result = bookingDAO.getBookingById(5);

        assertNotNull(result);
        assertNull(result.getRoomId());
    }

    @Test
    @DisplayName("getBookingById – not found returns null")
    void testGetBookingById_notFound_returnsNull() throws Exception {
        when(mockRs.next()).thenReturn(false);

        assertNull(bookingDAO.getBookingById(999));
    }

    @Test
    @DisplayName("getBookingById – SQL exception returns null")
    void testGetBookingById_sqlException_returnsNull() throws Exception {
        when(mockConn.prepareStatement(anyString())).thenThrow(new SQLException("DB error"));

        assertNull(bookingDAO.getBookingById(1));
    }

    // ─── getBookingsByGuestId ─────────────────────────────────────────────────

    @Test
    @DisplayName("getBookingsByGuestId – two rows returns list of size 2")
    void testGetBookingsByGuestId_multipleRows_returnsCorrectList() throws Exception {
        when(mockRs.next()).thenReturn(true, true, false);
        stubMapRow(5, 1, 101, false);

        List<Booking> result = bookingDAO.getBookingsByGuestId(1);

        assertNotNull(result);
        assertEquals(2, result.size());
        verify(mockPstmt).setInt(1, 1);
    }

    @Test
    @DisplayName("getBookingsByGuestId – no bookings returns empty list")
    void testGetBookingsByGuestId_noBookings_returnsEmptyList() throws Exception {
        when(mockRs.next()).thenReturn(false);

        List<Booking> result = bookingDAO.getBookingsByGuestId(1);

        assertNotNull(result);
        assertTrue(result.isEmpty());
    }

    @Test
    @DisplayName("getBookingsByGuestId – SQL exception returns empty list")
    void testGetBookingsByGuestId_sqlException_returnsEmptyList() throws Exception {
        when(mockConn.prepareStatement(anyString())).thenThrow(new SQLException("DB error"));

        List<Booking> result = bookingDAO.getBookingsByGuestId(1);

        assertNotNull(result);
        assertTrue(result.isEmpty());
    }

    // ─── getAllBookings ────────────────────────────────────────────────────────

    @Test
    @DisplayName("getAllBookings – three rows returns list of size 3")
    void testGetAllBookings_multipleRows_returnsCorrectSize() throws Exception {
        when(mockRs.next()).thenReturn(true, true, true, false);
        stubMapRow(1, 1, 101, false);

        List<Booking> result = bookingDAO.getAllBookings();

        assertNotNull(result);
        assertEquals(3, result.size());
    }

    @Test
    @DisplayName("getAllBookings – empty table returns empty list")
    void testGetAllBookings_emptyTable_returnsEmptyList() throws Exception {
        when(mockRs.next()).thenReturn(false);

        List<Booking> result = bookingDAO.getAllBookings();

        assertNotNull(result);
        assertTrue(result.isEmpty());
    }

    @Test
    @DisplayName("getAllBookings – SQL exception returns empty list")
    void testGetAllBookings_sqlException_returnsEmptyList() throws Exception {
        when(mockConn.prepareStatement(anyString())).thenThrow(new SQLException("DB error"));

        List<Booking> result = bookingDAO.getAllBookings();

        assertNotNull(result);
        assertTrue(result.isEmpty());
    }

    // ─── deleteBooking ────────────────────────────────────────────────────────

    @Test
    @DisplayName("deleteBooking – success returns true")
    void testDeleteBooking_success_returnsTrue() throws Exception {
        when(mockPstmt.executeUpdate()).thenReturn(1);

        assertTrue(bookingDAO.deleteBooking(5));
        verify(mockPstmt).setInt(1, 5);
    }

    @Test
    @DisplayName("deleteBooking – id not found returns false")
    void testDeleteBooking_idNotFound_returnsFalse() throws Exception {
        when(mockPstmt.executeUpdate()).thenReturn(0);

        assertFalse(bookingDAO.deleteBooking(999));
    }

    @Test
    @DisplayName("deleteBooking – SQL exception returns false")
    void testDeleteBooking_sqlException_returnsFalse() throws Exception {
        when(mockConn.prepareStatement(anyString())).thenThrow(new SQLException("DB error"));

        assertFalse(bookingDAO.deleteBooking(1));
    }

    // ─── isRoomAvailable ──────────────────────────────────────────────────────

    @Test
    @DisplayName("isRoomAvailable – count 0 means available, returns true")
    void testIsRoomAvailable_noConflicts_returnsTrue() throws Exception {
        when(mockRs.next()).thenReturn(true);
        when(mockRs.getInt(1)).thenReturn(0);

        assertTrue(bookingDAO.isRoomAvailable("deluxe", CHECK_IN, CHECK_OUT));

        verify(mockPstmt).setString(1, "deluxe");
        verify(mockPstmt).setDate(2, Date.valueOf(CHECK_OUT));
        verify(mockPstmt).setDate(3, Date.valueOf(CHECK_IN));
        verify(mockPstmt).setDate(4, Date.valueOf(CHECK_IN));
        verify(mockPstmt).setDate(5, Date.valueOf(CHECK_OUT));
    }

    @Test
    @DisplayName("isRoomAvailable – count > 0 means conflicting booking, returns false")
    void testIsRoomAvailable_conflictingBooking_returnsFalse() throws Exception {
        when(mockRs.next()).thenReturn(true);
        when(mockRs.getInt(1)).thenReturn(2);

        assertFalse(bookingDAO.isRoomAvailable("deluxe", CHECK_IN, CHECK_OUT));
    }

    @Test
    @DisplayName("isRoomAvailable – ResultSet returns no rows, returns false")
    void testIsRoomAvailable_noResultSetRow_returnsFalse() throws Exception {
        when(mockRs.next()).thenReturn(false);

        assertFalse(bookingDAO.isRoomAvailable("deluxe", CHECK_IN, CHECK_OUT));
    }

    @Test
    @DisplayName("isRoomAvailable – SQL exception returns false")
    void testIsRoomAvailable_sqlException_returnsFalse() throws Exception {
        when(mockConn.prepareStatement(anyString())).thenThrow(new SQLException("DB error"));

        assertFalse(bookingDAO.isRoomAvailable("deluxe", CHECK_IN, CHECK_OUT));
    }

    // ─── updateBookingStatus ──────────────────────────────────────────────────

    @Test
    @DisplayName("updateBookingStatus – success returns true")
    void testUpdateBookingStatus_success_returnsTrue() throws Exception {
        when(mockPstmt.executeUpdate()).thenReturn(1);

        assertTrue(bookingDAO.updateBookingStatus(5, "checked_in"));
        verify(mockPstmt).setString(1, "checked_in");
        verify(mockPstmt).setInt(2, 5);
    }

    @Test
    @DisplayName("updateBookingStatus – id not found returns false")
    void testUpdateBookingStatus_notFound_returnsFalse() throws Exception {
        when(mockPstmt.executeUpdate()).thenReturn(0);

        assertFalse(bookingDAO.updateBookingStatus(999, "checked_in"));
    }

    @Test
    @DisplayName("updateBookingStatus – SQL exception returns false")
    void testUpdateBookingStatus_sqlException_returnsFalse() throws Exception {
        when(mockConn.prepareStatement(anyString())).thenThrow(new SQLException("DB error"));

        assertFalse(bookingDAO.updateBookingStatus(5, "checked_in"));
    }

    // ─── updateBooking ────────────────────────────────────────────────────────

    @Test
    @DisplayName("updateBooking – with roomId, success returns true")
    void testUpdateBooking_withRoomId_success_returnsTrue() throws Exception {
        when(mockPstmt.executeUpdate()).thenReturn(1);

        Booking booking = buildBooking(5, 1, 101, "deluxe", 2, CHECK_IN, CHECK_OUT, "confirmed");
        assertTrue(bookingDAO.updateBooking(booking));

        verify(mockPstmt).setInt(1, 101);
        verify(mockPstmt).setString(2, "deluxe");
        verify(mockPstmt).setInt(3, 2);
        verify(mockPstmt).setDate(4, Date.valueOf(CHECK_IN));
        verify(mockPstmt).setDate(5, Date.valueOf(CHECK_OUT));
        verify(mockPstmt).setString(6, booking.getSpecialRequests());
        verify(mockPstmt).setString(7, "confirmed");
        verify(mockPstmt).setInt(8, 5);
    }

    @Test
    @DisplayName("updateBooking – null roomId sets SQL NULL")
    void testUpdateBooking_nullRoomId_setsNullAndReturnsTrue() throws Exception {
        when(mockPstmt.executeUpdate()).thenReturn(1);

        Booking booking = buildBooking(5, 1, null, "standard", 1, CHECK_IN, CHECK_OUT, "pending");
        assertTrue(bookingDAO.updateBooking(booking));

        verify(mockPstmt).setNull(1, Types.INTEGER);
    }

    @Test
    @DisplayName("updateBooking – no rows affected returns false")
    void testUpdateBooking_noRowsAffected_returnsFalse() throws Exception {
        when(mockPstmt.executeUpdate()).thenReturn(0);

        Booking booking = buildBooking(999, 1, 101, "deluxe", 2, CHECK_IN, CHECK_OUT, "pending");
        assertFalse(bookingDAO.updateBooking(booking));
    }

    @Test
    @DisplayName("updateBooking – SQL exception returns false")
    void testUpdateBooking_sqlException_returnsFalse() throws Exception {
        when(mockConn.prepareStatement(anyString())).thenThrow(new SQLException("DB error"));

        Booking booking = buildBooking(5, 1, 101, "deluxe", 2, CHECK_IN, CHECK_OUT, "pending");
        assertFalse(bookingDAO.updateBooking(booking));
    }

    // ─── Private Helpers ─────────────────────────────────────────────────────

    /**
     * Stubs all ResultSet columns read by {@code mapResultSetToBooking()}.
     *
     * @param id        booking id
     * @param guestId   guest id
     * @param roomId    numeric room id (ignored when {@code wasNull=true})
     * @param wasNull   whether {@code rs.wasNull()} reports NULL for room_id
     */
    private void stubMapRow(int id, int guestId, int roomId, boolean wasNull) throws Exception {
        java.sql.Date sqlCheckIn  = Date.valueOf(CHECK_IN);
        java.sql.Date sqlCheckOut = Date.valueOf(CHECK_OUT);

        when(mockRs.getInt("id")).thenReturn(id);
        when(mockRs.getInt("guest_id")).thenReturn(guestId);
        when(mockRs.getInt("room_id")).thenReturn(roomId);
        when(mockRs.wasNull()).thenReturn(wasNull);
        when(mockRs.getString("room_type")).thenReturn("deluxe");
        when(mockRs.getInt("num_guests")).thenReturn(2);
        when(mockRs.getDate("check_in")).thenReturn(sqlCheckIn);
        when(mockRs.getDate("check_out")).thenReturn(sqlCheckOut);
        when(mockRs.getString("special_requests")).thenReturn("Sea view please");
        when(mockRs.getString("booking_status")).thenReturn("pending");
        when(mockRs.getString("created_at")).thenReturn("2026-03-01 10:00:00");
        when(mockRs.getString("updated_at")).thenReturn("2026-03-01 10:00:00");
    }

    /** Builds a {@link Booking} with all fields set for testing. */
    private Booking buildBooking(int id, int guestId, Integer roomId,
                                 String roomType, int numGuests,
                                 LocalDate checkIn, LocalDate checkOut,
                                 String status) {
        Booking b = new Booking();
        b.setId(id);
        b.setGuestId(guestId);
        b.setRoomId(roomId);
        b.setRoomType(roomType);
        b.setNumGuests(numGuests);
        b.setCheckIn(checkIn);
        b.setCheckOut(checkOut);
        b.setSpecialRequests("Sea view please");
        b.setBookingStatus(status);
        return b;
    }
}
