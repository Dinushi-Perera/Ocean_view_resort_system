package model;

import java.math.BigDecimal;

public class Room {
    private int id;
    private String roomNumber;
    private String roomType;
    private int floor;
    private BigDecimal pricePerNight;
    private int maxOccupancy;
    private String status;
    private String cleaningStatus;  // Added for cleaning management
    private String description;
    private String amenities;
    private String createdAt;
    private String updatedAt;

    // Constructors
    public Room() {
    }

    public Room(String roomNumber, String roomType, int floor, BigDecimal pricePerNight, 
                int maxOccupancy, String status, String description, String amenities) {
        this.roomNumber = roomNumber;
        this.roomType = roomType;
        this.floor = floor;
        this.pricePerNight = pricePerNight;
        this.maxOccupancy = maxOccupancy;
        this.status = status;
        this.description = description;
        this.amenities = amenities;
    }

    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getRoomNumber() {
        return roomNumber;
    }

    public void setRoomNumber(String roomNumber) {
        this.roomNumber = roomNumber;
    }

    public String getRoomType() {
        return roomType;
    }

    public void setRoomType(String roomType) {
        this.roomType = roomType;
    }

    public int getFloor() {
        return floor;
    }

    public void setFloor(int floor) {
        this.floor = floor;
    }

    public BigDecimal getPricePerNight() {
        return pricePerNight;
    }

    public void setPricePerNight(BigDecimal pricePerNight) {
        this.pricePerNight = pricePerNight;
    }

    public int getMaxOccupancy() {
        return maxOccupancy;
    }

    public void setMaxOccupancy(int maxOccupancy) {
        this.maxOccupancy = maxOccupancy;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getCleaningStatus() {
        return cleaningStatus;
    }

    public void setCleaningStatus(String cleaningStatus) {
        this.cleaningStatus = cleaningStatus;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getAmenities() {
        return amenities;
    }

    public void setAmenities(String amenities) {
        this.amenities = amenities;
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

    @Override
    public String toString() {
        return "Room{" +
                "id=" + id +
                ", roomNumber='" + roomNumber + '\'' +
                ", roomType='" + roomType + '\'' +
                ", floor=" + floor +
                ", pricePerNight=" + pricePerNight +
                ", maxOccupancy=" + maxOccupancy +
                ", status='" + status + '\'' +
                ", description='" + description + '\'' +
                ", amenities='" + amenities + '\'' +
                '}';
    }
}
