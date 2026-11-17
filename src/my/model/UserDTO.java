package my.model;

public class UserDTO {
    private String userId;
    private String password;
    private String name;
    private String school;

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }
    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public String getSchool() { return school; }
    public void setSchool(String school) { this.school = school; }
}
