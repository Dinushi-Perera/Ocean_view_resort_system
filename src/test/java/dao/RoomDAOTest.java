package dao;

import DAO.RoomDAO;
import model.Room;
import org.junit.jupiter.api.*;
import org.mockito.*;
import util.DBConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDate;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

/**
 * Unit tests for {@link RoomDAO}.
 *
 * All database interactions are mocked via Mockito static-method mocking –
 * no live database connection is required.
 */
@TestMethodOrder(MethodOrderer.DisplayName.class)
class RoomDAOTest {

    private RoomDAO roomDAO;
    private Connection        mockConn;
    private PreparedStatement mockPstmt;
    private ResultSet         mockRs;
    private MockedStatic<DBConnection> mockedDB;

    private static final LocalDate CHECK_IN  = LocalDate.of(2026, 4, 1);
    private static final LocalDate CHECK_OUT = LocalDate.of(2026, 4, 5);

    // ─── Setup / Teardown ─────────────────────────────────────────────────────

    @BeforeEach
    void setUp() throws Exception {
        roomDAO   = new RoomDAO();
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

    // ─── getAllRooms ──────────────────────────────────────────────────────────

    @Test
    @DisplayName("getAllRooms – two rows returns list of size 2")
    void testGetAllRooms_multipleRows_returnsCorrectSize() throws Exception {
        when(mockRs.next()).thenReturn(true, true, false);
        stubRoomRow(1);

        List<Room> result = roomDAO.getAllRooms();

        assertNotNull(result);
        assertEquals(2, result.size());
    }

    @Test
    @DisplayName("getAllRooms – empty table returns empty list")
    void testGetAllRooms_emptyTable_returnsEmptyList() throws Exception {
        when(mockRs.next()).thenReturn(false);

        List<Room> result = roomDAO.getAllRooms();

        assertNotNull(result);
        assertTrue(result.isEmpty());
    }

    @Test
    @DisplayName("getAllRooms – SQL exception returns empty list")
    void testGetAllRooms_sqlException_returnsEmptyList() throws Exception {
        when(mockConn.prepareStatement(anyString())).thenThrow(new SQLException("DB error"));

        List<Room> result = roomDAO.getAllRooms();

        assertNotNull(result);
        assertTrue(result.isEmpty());
    }

    // ─── getRoomById ──────────────────────────────────────────────────────────

    @Test
    @DisplayName("getRoomById – found returns populated Room")
    void testGetRoomById_found_returnsRoom() throws Exception {
        when(mockRs.next()).thenReturn(true);
        stubRoomRow(1);

        Room result = roomDAO.getRoomById(1);

        assertNotNull(result);
        assertEquals(1,          result.getId());
        assertEquals("101",      result.getRoomNumber());
        assertEquals("deluxe",   result.getRoomType());
        assertEquals(1,          result.getFloor());
        assertEquals("available", result.getStatus());
        verify(mockPstmt).setInt(1, 1);
    }

    @Test
    @DisplayName("getRoomById – not found returns null")
    void testGetRoomById_notFound_returnsNull() throws Exception {
        when(mockRs.next()).thenReturn(false);

        assertNull(roomDAO.getRoomById(999));
    }

    @Test
    @DisplayName("getRoomById – SQL exception returns null")
    void testGetRoomById_sqlException_returnsNull() throws Exception {
        when(mockConn.prepareStatement(anyString())).thenThrow(new SQLException("DB error"));

        assertNull(roomDAO.getRoomById(1));
    }

    // ─── getRoomByNumber ─────────────────────────────────────────────────────

    @Test
    @DisplayName("getRoomByNumber – found returns populated Room")
    void testGetRoomByNumber_found_returnsRoom() throws Exception {
        when(mockRs.next()).thenReturn(true);
        stubRoomRow(1);

        Room result = roomDAO.getRoomByNumber("101");

        assertNotNull(result);
        assertEquals("101", result.getRoomNumber());
        verify(mockPstmt).setString(1, "101");
    }

    @Test
    @DisplayName("getRoomByNumber – not found returns null")
    void testGetRoomByNumber_notFound_returnsNull() throws Exception {
        when(mockRs.next()).thenReturn(false);

        assertNull(roomDAO.getRoomByNumber("999"));
    }

    @Test
    @DisplayName("getRoomByNumber – SQL exception returns null")
    void testGetRoomByNumber_sqlException_returnsNull() throws Exception {
        when(mockConn.prepareStatement(anyString())).thenThrow(new SQLException("DB error"));

        assertNull(roomDAO.getRoomByNumber("101"));
    }

    // ─── getRoomsByType ───────────────────────────────────────────────────────

    @Test
    @DisplayName("getRoomsByType – two matching rooms returns list of size 2")
    void testGetRoomsByType_multipleRows_returnsCorrectSize() throws Exception {
        when(mockRs.next()).thenReturn(true, true, false);
        stubRoomRow(1);

        List<Room> result = roomDAO.getRoomsByType("deluxe");

        assertNotNull(result);
        assertEquals(2, result.size());
        verify(mockPstmt).setString(1, "deluxe");
    }

    @Test
    @DisplayName("getRoomsByType – no matching rooms returns empty list")
    void testGetRoomsByType_noRows_returnsEmptyList() throws Exception {
        when(mockRs.next()).thenReturn(false);

        assertTrue(roomDAO.getRoomsByType("suite").isEmpty());
    }

    @Test
    @DisplayName("getRoomsByType – SQL exception returns empty list")
    void testGetRoomsByType_sqlException_returnsEmptyList() throws Exception {
        when(mockConn.prepareStatement(anyString())).thenThrow(new SQLException("DB error"));

        assertTrue(roomDAO.getRoomsByType("deluxe").isEmpty());
    }

    // ─── getAvailableRoomsByType ──────────────────────────────────────────────

    @Test
    @DisplayName("getAvailableRoomsByType – available rooms returns correct list")
    void testGetAvailableRoomsByType_roomsFound_returnsCorrectSize() throws Exception {
        when(mockRs.next()).thenReturn(true, true, false);
        stubRoomRow(1);

        List<Room> result = roomDAO.getAvailableRoomsByType("deluxe");

        assertNotNull(result);
        assertEquals(2, result.size());
        verify(mockPstmt).setString(1, "deluxe");
    }

    @Test
    @DisplayName("getAvailableRoomsByType – none available returns empty list")
    void testGetAvailableRoomsByType_noneAvailable_returnsEmptyList() throws Exception {
        when(mockRs.next()).thenReturn(false);

        assertTrue(roomDAO.getAvailableRoomsByType("deluxe").isEmpty());
    }

    @Test
    @DisplayName("getAvailableRoomsByType – SQL exception returns empty list")
    void testGetAvailableRoomsByType_sqlException_returnsEmptyList() throws Exception {
        when(mockConn.prepareStatement(anyString())).thenThrow(new SQLException("DB error"));

        assertTrue(roomDAO.getAvailableRoomsByType("deluxe").isEmpty());
    }

    // ─── getAvailableRoomsForDates ────────────────────────────────────────────

    @Test
    @DisplayName("getAvailableRoomsForDates – rooms available returns correct list")
    void testGetAvailableRoomsForDates_roomsFound_returnsCorrectSize() throws Exception {
        when(mockRs.next()).thenReturn(true, false);
        stubRoomRow(1);

        List<Room> result = roomDAO.getAvailableRoomsForDates("deluxe", CHECK_IN, CHECK_OUT);

        assertNotNull(result);
        assertEquals(1, result.size());
        verify(mockPstmt).setString(1, "deluxe");
        verify(mockPstmt).setDate(2, Date.valueOf(CHECK_OUT));
        verify(mockPstmt).setDate(3, Date.valueOf(CHECK_IN));
        verify(mockPstmt).setDate(4, Date.valueOf(CHECK_IN));
        verify(mockPstmt).setDate(5, Date.valueOf(CHECK_OUT));
    }

    @Test
    @DisplayName("getAvailableRoomsForDates – all booked returns empty list")
    void testGetAvailableRoomsForDates_allBooked_returnsEmptyList() throws Exception {
        when(mockRs.next()).thenReturn(false);

        assertTrue(roomDAO.getAvailableRoomsForDates("deluxe", CHECK_IN, CHECK_OUT).isEmpty());
    }

    @Test
    @DisplayName("getAvailableRoomsForDates – SQL exception returns empty list")
    void testGetAvailableRoomsForDates_sqlException_returnsEmptyList() throws Exception {
        when(mockConn.prepareStatement(anyString())).thenThrow(new SQLException("DB error"));

        assertTrue(roomDAO.getAvailableRoomsForDates("deluxe", CHECK_IN, CHECK_OUT).isEmpty());
    }

    // ─── updateRoomStatus ─────────────────────────────────────────────────────

    @Test
    @DisplayName("updateRoomStatus – success returns true")
    void testUpdateRoomStatus_success_returnsTrue() throws Exception {
        when(mockPstmt.executeUpdate()).thenReturn(1);

        assertTrue(roomDAO.updateRoomStatus(1, "occupied"));
        verify(mockPstmt).setString(1, "occupied");
        verify(mockPstmt).setInt(2, 1);
    }

    @Test
    @DisplayName("updateRoomStatus – id not found returns false")
    void testUpdateRoomStatus_notFound_returnsFalse() throws Exception {
        when(mockPstmt.executeUpdate()).thenReturn(0);

        assertFalse(roomDAO.updateRoomStatus(999, "occupied"));
    }

    @Test
    @DisplayName("updateRoomStatus – SQL exception returns false")
    void testUpdateRoomStatus_sqlException_returnsFalse() throws Exception {
        when(mockConn.prepareStatement(anyString())).thenThrow(new SQLException("DB error"));

        assertFalse(roomDAO.updateRoomStatus(1, "occupied"));
    }

    // ─── updateRoomStatusByNumber ─────────────────────────────────────────────

    @Test
    @DisplayName("updateRoomStatusByNumber – success returns true")
    void testUpdateRoomStatusByNumber_success_returnsTrue() throws Exception {
        when(mockPstmt.executeUpdate()).thenReturn(1);

        assertTrue(roomDAO.updateRoomStatusByNumber("101", "maintenance"));
        verify(mockPstmt).setString(1, "maintenance");
        verify(mockPstmt).setString(2, "101");
    }

    @Test
    @DisplayName("updateRoomStatusByNumber – room number not found returns false")
    void testUpdateRoomStatusByNumber_notFound_returnsFalse() throws Exception {
        when(mockPstmt.executeUpdate()).thenReturn(0);

        assertFalse(roomDAO.updateRoomStatusByNumber("999", "maintenance"));
    }

    @Test
    @DisplayName("updateRoomStatusByNumber – SQL exception returns false")
    void testUpdateRoomStatusByNumber_sqlException_returnsFalse() throws Exception {
        when(mockConn.prepareStatement(anyString())).thenThrow(new SQLException("DB error"));

        assertFalse(roomDAO.updateRoomStatusByNumber("101", "maintenance"));
    }

    // ─── createRoom ───────────────────────────────────────────────────────────

    @Test
    @DisplayName("createRoom – success returns true and sets generated id")
    void testCreateRoom_success_returnsTrueAndSetsId() throws Exception {
        ResultSet mockKeys = mock(ResultSet.class);
        when(mockPstmt.executeUpdate()).thenReturn(1);
        when(mockPstmt.getGeneratedKeys()).thenReturn(mockKeys);
        when(mockKeys.next()).thenReturn(true);
        when(mockKeys.getInt(1)).thenReturn(5);

        Room room = buildRoom(0);
        assertTrue(roomDAO.createRoom(room));
        assertEquals(5, room.getId());

        verify(mockPstmt).setString(1, "101");
        verify(mockPstmt).setString(2, "deluxe");
        verify(mockPstmt).setInt(3, 1);
        verify(mockPstmt).setBigDecimal(4, new BigDecimal("9000.00"));
        verify(mockPstmt).setInt(5, 2);
        verify(mockPstmt).setString(6, "available");
        verify(mockPstmt).setString(7, "clean");  // default cleaning status
    }

    @Test
    @DisplayName("createRoom – null cleaningStatus defaults to 'clean'")
    void testCreateRoom_nullCleaningStatus_defaultsToClean() throws Exception {
        ResultSet mockKeys = mock(ResultSet.class);
        when(mockPstmt.executeUpdate()).thenReturn(1);
        when(mockPstmt.getGeneratedKeys()).thenReturn(mockKeys);
        when(mockKeys.next()).thenReturn(true);
        when(mockKeys.getInt(1)).thenReturn(6);

        Room room = buildRoom(0);
        room.setCleaningStatus(null);
        assertTrue(roomDAO.createRoom(room));

        verify(mockPstmt).setString(7, "clean");
    }

    @Test
    @DisplayName("createRoom – zero rows affected returns false")
    void testCreateRoom_noRowsAffected_returnsFalse() throws Exception {
        when(mockPstmt.executeUpdate()).thenReturn(0);

        assertFalse(roomDAO.createRoom(buildRoom(0)));
    }

    @Test
    @DisplayName("createRoom – SQL exception returns false")
    void testCreateRoom_sqlException_returnsFalse() throws Exception {
        when(mockConn.prepareStatement(anyString(), anyInt())).thenThrow(new SQLException("DB error"));

        assertFalse(roomDAO.createRoom(buildRoom(0)));
    }

    // ─── updateRoom ───────────────────────────────────────────────────────────

    @Test
    @DisplayName("updateRoom – success returns true")
    void testUpdateRoom_success_returnsTrue() throws Exception {
        when(mockPstmt.executeUpdate()).thenReturn(1);

        Room room = buildRoom(1);
        assertTrue(roomDAO.updateRoom(room));

        verify(mockPstmt).setString(1, "deluxe");
        verify(mockPstmt).setInt(2, 1);
        verify(mockPstmt).setBigDecimal(3, new BigDecimal("9000.00"));
        verify(mockPstmt).setInt(4, 2);
        verify(mockPstmt).setString(5, "available");
        verify(mockPstmt).setString(6, "clean");
        verify(mockPstmt).setString(7, room.getDescription());
        verify(mockPstmt).setString(8, room.getAmenities());
        verify(mockPstmt).setInt(9, 1);
    }

    @Test
    @DisplayName("updateRoom – no rows affected returns false")
    void testUpdateRoom_noRowsAffected_returnsFalse() throws Exception {
        when(mockPstmt.executeUpdate()).thenReturn(0);

        assertFalse(roomDAO.updateRoom(buildRoom(999)));
    }

    @Test
    @DisplayName("updateRoom – SQL exception returns false")
    void testUpdateRoom_sqlException_returnsFalse() throws Exception {
        when(mockConn.prepareStatement(anyString())).thenThrow(new SQLException("DB error"));

        assertFalse(roomDAO.updateRoom(buildRoom(1)));
    }

    // ─── deleteRoom ───────────────────────────────────────────────────────────

    @Test
    @DisplayName("deleteRoom – success returns true")
    void testDeleteRoom_success_returnsTrue() throws Exception {
        when(mockPstmt.executeUpdate()).thenReturn(1);

        assertTrue(roomDAO.deleteRoom(1));
        verify(mockPstmt).setInt(1, 1);
    }

    @Test
    @DisplayName("deleteRoom – id not found returns false")
    void testDeleteRoom_idNotFound_returnsFalse() throws Exception {
        when(mockPstmt.executeUpdate()).thenReturn(0);

        assertFalse(roomDAO.deleteRoom(999));
    }

    @Test
    @DisplayName("deleteRoom – SQL exception returns false")
    void testDeleteRoom_sqlException_returnsFalse() throws Exception {
        when(mockConn.prepareStatement(anyString())).thenThrow(new SQLException("DB error"));

        assertFalse(roomDAO.deleteRoom(1));
    }

    // ─── getRoomCountByType ───────────────────────────────────────────────────

    @Test
    @DisplayName("getRoomCountByType – returns count from database")
    void testGetRoomCountByType_returnsCount() throws Exception {
        when(mockRs.next()).thenReturn(true);
        when(mockRs.getInt(1)).thenReturn(4);

        assertEquals(4, roomDAO.getRoomCountByType("deluxe"));
        verify(mockPstmt).setString(1, "deluxe");
    }

    @Test
    @DisplayName("getRoomCountByType – no ResultSet row returns 0")
    void testGetRoomCountByType_noRow_returnsZero() throws Exception {
        when(mockRs.next()).thenReturn(false);

        assertEquals(0, roomDAO.getRoomCountByType("deluxe"));
    }

    @Test
    @DisplayName("getRoomCountByType – SQL exception returns 0")
    void testGetRoomCountByType_sqlException_returnsZero() throws Exception {
        when(mockConn.prepareStatement(anyString())).thenThrow(new SQLException("DB error"));

        assertEquals(0, roomDAO.getRoomCountByType("deluxe"));
    }

    // ─── getAvailableRoomCountByType ──────────────────────────────────────────

    @Test
    @DisplayName("getAvailableRoomCountByType – returns available count")
    void testGetAvailableRoomCountByType_returnsCount() throws Exception {
        when(mockRs.next()).thenReturn(true);
        when(mockRs.getInt(1)).thenReturn(2);

        assertEquals(2, roomDAO.getAvailableRoomCountByType("deluxe"));
        verify(mockPstmt).setString(1, "deluxe");
    }

    @Test
    @DisplayName("getAvailableRoomCountByType – no ResultSet row returns 0")
    void testGetAvailableRoomCountByType_noRow_returnsZero() throws Exception {
        when(mockRs.next()).thenReturn(false);

        assertEquals(0, roomDAO.getAvailableRoomCountByType("deluxe"));
    }

    @Test
    @DisplayName("getAvailableRoomCountByType – SQL exception returns 0")
    void testGetAvailableRoomCountByType_sqlException_returnsZero() throws Exception {
        when(mockConn.prepareStatement(anyString())).thenThrow(new SQLException("DB error"));

        assertEquals(0, roomDAO.getAvailableRoomCountByType("deluxe"));
    }

    // ─── getRoomPriceByType ───────────────────────────────────────────────────

    @Test
    @DisplayName("getRoomPriceByType – found returns correct price")
    void testGetRoomPriceByType_found_returnsPrice() throws Exception {
        when(mockRs.next()).thenReturn(true);
        when(mockRs.getDouble("price_per_night")).thenReturn(9000.0);

        assertEquals(9000.0, roomDAO.getRoomPriceByType("deluxe"), 0.001);
        verify(mockPstmt).setString(1, "deluxe"); // DAO calls toLowerCase()
    }

    @Test
    @DisplayName("getRoomPriceByType – not found returns default price 5000.0")
    void testGetRoomPriceByType_notFound_returnsDefault() throws Exception {
        when(mockRs.next()).thenReturn(false);

        assertEquals(5000.0, roomDAO.getRoomPriceByType("unknown"), 0.001);
    }

    @Test
    @DisplayName("getRoomPriceByType – SQL exception returns default price 5000.0")
    void testGetRoomPriceByType_sqlException_returnsDefault() throws Exception {
        when(mockConn.prepareStatement(anyString())).thenThrow(new SQLException("DB error"));

        assertEquals(5000.0, roomDAO.getRoomPriceByType("deluxe"), 0.001);
    }

    // ─── Private Helpers ─────────────────────────────────────────────────────

    /**
     * Stubs all ResultSet columns read by {@code mapResultSetToRoom()} inside {@link RoomDAO}.
     */
    private void stubRoomRow(int id) throws Exception {
        when(mockRs.getInt("id")).thenReturn(id);
        when(mockRs.getString("room_number")).thenReturn("101");
        when(mockRs.getString("room_type")).thenReturn("deluxe");
        when(mockRs.getInt("floor")).thenReturn(1);
        when(mockRs.getBigDecimal("price_per_night")).thenReturn(new BigDecimal("9000.00"));
        when(mockRs.getInt("max_occupancy")).thenReturn(2);
        when(mockRs.getString("status")).thenReturn("available");
        when(mockRs.getString("cleaning_status")).thenReturn("clean");
        when(mockRs.getString("description")).thenReturn("Ocean view deluxe room");
        when(mockRs.getString("amenities")).thenReturn("WiFi, AC, TV");
        when(mockRs.getString("created_at")).thenReturn("2026-01-01 10:00:00");
        when(mockRs.getString("updated_at")).thenReturn("2026-01-01 10:00:00");
    }

    /** Builds a fully-populated {@link Room} for create/update/delete tests. */
    private Room buildRoom(int id) {
        Room r = new Room();
        r.setId(id);
        r.setRoomNumber("101");
        r.setRoomType("deluxe");
        r.setFloor(1);
        r.setPricePerNight(new BigDecimal("9000.00"));
        r.setMaxOccupancy(2);
        r.setStatus("available");
        r.setCleaningStatus("clean");
        r.setDescription("Ocean view deluxe room");
        r.setAmenities("WiFi, AC, TV");
        return r;
    }
}
