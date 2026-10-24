package Models;

import java.io.Serializable;

public class VehicleBrand implements Serializable {
    private static final long serialVersionUID = 1L;

    private int brandId;
    private String brandName;

    public VehicleBrand() {
    }

    public VehicleBrand(int brandId, String brandName) {
        this.brandId = brandId;
        this.brandName = brandName;
    }

    public VehicleBrand(String brandName) {
        this.brandName = brandName;
    }

    public int getBrandId() {
        return brandId;
    }

    public void setBrandId(int brandId) {
        this.brandId = brandId;
    }

    public String getBrandName() {
        return brandName;
    }

    public void setBrandName(String brandName) {
        this.brandName = brandName;
    }

    @Override
    public String toString() {
        return "VehicleBrand{" +
                "brandId=" + brandId +
                ", brandName='" + brandName + '\'' +
                '}';
    }
}
