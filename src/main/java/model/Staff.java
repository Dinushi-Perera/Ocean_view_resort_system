package model;

public class Staff {
    private int id;
    private String username;
    private String password;
    private String staffRole;
    private String firstName;
    private String lastName;
    private String email;
    private String contact;
    private boolean isActive;
    private String createdAt;
    private String updatedAt;

    public Staff() {}

    public Staff(String username, String password, String staffRole,
                 String firstName, String lastName, String email, String contact) {
        this.username = username;
        this.password = password;
        this.staffRole = staffRole;
        this.firstName = firstName;
        this.lastName = lastName;
        this.email = email;
        this.contact = contact;
        this.isActive = true;
    }

    // Getters & Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getUsername() { return username; }
    public void setUsername(String username) { this.username = username; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getStaffRole() { return staffRole; }
    public void setStaffRole(String staffRole) { this.staffRole = staffRole; }

    public String getFirstName() { return firstName; }
    public void setFirstName(String firstName) { this.firstName = firstName; }

    public String getLastName() { return lastName; }
    public void setLastName(String lastName) { this.lastName = lastName; }

    public String getFullName() {
        return (firstName != null ? firstName : "") + " " + (lastName != null ? lastName : "");
    }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getContact() { return contact; }
    public void setContact(String contact) { this.contact = contact; }

    public boolean isActive() { return isActive; }
    public void setActive(boolean active) { isActive = active; }

    public String getCreatedAt() { return createdAt; }
    public void setCreatedAt(String createdAt) { this.createdAt = createdAt; }

    public String getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(String updatedAt) { this.updatedAt = updatedAt; }
}
