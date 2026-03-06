package model;

import java.time.LocalDateTime;

public class CleaningRequest {
    private int id;
    private int guestId;
    private Integer bookingId;
    private String roomNumber;
    private String requestType;
    private String priority;
    private String specialInstructions;
    private String requestStatus;
    private LocalDateTime requestedAt;
    private LocalDateTime completedAt;
    private Integer assignedTo;
    private String notes;

    // Constructors
    public CleaningRequest() {
    }

    public CleaningRequest(int guestId, String roomNumber, String requestType, 
                          String priority, String specialInstructions) {
        this.guestId = guestId;
        this.roomNumber = roomNumber;
        this.requestType = requestType;
        this.priority = priority;
        this.specialInstructions = specialInstructions;
        this.requestStatus = "pending";
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

    public Integer getBookingId() {
        return bookingId;
    }

    public void setBookingId(Integer bookingId) {
        this.bookingId = bookingId;
    }

    public String getRoomNumber() {
        return roomNumber;
    }

    public void setRoomNumber(String roomNumber) {
        this.roomNumber = roomNumber;
    }

    public String getRequestType() {
        return requestType;
    }

    public void setRequestType(String requestType) {
        this.requestType = requestType;
    }

    public String getPriority() {
        return priority;
    }

    public void setPriority(String priority) {
        this.priority = priority;
    }

    public String getSpecialInstructions() {
        return specialInstructions;
    }

    public void setSpecialInstructions(String specialInstructions) {
        this.specialInstructions = specialInstructions;
    }

    public String getRequestStatus() {
        return requestStatus;
    }

    public void setRequestStatus(String requestStatus) {
        this.requestStatus = requestStatus;
    }

    public LocalDateTime getRequestedAt() {
        return requestedAt;
    }

    public void setRequestedAt(LocalDateTime requestedAt) {
        this.requestedAt = requestedAt;
    }

    public LocalDateTime getCompletedAt() {
        return completedAt;
    }

    public void setCompletedAt(LocalDateTime completedAt) {
        this.completedAt = completedAt;
    }

    public Integer getAssignedTo() {
        return assignedTo;
    }

    public void setAssignedTo(Integer assignedTo) {
        this.assignedTo = assignedTo;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    @Override
    public String toString() {
        return "CleaningRequest{" +
                "id=" + id +
                ", guestId=" + guestId +
                ", roomNumber='" + roomNumber + '\'' +
                ", requestType='" + requestType + '\'' +
                ", priority='" + priority + '\'' +
                ", requestStatus='" + requestStatus + '\'' +
                ", requestedAt=" + requestedAt +
                '}';
    }
}
