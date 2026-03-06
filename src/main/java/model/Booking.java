package model;

import java.io.Serializable;
import java.time.LocalDate;

public class Booking implements Serializable {
    private int id;
    private int guestId;
    private Integer roomId;  // Added for room assignment
    private String roomType;
    private int numGuests;
    private LocalDate checkIn;
    private LocalDate checkOut;
    private String specialRequests;
    private String bookingStatus;
    private String createdAt;
    private String updatedAt;

    // Constructors
    public Booking() {
    }

    public Booking(int guestId, String roomType, int numGuests, LocalDate checkIn,
                   LocalDate checkOut, String specialRequests) {
        this.guestId = guestId;
        this.roomType = roomType;
        this.numGuests = numGuests;
        this.checkIn = checkIn;
        this.checkOut = checkOut;
        this.specialRequests = specialRequests;
        this.bookingStatus = "pending";
    }

    public Booking(int id, int guestId, String roomType, int numGuests, LocalDate checkIn,
                   LocalDate checkOut, String specialRequests, String bookingStatus) {
        this.id = id;
        this.guestId = guestId;
        this.roomType = roomType;
        this.numGuests = numGuests;
        this.checkIn = checkIn;
        this.checkOut = checkOut;
        this.specialRequests = specialRequests;
        this.bookingStatus = bookingStatus;
    }

    public Booking(int id, int guestId, Integer roomId, String roomType, int numGuests, LocalDate checkIn,
                   LocalDate checkOut, String specialRequests, String bookingStatus) {
        this.id = id;
        this.guestId = guestId;
        this.roomId = roomId;
        this.roomType = roomType;
        this.numGuests = numGuests;
        this.checkIn = checkIn;
        this.checkOut = checkOut;
        this.specialRequests = specialRequests;
        this.bookingStatus = bookingStatus;
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getGuestId() {
        return guestId;
    }

    public void setGuestId(int guestId) {
        this.guestId = guestId;
    }

    public Integer getRoomId() {
        return roomId;
    }

    public void setRoomId(Integer roomId) {
        this.roomId = roomId;
    }

    public String getRoomType() {
        return roomType;
    }

    public void setRoomType(String roomType) {
        this.roomType = roomType;
    }

    public int getNumGuests() {
        return numGuests;
    }

    public void setNumGuests(int numGuests) {
        this.numGuests = numGuests;
    }

    public LocalDate getCheckIn() {
        return checkIn;
    }

    public void setCheckIn(LocalDate checkIn) {
        this.checkIn = checkIn;
    }

    public LocalDate getCheckOut() {
        return checkOut;
    }

    public void setCheckOut(LocalDate checkOut) {
        this.checkOut = checkOut;
    }

    public String getSpecialRequests() {
        return specialRequests;
    }

    public void setSpecialRequests(String specialRequests) {
        this.specialRequests = specialRequests;
    }

    public String getBookingStatus() {
        return bookingStatus;
    }

    public void setBookingStatus(String bookingStatus) {
        this.bookingStatus = bookingStatus;
    }

    public String getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(String createdAt) {
        this.createdAt = createdAt;
    }

    public String getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(String updatedAt) {
        this.updatedAt = updatedAt;
    }

    // Calculate number of nights
    public long getNumberOfNights() {
        if (checkIn != null && checkOut != null) {
            return java.time.temporal.ChronoUnit.DAYS.between(checkIn, checkOut);
        }
        return 0;
    }

    @Override
    public String toString() {
        return "Booking{" +
                "id=" + id +
                ", guestId=" + guestId +
                ", roomId=" + roomId +
                ", roomType='" + roomType + '\'' +
                ", numGuests=" + numGuests +
                ", checkIn=" + checkIn +
                ", checkOut=" + checkOut +
                ", bookingStatus='" + bookingStatus + '\'' +
                '}';
    }
}

