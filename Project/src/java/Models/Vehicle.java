package Models;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Timestamp;

public class Vehicle implements Serializable {
    private static final long serialVersionUID = 1L;

    private int vehicleId;
    private int ownerId;
    private int brandId;
    private int typeId;
    private String modelName;
    private String engineNumber;
    private String chassisNumber;
    private String color;
    private int engineCapacity;
    private BigDecimal vehicleValue;
    private String taxReceiptNumber;
    private String invoiceNumber;
    private Timestamp createAt;

    // Navigation objects / Join fields
    private User owner;
    private VehicleBrand brand;
    private VehicleType type;

    public Vehicle() {
    }

    public Vehicle(int vehicleId, int ownerId, int brandId, int typeId, String modelName, 
                   String engineNumber, String chassisNumber, String color, int engineCapacity, 
                   BigDecimal vehicleValue, String taxReceiptNumber, String invoiceNumber, Timestamp createAt) {
        this.vehicleId = vehicleId;
        this.ownerId = ownerId;
        this.brandId = brandId;
        this.typeId = typeId;
        this.modelName = modelName;
        this.engineNumber = engineNumber;
        this.chassisNumber = chassisNumber;
        this.color = color;
        this.engineCapacity = engineCapacity;
        this.vehicleValue = vehicleValue;
        this.taxReceiptNumber = taxReceiptNumber;
        this.invoiceNumber = invoiceNumber;
        this.createAt = createAt;
    }

    // Constructor without vehicleId and createAt (for insert)
    public Vehicle(int ownerId, int brandId, int typeId, String modelName, 
                   String engineNumber, String chassisNumber, String color, int engineCapacity, 
                   BigDecimal vehicleValue, String taxReceiptNumber, String invoiceNumber) {
        this.ownerId = ownerId;
        this.brandId = brandId;
        this.typeId = typeId;
        this.modelName = modelName;
        this.engineNumber = engineNumber;
        this.chassisNumber = chassisNumber;
        this.color = color;
        this.engineCapacity = engineCapacity;
        this.vehicleValue = vehicleValue;
        this.taxReceiptNumber = taxReceiptNumber;
        this.invoiceNumber = invoiceNumber;
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

    public int getBrandId() {
        return brandId;
    }

    public void setBrandId(int brandId) {
        this.brandId = brandId;
    }

    public int getTypeId() {
        return typeId;
    }

    public void setTypeId(int typeId) {
        this.typeId = typeId;
    }

    public String getModelName() {
        return modelName;
    }

    public void setModelName(String modelName) {
        this.modelName = modelName;
    }

    public String getEngineNumber() {
        return engineNumber;
    }

    public void setEngineNumber(String engineNumber) {
        this.engineNumber = engineNumber;
    }

    public String getChassisNumber() {
        return chassisNumber;
    }

    public void setChassisNumber(String chassisNumber) {
        this.chassisNumber = chassisNumber;
    }

    public String getColor() {
        return color;
    }

    public void setColor(String color) {
        this.color = color;
    }

    public int getEngineCapacity() {
        return engineCapacity;
    }

    public void setEngineCapacity(int engineCapacity) {
        this.engineCapacity = engineCapacity;
    }

    public BigDecimal getVehicleValue() {
        return vehicleValue;
    }

    public void setVehicleValue(BigDecimal vehicleValue) {
        this.vehicleValue = vehicleValue;
    }

    public String getTaxReceiptNumber() {
        return taxReceiptNumber;
    }

    public void setTaxReceiptNumber(String taxReceiptNumber) {
        this.taxReceiptNumber = taxReceiptNumber;
    }

    public String getInvoiceNumber() {
        return invoiceNumber;
    }

    public void setInvoiceNumber(String invoiceNumber) {
        this.invoiceNumber = invoiceNumber;
    }

    public Timestamp getCreateAt() {
        return createAt;
    }

    public void setCreateAt(Timestamp createAt) {
        this.createAt = createAt;
    }

    public User getOwner() {
        return owner;
    }

    public void setOwner(User owner) {
        this.owner = owner;
    }

    public VehicleBrand getBrand() {
        return brand;
    }

    public void setBrand(VehicleBrand brand) {
        this.brand = brand;
    }

    public VehicleType getType() {
        return type;
    }

    public void setType(VehicleType type) {
        this.type = type;
    }

    public String getBrandName() {
        return brand != null ? brand.getBrandName() : null;
    }

    public String getTypeName() {
        return type != null ? type.getTypeName() : null;
    }

    public String getOwnerFullName() {
        return owner != null ? owner.getFullName() : null;
    }

    @Override
    public String toString() {
        return "Vehicle{" +
                "vehicleId=" + vehicleId +
                ", modelName='" + modelName + '\'' +
                ", engineNumber='" + engineNumber + '\'' +
                ", chassisNumber='" + chassisNumber + '\'' +
                ", color='" + color + '\'' +
                ", engineCapacity=" + engineCapacity +
                ", vehicleValue=" + vehicleValue +
                '}';
    }
}
