package dao;

import DAO.GuestDAO;
import model.Guest;
import org.junit.jupiter.api.*;
import org.mockito.*;
import util.DBConnection;
import util.PasswordUtil;

import java.sql.*;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

/**
 * Unit tests for {@link GuestDAO}.
 *
 * All database interactions are mocked via Mockito static-method mocking.
 * {@link PasswordUtil#verifyPassword} is also mocked for {@code validateLogin} tests.
 */
@TestMethodOrder(MethodOrderer.DisplayName.class)
class GuestDAOTest {

    private GuestDAO guestDAO;
    private Connection        mockConn;
    private PreparedStatement mockPstmt;
    private Statement         mockStmt;   // used by getAllGuests()
    private ResultSet         mockRs;
    private MockedStatic<DBConnection>  mockedDB;
    private MockedStatic<PasswordUtil>  mockedPwUtil;

    // ─── Setup / Teardown ─────────────────────────────────────────────────────

    @BeforeEach
    void setUp() throws Exception {
        guestDAO   = new GuestDAO();
        mockConn   = mock(Connection.class);
        mockPstmt  = mock(PreparedStatement.class);
        mockStmt   = mock(Statement.class);
        mockRs     = mock(ResultSet.class);

        mockedDB = mockStatic(DBConnection.class);
        mockedDB.when(DBConnection::getConnection).thenReturn(mockConn);

        mockedPwUtil = mockStatic(PasswordUtil.class);

        when(mockConn.prepareStatement(anyString())).thenReturn(mockPstmt);
        when(mockConn.createStatement()).thenReturn(mockStmt);
        when(mockPstmt.executeQuery()).thenReturn(mockRs);
        when(mockStmt.executeQuery(anyString())).thenReturn(mockRs);
    }

    @AfterEach
    void tearDown() {
        mockedDB.close();
        mockedPwUtil.close();
    }

    // ─── registerGuest ────────────────────────────────────────────────────────

    @Test
    @DisplayName("registerGuest – success returns true")
    void testRegisterGuest_success_returnsTrue() throws Exception {
        when(mockPstmt.executeUpdate()).thenReturn(1);

        Guest guest = buildGuest(0);
        assertTrue(guestDAO.registerGuest(guest));

        verify(mockPstmt).setString(1, guest.getFirstName());
        verify(mockPstmt).setString(2, guest.getLastName());
        verify(mockPstmt).setString(3, guest.getEmail());
        verify(mockPstmt).setString(4, guest.getPassword());
        verify(mockPstmt).setString(5, guest.getContact());
        verify(mockPstmt).setString(6, guest.getNic());
    }

    @Test
    @DisplayName("registerGuest – zero rows affected returns false")
    void testRegisterGuest_noRowsAffected_returnsFalse() throws Exception {
        when(mockPstmt.executeUpdate()).thenReturn(0);

        assertFalse(guestDAO.registerGuest(buildGuest(0)));
    }

    @Test
    @DisplayName("registerGuest – SQL exception returns false")
    void testRegisterGuest_sqlException_returnsFalse() throws Exception {
        when(mockConn.prepareStatement(anyString())).thenThrow(new SQLException("DB error"));

        assertFalse(guestDAO.registerGuest(buildGuest(0)));
    }

    // ─── validateLogin ────────────────────────────────────────────────────────

    @Test
    @DisplayName("validateLogin – correct password returns populated Guest")
    void testValidateLogin_correctPassword_returnsGuest() throws Exception {
        when(mockRs.next()).thenReturn(true);
        stubGuestRow(1);

        mockedPwUtil.when(() -> PasswordUtil.verifyPassword("plain", "$2a$hashed"))
                    .thenReturn(true);

        Guest result = guestDAO.validateLogin("alice@hotel.com", "plain");

        assertNotNull(result);
        assertEquals(1,                  result.getId());
        assertEquals("alice@hotel.com",  result.getEmail());
        assertEquals("Alice",            result.getFirstName());
        verify(mockPstmt).setString(1, "alice@hotel.com");
    }

    @Test
    @DisplayName("validateLogin – wrong password returns null")
    void testValidateLogin_wrongPassword_returnsNull() throws Exception {
        when(mockRs.next()).thenReturn(true);
        stubGuestRow(1);

        mockedPwUtil.when(() -> PasswordUtil.verifyPassword("wrong", "$2a$hashed"))
                    .thenReturn(false);

        assertNull(guestDAO.validateLogin("alice@hotel.com", "wrong"));
    }

    @Test
    @DisplayName("validateLogin – email not found returns null")
    void testValidateLogin_emailNotFound_returnsNull() throws Exception {
        when(mockRs.next()).thenReturn(false);

        assertNull(guestDAO.validateLogin("nobody@hotel.com", "pass"));
    }

    @Test
    @DisplayName("validateLogin – SQL exception returns null")
    void testValidateLogin_sqlException_returnsNull() throws Exception {
        when(mockConn.prepareStatement(anyString())).thenThrow(new SQLException("DB error"));

        assertNull(guestDAO.validateLogin("alice@hotel.com", "pass"));
    }

    // ─── emailExists ──────────────────────────────────────────────────────────

    @Test
    @DisplayName("emailExists – count > 0 returns true")
    void testEmailExists_emailFound_returnsTrue() throws Exception {
        when(mockRs.next()).thenReturn(true);
        when(mockRs.getInt(1)).thenReturn(1);

        assertTrue(guestDAO.emailExists("alice@hotel.com"));
        verify(mockPstmt).setString(1, "alice@hotel.com");
    }

    @Test
    @DisplayName("emailExists – count == 0 returns false")
    void testEmailExists_emailNotFound_returnsFalse() throws Exception {
        when(mockRs.next()).thenReturn(true);
        when(mockRs.getInt(1)).thenReturn(0);

        assertFalse(guestDAO.emailExists("nobody@hotel.com"));
    }

    @Test
    @DisplayName("emailExists – SQL exception returns false")
    void testEmailExists_sqlException_returnsFalse() throws Exception {
        when(mockConn.prepareStatement(anyString())).thenThrow(new SQLException("DB error"));

        assertFalse(guestDAO.emailExists("alice@hotel.com"));
    }

    // ─── getGuestById ────────────────────────────────────────────────────────

    @Test
    @DisplayName("getGuestById – found returns populated Guest")
    void testGetGuestById_found_returnsGuest() throws Exception {
        when(mockRs.next()).thenReturn(true);
        stubGuestRow(1);

        Guest result = guestDAO.getGuestById(1);

        assertNotNull(result);
        assertEquals(1,                 result.getId());
        assertEquals("Alice",           result.getFirstName());
        assertEquals("Smith",           result.getLastName());
        assertEquals("alice@hotel.com", result.getEmail());
        assertEquals("0771234567",      result.getContact());
        assertEquals("NIC123456",       result.getNic());
        verify(mockPstmt).setInt(1, 1);
    }

    @Test
    @DisplayName("getGuestById – not found returns null")
    void testGetGuestById_notFound_returnsNull() throws Exception {
        when(mockRs.next()).thenReturn(false);

        assertNull(guestDAO.getGuestById(999));
    }

    @Test
    @DisplayName("getGuestById – SQL exception returns null")
    void testGetGuestById_sqlException_returnsNull() throws Exception {
        when(mockConn.prepareStatement(anyString())).thenThrow(new SQLException("DB error"));

        assertNull(guestDAO.getGuestById(1));
    }

    // ─── getGuestByEmail ─────────────────────────────────────────────────────

    @Test
    @DisplayName("getGuestByEmail – found returns populated Guest")
    void testGetGuestByEmail_found_returnsGuest() throws Exception {
        when(mockRs.next()).thenReturn(true);
        stubGuestRow(1);

        Guest result = guestDAO.getGuestByEmail("alice@hotel.com");

        assertNotNull(result);
        assertEquals("alice@hotel.com", result.getEmail());
        verify(mockPstmt).setString(1, "alice@hotel.com");
    }

    @Test
    @DisplayName("getGuestByEmail – not found returns null")
    void testGetGuestByEmail_notFound_returnsNull() throws Exception {
        when(mockRs.next()).thenReturn(false);

        assertNull(guestDAO.getGuestByEmail("nobody@hotel.com"));
    }

    @Test
    @DisplayName("getGuestByEmail – SQL exception returns null")
    void testGetGuestByEmail_sqlException_returnsNull() throws Exception {
        when(mockConn.prepareStatement(anyString())).thenThrow(new SQLException("DB error"));

        assertNull(guestDAO.getGuestByEmail("alice@hotel.com"));
    }

    // ─── getGuestByContact ───────────────────────────────────────────────────

    @Test
    @DisplayName("getGuestByContact – found returns populated Guest")
    void testGetGuestByContact_found_returnsGuest() throws Exception {
        when(mockRs.next()).thenReturn(true);
        stubGuestRow(1);

        Guest result = guestDAO.getGuestByContact("0771234567");

        assertNotNull(result);
        assertEquals("0771234567", result.getContact());
        verify(mockPstmt).setString(1, "0771234567");
    }

    @Test
    @DisplayName("getGuestByContact – not found returns null")
    void testGetGuestByContact_notFound_returnsNull() throws Exception {
        when(mockRs.next()).thenReturn(false);

        assertNull(guestDAO.getGuestByContact("0000000000"));
    }

    @Test
    @DisplayName("getGuestByContact – SQL exception returns null")
    void testGetGuestByContact_sqlException_returnsNull() throws Exception {
        when(mockConn.prepareStatement(anyString())).thenThrow(new SQLException("DB error"));

        assertNull(guestDAO.getGuestByContact("0771234567"));
    }

    // ─── getAllGuests ─────────────────────────────────────────────────────────

    @Test
    @DisplayName("getAllGuests – two rows returns list of size 2")
    void testGetAllGuests_multipleRows_returnsCorrectSize() throws Exception {
        when(mockRs.next()).thenReturn(true, true, false);
        stubGuestRow(1);

        List<Guest> result = guestDAO.getAllGuests();

        assertNotNull(result);
        assertEquals(2, result.size());
        // getAllGuests uses createStatement, not prepareStatement
        verify(mockConn).createStatement();
    }

    @Test
    @DisplayName("getAllGuests – empty table returns empty list")
    void testGetAllGuests_emptyTable_returnsEmptyList() throws Exception {
        when(mockRs.next()).thenReturn(false);

        List<Guest> result = guestDAO.getAllGuests();

        assertNotNull(result);
        assertTrue(result.isEmpty());
    }

    @Test
    @DisplayName("getAllGuests – SQL exception returns empty list")
    void testGetAllGuests_sqlException_returnsEmptyList() throws Exception {
        when(mockConn.createStatement()).thenThrow(new SQLException("DB error"));

        List<Guest> result = guestDAO.getAllGuests();

        assertNotNull(result);
        assertTrue(result.isEmpty());
    }

    // ─── updateGuest ─────────────────────────────────────────────────────────

    @Test
    @DisplayName("updateGuest – success returns true")
    void testUpdateGuest_success_returnsTrue() throws Exception {
        when(mockPstmt.executeUpdate()).thenReturn(1);

        Guest guest = buildGuest(1);
        assertTrue(guestDAO.updateGuest(guest));

        verify(mockPstmt).setString(1, guest.getFirstName());
        verify(mockPstmt).setString(2, guest.getLastName());
        verify(mockPstmt).setString(3, guest.getContact());
        verify(mockPstmt).setString(4, guest.getNic());
        verify(mockPstmt).setInt(5, 1);
    }

    @Test
    @DisplayName("updateGuest – no rows affected returns false")
    void testUpdateGuest_noRowsAffected_returnsFalse() throws Exception {
        when(mockPstmt.executeUpdate()).thenReturn(0);

        assertFalse(guestDAO.updateGuest(buildGuest(999)));
    }

    @Test
    @DisplayName("updateGuest – SQL exception returns false")
    void testUpdateGuest_sqlException_returnsFalse() throws Exception {
        when(mockConn.prepareStatement(anyString())).thenThrow(new SQLException("DB error"));

        assertFalse(guestDAO.updateGuest(buildGuest(1)));
    }

    // ─── deleteGuest ─────────────────────────────────────────────────────────

    @Test
    @DisplayName("deleteGuest – success returns true")
    void testDeleteGuest_success_returnsTrue() throws Exception {
        when(mockPstmt.executeUpdate()).thenReturn(1);

        assertTrue(guestDAO.deleteGuest(1));
        verify(mockPstmt).setInt(1, 1);
    }

    @Test
    @DisplayName("deleteGuest – id not found returns false")
    void testDeleteGuest_idNotFound_returnsFalse() throws Exception {
        when(mockPstmt.executeUpdate()).thenReturn(0);

        assertFalse(guestDAO.deleteGuest(999));
    }

    @Test
    @DisplayName("deleteGuest – SQL exception returns false")
    void testDeleteGuest_sqlException_returnsFalse() throws Exception {
        when(mockConn.prepareStatement(anyString())).thenThrow(new SQLException("DB error"));

        assertFalse(guestDAO.deleteGuest(1));
    }

    // ─── Private Helpers ─────────────────────────────────────────────────────

    /**
     * Stubs the ResultSet columns read by inline Guest mapping in {@link GuestDAO}.
     */
    private void stubGuestRow(int id) throws Exception {
        when(mockRs.getInt("id")).thenReturn(id);
        when(mockRs.getString("first_name")).thenReturn("Alice");
        when(mockRs.getString("last_name")).thenReturn("Smith");
        when(mockRs.getString("email")).thenReturn("alice@hotel.com");
        when(mockRs.getString("password")).thenReturn("$2a$hashed");
        when(mockRs.getString("contact")).thenReturn("0771234567");
        when(mockRs.getString("nic")).thenReturn("NIC123456");
        when(mockRs.getString("created_at")).thenReturn("2026-01-01 10:00:00");
    }

    /** Builds a fully-populated {@link Guest} for create/update/delete tests. */
    private Guest buildGuest(int id) {
        Guest g = new Guest();
        g.setId(id);
        g.setFirstName("Alice");
        g.setLastName("Smith");
        g.setEmail("alice@hotel.com");
        g.setPassword("$2a$hashed");
        g.setContact("0771234567");
        g.setNic("NIC123456");
        return g;
    }
}
