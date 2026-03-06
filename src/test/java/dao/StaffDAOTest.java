package dao;

import DAO.StaffDAO;
import model.Staff;
import org.junit.jupiter.api.*;
import org.mockito.*;
import util.DBConnection;

import java.sql.*;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

/**
 * Unit tests for {@link StaffDAO}.
 *
 * All database interactions are mocked via Mockito's static-method mocking
 * so no live database connection is required.
 */
@TestMethodOrder(MethodOrderer.DisplayName.class)
class StaffDAOTest {

    private StaffDAO staffDAO;
    private Connection mockConn;
    private PreparedStatement mockPstmt;
    private ResultSet mockRs;
    private MockedStatic<DBConnection> mockedDB;

    // ─── Setup / Teardown ────────────────────────────────────────────────────

    @BeforeEach
    void setUp() throws Exception {
        staffDAO  = new StaffDAO();
        mockConn  = mock(Connection.class);
        mockPstmt = mock(PreparedStatement.class);
        mockRs    = mock(ResultSet.class);

        // Intercept every call to DBConnection.getConnection()
        mockedDB = mockStatic(DBConnection.class);
        mockedDB.when(DBConnection::getConnection).thenReturn(mockConn);

        // Default connection behaviour
        when(mockConn.prepareStatement(anyString())).thenReturn(mockPstmt);
        when(mockConn.prepareStatement(anyString(), anyInt())).thenReturn(mockPstmt);
        when(mockPstmt.executeQuery()).thenReturn(mockRs);
    }

    @AfterEach
    void tearDown() {
        mockedDB.close();
    }

    // ─── authenticateStaff ───────────────────────────────────────────────────

    @Test
    @DisplayName("authenticateStaff – valid credentials returns true")
    void testAuthenticateStaff_validCredentials_returnsTrue() throws Exception {
        when(mockRs.next()).thenReturn(true);

        assertTrue(staffDAO.authenticateStaff("john", "pass123", "receptionist"));

        verify(mockPstmt).setString(1, "john");
        verify(mockPstmt).setString(2, "pass123");
        verify(mockPstmt).setString(3, "receptionist");
    }

    @Test
    @DisplayName("authenticateStaff – wrong password returns false")
    void testAuthenticateStaff_invalidCredentials_returnsFalse() throws Exception {
        when(mockRs.next()).thenReturn(false);

        assertFalse(staffDAO.authenticateStaff("john", "wrongpass", "receptionist"));
    }

    @Test
    @DisplayName("authenticateStaff – SQL exception returns false")
    void testAuthenticateStaff_sqlException_returnsFalse() throws Exception {
        when(mockConn.prepareStatement(anyString())).thenThrow(new SQLException("DB error"));

        assertFalse(staffDAO.authenticateStaff("john", "pass", "receptionist"));
    }

    // ─── authenticateAdmin ───────────────────────────────────────────────────

    @Test
    @DisplayName("authenticateAdmin – valid admin credentials returns true")
    void testAuthenticateAdmin_validCredentials_returnsTrue() throws Exception {
        when(mockRs.next()).thenReturn(true);

        assertTrue(staffDAO.authenticateAdmin("admin", "adminpass"));

        verify(mockPstmt).setString(1, "admin");
        verify(mockPstmt).setString(2, "adminpass");
    }

    @Test
    @DisplayName("authenticateAdmin – wrong password returns false")
    void testAuthenticateAdmin_invalidCredentials_returnsFalse() throws Exception {
        when(mockRs.next()).thenReturn(false);

        assertFalse(staffDAO.authenticateAdmin("admin", "wrongpass"));
    }

    @Test
    @DisplayName("authenticateAdmin – SQL exception returns false")
    void testAuthenticateAdmin_sqlException_returnsFalse() throws Exception {
        when(mockConn.prepareStatement(anyString())).thenThrow(new SQLException("DB error"));

        assertFalse(staffDAO.authenticateAdmin("admin", "pass"));
    }

    // ─── getStaffByUsername ──────────────────────────────────────────────────

    @Test
    @DisplayName("getStaffByUsername – found returns 6-element array")
    void testGetStaffByUsername_found_returnsArray() throws Exception {
        when(mockRs.next()).thenReturn(true);
        when(mockRs.getInt("id")).thenReturn(1);
        when(mockRs.getString("username")).thenReturn("john");
        when(mockRs.getString("staff_role")).thenReturn("receptionist");
        when(mockRs.getString("first_name")).thenReturn("John");
        when(mockRs.getString("last_name")).thenReturn("Doe");
        when(mockRs.getString("email")).thenReturn("john@hotel.com");

        String[] result = staffDAO.getStaffByUsername("john");

        assertNotNull(result);
        assertEquals(6, result.length);
        assertEquals("1",              result[0]);
        assertEquals("john",           result[1]);
        assertEquals("receptionist",   result[2]);
        assertEquals("John",           result[3]);
        assertEquals("Doe",            result[4]);
        assertEquals("john@hotel.com", result[5]);
    }

    @Test
    @DisplayName("getStaffByUsername – not found returns null")
    void testGetStaffByUsername_notFound_returnsNull() throws Exception {
        when(mockRs.next()).thenReturn(false);

        assertNull(staffDAO.getStaffByUsername("nobody"));
    }

    @Test
    @DisplayName("getStaffByUsername – SQL exception returns null")
    void testGetStaffByUsername_sqlException_returnsNull() throws Exception {
        when(mockConn.prepareStatement(anyString())).thenThrow(new SQLException("DB error"));

        assertNull(staffDAO.getStaffByUsername("john"));
    }

    // ─── getAllStaff ─────────────────────────────────────────────────────────

    @Test
    @DisplayName("getAllStaff – two rows returns list of size 2")
    void testGetAllStaff_multipleRows_returnsCorrectSize() throws Exception {
        when(mockRs.next()).thenReturn(true, true, false);
        stubMapRow();

        List<Staff> result = staffDAO.getAllStaff();

        assertNotNull(result);
        assertEquals(2, result.size());
    }

    @Test
    @DisplayName("getAllStaff – empty table returns empty list")
    void testGetAllStaff_emptyTable_returnsEmptyList() throws Exception {
        when(mockRs.next()).thenReturn(false);

        List<Staff> result = staffDAO.getAllStaff();

        assertNotNull(result);
        assertTrue(result.isEmpty());
    }

    @Test
    @DisplayName("getAllStaff – SQL exception returns empty list")
    void testGetAllStaff_sqlException_returnsEmptyList() throws Exception {
        when(mockConn.prepareStatement(anyString())).thenThrow(new SQLException("DB error"));

        List<Staff> result = staffDAO.getAllStaff();

        assertNotNull(result);
        assertTrue(result.isEmpty());
    }

    // ─── getStaffById ────────────────────────────────────────────────────────

    @Test
    @DisplayName("getStaffById – found returns populated Staff object")
    void testGetStaffById_found_returnsStaff() throws Exception {
        when(mockRs.next()).thenReturn(true);
        stubMapRow();

        Staff result = staffDAO.getStaffById(1);

        assertNotNull(result);
        assertEquals(1,              result.getId());
        assertEquals("john",         result.getUsername());
        assertEquals("receptionist", result.getStaffRole());
        assertEquals("John",         result.getFirstName());
        assertEquals("Doe",          result.getLastName());
        assertTrue(result.isActive());
    }

    @Test
    @DisplayName("getStaffById – not found returns null")
    void testGetStaffById_notFound_returnsNull() throws Exception {
        when(mockRs.next()).thenReturn(false);

        assertNull(staffDAO.getStaffById(999));
    }

    @Test
    @DisplayName("getStaffById – SQL exception returns null")
    void testGetStaffById_sqlException_returnsNull() throws Exception {
        when(mockConn.prepareStatement(anyString())).thenThrow(new SQLException("DB error"));

        assertNull(staffDAO.getStaffById(1));
    }

    // ─── createStaff ─────────────────────────────────────────────────────────

    @Test
    @DisplayName("createStaff – success inserts row and assigns generated id")
    void testCreateStaff_success_returnsTrueAndSetsId() throws Exception {
        ResultSet mockKeys = mock(ResultSet.class);
        when(mockPstmt.executeUpdate()).thenReturn(1);
        when(mockPstmt.getGeneratedKeys()).thenReturn(mockKeys);
        when(mockKeys.next()).thenReturn(true);
        when(mockKeys.getInt(1)).thenReturn(42);

        Staff staff = new Staff("newuser", "pass", "receptionist", "New", "User", "new@hotel.com", "0771234567");
        boolean result = staffDAO.createStaff(staff);

        assertTrue(result);
        assertEquals(42, staff.getId());
        verify(mockPstmt).setString(1, "newuser");
        verify(mockPstmt).setString(3, "receptionist");
    }

    @Test
    @DisplayName("createStaff – zero rows affected returns false")
    void testCreateStaff_noRowsAffected_returnsFalse() throws Exception {
        when(mockPstmt.executeUpdate()).thenReturn(0);

        Staff staff = new Staff("newuser", "pass", "receptionist", "New", "User", "new@hotel.com", "077");
        assertFalse(staffDAO.createStaff(staff));
    }

    @Test
    @DisplayName("createStaff – SQL exception returns false")
    void testCreateStaff_sqlException_returnsFalse() throws Exception {
        when(mockConn.prepareStatement(anyString(), anyInt())).thenThrow(new SQLException("DB error"));

        Staff staff = new Staff("newuser", "pass", "receptionist", "New", "User", "new@hotel.com", "077");
        assertFalse(staffDAO.createStaff(staff));
    }

    // ─── updateStaff ─────────────────────────────────────────────────────────

    @Test
    @DisplayName("updateStaff – success returns true")
    void testUpdateStaff_success_returnsTrue() throws Exception {
        when(mockPstmt.executeUpdate()).thenReturn(1);

        Staff staff = buildStaff(1);
        assertTrue(staffDAO.updateStaff(staff));

        verify(mockPstmt).setString(1, staff.getFirstName());
        verify(mockPstmt).setString(2, staff.getLastName());
        verify(mockPstmt).setString(3, staff.getEmail());
        verify(mockPstmt).setString(4, staff.getContact());
        verify(mockPstmt).setString(5, staff.getStaffRole());
        verify(mockPstmt).setBoolean(6, staff.isActive());
        verify(mockPstmt).setInt(7, 1);
    }

    @Test
    @DisplayName("updateStaff – no rows affected returns false")
    void testUpdateStaff_noRowsAffected_returnsFalse() throws Exception {
        when(mockPstmt.executeUpdate()).thenReturn(0);

        assertFalse(staffDAO.updateStaff(buildStaff(1)));
    }

    @Test
    @DisplayName("updateStaff – SQL exception returns false")
    void testUpdateStaff_sqlException_returnsFalse() throws Exception {
        when(mockConn.prepareStatement(anyString())).thenThrow(new SQLException("DB error"));

        assertFalse(staffDAO.updateStaff(buildStaff(1)));
    }

    // ─── toggleStaffStatus ───────────────────────────────────────────────────

    @Test
    @DisplayName("toggleStaffStatus – success returns true")
    void testToggleStaffStatus_success_returnsTrue() throws Exception {
        when(mockPstmt.executeUpdate()).thenReturn(1);

        assertTrue(staffDAO.toggleStaffStatus(1));
        verify(mockPstmt).setInt(1, 1);
    }

    @Test
    @DisplayName("toggleStaffStatus – id not found returns false")
    void testToggleStaffStatus_noRowsAffected_returnsFalse() throws Exception {
        when(mockPstmt.executeUpdate()).thenReturn(0);

        assertFalse(staffDAO.toggleStaffStatus(999));
    }

    @Test
    @DisplayName("toggleStaffStatus – SQL exception returns false")
    void testToggleStaffStatus_sqlException_returnsFalse() throws Exception {
        when(mockConn.prepareStatement(anyString())).thenThrow(new SQLException("DB error"));

        assertFalse(staffDAO.toggleStaffStatus(1));
    }

    // ─── deleteStaff ─────────────────────────────────────────────────────────

    @Test
    @DisplayName("deleteStaff – success returns true")
    void testDeleteStaff_success_returnsTrue() throws Exception {
        when(mockPstmt.executeUpdate()).thenReturn(1);

        assertTrue(staffDAO.deleteStaff(1));
        verify(mockPstmt).setInt(1, 1);
    }

    @Test
    @DisplayName("deleteStaff – id not found returns false")
    void testDeleteStaff_idNotFound_returnsFalse() throws Exception {
        when(mockPstmt.executeUpdate()).thenReturn(0);

        assertFalse(staffDAO.deleteStaff(999));
    }

    @Test
    @DisplayName("deleteStaff – SQL exception returns false")
    void testDeleteStaff_sqlException_returnsFalse() throws Exception {
        when(mockConn.prepareStatement(anyString())).thenThrow(new SQLException("DB error"));

        assertFalse(staffDAO.deleteStaff(1));
    }

    // ─── usernameExists ──────────────────────────────────────────────────────

    @Test
    @DisplayName("usernameExists – count > 0 returns true")
    void testUsernameExists_userExists_returnsTrue() throws Exception {
        when(mockRs.next()).thenReturn(true);
        when(mockRs.getInt(1)).thenReturn(1);

        assertTrue(staffDAO.usernameExists("john"));
        verify(mockPstmt).setString(1, "john");
    }

    @Test
    @DisplayName("usernameExists – count == 0 returns false")
    void testUsernameExists_userNotFound_returnsFalse() throws Exception {
        when(mockRs.next()).thenReturn(true);
        when(mockRs.getInt(1)).thenReturn(0);

        assertFalse(staffDAO.usernameExists("nobody"));
    }

    @Test
    @DisplayName("usernameExists – SQL exception returns false")
    void testUsernameExists_sqlException_returnsFalse() throws Exception {
        when(mockConn.prepareStatement(anyString())).thenThrow(new SQLException("DB error"));

        assertFalse(staffDAO.usernameExists("john"));
    }

    // ─── Private Helpers ─────────────────────────────────────────────────────

    /** Stubs the ResultSet columns read by {@code mapRow()} inside StaffDAO. */
    private void stubMapRow() throws Exception {
        when(mockRs.getInt("id")).thenReturn(1);
        when(mockRs.getString("username")).thenReturn("john");
        when(mockRs.getString("password")).thenReturn("hashed_password");
        when(mockRs.getString("staff_role")).thenReturn("receptionist");
        when(mockRs.getString("first_name")).thenReturn("John");
        when(mockRs.getString("last_name")).thenReturn("Doe");
        when(mockRs.getString("email")).thenReturn("john@hotel.com");
        when(mockRs.getString("contact")).thenReturn("0771234567");
        when(mockRs.getBoolean("is_active")).thenReturn(true);
        when(mockRs.getString("created_at")).thenReturn("2026-01-01 10:00:00");
    }

    /** Builds a fully-populated {@link Staff} for update/toggle tests. */
    private Staff buildStaff(int id) {
        Staff s = new Staff("john", "pass", "receptionist", "John", "Doe", "john@hotel.com", "0771234567");
        s.setId(id);
        s.setActive(true);
        return s;
    }
}
