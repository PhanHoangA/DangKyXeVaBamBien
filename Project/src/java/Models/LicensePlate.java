package Models;

import java.io.Serializable;
import java.sql.Timestamp;

public class LicensePlate implements Serializable {
    private static final long serialVersionUID = 1L;

    // Constants for status
    public static final String STATUS_AVAILABLE = "AVAILABLE";
    public static final String STATUS_ASSIGNED = "ASSIGNED";
    public static final String STATUS_BLOCKED = "BLOCKED";

    private int plateId;
    private int districtId;
    private String plateNumber;
    private String fullPlate;
    private String status; // 'AVAILABLE', 'ASSIGNED', 'BLOCKED'
    private Timestamp assignedAt;

    // Navigation objects / Join fields
    private District district;

    public LicensePlate() {
    }

    public LicensePlate(int plateId, int districtId, String plateNumber, String fullPlate, String status, Timestamp assignedAt) {
        this.plateId = plateId;
        this.districtId = districtId;
        this.plateNumber = plateNumber;
        this.fullPlate = fullPlate;
        this.status = status;
        this.assignedAt = assignedAt;
    }

    // Constructor without plateId and assignedAt (for batch generation)
    public LicensePlate(int districtId, String plateNumber, String fullPlate, String status) {
        this.districtId = districtId;
        this.plateNumber = plateNumber;
        this.fullPlate = fullPlate;
        this.status = status;
    }

    public int getPlateId() {
        return plateId;
    }

    public void setPlateId(int plateId) {
        this.plateId = plateId;
    }

    public int getDistrictId() {
        return districtId;
    }

    public void setDistrictId(int districtId) {
        this.districtId = districtId;
    }

    public String getPlateNumber() {
        return plateNumber;
    }

    public void setPlateNumber(String plateNumber) {
        this.plateNumber = plateNumber;
    }

    public String getFullPlate() {
        return fullPlate;
    }

    public void setFullPlate(String fullPlate) {
        this.fullPlate = fullPlate;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Timestamp getAssignedAt() {
        return assignedAt;
    }

    public void setAssignedAt(Timestamp assignedAt) {
        this.assignedAt = assignedAt;
    }

    public District getDistrict() {
        return district;
    }

    public void setDistrict(District district) {
        this.district = district;
    }

    public String getDistrictName() {
        return district != null ? district.getDistrictName() : null;
    }

    @Override
    public String toString() {
        return "LicensePlate{" +
                "plateId=" + plateId +
                ", districtId=" + districtId +
                ", plateNumber='" + plateNumber + '\'' +
                ", fullPlate='" + fullPlate + '\'' +
                ", status='" + status + '\'' +
                ", assignedAt=" + assignedAt +
                '}';
    }
}
