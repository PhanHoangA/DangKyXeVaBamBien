package Models;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Timestamp;

public class Registration implements Serializable {
    private static final long serialVersionUID = 1L;

    // Constants for status
    public static final String STATUS_PENDING = "PENDING";
    public static final String STATUS_APPROVED = "APPROVED";
    public static final String STATUS_DRAWN = "DRAWN";
    public static final String STATUS_REJECTED = "REJECTED";

    private int registrationId;
    private int vehicleId;
    private int ownerId;
    private int districtId;
    private Integer plateId; // Nullable
    private Integer officerId; // Nullable
    private String drawCode; // Nullable (DRAW-XXXXXX)
    private BigDecimal feeAmount; // Nullable
    private String status; // 'PENDING', 'APPROVED', 'DRAWN', 'REJECTED'
    private String rejectionReason; // Max 225 chars
    private Timestamp submittedAt;
    private Timestamp approvedAt;
    private Timestamp drawnAt;

    // Navigation objects / Join fields
    private Vehicle vehicle;
    private User owner;
    private District district;
    private LicensePlate plate;
    private User officer;

    public Registration() {
    }

    public Registration(int registrationId, int vehicleId, int ownerId, int districtId, 
                        Integer plateId, Integer officerId, String drawCode, BigDecimal feeAmount, 
                        String status, String rejectionReason, Timestamp submittedAt, 
                        Timestamp approvedAt, Timestamp drawnAt) {
        this.registrationId = registrationId;
        this.vehicleId = vehicleId;
        this.ownerId = ownerId;
        this.districtId = districtId;
        this.plateId = plateId;
        this.officerId = officerId;
        this.drawCode = drawCode;
        this.feeAmount = feeAmount;
        this.status = status;
        this.rejectionReason = rejectionReason;
        this.submittedAt = submittedAt;
        this.approvedAt = approvedAt;
        this.drawnAt = drawnAt;
    }

    // Constructor for creating new registration (FR-03)
    public Registration(int vehicleId, int ownerId, int districtId) {
        this.vehicleId = vehicleId;
        this.ownerId = ownerId;
        this.districtId = districtId;
        this.status = STATUS_PENDING;
    }

    public int getRegistrationId() {
        return registrationId;
    }

    public void setRegistrationId(int registrationId) {
        this.registrationId = registrationId;
    }

    public int getVehicleId() {
        return vehicleId;
    }

    public void setVehicleId(int vehicleId) {
        this.vehicleId = vehicleId;
    }

    public int getOwnerId() {
        return ownerId;
    }

    public void setOwnerId(int ownerId) {
        this.ownerId = ownerId;
    }

    public int getDistrictId() {
        return districtId;
    }

    public void setDistrictId(int districtId) {
        this.districtId = districtId;
    }

    public Integer getPlateId() {
        return plateId;
    }

    public void setPlateId(Integer plateId) {
        this.plateId = plateId;
    }

    public Integer getOfficerId() {
        return officerId;
    }

    public void setOfficerId(Integer officerId) {
        this.officerId = officerId;
    }

    public String getDrawCode() {
        return drawCode;
    }

    public void setDrawCode(String drawCode) {
        this.drawCode = drawCode;
    }

    public BigDecimal getFeeAmount() {
        return feeAmount;
    }

    public void setFeeAmount(BigDecimal feeAmount) {
        this.feeAmount = feeAmount;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getRejectionReason() {
        return rejectionReason;
    }

    public void setRejectionReason(String rejectionReason) {
        this.rejectionReason = rejectionReason;
    }

    public Timestamp getSubmittedAt() {
        return submittedAt;
    }

    public void setSubmittedAt(Timestamp submittedAt) {
        this.submittedAt = submittedAt;
    }

    public Timestamp getApprovedAt() {
        return approvedAt;
    }

    public void setApprovedAt(Timestamp approvedAt) {
        this.approvedAt = approvedAt;
    }

    public Timestamp getDrawnAt() {
        return drawnAt;
    }

    public void setDrawnAt(Timestamp drawnAt) {
        this.drawnAt = drawnAt;
    }

    public Vehicle getVehicle() {
        return vehicle;
    }

    public void setVehicle(Vehicle vehicle) {
        this.vehicle = vehicle;
    }

    public User getOwner() {
        return owner;
    }

    public void setOwner(User owner) {
        this.owner = owner;
    }

    public District getDistrict() {
        return district;
    }

    public void setDistrict(District district) {
        this.district = district;
    }

    public LicensePlate getPlate() {
        return plate;
    }

    public void setPlate(LicensePlate plate) {
        this.plate = plate;
    }

    public User getOfficer() {
        return officer;
    }

    public void setOfficer(User officer) {
        this.officer = officer;
    }

    // Helper status checks
    public boolean isPending() {
        return STATUS_PENDING.equalsIgnoreCase(this.status);
    }

    public boolean isApproved() {
        return STATUS_APPROVED.equalsIgnoreCase(this.status);
    }

    public boolean isDrawn() {
        return STATUS_DRAWN.equalsIgnoreCase(this.status);
    }

    public boolean isRejected() {
        return STATUS_REJECTED.equalsIgnoreCase(this.status);
    }

    // Helper badge class for JSP / Bootstrap UI
    public String getStatusBadgeClass() {
        if (isPending()) return "bg-warning text-dark";
        if (isApproved()) return "bg-info text-dark";
        if (isDrawn()) return "bg-success text-white";
        if (isRejected()) return "bg-danger text-white";
        return "bg-secondary text-white";
    }

    // Helper display title
    public String getStatusTitle() {
        if (isPending()) return "Ch\u1edd th\u1ea9m \u0111\u1ecbnh";
        if (isApproved()) return "\u0110\u00e3 duy\u1ec7t (Ch\u1edd b\u1ea5m bi\u1ec3n)";
        if (isDrawn()) return "\u0110\u00e3 c\u1ea5p bi\u1ec3n s\u1ed1";
        if (isRejected()) return "B\u1ecb t\u1eeb ch\u1ed1i";
        return status;
    }

    @Override
    public String toString() {
        return "Registration{" +
                "registrationId=" + registrationId +
                ", vehicleId=" + vehicleId +
                ", ownerId=" + ownerId +
                ", districtId=" + districtId +
                ", plateId=" + plateId +
                ", drawCode='" + drawCode + '\'' +
                ", feeAmount=" + feeAmount +
                ", status='" + status + '\'' +
                '}';
    }
}
