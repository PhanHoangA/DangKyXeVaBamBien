package Models;

import java.io.Serializable;
import java.sql.Timestamp;

public class User implements Serializable {
    private static final long serialVersionUID = 1L;

    private int userId;
    private String userName;
    private String userpassword;
    private String fullName;
    private String identityCard;
    private String phone;
    private String email;
    private String address;
    private int districtId;
    private int roleId;
    private Timestamp createAt;

    // Navigation objects / Join fields
    private District district;
    private Role role;

    public User() {
    }

    public User(int userId, String userName, String userpassword, String fullName, String identityCard, 
                String phone, String email, String address, int districtId, int roleId, Timestamp createAt) {
        this.userId = userId;
        this.userName = userName;
        this.userpassword = userpassword;
        this.fullName = fullName;
        this.identityCard = identityCard;
        this.phone = phone;
        this.email = email;
        this.address = address;
        this.districtId = districtId;
        this.roleId = roleId;
        this.createAt = createAt;
    }

    // Constructor without userId and createAt (for registration)
    public User(String userName, String userpassword, String fullName, String identityCard, 
                String phone, String email, String address, int districtId, int roleId) {
        this.userName = userName;
        this.userpassword = userpassword;
        this.fullName = fullName;
        this.identityCard = identityCard;
        this.phone = phone;
        this.email = email;
        this.address = address;
        this.districtId = districtId;
        this.roleId = roleId;
    }

    public int getUserId() {
        return userId;
    }

    public void setUserId(int userId) {
        this.userId = userId;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getUserpassword() {
        return userpassword;
    }

    public void setUserpassword(String userpassword) {
        this.userpassword = userpassword;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getIdentityCard() {
        return identityCard;
    }

    public void setIdentityCard(String identityCard) {
        this.identityCard = identityCard;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public int getDistrictId() {
        return districtId;
    }

    public void setDistrictId(int districtId) {
        this.districtId = districtId;
    }

    public int getRoleId() {
        return roleId;
    }

    public void setRoleId(int roleId) {
        this.roleId = roleId;
    }

    public Timestamp getCreateAt() {
        return createAt;
    }

    public void setCreateAt(Timestamp createAt) {
        this.createAt = createAt;
    }

    public District getDistrict() {
        return district;
    }

    public void setDistrict(District district) {
        this.district = district;
    }

    public Role getRole() {
        return role;
    }

    public void setRole(Role role) {
        this.role = role;
    }

    // Convenience helper getters
    public String getRoleName() {
        return role != null ? role.getRoleName() : null;
    }

    public String getDistrictName() {
        return district != null ? district.getDistrictName() : null;
    }

    @Override
    public String toString() {
        return "User{" +
                "userId=" + userId +
                ", userName='" + userName + '\'' +
                ", fullName='" + fullName + '\'' +
                ", identityCard='" + identityCard + '\'' +
                ", phone='" + phone + '\'' +
                ", email='" + email + '\'' +
                ", districtId=" + districtId +
                ", roleId=" + roleId +
                '}';
    }
}
