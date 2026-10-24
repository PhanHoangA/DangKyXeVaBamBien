package Models;

import java.io.Serializable;

public class VehicleType implements Serializable {
    private static final long serialVersionUID = 1L;

    private int typeId;
    private String typeName;
    private String capacityRange;

    public VehicleType() {
    }

    public VehicleType(int typeId, String typeName, String capacityRange) {
        this.typeId = typeId;
        this.typeName = typeName;
        this.capacityRange = capacityRange;
    }

    public VehicleType(String typeName, String capacityRange) {
        this.typeName = typeName;
        this.capacityRange = capacityRange;
    }

    public int getTypeId() {
        return typeId;
    }

    public void setTypeId(int typeId) {
        this.typeId = typeId;
    }

    public String getTypeName() {
        return typeName;
    }

    public void setTypeName(String typeName) {
        this.typeName = typeName;
    }

    public String getCapacityRange() {
        return capacityRange;
    }

    public void setCapacityRange(String capacityRange) {
        this.capacityRange = capacityRange;
    }

    @Override
    public String toString() {
        return "VehicleType{" +
                "typeId=" + typeId +
                ", typeName='" + typeName + '\'' +
                ", capacityRange='" + capacityRange + '\'' +
                '}';
    }
}
