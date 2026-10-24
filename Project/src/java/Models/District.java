package Models;

import java.io.Serializable;

public class District implements Serializable {
    private static final long serialVersionUID = 1L;

    private int districtId;
    private String provinceName;
    private String districtName;
    private String platePrefix;

    public District() {
    }

    public District(int districtId, String provinceName, String districtName, String platePrefix) {
        this.districtId = districtId;
        this.provinceName = provinceName;
        this.districtName = districtName;
        this.platePrefix = platePrefix;
    }

    public District(String provinceName, String districtName, String platePrefix) {
        this.provinceName = provinceName;
        this.districtName = districtName;
        this.platePrefix = platePrefix;
    }

    public int getDistrictId() {
        return districtId;
    }

    public void setDistrictId(int districtId) {
        this.districtId = districtId;
    }

    public String getProvinceName() {
        return provinceName;
    }

    public void setProvinceName(String provinceName) {
        this.provinceName = provinceName;
    }

    public String getDistrictName() {
        return districtName;
    }

    public void setDistrictName(String districtName) {
        this.districtName = districtName;
    }

    public String getPlatePrefix() {
        return platePrefix;
    }

    public void setPlatePrefix(String platePrefix) {
        this.platePrefix = platePrefix;
    }

    @Override
    public String toString() {
        return "District{" +
                "districtId=" + districtId +
                ", provinceName='" + provinceName + '\'' +
                ", districtName='" + districtName + '\'' +
                ", platePrefix='" + platePrefix + '\'' +
                '}';
    }
}
